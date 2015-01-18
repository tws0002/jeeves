'''
- so, jeeves can be run from within maya or nuke. the beginning of this module ascertains which program is calling it.
if it can import maya.cmds  etc, maya called it, if it can import nuke, then nuke called it, simples. once the run mode is
known, then the functions at the bottom of the module can be used to set jeeves up for each program.

this was originally this way when there was the intention to make it a standalone gui also, but since i can call runMaya() or
runNuke() directly, the runMode variable is largely pointless.

the uiFile var is simply the location of the jeeves.ui file

there are a few other bits, which are fairly self explanatory, but the most important one, for nuke anyway, is the
appending to the sys path of the maya site-packages folder, as this contains the pysideuic module, required for nuke to
convert and load the ui file from designer.

note: sometimes in maya, the ui gets stuck and you can select both a publish and a version, when this happends, jeeves doesnt know 
what to dowhen you click a button, like save or publish, when only one version or publish is selected all is fine.
'''

print '> importing core.ui.jeeves_ui'

import os, sys, pprint, subprocess, pickle
import xml.etree.ElementTree as xml
from cStringIO import StringIO

import core
import core.job as job
import core.shots as shot
import core.assets as assets
import core.wrappers as wrappers

sys.dont_write_bytecode = True

#path to jeeves.ui file and jeeves window titles
uiFile = os.path.join(core.jeeves_ui, 'templates', 'jeeves.ui')
windowTitle = "Jeeves %s" % core.jeeves_version
windowObject = 'jeeves'

# maya settings
launchAsDockedWindow = False
# nuke settings
launchAsPanel = False

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

try:
    import nuke
    from nukescripts import panels
    runMode = 'nuke'
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

#the main jeeves class

class Jeeves(form, base):
    '''
    - so, prior to this class being instanced, weve set the sys paths, imported maya.cmds / nuke modules, deleted any previous
    instanced of jeeves, and wrapped this instance so that we can convert a pointer to a Qt class instance
    
    - once that is done, the __init__ method, imports my pipeline stuff, either jmaya or jnuke. the reason it's jmaya or jnuke
    is becuase there is already a module called nuke and maya, so i had to choose a different name otherwise it might get
    confusing.
    
    - the names of the drop downs, menus, buttons etc are all set in qt designer, not in this file. so you'll need to have that
    installed to find out the names of the bits and bobs. also, the signals and slots are defined in qt designer, not here.
    
    - the reason i've done this, is two fold. firstly, it's easier to make layout changes in qt and secondly there are so many
    functions that i didnt want a 3000 line script, it would be too big. i used qt desinger 4.7 i think. 
    '''
    def __init__(self, parent=None):
        '''
        the only thing we do, initially anyway is to load the recent jobs pkl file so that the user can quickly select jobs and
        we disbale the buttons or drop downs, they are useless anyway unitl a job has been entered.
        '''
        #"""Super, loadUi, signal connections"""
        super(Jeeves, self).__init__(parent)

        #runMode can be nuke or maya, self.mode can be either maya or nuke
        self.mode = runMode

        if self.mode == 'nuke':
            import jnuke.pipeline
        elif self.mode == 'maya':
            import jmaya.pipeline
        
        self.setupUi(self)

        self.setObjectName(windowObject)
        self.setWindowTitle(windowTitle)
        
        #disable the tabs till a job has been entered
        self.layout_tabs.setEnabled(False)            
        self.recent_jobs()

    def recent_jobs(self):
        '''
        the jeeves.core __init__ method should have created the ~/.jeeves folder, here is where we store a pickle
        file that contians the recently selected jobs, we will load it and create a menu with those jobs in.
        
        when one is selected or typed in, the 'job_search_func' method is called, which uses the core.job module to match
        against a job on bertie
        '''
        jeeves_recent = os.path.join(core.home, '.jeeves', 'jeeves_recent.pkl')
        
        #if there is a pkl file, use it, if not dont. when a job is searched it will automatically be created for the future
        if os.path.isfile(jeeves_recent):
            f = open(jeeves_recent, 'r')
            jobs = pickle.load(f)
            f.close()
            
            self.recent_menu = QtGui.QMenu()
            
            for each in jobs:
                self.recent_menu.addAction(each)
                
            self.recent.setMenu(self.recent_menu)

    def job_search_func(self, text = ''):
        '''
        lets find the job from the search string or the chosen menu itme from recent jobs
        
        if a job is found, we create the self.job var from the object we get back from the core.job module (we also get a basic
        dictionary), we then add that job to recent jobs, if required.
        
        we set the job string in the search bar, clearout all the fields, enable everything and then go through and
        start populating the tabs with shots or assets.
        
        we call self.populate_assets and/or self.populate_shots
        
        lastly, we call self.tab_changed, which enables / disbales buttons based on the currently selected tab.
        '''
        if not text:
            text = self.job_search.text()
        
        self.jobdict = job.lookup(searchtext = text)

        if not self.jobdict.job:
            self.job_search.setText('No Job : %s' % text)
            self.statusBar().showMessage('Job not found : %s' % text, timeout=4000)
            self.clearout()
            return
        
        self.job = self.jobdict.job
        self.add_to_recent()
        self.jobdict = self.jobdict.jobdict
        self.job_search.setText(self.job)
        self.statusBar().showMessage('Job found : %s' % os.path.join(core.jobsRoot, self.job), timeout=4000)

        self.clearout()
        self.enable()
        
        if self.mode == 'maya':
            self.populate_assets()
        
        self.populate_shots()
        self.layout_tabs.setEnabled(True)

        if self.mode == 'nuke':
            self.assets_tab.setEnabled(False)
        
        self.tab_changed()


    #logic of what is enabled and disabled according to self.mode and tab index
    def tab_changed(self):
        '''
        index 0 = assets tab
        index 1 = shots tab
        index 2 = tools tab
        
        nuke doesnt have the assets tab enbaled, ever.
        
        this method is called whenever the tabs are changed so that only the correct buttons can be clicked
        
        the master button is disabled for shots
        
        the publish button is disabled for assets
        
        and vice versa.
        '''
        cur_index = self.layout_tabs.currentIndex()
        
        if cur_index == 0 and self.mode == 'maya':
            self.btn_publish.setEnabled(False)
            self.btn_master.setEnabled(True)
            self.btn_version.setEnabled(True)
            self.btn_save.setEnabled(True)
            self.btn_saveas.setEnabled(True)
        elif cur_index == 1:
            self.btn_publish.setEnabled(True)
            self.btn_master.setEnabled(False)
            self.btn_version.setEnabled(True)
            self.btn_save.setEnabled(True)
            self.btn_saveas.setEnabled(True)
            self.btn_open.setEnabled(True)
            self.btn_import.setEnabled(True)
        else:
            self.btn_master.setEnabled(False)
            self.btn_publish.setEnabled(False)
            self.btn_version.setEnabled(False)
            self.btn_save.setEnabled(False)
            self.btn_saveas.setEnabled(False)
        
        if cur_index == 0 and self.mode == 'nuke':
            self.btn_open.setEnabled(False)
            self.btn_import.setEnabled(False)
        
        if self.mode == 'nuke':
            self.btn_publish.setEnabled(False)
    
    def enable(self):
        '''
        used by the __init__ method when jeeves is created
        '''
        self.asset_reveal.setEnabled(True)
        self.asset_save_thumbnail.setEnabled(True)
        self.asset_save_note.setEnabled(True)
        
        self.shot_reveal.setEnabled(True)
        self.shot_save_thumbnail.setEnabled(True)
        self.shot_save_note.setEnabled(True)
        
        self.btn_open.setEnabled(True)
        self.btn_import.setEnabled(True)
        
        self.btn_shot_refresh.setEnabled(True)
        self.btn_shot_sortalpha.setEnabled(True)
        self.btn_shot_sortdate.setEnabled(True)
        
        self.btn_asset_refresh.setEnabled(True)
        self.btn_asset_sortalpha.setEnabled(True)
        self.btn_asset_sortdate.setEnabled(True)
        
        if self.mode == 'nuke':
            #nuke doesnt use publishes - yet anyway
            self.shot_publishes_label.setEnabled(False)
            self.shot_publishes.setEnabled(False)
    
    def clearout(self):
        '''
        clearing out of all the fields, fresh start
        '''
        #assets
        self.asset_combo_category.clear()
        self.asset_combo_asset.clear()
        self.asset_thumbnail.clear()
        self.asset_note.clear()
        self.asset_filter.clear()
        self.asset_versions.clear()
        self.asset_masters.clear()
        #shots
        self.shot_combo.clear()
        self.shot_thumbnail.clear()
        self.shot_note.clear()
        self.shot_filter.clear()
        self.shot_versions.clear()
        self.shot_publishes.clear()

    def recent_selected(self, selected_job):
        '''
        this method is triggered when a job is selected from the recent jobs drop down. it is defined in the ui file,
        but is simply points to the main search function
        '''
        self.job_search_func(selected_job.text())

    def add_to_recent(self):
        '''
        method that adds jobs to recent job pickle file, i've limited it to store only the last 5 searched jobs
        '''
        jeeves_recent = os.path.join(core.home, '.jeeves', 'jeeves_recent.pkl')
        
        if os.path.isfile(jeeves_recent):
            f = open(jeeves_recent, 'r')
            jobs = pickle.load(f)
            f.close()
          
            if self.job in jobs:
                #print 'job already in recent'
                jobs.remove(self.job)
                jobs.insert(0, self.job)
                f = open(jeeves_recent, 'w')
                pickle.dump(jobs, f)
                f.close()
                self.recent_jobs()
            else:
                #this is where we set the amount of recent jobs we hold
                if len(jobs) < 6:
                    jobs.insert(0, self.job)
                else:
                    jobs.pop(-1)
                    jobs.insert(0, self.job)
                
                f = open(jeeves_recent, 'w')
                pickle.dump(jobs, f)
                f.close()
                self.recent_jobs()

        else:
            #if the pkl doesnt exist, this will also create it 
            f = open(jeeves_recent, 'w')
            pickle.dump([self.job], f)
            f.close()
            self.recent_jobs()

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#ASSETS - this is where the fun begins
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def populate_assets(self):
        '''
        this is called from the the job_search_func method. first we pass the core.assets module the basic jobdict we got
        back from the job lookup and receive back a dict with the categories populated. we then creat some variables from
        the object that we get back from that class
        
        we clear out the category drop down and then add the recently acquired categories from the assets.categorylookup object
        
        after that, we call the change_category method.
        '''
        self.jobdict = assets.categorylookup(jobdict = self.jobdict)
        self.asset_categories = self.jobdict.asset_categories
        self.asset_categories = sorted(self.asset_categories)
        self.jobdict = self.jobdict.jobdict

        self.asset_combo_category.clear()
        self.asset_combo_category.addItems(self.asset_categories)
        
        self.change_category()

    #ASSET SLOT
    def change_category(self):
        '''
        this method is called from the populate_assets method and also from a trigger that is envoked when a change in
        category is made.
        
        the self.int_call var, is used so that we can distinguish between user calls that need action and internal calls
        that dont required further calls to methods. without this, we get doubling up on some method calls.
        
        we pass self.jobdict to core.assets.assetslookup as well as the currently selected category. this way we only
        look at one category, not all of them. we recieve back a dict with all the assets of a particular category
        populated
        
        we create various vars from the object, then sort the self.assets list alphabetically. we clear out previous
        assets and then append that list to the drop down (self.asset_combo_asset)
        
        following on from here we call the change_asset method where we get back versions and masters of that
        particular asset.
        '''
        self.int_call = True

        self.jobdict = assets.assetlookup(jobdict = self.jobdict, category = self.asset_combo_category.currentText())
        self.assets = self.jobdict.assets
        self.assets = sorted(self.assets, key=lambda s: s.lower())
        self.assets.append('Add Asset')
        self.jobdict = self.jobdict.jobdict

        self.asset_combo_asset.clear()
        self.asset_combo_asset.addItems(self.assets)
        
        self.change_asset()
        self.int_call = False

    #ASSET SLOT
    def change_asset(self):
        '''
        this method is also activated when the asset combo box is changed as well as being called by internal functions
        
        we take the current category and asset and use the wrappers module to find out both the versions and the masters. we
        could do both as separate calles to the respective classes in core.assets, but this is easier adn simpler.
        
        once we get the jobdict back and create some vars, we clear out the versions and masters, sort the lists and append
        to the relevant ui list boxes.
        
        we then look for a note for the currently selected version as well as a thumbnail for that particular asset
        
        that concludes the process of looking for an asset and populating both the dictionary and the ui.
        
        '''
        self.int_call = True
        
        #at the bottom of the asset list, there is the option to create an asset also. if selected we run up a dialog
        #to get an asset name, then we create it. afer creating there wont be any versions or masters, so we return.
        if self.asset_combo_asset.currentText() == 'Add Asset':
            self.add_asset()
            return
        
        self.cat = self.asset_combo_category.currentText()
        self.asset = self.asset_combo_asset.currentText()
        
        #take the current values of category and asset and pass them into a dict
        self.jobdict = wrappers.get_assets(jobdict = self.jobdict, category = self.cat, asset = self.asset).jobdict

        #empty lists for verisons and masters
        
        self.asset_version_list = []
        self.masters = []
        
        #GET VERSIONS
        if self.jobdict[self.job]['3d']['assets'][self.cat].keys() == []:
            #print  'no assets'
            self.asset_combo_asset.clear()
            self.asset_thumbnail.clear()
            self.asset_note.clear()
            self.asset_filter.clear()
            self.asset_versions.clear()
            self.asset_masters.clear()
            return
        
        for each in self.jobdict[self.job]['3d']['assets'][self.cat][self.asset].keys():
            #MASTERS
            if each == 'masters':
                for every in self.jobdict[self.job]['3d']['assets'][self.cat][self.asset][each]['current']:
                    self.masters.append(every)
            #VERSIONS
            else:
                if each == 'loose':
                    for every in self.jobdict[self.job]['3d']['assets'][self.cat][self.asset][each]['working']:
                        self.asset_version_list.append(every)
                else:
                    for every in self.jobdict[self.job]['3d']['assets'][self.cat][self.asset][each]['working']:
                        self.asset_version_list.append(each + os.path.sep + every)
        
        p =  os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText())
        
        #sorted by date madified
        self.asset_version_list = sorted(self.asset_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
        
        self.asset_versions.clear()
        self.asset_versions.addItems(self.asset_version_list)
        self.asset_versions.setCurrentRow(0)

        self.asset_masters.clear()
        self.masters = sorted(self.masters)
        self.asset_masters.addItems(self.masters)
        
        self.asset_filter.clear()
        
        self.asset_note_path()
        self.read_asset_note()
        self.update_asset_thumb()
        self.int_call = False

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#SHOTS
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def populate_shots(self):
        '''
        this is called from the the job_search_func method. first we pass the core.shots module the basic jobdict we got
        back from the job lookup as well as the dept we want shots for, 3d or nuke. we receive back a dict with the
        shots populated. we then create some variables from the object that we get back from that class
        
        we clear out the shots drop down and then add the sorted shot list from the shot.shotslookup object
        
        after that, we call the change_shot method.
        '''
        
        #self.mode is setin __init__
        if self.mode == 'maya':
            self.jobdict = shot.shotslookup(self.jobdict, dept = '3d')
        elif self.mode == 'nuke':
            self.jobdict = shot.shotslookup(self.jobdict, dept = 'nuke')        
            
        self.shots = self.jobdict.shots
        self.shots = sorted(self.shots)
        self.shots.append('Add Shot')
        self.jobdict = self.jobdict.jobdict

        self.shot_combo.clear()
        self.shot_combo.addItems(self.shots)
        
        self.change_shot()
    
    def change_shot(self):
        '''
        this method is called from the populate_shots method and also from a trigger that is envoked when a change in
        shots is made from the gui
        
        the self.int_call var, is used so that we can distinguish between user calls that need action and internal calls
        that dont required further calls to methods. without this, we get doubling up on some method calls.
    
        we take the current shot and use the wrappers module to find out both the versions and the publishes. we
        could do both as separate calles to the respective classes in core.shots, but this is easier and simpler.
        
        once we get the jobdict back and create some vars, we clear out the versions and pubishes, sort the lists and append
        to the relevant ui list boxes.
        
        we then look for a note for the currently selected version as well as a thumbnail for that particular shot
        
        that concludes the process of looking for a shot and populating both the dictionary and the ui.
        '''
        self.int_call = True
        
        if self.shot_combo.currentText() == 'Add Shot':
            self.add_shot()
            return
        
        #MAYA
        if self.mode == 'maya':
            self.jobdict = wrappers.get_scenes(jobdict = self.jobdict, dept = '3d', shot = self.shot_combo.currentText()).jobdict
            
            self.publishes = []
            self.shot_version_list = []
            
            for each in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()].keys():
                if each == 'publishes':
                    for cachetype in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()]['publishes'].keys():
                        for current in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()]['publishes'][cachetype]['current']:
                            self.publishes.append(cachetype + os.path.sep + current)
                elif each == 'scenes':
                    for task in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()]['scenes']:
                        if task == 'loose':
                            for version in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()]['scenes']['loose']:
                                self.shot_version_list.append(version)
                        else:
                            for version in self.jobdict[self.job]['3d']['shots'][self.shot_combo.currentText()]['scenes'][task]:
                                self.shot_version_list.append(task + os.path.sep + version)
            
            
            p = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'Scenes')
        
        #NUKE
        if self.mode == 'nuke':
            self.jobdict = wrappers.get_scenes(jobdict = self.jobdict, dept = 'nuke', shot = self.shot_combo.currentText()).jobdict
    
            self.shot_version_list = []
            
            for each in self.jobdict[self.job]['nuke']['shots'][self.shot_combo.currentText()].keys():
                if each == 'scripts':
                    for user in self.jobdict[self.job]['nuke']['shots'][self.shot_combo.currentText()]['scripts']:
                        if user == 'loose':
                            for version in self.jobdict[self.job]['nuke']['shots'][self.shot_combo.currentText()]['scripts']['loose']:
                                self.shot_version_list.append(version)
                        else:
                            for version in self.jobdict[self.job]['nuke']['shots'][self.shot_combo.currentText()]['scripts'][user]:
                                self.shot_version_list.append(user + os.path.sep + version)
            
            
            p = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText(), 'scripts')        
        

        self.shot_version_list = sorted(self.shot_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
        
        self.shot_versions.clear()
        self.shot_versions.addItems(self.shot_version_list)
        self.shot_versions.setCurrentRow(0)

        self.shot_publishes.clear()
        
        #we dont publish for nuke, not yet anyway
        if self.mode == 'maya':
            self.shot_publishes.addItems(self.publishes)
    
        self.shot_filter.clear()
        
        self.shot_note_path()
        self.read_shot_note()
        
        self.update_shot_thumb()
        self.int_call = False

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#THUMBNAILS
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def update_asset_thumb(self):
        '''
        we build the path the to thumbnail, self.assetthumbpath and if there, we set it as the thumb for that asset. this is triggered
        whenever the asset is changed in the ui. there is only one thumb for each asset
        
        we use the try/except becuase i dont want it failing if a thumb isnt there
        '''
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
            
        try:
            self.assetthumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'thumb.jpg')
            self.asset_thumbnail.setPixmap(QtGui.QPixmap(self.assetthumbpath))    
        except:
            pass
    
    def update_shot_thumb(self):
        '''
        we build the path the to thumbnail, self.shotthumbpath and if there, we set it as the thumb for that asset. this is triggered
        whenever the shot is changed in the ui. there is only one thunb for each shot
        
        we use the try/except becuase i dont want it failing if a thumb isnt there
        '''
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
            
        try:
            if self.mode == 'maya':
                self.shotthumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), scenes, 'thumb.jpg')
            elif self.mode == 'nuke':
                self.shotthumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText(), 'scripts', 'thumb.jpg')

            self.shot_thumbnail.setPixmap(QtGui.QPixmap(self.shotthumbpath))
        except:
            pass

    def savethumb(self):
        '''
        index 0 = assets tab
        index 1 = shots tab
        index 2 = tools tab
        
        to create a thumbnail, we import the jnuke.pipeline.thumbnail or jmaya.pipeline.thumbnail modules. we pass it the job, the shot and the
        path that it is to save the thumbnail to
        
        after we've generated the thumbnail, we update the gui with the self.update_asset_thumb and self.update_shot_thumb calls
        '''
        cur_index = self.layout_tabs.currentIndex()
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
        
        if self.mode == 'maya':
            if cur_index == 0:
                self.thumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'thumb.jpg')
            elif cur_index == 1:
                self.thumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), scenes, 'thumb.jpg')
            
            import jmaya.pipeline.thumbnail
            jmaya.pipeline.thumbnail.run(self.job, self.shot_combo.currentText(), self.thumbpath)
        
        elif self.mode == 'nuke':
            #no need to check for assets - nuke not concerned with assets yet
            import jnuke.pipeline.thumbnail
            jnuke.pipeline.thumbnail.run(self.job, self.shot_combo.currentText())

        self.update_asset_thumb()
        self.update_shot_thumb()
        self.statusBar().showMessage('Thumbnail created', timeout=4000)

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#NOTES
#---------------------------------------------------------------------------------------------------------------------------------------------------------
    
    def asset_note_path(self):
        '''
        here we build a path to the asset version note, based on the currently selected scene / script
        
        this note_path is then used by other methods to read or save to it
        '''
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
            
        try:
            self.file = self.asset_versions.currentItem().text()
            
            if os.path.sep in self.file:
                halves = self.file.split(os.path.sep)
                filenote = '.' + halves[-1].split('.')[0] + '.txt'
                filenote = halves[0] + os.path.sep + filenote
            else:
                filenote = '.' + self.file.split('.')[0] + '.txt'
                
            self.note_path = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), filenote)
        except:
            pass
        
    def shot_note_path(self):
        '''
        here we build a path to the shot version note, based on the currently selected scene / script
        
        this note_path is then used by other methods to read or save to it       
        '''
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
        
        try:
            self.file = self.shot_versions.currentItem().text()
            
            if os.path.sep in self.file:
                halves = self.file.split(os.path.sep)
                filenote = '.' + halves[-1].split('.')[0] + '.txt'
                filenote = halves[0] + os.path.sep + filenote
            else:
                filenote = '.' + self.file.split('.')[0] + '.txt'
            
            if self.mode == 'maya':
                self.note_path = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), scenes, filenote)
            elif self.mode == 'nuke':
                self.note_path = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText(), 'scripts', filenote)
            
        except:
            pass

    def read_shot_note(self):
        '''
        once the note path is know, we can then read it in
        '''
        try:
            if os.path.isfile(self.note_path):
                pass
            else:
                f = open(self.note_path, 'w')
                f.close()
            
            ver_note = open(self.note_path, 'r')
            note_contents = ver_note.read()
            
            self.shot_note.clear()
            self.shot_note.setText(note_contents)
        except:
            pass
        
    def read_asset_note(self):
        '''
        once the note path is know, we can then read it in
        '''
        try:
            if os.path.isfile(self.note_path):
                pass
            else:
                f = open(self.note_path, 'w')
                f.close()
            
            ver_note = open(self.note_path, 'r')
            note_contents = ver_note.read()
            
            self.asset_note.clear()
            self.asset_note.setText(note_contents)
        except:
            pass    

    def savenote(self):
        '''
        simple method to save the note for the asset or shots version
        '''
        cur_index = self.layout_tabs.currentIndex()
        
        if cur_index == 0:
            self.asset_note_path()
            cur_text = self.asset_note.toPlainText()
        elif cur_index == 1:
            self.shot_note_path()
            cur_text = self.shot_note.toPlainText()

        f = open(self.note_path, 'w')
        f.write(cur_text)
        f.close()
        self.statusBar().showMessage('Note saved', timeout=4000)

#---------------------------------------------------------------------------------------------------------------------------------------------------------
    #REVEAL
    def reveal_folder(self):
        '''
        method to find the currently selected version parent folder.
        
        once known we then pop open a os level finder window to reveal it's location to the user
        '''
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
        elif sys.platform == 'win32':
            scenes = 'scenes'
        
        cur_index = self.layout_tabs.currentIndex()
        if cur_index == 0:
            folder = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText())
        elif cur_index == 1:
            if self.mode == 'maya':
                folder = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText())
            elif self.mode == 'nuke':
                folder = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText())

        if os.path.isdir(folder):
            if sys.platform == 'darwin':
                subprocess.Popen(["open", folder])
            elif sys.platform == 'win32':
                os.startfile(folder)
            elif sys.platform == 'linux2':
                subprocess.Popen(["xdg-open", folder])

#---------------------------------------------------------------------------------------------------------------------------------------------------------
    #VERSION SORT BUTTONS
    
    def refresh(self):
        '''
        simply refreshes the versions / masters / publishes lists
        '''
        self.cur_index = self.layout_tabs.currentIndex()
        if self.cur_index == 0:
            self.change_asset()
        elif self.cur_index == 1:
            self.change_shot()

    def sortalpha(self):
        '''
        sorts the versions list alpabetically
        '''
        self.int_call = True
        cur_index = self.layout_tabs.currentIndex()
        if cur_index == 0:
            self.asset_versions.clear()
            self.asset_version_list = sorted(self.asset_version_list, key=lambda s: s.lower())
            self.asset_versions.addItems(self.asset_version_list)
            self.asset_versions.setCurrentRow(0)
            
            self.asset_filter.clear()
            
            self.asset_note_path()
            self.read_asset_note()
        
        elif cur_index == 1:
            self.shot_versions.clear()
            self.shot_version_list = sorted(self.shot_version_list, key=lambda s: s.lower())
            self.shot_versions.addItems(self.shot_version_list)
            self.shot_versions.setCurrentRow(0)
            
            self.shot_filter.clear()
            
            self.shot_note_path()
            self.read_shot_note()
        
        self.int_call = False
        
    def sortdate(self):
        '''
        sorts the versions list by date
        '''
        self.int_call = True
        cur_index = self.layout_tabs.currentIndex()
        
        tmp = []
        
        if cur_index == 0:
            p =  os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText())
            
            self.asset_version_list = sorted(self.asset_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
            self.asset_versions.clear()
            self.asset_versions.addItems(self.asset_version_list)
            self.asset_versions.setCurrentRow(0)
            self.asset_filter.clear()
            
            self.asset_note_path()
            self.read_asset_note()
        
        elif cur_index == 1:
            if self.mode == 'maya':
                p = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'Scenes')
            elif self.mode == 'nuke':
                p = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText(), 'scripts')
            
            self.shot_version_list = sorted(self.shot_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
            self.shot_versions.clear()
            self.shot_versions.addItems(self.shot_version_list)
            self.shot_versions.setCurrentRow(0)
            self.shot_filter.clear()
            
            self.shot_note_path()
            self.read_shot_note()
        
        self.int_call = False
        
    def change_filter(self):
        '''
        is triggered when the user searches using the ui, basic string matching, creating a temp list
        that we use to populate versions, after clearing it out. we maintain the full self.shot_version_list
        and self.asset_version_list vars, so we can re-populate when needed without having to do another lookup
        '''
        self.int_call = True
        
        cur_index = self.layout_tabs.currentIndex()
        
        if cur_index == 0:
            cur_text = self.asset_filter.text()
            tmp = []
            for each in self.asset_version_list:
                if cur_text in each:
                    tmp.append(each)
            
            self.asset_versions.clear()
            self.asset_versions.addItems(tmp)
            
        elif cur_index == 1:
            cur_text = self.shot_filter.text()
            tmp = []
            for each in self.shot_version_list:
                if cur_text in each:
                    tmp.append(each)
            
            self.shot_versions.clear()
            self.shot_versions.addItems(tmp)

        self.int_call = False

#---------------------------------------------------------------------------------------------------------------------------------------------------------
    #CHANGE SLOTS
    
    def change_shot_publish(self):
        '''
        triggers
        '''
        self.shot_versions.clearSelection()
        self.shot_note.clear()
    
    def change_asset_master(self):
        self.asset_versions.clearSelection()
        self.asset_note.clear()
    
    def change_shot_version(self):
        '''
        triggers
        '''
        self.shot_publishes.clearSelection()
        
        if not self.int_call:
            self.shot_note_path()
            self.read_shot_note()

    def change_asset_version(self):
        '''
        triggers
        '''
        self.asset_masters.clearSelection()
        if not self.int_call:
            self.asset_note_path()
            self.read_asset_note()

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#FILE OPEN AND IMPORT BUTTON SLOTS
#---------------------------------------------------------------------------------------------------------------------------------------------------------
    
    def file_open(self, ):
        '''
        first we use the self.find_file method to check the file is where it should be. if it is, we procedd to opening it.
        
        we pass the found file to the respective open modules    
        '''
        if self.find_file():
            if self.mode == 'maya':
                import jmaya.pipeline.open
                jmaya.pipeline.open.run(self.found_file, self.selected_master_pub)
            
            elif self.mode == 'nuke':
                import jnuke.pipeline.open
                jnuke.pipeline.open.run(self.found_file)
                
        try:
            self.statusBar().showMessage('Open : %s' % self.found_file, timeout=4000)
        except:
            pass

    def file_import(self):
        '''
        first we use the self.find_file method to check the file is where it should be. if it is, we procedd to importing it.
        
        we pass the found file to the respective importer modules
        '''
        if self.find_file():
            if self.mode == 'maya':              
                import jmaya.pipeline.importer
                jmaya.pipeline.importer.run(self.found_file)
            
            elif self.mode == 'nuke':
                import jnuke.pipeline.importer
                jnuke.pipeline.importer.run(self.found_file)
            
        try:
            self.statusBar().showMessage('Import : %s' % self.found_file, timeout=4000)
        except:
            pass

    def find_file(self):
        '''
        this little method is used primarily to build a file path of the selected scene / script in the gui and then look on disk to see
        if its there.
        
        it's used when opening a selected scene / script. it returns false if the file isn't where the file should be and returns the name
        of the scene / script if it is on disk
        
        due to the case sensitive nature of linux, i've had to capitalise the filepath bits, eg Scenes not scenes
        
        the other thing we do is set the self.selected_master_pub var so that we know if the user has selected a master or a version.
        a master cannot be opened, so subsequent methods may stop if the user tries to do something they shoudlnt be doing
        
        '''
        cur_index = self.layout_tabs.currentIndex()
        self.selected_master_pub = False
        
        if sys.platform == 'linux2':
            scenes = 'Scenes'
            cache = 'cache'
            scripts = 'scripts'
        else:
            scenes = 'scenes'
            cache = 'cache'
            scripts = 'scripts'
        
        #need to find if version / master / publish is selected
        if cur_index == 0:
            if self.asset_versions.selectedItems() == []:
                self.selected_master_pub = True
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'master', self.asset_masters.currentItem().text())
    
            elif self.asset_masters.selectedItems() == []:
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', scenes, self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), self.asset_versions.currentItem().text())
    
        elif cur_index == 1:
            if self.shot_versions.selectedItems() == []:
                if self.mode == 'nuke':
                    return
                elif self.mode == 'maya':
                    self.selected_master_pub = True
                    found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), cache, self.shot_publishes.currentItem().text())
    
            elif self.shot_publishes.selectedItems() == []:
                if self.mode == 'maya':
                    found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), scenes, self.shot_versions.currentItem().text())
                elif self.mode == 'nuke':
                    found_file = os.path.join(core.jobsRoot, self.job, 'vfx', 'nuke', self.shot_combo.currentText(), scripts, self.shot_versions.currentItem().text())

        if os.path.isfile(found_file):
            print 'Found File : %s' % found_file
            self.found_file = found_file
            return self.found_file
        else:
            print 'NOT Found File : %s' % found_file
            return False
    
#---------------------------------------------------------------------------------------------------------------------------------------------------------
# the following methods deal with the currently opened scene / script. master and publish are only available for maya
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def save(self):
        '''
        the save call for nuke is easy
        
        the save call for maya is a little more complex. we build up two lists, one for shots and the other for assets. we then send those lists
        along with the jobdict, job, asset categories and current index of the tab we are in. we send all this data to the save module
        and let that figure out where we want to save it to.
        '''
        if self.mode == 'maya':
            cur_index = self.layout_tabs.currentIndex()
            exclude = ['Add Shot', 'Add Asset']
            shotlist = []
            assetlist = []
            
            for i in self.shots:
                if not i in exclude:
                    shotlist.append(i)
 
            for i in self.assets:
                if not i in exclude:
                    assetlist.append(i)

            import jmaya.pipeline.save
            x = jmaya.pipeline.save.save(self.jobdict, self.job, self.asset_categories, assetlist, shotlist, cur_index)
        
        elif self.mode == 'nuke':
            import jnuke.pipeline.save
            x = jnuke.pipeline.save.run()
        
        self.statusBar().showMessage('Save : %s' % x, timeout=4000)
        self.refresh()
    
    def save_as(self):
        '''
        the save_as call for nuke is easy, we dont deal with shots or assets, just shots and never have to save into a new task,
        because in the nuke pipeline, the tasks are the users, not lighting, modelling etc.
        
        the save_as call for maya is a little more complex. we build up two lists, one for shots and the other for assets. we then send those lists
        along with the jobdict, job, asset categories and current index of the tab we are in. we send all this data to the save_as module
        and let that figure out where we want to save it to.
        '''
        if self.mode == 'maya':
            cur_index = self.layout_tabs.currentIndex()
            exclude = ['Add Shot', 'Add Asset']
            shotlist = []
            assetlist = []
            
            for i in self.shots:
                if not i in exclude:
                    shotlist.append(i)

            for i in self.assets:
                if not i in exclude:
                    assetlist.append(i)
                    
            import jmaya.pipeline.save_as
            saveas = jmaya.pipeline.save_as.run(self.jobdict, self.job, self.asset_categories, assetlist, shotlist, cur_index)
            
        elif self.mode == 'nuke':
            pass
            # import jnuke.pipeline.save_as
            # saveas = jnuke.pipeline.save_as.run(self.jobdict, self.job, shotlist)
            
        self.refresh()
        
    def version(self):
        '''
        depending on whether we are running maya or nuke, we import and then run the different version modules / version_save classes
        '''
        if self.mode == 'maya':
            import jmaya.pipeline.version
            version = jmaya.pipeline.version.version_save()
        
        elif self.mode == 'nuke':
            import jnuke.pipeline.version
            version = jnuke.pipeline.version.version_save()
        
        self.refresh()
        
    def master(self):
        '''
        this is only available for maya and only for assets, not shots
        
        we initiate an instance of the publish class and then use it to pull out the masterpath and mastername
        '''
        if self.mode == 'maya':
            import jmaya.pipeline.master
            master = jmaya.pipeline.master.master_save()
            text = os.path.join(master.masterpath, master.mastername)
        
        self.statusBar().showMessage('Master : %s' % text, timeout=4000)
        self.change_asset()
        self.refresh()
    
    def publish(self):
        '''
        this is only available for maya and only for shots, not assets
        
        we initiate an instance of the publish class and then use it to pull out the publishpath and publishname
        '''
        if self.mode == 'maya':
            import jmaya.pipeline.publish
            publish = jmaya.pipeline.publish.publish_save()
    
            text = os.path.join(publish.publishpath, publish.publishname)
        
        self.statusBar().showMessage('Publish : %s' % text, timeout=4000)
        self.refresh()
 
#---------------------------------------------------------------------------------------------------------------------------------------------------------
#TOOLS SLOTS
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def shader_export(self):
        '''
        this method simply imports the jmaya.pipeline.tools.shaders module and executes the shader_export script
        
        this tool is documented in its own module
        '''
        import jmaya.pipeline.tools.shaders
        jmaya.pipeline.tools.shaders.shader_export()
    
    def shader_assign(self):
        '''
        this method simply imports the jmaya.pipeline.tools.shaders module and executes the shader_ui script
        
        the ui is used to assign shaders to geometries and documented in the maya.pipeline.tools.shaders module

        '''
        cur_index = self.layout_tabs.currentIndex()
        import jmaya.pipeline.tools.shaders
        jmaya.pipeline.tools.shaders.shader_ui(self.jobdict, self.job, self.asset_categories, self.assets, self.shots, cur_index)

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#ADD ASSET AND SHOT SLOTS
#---------------------------------------------------------------------------------------------------------------------------------------------------------

    def add_shot(self):
        '''
        using either maya.cmds or nuke, we pop open a dialog and ask for the shot name / number and then take that string and pass it to
        core.shot.add_shot along with the job string
        
        the shot, becuase it is a little complex, is made via the xmlrpc server running on bertie linux
        '''
        
        if self.mode == 'maya':
            result = cmds.promptDialog(title='Create Shot', message='Shot number:', button=['OK', 'Cancel'], defaultButton='OK', cancelButton='Cancel', dismissString='Cancel')
        
            if result == 'OK':
                text = cmds.promptDialog(query=True, text=True)
                if shot.shot_add(self.job, text):
                    #prob should redo the dict
                    self.populate_shots()
                    self.statusBar().showMessage('Shot made : %s' % text, timeout=4000)
        
        elif self.mode == 'nuke':
            text = nuke.getInput('Create Shot', '' )

            if shot.shot_add(self.job, text):
                self.populate_shots()
                self.statusBar().showMessage('Shot made : %s' % text, timeout=4000)


    def add_asset(self):
        '''
        using maya.cmds we pop open a dialog and prompt the user to enter in a name of the asset they wish to create.
        
        if they hit 'OK', we take that string and locally create that asset under the currently selected category
        '''
        cat = self.asset_combo_category.currentText()
        result = cmds.promptDialog(title='Create Asset', message='Asset name:', button=['OK', 'Cancel'], defaultButton='OK', cancelButton='Cancel', dismissString='Cancel')
    
        if result == 'OK':
            text = cmds.promptDialog(query=True, text=True)
            
            cat_asset_path = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', cat)
            asset_path = os.path.join(cat_asset_path, text)
            
            if not os.path.isdir(asset_path):
                os.makedirs(os.path.join(asset_path, 'master', 'old'))
                #print 'asset made'
                self.populate_assets()
                self.statusBar().showMessage('Asset made : %s' % text, timeout=4000)
            else:
                self.statusBar().showMessage('Asset exists : %s' % text, timeout=4000)


#the launch functions

def runMaya():
    '''
    we delete the jeeves ui if it already exists, then we bound the ui to the global gui var so that it can be messed with
    from the script editor from inside maya, not that we really need to, but we may as well have that option.
    
    we call the main Jeeves class with the arguement maya_main_window, which is a class that wraps the window as an instance
    
    finally, we show the gui
    '''
    if cmds.window(windowObject, q=True, exists=True):
        cmds.deleteUI(windowObject)
    if cmds.dockControl( 'MayaWindow|'+windowTitle, q=True, ex=True):
        cmds.deleteUI( 'MayaWindow|'+windowTitle )
    global gui
    gui = Jeeves( maya_main_window() )

    if launchAsDockedWindow:
        allowedAreas = ['right', 'left']
        cmds.dockControl( windowTitle, label=windowTitle, area='right', content=windowObject, allowedArea=allowedAreas )
    else:
        gui.show()

def runNuke():
    '''
    the nuke script is much simpler, though ive not checked for other instances of a jeeves window, which i perhaps should do
    '''
    moduleName = __name__
    if moduleName == '__main__':
        moduleName = ''
    else:
        moduleName = moduleName + '.'

    global gui
    if launchAsPanel:
        pane = nuke.getPaneFor('Properties.1')
        panel = panels.registerWidgetAsPanel( moduleName + 'Jeeves' , windowTitle, ('uk.co.thefoundry.'+windowObject+'Window'), True).addToPane(pane)
    else:
        gui = Jeeves()
        gui.show()

if runMode == 'maya':
    runMaya()
elif runMode == 'nuke':
    runNuke()