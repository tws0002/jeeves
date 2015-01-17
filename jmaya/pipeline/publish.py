'''
called from jeeves_ui

the module contains 3 classes:

publish_cmds - build the alembic export command and executes it. is called from the ui
publish_ui - loads the ui file. main purpose is to gather user options and send them as args to publish_cmds class
publish_save - this is called from jeeves_ui module publish button

'''
print '> importing jmaya.pipeline.publish'

import os, pickle, sys
import core
import core.job as job
import core.shots as shots
import core.locate as locate
import maya.cmds as cmds
import pymel.core as pmc
import jmaya.pipeline.workspace
import xml.etree.ElementTree as xml
from cStringIO import StringIO

sys.dont_write_bytecode = True

#path to publish.ui file and jeeves window titles
uiFile = os.path.join(core.jeeves_ui, 'templates', 'publish.ui')
windowTitle = 'Publisher %s' % core.jeeves_version
windowObject = 'Publisher'

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

############################################################################################################################

#the main publish classes

class publish_save(object):
    '''
    this class is called when the publish button in jeeves_ui is clicked, it takes no arguements
    
    think of this as a pre flight check, before we run up the ui, to make sure we know where we are in the filesystem
    and can rebuild the filepath with the sum of it's parts, self.job, self.shot etc etc
    
    self.publish_vars does this check
    
    then we build the filepaths and filenames and check the dirs exist, with self.publish_paths and self.publish_dirs, respectively
    
    lastly, we run up the self.pubish_ui, which concludes the pre flight check
    '''
    def __init__(self):
        '''
        initiates some variables, then calls subsequent methods to find the dirs and make them if necessary
        
        then runs up the ui
        '''
        print '\t> jmaya.pipeline.publish.publish_save'
        
        self.publishtype = 'abc'
        
        # first things first lets check the workspace        
        if not jmaya.pipeline.workspace.check_workspace():
            return
        
        # these are the vars were after
        self.job = None
        self.dept = None
        self.shot = None
        self.task = None
        self.version = None

        #lets save the current scene and get the full filepath
        cmds.file(s=True)
        self.mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        self.mayafile = os.path.normpath(self.mayafile)
        
        if self.publish_vars():
            self.publish_paths()
            self.publish_dirs()
            if self.publish_ui():
                print '\t> PUBLISH SAVED'
        else:
            print '\t> PUBLISH NOT SAVED'

    def publish_ui(self):
        '''
        run up the ui and pass self as an arguement to ui class
        '''
        print '\t> jmaya.pipeline.publish.publish_save.publish_ui'
        
        self.frame_start = cmds.playbackOptions(query=True, minTime=True)
        self.frame_end = cmds.playbackOptions(query=True, maxTime=True)
        self.sets = []

        if cmds.window(windowObject, q=True, exists=True):
            cmds.deleteUI(windowObject)
        if cmds.dockControl( 'MayaWindow|'+windowTitle, q=True, ex=True):
            cmds.deleteUI( 'MayaWindow|'+windowTitle )
        
        global gui
        gui = publish_ui(self )

        gui.show()

    def publish_paths(self):
        '''
        generates the self.publishpath and self.publishname vars
        '''
        print '\t> jmaya.pipeline.publish.publish_save.publish_paths'
        if self.publishtype == 'abc':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'alembic')
        
        elif self.publishtype == 'fbx':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'fbx')

        elif self.publishtype == 'geo':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'geo')

        self.validtasks = {'ani' : 'animation',
                           'sim' : 'simulation',
                           'rig' : 'rigging',
                           'mod' : 'modelling',
                           'lay' : 'layout',
                           }

        if self.task == 'loose':
            self.publishname = '%s_pub.%s' % (self.shot, self.publishtype)
            for each in self.validtasks.keys():
                if each in self.version:
                    task = self.validtasks[each]
                    self.publishname = '%s_%s_pub.%s' % (self.shot, task, self.publishtype)

        else:
            self.publishname = '%s_%s_pub.%s' % (self.shot, self.task, self.publishtype)    

    def publish_dirs(self):
        '''
        checks for publishpath and creates it if not present
        '''
        print '\t> jmaya.pipeline.publish.publish_save.publish_dirs'
        
        #if 'old' exists, retrun need to do nothing
        if os.path.isdir(os.path.join(self.publishpath, 'old')):
            return

        #if publish exists, but old doenst
        if os.path.isdir(self.publishpath):
            if not os.path.isdir(os.path.join(self.publishpath, 'old')):
                os.makedirs(os.path.join(self.publishpath, 'old'))
        
        #if the pub dir doenst exist - make it and old
        else:
            os.makedirs(os.path.join(self.publishpath, 'old'))
    
    def publish_vars(self):
        '''
        run so that we can be sure we know where we are on the filesystem, used to build publishpath and publishname
        
        i should really be using the general purpose locate script are core.locate.find() to generate these vars
        '''
        print '\t> jmaya.pipeline.publish.publish_save.publish_vars'
        
        #we have the mayafile, with correct workspace - this is all we need
        mayafile = self.mayafile.split(os.path.sep)
        
        #known quantity
        jobrootsplit = core.jobsRoot.split(os.path.sep)
        
        #remove jobs root from list
        for each in jobrootsplit:
            mayafile.remove(each)
        
        #index 0 should be the job - check with core.job and get a dict if valid job
        if job.lookup(mayafile[0]).job:
            self.job = mayafile[0]
            
            #index 2 should be the dept - we already have nuke and 3d keys in dict - nothing more needed
            if mayafile[2] == '3d':
                self.dept = mayafile[2]
    
                #index 3 should be the 3d_assets folder
                if 'sh_' in mayafile[3]:
                    self.shot = mayafile[3]
                    try:                    
                        #index 5 will be either the task or verison
                        if len(mayafile) == 7:
                            self.task = mayafile[5]
                            self.version = mayafile[6]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.task, self.version )
    
                        elif len(mayafile) == 6:
                            self.task = 'loose'
                            self.version = mayafile[5]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.version )
                        
                        if rebuild == self.mayafile:
                            return True
                        else:
                            return False
                    except:
                        return False
                if mayafile[3] == '3d_assets':
                    print '\t> CANNOT PUBLISH AN ASSET'
                    cmds.confirmDialog( title='Publish' ,  message='Cannot publish an asset scene', button=['Ok'], defaultButton='Yes', cancelButton='No', dismissString='No' )
    
                    return False

class publish_ui(form, base):
    def __init__(self, obj, parent=maya_main_window()):
        '''
        is passed an instance of the publish_save instance
        
        setup of ui and the setting of publish name label and frame ranges  
        '''
        super(publish_ui, self).__init__(parent)

        self.setupUi(self)

        self.setObjectName(windowObject)
        self.setWindowTitle(windowTitle)
        
        self.obj = obj
        self.frame_start = str(int(obj.frame_start))
        self.frame_end = str(int(obj.frame_end))
        
        self.queue_list = {}
        self.sets = []
        
        self.start()
    
    def start(self):
        '''
        set the publishpath label and the start and end frames, based on current time slider attributes
        '''
        self.publish_path.setText('Publish Path : ' + self.obj.publishpath)
        
        #disable this if the ops dont want our suggestion for a publish name
        self.publish_name_entry.setText(self.obj.publishname)
        
        self.publish_frames_start_entry.setText(self.frame_start)
        self.publish_frames_end_entry.setText(self.frame_end)

    def publish_button(self):
        '''
        trigered when the publish button is clicked - checks the result of the publish_cmds class
        and notifies the user of success / fail
        
        creates a load of bool vars for future query
        '''
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
        
        x = publish_cmds(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, mayafile)
        
        if x.fail == False:
            cmds.confirmDialog(title='Publish', message= 'Successful publish', button=['Ok'], defaultButton='Ok')
            self.reject()
        elif x.fail == True:
            cmds.confirmDialog(title='Publish', message= 'Unsuccessful publish', button=['Ok'], defaultButton='Ok')

class publish_cmds():
    '''
    once all the varibales are set, they are passed here for the execution of the alembic export command
    
    this isnt the prettiest execution, building the string of the cmd using mel stlye flags, instead of using pymel
    to use a more pythonic way. see the importer commands as an example of good pymel
    
    we take the passed variables and build the cmd, we execute it then write its namespaces out to a text file
    so that they can be imported automatically when the alembic is imported in the future
    '''
    def __init__(self, start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, mayafile):
        print '\t> jmaya.pipeline.publish.publish_cmds'
        self.start = start
        self.end = end
        self.strip_namespaces = strip_namespaces
        self.whole_frame_geo = whole_frame_geo
        self.world_space = world_space
        self.export_selected = export_selected
        self.uv_write = uv_write
        self.mayafile = mayafile
        
        self.nogeo = False

        #filename
        self.file_name = file_name.replace('\\', '/')
        
        if not self.file_name.endswith('.abc'):
            self.file_name = self.file_name + '.abc'
        
        #cmd
        self.cmd = "-frameRange %s %s" % (self.start, self.end)
        
        #generic options
        if strip_namespaces:
            self.cmd = self.cmd + ' -stripNamespaces'

        if uv_write:
            self.cmd = self.cmd + ' -uvWrite'

        if whole_frame_geo:
            self.cmd = self.cmd + ' -wholeFrameGeo'

        if world_space:
            self.cmd = self.cmd + ' -worldSpace'

        #geometries
        if not self.export_selected_cmds() == '':
            self.cmd = self.cmd + self.export_selected_cmds()

        if self.nogeo:
            self.fail = True
            return
        
        #final cmd
        self.cmd = self.cmd + " -file '%s'" % self.file_name
        
        if self.exec_cmd(self.cmd):
            self.save_namespaces()
            self.fail = False
        else:
            self.fail = True
    
    def export_selected_cmds(self):
        '''
        if selected geometries is checked, we need the selection of object as a string with ' -root ' preceeding it
        '''
        print '\t> jmaya.pipeline.publish.publish_cmds.export_seleted_cmds'
        geometries = ''
        if self.export_selected:
            selected = cmds.ls(selection=True, l=True)
        
            if not len(selected) > 0:
                print 'NO OBJECTS SELECTED'
                self.nogeo = True
                #self.fail
            
            else:
                self.nogeo = False
                for each in selected:
                    add = ' -root %s' % each
                    geometries = geometries + add
        
        return geometries

    def exec_cmd(self, cmd):
        '''
        simply executes the alembic export command
        '''
        print '\t> jmaya.pipeline.publish.publish_cmds.exex_cmd'
        try:
            cmds.AbcExport(j = cmd)
            return True
        except:
            return False
        
    def save_namespaces(self):
        '''
        save out the non standard namespaces to a pickled list
        '''
        print '\t> jmaya.pipeline.publish.publish_cmds.save_namespaces'
        all_namespaces = cmds.namespaceInfo( lon=True )
        all_namespaces.remove('shared')
        all_namespaces.remove('UI')
        
        x = self.file_name.split('.')
        nmpkl = x[0] + '_namespaces.txt'
        f = open(nmpkl, 'w')
        pickle.dump(all_namespaces, f)
        f.close()
        print 'Namespaces saved : %s' % nmpkl