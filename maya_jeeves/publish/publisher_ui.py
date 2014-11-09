print '> importing maya_jeeves.publish.publisher_ui'

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
import maya_jeeves.workspace
import maya_jeeves.publish.pub_class;reload(maya_jeeves.publish.pub_class)


sys.dont_write_bytecode = True

''' CONFIGURATION '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

# General
QtType = 'PySide'										# Edit this to switch between PySide and PyQt
sys.dont_write_bytecode = True									# Do not generate .pyc files

uiFile = os.path.join(core.resourcesRoot, 'vfx', 'pipeline', 'jeeves', 'maya_jeeves', 'ui', 'templates', 'publish.ui')
uiFile = os.path.join(core.resourcesRoot, 'vfx', 'pipeline', 'jeeves_dev', 'maya_jeeves', 'ui', 'templates', 'publish.ui')
#uiFile = '/Users/elliott/Google Drive/jeeves/maya_jeeves/ui/templates/publish.ui'

windowTitle = 'Publisher'									# The visible title of the window
windowObject = 'Publisher'									# The name of the window object

# Standalone settings
darkorange = True										# Use the 'darkorange' stylesheet

# Maya settings
launchAsDockedWindow = False									# False = opens as free floating window, True = docks window to Maya UI

# Nuke settings
launchAsPanel = False										# False = opens as regular window, True = opens as panel

# Site-packages location:
site_packages_Win = ''										# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
site_packages_Linux = ''									# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
#site_packages_OSX = '/Applications/Autodesk/maya2014/Maya.app/Contents/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages'										# Location of site-packages containing PySide and pysideuic and/or PyQt and SIP
#site_packages_Win = 'C:/Python26/Lib/site-packages'						# Example: Windows 7
site_packages_Linux = '/usr/lib/python2.6/site-packages'					# Example: Linux CentOS 6.4
site_packages_OSX = '/Library/Python/2.7/site-packages'					# Example: Mac OS X 10.8 Mountain Lion



''' Run mode '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''
runMode = 'standalone'
try:
    import maya.cmds as cmds
    import maya.OpenMayaUI as omui
    import shiboken
    runMode = 'maya'
except:
    pass
try:
    import nuke
    from nukescripts import panels
    runMode = 'nuke'
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

#print 'This app is now using ' + QtType

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
            #print 'Loading UI using PySide'
            self.setupUi(self)

        elif QtType == 'PyQt':
            #print 'Loading UI using PyQt'
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
        print self.obj.publishpath
        self.publish_path.setText('Publish Path : ' + self.obj.publishpath)
        
        self.publish_frames_start_entry.setText(self.frame_start)
        self.publish_frames_end_entry.setText(self.frame_end)
        self.publish_sets_frames_start_entry.setText(self.frame_start)
        self.publish_sets_frames_end_entry.setText(self.frame_end)

        self.publish_sets_combo.addItems(self.sets)
    
    def add_to_queue(self):
        start = self.publish_sets_frames_start_entry.text()
        end = self.publish_sets_frames_end_entry.text()
        
        file_name = os.path.join(self.obj.publishpath, self.publish_sets_name_entry.text())
        mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        mayafile = os.path.normpath(mayafile)
        
        strip_namespaces = self.publish_sets_chk_strip.isChecked()
        world_space = self.publish_sets_chk_world.isChecked()
        whole_frame_geo = self.publish_sets_chk_whole.isChecked()
        uv_write = self.publish_sets_chk_uv.isChecked()
        subprocess = self.publish_sets_chk_subprocess.isChecked()
        sets = self.publish_sets_combo.currentText()
        export_selected = False
        queue = True

        pub_class = maya_jeeves.publish.pub_class.publish(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, subprocess, mayafile, sets, queue)
        
        self.queue_list[file_name] = pub_class.cmd
        self.publish_sets_queue_list.addItem('> %s > %s' % (sets, pub_class.cmd))
    
    def clear_queue(self):      
        self.publish_sets_queue_list.clear()
        self.queue_list = {}
    
    def get_sets(self):
        self.publish_sets_combo.clear()
        self.sets = cmds.ls(selection=True)
        self.publish_sets_combo.addItems(self.sets)
    
    def publish_queue(self):
        for i in self.queue_list:
            print self.queue_list[i]

        self.clear_queue()

    def publish_button(self):
        
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
        subprocess = self.publish_chk_subprocess.isChecked()
        sets = None
        queue = False

        maya_jeeves.publish.pub_class.publish(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, subprocess, mayafile, sets, queue)


''' Run functions '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

def runStandalone():
    app = QtGui.QApplication(sys.argv)
    global gui
    gui = publisher()
    gui.show()

    if darkorange:
        themePath = os.path.join( os.path.dirname(__file__), 'theme' )
        sys.path.append( themePath )
        import darkorangeResource
        stylesheetFilepath = os.path.join( themePath, 'darkorange.stylesheet' )
        with open( stylesheetFilepath , 'r' ) as shfp:
            gui.setStyleSheet( shfp.read() )
        app.setStyle("plastique")

    sys.exit(app.exec_())

def runMaya(obj):
    #print obj

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

def runNuke():
    moduleName = __name__
    if moduleName == '__main__':
        moduleName = ''
    else:
        moduleName = moduleName + '.'
    global gui
    if launchAsPanel:
        pane = nuke.getPaneFor('Properties.1')
        panel = panels.registerWidgetAsPanel( moduleName + 'Jeeves' , windowTitle, ('uk.co.thefoundry.'+windowObject+'Window'), True).addToPane(pane) # View pane and add it to panes menu
        gui = panel.customKnob.getObject().widget
    else:
        gui = Publisher()
        gui.show()

if runMode == 'standalone':
    runStandalone()
#elif runMode == 'maya':
    #runMaya()
#elif runMode == 'nuke':
    #runNuke()