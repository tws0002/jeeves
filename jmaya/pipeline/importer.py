'''
this is the importer module for maya, it handles the importing of maya file and alembic files only

it is launched from the main jeeves_ui module and is passed the filepath to import as an arguement

the import options are copied directly from the standard import dialogs found within maya. the only reason
why i've re-written it is becuase now i can pass it a speific file, the once selected from within the
jeeves ui. i've tried to keep the layout and wording exactly the same so the ops are familiar with it

the alembic importer method only works within the gui, really needs to be shoved off to another class for
external use
'''
print '> importing jmaya.pipeline.importer_ui'

import os, sys, pickle
import xml.etree.ElementTree as xml
from cStringIO import StringIO

import core

sys.dont_write_bytecode = True

#path to import.ui file and import window titles
uiFile = os.path.join(core.jeeves_ui, 'templates', 'import.ui')

windowTitle = "Importer %s" % core.jeeves_version
windowObject = 'importer'

# maya settings
launchAsDockedWindow = False

# site-packages location, required for pysideuic
site_packages_OSX = '/Applications/Autodesk/maya2015/Maya.app/Contents/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages'
site_packages_Win = r'C:\Program Files\Autodesk\Maya2015\Python\Lib\site-packages'
site_packages_Linux = '/usr/autodesk/maya2015-x64/lib/python2.7/site-packages'


#lets determine the package that is trying to run up jeeves, ive choosen to determine this by the modules that i can import
#there are probably more elegant ways, but since i need those modules imported anyway, it works, we also set the runMode, but
#this is mostly depreciated

global runMode

try:
    import maya.cmds as cmds
    import maya.OpenMayaUI as omui
    import pymel.core as pmc
    import shiboken
    runMode = 'maya'
except:
    pass

if (site_packages_Win != '') and ('win' in sys.platform):
    sys.path.append( site_packages_Win )
if (site_packages_Linux != '') and ('linux' in sys.platform):
    sys.path.append( site_packages_Linux )
if (site_packages_OSX != '') and ('darwin' in sys.platform):
    sys.path.append( site_packages_OSX )

from PySide import QtCore, QtGui, QtUiTools
import pysideuic

############################################################################################################################

#Auto-setup classes and functions

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

        pysideuic.compileUi(f, o, indent=0)
        pyc = compile(o.getvalue(), '<string>', 'exec')
        exec pyc in frame

        #Fetch the base_class and form class based on their type in the xml from designer
        form_class = frame['Ui_%s'%form_class]
        base_class = eval('QtGui.%s'%widget_class)
    
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
    return wrapinstance( long( main_window_ptr ), QtGui.QWidget )

#########################################################################################################

class Importer(form, base):
    '''
    after the inital setup of the gui, the main Imported class is instance and is passed the file to import
    as an argurment. we create self.found_file and self.ext from the passed arg.
    
    we import jmaya.pipeline, though it should already be imported
    '''
    def __init__(self, found_file, parent=None):
        '''
        unlike the main jeeves_ui module, we set up the signals and slots here, rather than hard code it into the
        importer.ui file. there arent that many so it's quite easy to manage
        
        once the setup is done, we create those connections and then enable the relevant tabs
        '''
        #"""Super, loadUi, signal connections"""
        super(Importer, self).__init__(parent)
        
        self.found_file = found_file
        self.ext = self.found_file.split('.')[-1]

        try:
            import jmaya.pipeline
        except:
            pass
        
        self.setupUi(self)

        self.setObjectName(windowObject)
        self.setWindowTitle(windowTitle)
        self.create_connections()
        self.tab_enable()
    
    def create_connections(self):
        '''
        simple method to connect the buttons to other methods. the names of the widgets in the ui file
        are hard coded into the ui file. you'll need open the ui file in qt designer to find the name
        '''
        #alembic
        self.alembic_importroot_radio.clicked.connect(self.alembic_importroot)
        self.alembic_importcurrent_radio.clicked.connect(self.alembic_importcurrent)
        self.alembic_add_radio.clicked.connect(self.alembic_add)
        self.alembic_merge_radio.clicked.connect(self.alembic_merge)
        
        #maya
        self.maya_parentnm_radio.clicked.connect(self.parent_radio)
        self.maya_merge_radio.clicked.connect(self.merge_radio)
        self.maya_filename_radio.clicked.connect(self.filename_radio)
        
        self.btn_import.clicked.connect(self.importbtn)
    
    def tab_enable(self):
        '''
        in the __init__ method, we determine the file extension, from that we can enable / disbale either the
        maya or the alembic tabs and then set the current index of the tab widget to the relevant type
        
        index 0 = maya
        index 1 = alembic
        
        once this is done, the setup is done and we are now waiting for the user to start clicking buttons
        '''
        if self.ext == 'abc':
            self.alembic.setEnabled(True)
            self.maya.setEnabled(False)
            self.index = 1
            self.import_label.setText('Alembic file : %s' % self.found_file)
            
        elif self.ext == 'mb':
            '''
            this scenario isnt supported yet - there are just too many options and i havent had time to test it yet
            '''
            print 'No support for the importing of maya files yet, this is limited to alembic files currently'
            self.alembic.setEnabled(False)
            self.maya.setEnabled(False)
            self.index = 0
            self.import_label.setText("Maya file : %s\nApologies, this isn't written yet. You can only import alembic files here" % self.found_file)
            # self.import_label.setText('Maya file : %s' % self.found_file)
            #because we need to give namespace options to import under, we call the self.scene_namespaces to
            #get a list of namespaces in the current scene
            self.maya_namespaces_list.addItems(self.scene_namespaces())
        
        try:
            self.tabWidget.setCurrentIndex(self.index)
        except:
            pass

    def importbtn(self):
        '''
        when the import button is clicked this method runs and then in turn runs another method based on the
        extension of the importing file
        '''
        if self.ext == 'mb':
            self.import_mb()
        elif self.ext == 'abc':
            self.import_alembic()
        

#########################################################################################################
#MAYA
#########################################################################################################
    def parent_radio(self):
        '''
        this is triggered when the parent radio button is selected, all it does is enable the text entry box
        so that the user can enter a string
        '''
        self.maya_parentnm_entry.setEnabled(True)
    
    def merge_radio(self):
        '''
        triggered when the merge radio button is selected. it disbales the text entry box for parent namespaces radio
        '''
        self.maya_parentnm_entry.setEnabled(False)
    
    def filename_radio(self):
        '''
        triggered when the merge radio button is selected. it disbales the text entry box for parent namespaces radio
        '''
        self.maya_parentnm_entry.setEnabled(False)

    def scene_namespaces(self):
        nm = pmc.namespaceInfo(lon=True, r=True)
        namespaces = []
        exclude = ['UI', 'shared']
        
        for i in nm:
            if i not in exclude:
                namespaces.append(i)
        
        return namespaces
        
    def import_mb(self):
        '''
        this is called, indirectly from the user clicking on the import button from the importer ui
        '''
        print '\t> jmaya.pipeline.importer.import_mb'
        
        self.group = self. maya_group_check.isChecked()
        self.remove = self.maya_remove_check.isChecked()
        self.preserve = self.maya_preserver_check.isChecked()
        self.preservetext = self.maya_preserve_combo.currentText()
        self.sel_nm = self.maya_namespaces_list.currentItem().text()
        self.merge = self.maya_merge_radio.isChecked()
        self.parentnm = self.maya_parentnm_radio.isChecked()
        self.paretnnmtext = self.maya_parentnm_entry.text()
        self.filename = self.maya_filename_radio.isChecked()
        
        self.maya_import_cmd()

    def maya_import_cmd(self):
        '''
        using user selceted option, create the maya import command and execute
        '''
        print '\t> jmaya.pipeline.importer.maya_import_cmd'
        
        self.found_file = self.found_file.replace('\\', '/')
        
        #the first arg is the filename
        self.cmd = '"%s"' % self.found_file
        
        self.cmd = '%s, %s' % (self.cmd, 'preserveReferences=True')
        
        if self.group:
            self.cmd = '%s, %s' % (self.cmd, 'groupReference=True')
        
        self.cmd = '%s, %s' % (self.cmd, 'ignoreVersion=True')
        self.cmd = '%s, %s' % (self.cmd, 'i=True')
        
        if self.merge:
            self.cmd = '%s, %s' % (self.cmd, 'mergeNamespacesOnClash=True')
        else:
            self.cmd = '%s, %s' % (self.cmd, 'mergeNamespacesOnClash=False')

        
        self.cmd = '%s, %s' % (self.cmd, 'options="v=0;p=17;f=0"')
        
        cmd = 'cmds.file(%s)' % self.cmd
        print '\t> jmaya.pipeline.importer.maya_import_cmd > %s' % cmd
        
#########################################################################################################
#ALEMBIC
#########################################################################################################
    def alembic_importroot(self):
        '''
        triggers
        '''
        self.alembic_add_radio.setEnabled(False)
        self.alembic_merge_radio.setEnabled(False)
        self.alembic_addnon_check.setEnabled(False)
        self.alembic_removenon_check.setEnabled(False)
    
    def alembic_importcurrent(self):
        '''
        triggers
        '''
        self.alembic_add_radio.setEnabled(True)
        self.alembic_merge_radio.setEnabled(True)
        self.alembic_add_radio.setChecked(True)
    
    def alembic_add(self):
        '''
        triggers
        '''
        self.alembic_addnon_check.setEnabled(False)
        self.alembic_removenon_check.setEnabled(False)
    
    def alembic_merge(self):
        '''
        triggers
        '''
        self.alembic_addnon_check.setEnabled(True)
        self.alembic_removenon_check.setEnabled(True)
    
    def import_alembic(self):
        '''
        this is called, indirectly from the user clicking on the import button from the importer ui
        
        first off, we create loads of boolean variables based on whether or the the button / radio is checked
        or not
        
        once the vars are created, we run up self.alembic_cmd

        '''
        self.importroot = self.alembic_importroot_radio.isChecked()
        self.importcurrent = self.alembic_importcurrent_radio.isChecked()
        self.add = self.alembic_add_radio.isChecked()
        self.merge = self.alembic_merge_radio.isChecked()
        self.addnon = self.alembic_addnon_check.isChecked()
        self.removenon = self.alembic_removenon_check.isChecked()
        self.fit = self.alembic_fit_check.isChecked()
        self.settime = self.alembic_set_check.isChecked()
        self.debug = self.alembic_debug_check.isChecked()
        self.importnm = self.alembic_importnm_check.isChecked()
    
        self.alembic_cmd()
    
    def alembic_cmd(self):
        '''
        this is the method that actually builds the command to import the alembic file
        
        we use pymel here so that the buildn cmd is easier. maya.cmds is basically a wrapper for mel, as such we cant
        use syntax such as 'debug=True', instead we would have to use the string '-debug'. so for that reason we use
        pymel
        
        if the self.importnm is true, we attempt to read in a pickle file that contains the namespaces that were present
        when the alembic was created.
        
        when the full command is built, we have to then evaluate it, we then close the ui
        '''
        print '\t> jmaya.pipeline.importer.alembic_cmd'
        if self.importnm:
            self.import_namespaces()
        
        #standard stuffs
        self.found_file = self.found_file.replace('\\', '/')
        self.cmd = '"%s"' % self.found_file
        
        if self.importcurrent:
            if self.add:
                selected = cmds.ls(sl=True)
                if len(selected) == 1:
                    parent = '|' + selected[0]
                    self.cmd = '%s, %s' % (self.cmd, 'rpr=parent')
                else:
                    print 'too many objects selected'
                    return
            elif self.merge:
                self.cmd = '%s, %s' % (self.cmd, 'connect="/"')
                if self.addnon:
                    self.cmd = '%s, %s' % (self.cmd, 'createIfNotFound=True')
                if self.removenon:
                    self.cmd = '%s, %s' % (self.cmd, 'removeIfNoUpdate=True')

        if self.fit:
            self.cmd = '%s, %s' % (self.cmd, 'ftr=True')

        if self.settime:
            self.cmd = '%s, %s' % (self.cmd, 'sts=True')

        if self.debug:
            self.cmd = '%s, %s' % (self.cmd, 'debug=True')
        
        abc = ("pmc.AbcImport(%s)" % self.cmd)
        print '\t> jmaya.pipeline.importer.alembic_cmd > %s' % abc
        eval(abc)
        self.reject()
                            
        
    def import_namespaces(self):
        '''
        if we dont import these namespaes prior to importing the alembic geometry, the geometry doesnt parent itself
        to any namespaces, instead it just goes under root. why? becuase the nm that were present when the export was arent
        in the scene. if they are, they get assigned to the correct nm. it should, in my opinion automatically create
        the nm if they dont exist, but it doesnt.
        
        for each alembic file (sh_001_animation.abc) there is a coresponding file (sh_001_animation_namespaces.txt)
        '''
        print '\t> jmaya.pipeline.importer.import_namespaces'        
        x = self.found_file.split('.')
        nmpkl = x[0] + '_namespaces.txt'
        
        f = open(nmpkl, 'r')
        nm = pickle.load(f)
        f.close()
        
        for each in nm:
            if not cmds.namespace(ex = each):
                cmds.namespace( add=each )

#########################################################################################################

def run(found_file):
    if cmds.window(windowObject, q=True, exists=True):
        cmds.deleteUI(windowObject)
    if cmds.dockControl( 'MayaWindow|'+windowTitle, q=True, ex=True):
        cmds.deleteUI( 'MayaWindow|'+windowTitle )
    global gui
    gui = Importer( found_file, maya_main_window())
    gui.show()
