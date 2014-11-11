print '> importing jmaya.pipeline.publisher_ui'

''' Imports regardless of Qt type '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''
import os, sys, pprint, subprocess, pickle
import xml.etree.ElementTree as xml
from cStringIO import StringIO

import core
import core.job as job
import core.shots as shot
import core.assets as assets
import core.wrappers as wrappers

sys.dont_write_bytecode = True

''' CONFIGURATION '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

# General
QtType = 'PySide'										# Edit this to switch between PySide and PyQt
sys.dont_write_bytecode = True									# Do not generate .pyc files

uiFile = os.path.join(core.jeeves_ui, 'templates', 'publish.ui')

windowTitle = 'Publisher'									# The visible title of the window
windowObject = 'Publisher'									# The name of the window object
									# Use the 'darkorange' stylesheet
# Maya settings
launchAsDockedWindow = False									# False = opens as free floating window, True = docks window to Maya UI
									# False = opens as regular window, True = opens as panel
# Site-packages location:
site_packages_Win = ''										# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
site_packages_Linux = ''									# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
#site_packages_OSX = '/Applications/Autodesk/maya2014/Maya.app/Contents/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages'										# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
#site_packages_Win = 'C:/Python26/Lib/site-packages'						# Example: Windows 7
site_packages_Linux = '/usr/lib/python2.6/site-packages'					# Example: Linux CentOS 6.4
site_packages_OSX = '/Library/Python/2.7/site-packages'					# Example: Mac OS X 10.8 Mountain Lion



''' Run mode '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

try:
    import maya.cmds as cmds
    import maya.OpenMayaUI as omui
    import shiboken
    runMode = 'maya'
    import jmaya.pipeline.workspace
    import jmaya.pipeline.pub_class
except:
    pass


''' PySide or PyQt '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''
if (site_packages_Win != '') and ('win' in sys.platform):
    sys.path.append( site_packages_Win )
if (site_packages_Linux != '') and ('linux' in sys.platform):
    sys.path.append( site_packages_Linux )
if (site_packages_OSX != '') and ('darwin' in sys.platform):
    sys.path.append( site_packages_OSX )

if QtType == 'PySide':
    from PySide import QtCore, QtGui, QtUiTools
    import pysideuic
elif QtType == 'PyQt':
    from PyQt4 import QtCore, QtGui, uic
    import sip

''' Auto-setup classes and functions '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''


class PyQtFixer(QtGui.QMainWindow):
    def __init__(self, parent=None):
            """Super, loadUi, signal connections"""
            super(PyQtFixer, self).__init__(parent)
            print 'Making a detour (hack), necessary for when using PyQt'

def loadUiType(uiFile):
    """
    Pyside lacks the "loadUiType" command, so we have to convert the ui file to py code in-memory first
    and then execute it in a special frame to retrieve the form_class.
    """
    parsed = xml.parse(uiFile)
    widget_class = parsed.find('widget').get('class')
    form_class = parsed.find('class').text

    with open(uiFile, 'r') as f:
        o = StringIO()
        frame = {}

        if QtType == 'PySide':
            pysideuic.compileUi(f, o, indent=0)
            pyc = compile(o.getvalue(), '<string>', 'exec')
            exec pyc in frame

            #Fetch the base_class and form class based on their type in the xml from designer
            form_class = frame['Ui_%s'%form_class]
            base_class = eval('QtGui.%s'%widget_class)
        elif QtType == 'PyQt':
            form_class = PyQtFixer
            base_class = QtGui.QMainWindow
    
    return form_class, base_class

form, base = loadUiType(uiFile)

def wrapinstance(ptr, base=None):
    """
    Utility to convert a pointer to a Qt class instance (PySide/PyQt compatible)

    :param ptr: Pointer to QObject in memory
    :type ptr: long or Swig instance
    :param base: (Optional) Base class to wrap with (Defaults to QObject, which should handle anything)
    :type base: QtGui.QWidget
    :return: QWidget or subclass instance
    :rtype: QtGui.QWidget
    """
    if ptr is None:
        return None
    ptr = long(ptr) #Ensure type
    if globals().has_key('shiboken'):
        if base is None:
            qObj = shiboken.wrapInstance(long(ptr), QtCore.QObject)
            metaObj = qObj.metaObject()
            cls = metaObj.className()
            superCls = metaObj.superClass().className()
            if hasattr(QtGui, cls):
                base = getattr(QtGui, cls)
            elif hasattr(QtGui, superCls):
                base = getattr(QtGui, superCls)
            else:
                base = QtGui.QWidget
        return shiboken.wrapInstance(long(ptr), base)
    elif globals().has_key('sip'):
        base = QtCore.QObject
        return sip.wrapinstance(long(ptr), base)
    else:
        return None

def maya_main_window():
    main_window_ptr = omui.MQtUtil.mainWindow()
    return wrapinstance( long( main_window_ptr ), QtGui.QWidget )	# Works with both PyQt and PySide

''' Main class '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

class Publisher(form, base):
    def __init__(self, obj, parent=maya_main_window()):
        #"""Super, loadUi, signal connections"""
        super(Publisher, self).__init__(parent)

        if QtType == 'PySide':
            self.setupUi(self)

        elif QtType == 'PyQt':
            uic.loadUi(uiFile, self)

        self.setObjectName(windowObject)
        self.setWindowTitle(windowTitle)
        
        self.obj = obj
        self.frame_start = str(int(obj.frame_start))
        self.frame_end = str(int(obj.frame_end))
        
        self.queue_list = {}
        self.sets = []
        
        self.start()
    
    def start(self):
        #print self.obj.publishpath
        self.publish_path.setText('Publish Path : ' + self.obj.publishpath)
        
        self.publish_frames_start_entry.setText(self.frame_start)
        self.publish_frames_end_entry.setText(self.frame_end)

    def publish_button(self):
        #print 'publish button'
        start = self.publish_frames_start_entry.text()
        end = self.publish_frames_end_entry.text()
        
        file_name = os.path.join(self.obj.publishpath, self.publish_name_entry.text())
        mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        mayafile = os.path.normpath(mayafile)
        
        export_selected = self.publish_chk_exportselected.isChecked()
        strip_namespaces = self.publish_chk_strip.isChecked()
        world_space = self.publish_chk_world.isChecked()
        whole_frame_geo = self.publish_chk_whole.isChecked()
        uv_write = self.publish_chk_uv.isChecked()
        
        jmaya.pipeline.publish.publish(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, mayafile)
        self.reject()

''' Run functions '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

def runMaya(obj):
    
    if cmds.window(windowObject, q=True, exists=True):
        cmds.deleteUI(windowObject)
    if cmds.dockControl( 'MayaWindow|'+windowTitle, q=True, ex=True):
        cmds.deleteUI( 'MayaWindow|'+windowTitle )
    global gui
    gui = Publisher(obj )

    if launchAsDockedWindow:
        allowedAreas = ['right', 'left']
        cmds.dockControl( windowTitle, label=windowTitle, area='left', content=windowObject, allowedArea=allowedAreas )
    else:
        gui.show()