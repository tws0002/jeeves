print '> importing maya_jeeves.ui.jeeves_ui'

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

sys.dont_write_bytecode = True

''' CONFIGURATION '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

# General
QtType = 'PySide'										# Edit this to switch between PySide and PyQt
sys.dont_write_bytecode = True									# Do not generate .pyc files

uiFile = os.path.join(core.resourcesRoot, 'vfx', 'pipeline', 'jeeves', 'maya_jeeves', 'ui', 'templates', 'jeeves.ui')
uiFile = os.path.join(core.resourcesRoot, 'vfx', 'pipeline', 'jeeves_dev', 'maya_jeeves', 'ui', 'templates', 'jeeves.ui')
uiFile = '/Users/elliott/Google Drive/pipeline/jeeves_dev/maya_jeeves/ui/templates/jeeves.ui'

windowTitle = 'Jeeves'									# The visible title of the window
windowObject = 'jeeves'									# The name of the window object

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

class Jeeves(form, base):
    def __init__(self, parent=None):
        #"""Super, loadUi, signal connections"""
        super(Jeeves, self).__init__(parent)

        if QtType == 'PySide':
            #print 'Loading UI using PySide'
            self.setupUi(self)

        elif QtType == 'PyQt':
            #print 'Loading UI using PyQt'
            uic.loadUi(uiFile, self)

        self.setObjectName(windowObject)
        self.setWindowTitle(windowTitle)
        #self.tab_changed()
        self.layout_tabs.setEnabled(False)
        self.recent_jobs()

#--------------------------------------------------------------------------------------------------------------------------------------------------------- 
    def tab_changed(self):
        cur_index = self.layout_tabs.currentIndex()
        if cur_index == 0:
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
        else:
            self.btn_master.setEnabled(False)
            self.btn_publish.setEnabled(False)
            self.btn_version.setEnabled(False)
            self.btn_save.setEnabled(False)
            self.btn_saveas.setEnabled(False)

    def job_search_func(self, text = ''):
        '''
        lets find the job from the search string
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
        
        self.populate_assets()
        self.populate_shots()
        self.layout_tabs.setEnabled(True)
        self.tab_changed()
    
    def recent_jobs(self):
        jeeves_recent = os.path.join(os.getenv('HOME'), '.jeeves_recent.pkl')
        
        if os.path.isfile(jeeves_recent):
            f = open(jeeves_recent, 'r')
            jobs = pickle.load(f)
            f.close()
            
            self.recent_menu = QtGui.QMenu()
            
            for each in jobs:
                self.recent_menu.addAction(each)
                
            self.recent.setMenu(self.recent_menu)
    
    def recent_selected(self, selected_job):
        #print selected_job.text()
        self.job_search_func(selected_job.text())

    def add_to_recent(self):
        jeeves_recent = os.path.join(os.getenv('HOME'), '.jeeves_recent.pkl')
        
        if os.path.isfile(jeeves_recent):
            f = open(jeeves_recent, 'r')
            jobs = pickle.load(f)
            f.close()
            
            #print jobs
            #print len(jobs)
            
            if self.job in jobs:
                print 'job already in recent'
                jobs.remove(self.job)
                jobs.insert(0, self.job)
                f = open(jeeves_recent, 'w')
                pickle.dump(jobs, f)
                f.close()
                self.recent_jobs()
            else:
                if len(jobs) < 5:
                    jobs.insert(0, self.job)
                else:
                    jobs.pop(-1)
                    jobs.insert(0, self.job)
                
                f = open(jeeves_recent, 'w')
                pickle.dump(jobs, f)
                f.close()
                self.recent_jobs()
                #print jobs

        else:
            f = open(jeeves_recent, 'w')
            pickle.dump([self.job], f)
            f.close()
            self.recent_jobs()

    def enable(self):
        self.asset_reveal.setEnabled(True)
        self.asset_save_thumbnail.setEnabled(True)
        self.asset_save_note.setEnabled(True)
        
        self.shot_reveal.setEnabled(True)
        self.shot_save_thumbnail.setEnabled(True)
        self.shot_save_note.setEnabled(True)
        
        #self.btn_reference.setEnabled(True)
        self.btn_open.setEnabled(True)
        self.btn_import.setEnabled(True)
        
        self.btn_shot_refresh.setEnabled(True)
        self.btn_shot_sortalpha.setEnabled(True)
        self.btn_shot_sortdate.setEnabled(True)
        
        self.btn_asset_refresh.setEnabled(True)
        self.btn_asset_sortalpha.setEnabled(True)
        self.btn_asset_sortdate.setEnabled(True)
    
    def clearout(self):
        #these are the gui items that need to be manipulated
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
        
#---------------------------------------------------------------------------------------------------------------------------------------------------------
    #ASSETS
    def populate_assets(self):
        self.jobdict = assets.categorylookup(jobdict = self.jobdict)
        self.asset_categories = self.jobdict.asset_categories
        self.asset_categories = sorted(self.asset_categories)
        self.jobdict = self.jobdict.jobdict

        self.asset_combo_category.clear()
        self.asset_combo_category.addItems(self.asset_categories)
        
        self.change_category()

    #ASSET SLOT
    def change_category(self):
        self.int_call = True
        #print 'change category'# this is also activated when the asset category combo box is changed
        self.jobdict = assets.assetlookup(jobdict = self.jobdict, category = self.asset_combo_category.currentText())
        self.assets = self.jobdict.assets
        #self.assets = sorted(self.assets)
        self.assets = sorted(self.assets, key=lambda s: s.lower())
        self.assets.append('Add Asset')
        self.jobdict = self.jobdict.jobdict

        self.asset_combo_asset.clear()
        self.asset_combo_asset.addItems(self.assets)
        
        self.change_asset()
        self.int_call = False

    #ASSET SLOT
    def change_asset(self): # this is also activated when the asset combo box is changed
        self.int_call = True
        
        if self.asset_combo_asset.currentText() == 'Add Asset':
            self.add_asset()
            return
        
        self.cat = self.asset_combo_category.currentText()
        self.asset = self.asset_combo_asset.currentText()
        
        #take the current values of category and asset and pass them into a dict
        self.jobdict = wrappers.get_assets(jobdict = self.jobdict, category = self.cat, asset = self.asset).jobdict

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
    def populate_shots(self):
        self.jobdict = shot.shotslookup(self.jobdict, dept = '3d')
        self.shots = self.jobdict.shots
        self.shots = sorted(self.shots)
        self.shots.append('Add Shot')
        self.jobdict = self.jobdict.jobdict

        self.shot_combo.clear()
        self.shot_combo.addItems(self.shots)
        
        self.change_shot()
    
    #SHOT SLOT
    def change_shot(self): # this is also activated when the combo box is changed
        #print 'change shot'
        self.int_call = True
        
        if self.shot_combo.currentText() == 'Add Shot':
            self.add_shot()
            return
        
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
        self.shot_version_list = sorted(self.shot_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
        
        self.shot_versions.clear()
        self.shot_versions.addItems(self.shot_version_list)
        self.shot_versions.setCurrentRow(0)

        self.shot_publishes.clear()
        self.shot_publishes.addItems(self.publishes)
    
        self.shot_filter.clear()
        
        self.shot_note_path()
        self.read_shot_note()
        
        self.update_shot_thumb()
        self.int_call = False

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# this are common methods / slots - notes and shots
#---------------------------------------------------------------------------------------------------------------------------------------------------------
    
    #THUMBNAILS
    def update_asset_thumb(self):
        try:
            self.assetthumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'thumb.jpg')
            self.asset_thumbnail.setPixmap(QtGui.QPixmap(self.assetthumbpath))
        except:
            pass
    
    def update_shot_thumb(self):
        try:
            self.shotthumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'scenes', 'thumb.jpg')
            self.shot_thumbnail.setPixmap(QtGui.QPixmap(self.shotthumbpath))
        except:
            pass

    def savethumb(self):
        #print 'save thumbnail'
        cur_index = self.layout_tabs.currentIndex()
        if cur_index == 0:
            self.thumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'thumb.jpg')
        elif cur_index == 1:
            self.thumbpath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'scenes', 'thumb.jpg')
        
        x = cmds.getAttr("defaultRenderGlobals.imageFormat")

        cur_frame = int(cmds.currentTime(q=True))
        cmds.setAttr("defaultRenderGlobals.imageFormat", 8)
        
        cmds.playblast( frame=cur_frame, format="image", orn=False, v=False, cf = self.thumbpath, fo = True, p = 100, wh = [256, 144])
        cmds.setAttr("defaultRenderGlobals.imageFormat", x)
        self.update_asset_thumb()
        self.update_shot_thumb()
        self.statusBar().showMessage('Thumbnail created', timeout=4000)

#---------------------------------------------------------------------------------------------------------------------------------------------------------

    #NOTES
    def asset_note_path(self):
        try:
            #print 'asset note path'
            self.file = self.asset_versions.currentItem().text()
            
            if os.path.sep in self.file:
                halves = self.file.split(os.path.sep)
                filenote = '.' + halves[-1].split('.')[0] + '.txt'
                filenote = halves[0] + os.path.sep + filenote
            else:
                filenote = '.' + self.file.split('.')[0] + '.txt'
                
            self.note_path = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), filenote)
        except:
            pass
        
    def shot_note_path(self):
        #print 'shot note path'
        try:
            self.file = self.shot_versions.currentItem().text()
            
            if os.path.sep in self.file:
                halves = self.file.split(os.path.sep)
                filenote = '.' + halves[-1].split('.')[0] + '.txt'
                filenote = halves[0] + os.path.sep + filenote
            else:
                filenote = '.' + self.file.split('.')[0] + '.txt'
            
            self.note_path = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'scenes', filenote)
        except:
            pass

    def read_shot_note(self):
        #print 'read / make shot note'
        if os.path.isfile(self.note_path):
            pass
        else:
            f = open(self.note_path, 'w')
            f.close()
        
        ver_note = open(self.note_path, 'r')
        note_contents = ver_note.read()
        
        self.shot_note.clear()
        self.shot_note.setText(note_contents)
        
    def read_asset_note(self):
        #print 'read / make asset note'
        if os.path.isfile(self.note_path):
            pass
        else:
            f = open(self.note_path, 'w')
            f.close()
        
        ver_note = open(self.note_path, 'r')
        note_contents = ver_note.read()
        
        self.asset_note.clear()
        self.asset_note.setText(note_contents)

    def savenote(self):
        #print 'save note'
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
        #print 'reveal folder'
        cur_index = self.layout_tabs.currentIndex()
        if cur_index == 0:
            folder = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText())
        elif cur_index == 1:
            folder = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText())

        if os.path.isdir(folder):
            if sys.platform == 'darwin':
                subprocess.Popen(["open", folder])
            elif sys.platform == 'win32':
                os.startfile(folder)
            elif sys.platform == 'linux2':
                subprocess.Popen(["xdg-open", folder])

#---------------------------------------------------------------------------------------------------------------------------------------------------------
    #VERSION SORT BUTTONS
    
    #currently disabled
    def refresh(self):
        #print 'refresh'
        self.cur_index = self.layout_tabs.currentIndex()
        if self.cur_index == 0:
            #self.cat = self.asset_combo_category.currentText()
            #self.ass = self.asset_combo_asset.currentText()
            self.change_asset()
        elif self.cur_index == 1:
            #self.shot = self.shot_combo.currentText()
            self.change_shot()

    def sortalpha(self):
        self.int_call = True
        #print 'sort alpha'
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
        
        #self.refresh()
        self.int_call = False
        
    #currently disabled
    def sortdate(self):
        self.int_call = True
        #print 'sort date'
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
            p = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'Scenes')
            
            self.shot_version_list = sorted(self.shot_version_list, key=lambda each: os.path.getmtime(os.path.join(p, each)), reverse=True)
            self.shot_versions.clear()
            self.shot_versions.addItems(self.shot_version_list)
            self.shot_versions.setCurrentRow(0)
            self.shot_filter.clear()
            
            self.shot_note_path()
            self.read_shot_note()
        
        #self.refresh()
        self.int_call = False
        
    def change_filter(self):
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
    
    #def user_change_shot
    
    def change_shot_publish(self):
        self.shot_versions.clearSelection()
        self.shot_note.clear()
    
    def change_asset_master(self):
        self.asset_versions.clearSelection()
        self.asset_note.clear()
    
    def change_shot_version(self):
        self.shot_publishes.clearSelection()
        
        if not self.int_call:
            #print 'change_shot_version'
            self.shot_note_path()
            self.read_shot_note()

    def change_asset_version(self):
        self.asset_masters.clearSelection()
        if not self.int_call:
            #print 'change asset version'
            self.asset_note_path()
            self.read_asset_note()

    #---------------------------------------------------------------------------------------------------------------------------------------------------------
    #button slots

    #file operations
    def file_open(self, ):
        if cmds.file(q=True, modified=True):
            print 'this scene has been modified'
            result = cmds.confirmDialog( title='Modified Scene', message='This scene has been modified, do you wish to save?', button=['Save', 'No', 'Cancel'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            if result == 'Save':
                print 'Saving scene before opening'
                cmds.file(s=True)
            elif result == 'No':
                print 'No - not saving, just opening the selected scene'
                pass
            elif result == 'Cancel':
                print 'Cancelling'
                pass

        if self.find_file():
            if self.selected_master_pub:
                cmds.confirmDialog( title='Forbidden', message='You cannot open a master or published file', button=['Close'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            else:
                cmds.file(self.found_file, open=True, force = True)
                maya_jeeves.workspace.check_workspace()
                

    def file_reference(self, ):
        if self.find_file():
            import maya_jeeves.ui.reference_ui
            maya_jeeves.ui.reference_ui.run(self.found_file)
            #self.statusBar().showMessage('Save As : %s' % text, timeout=4000)
            
    def file_import(self):
        if self.find_file():
            import maya_jeeves.importer#;reload(maya_jeeves.importer)
            maya_jeeves.importer.importer(self.found_file)
    
    def find_file(self):
        cur_index = self.layout_tabs.currentIndex()
        self.selected_master_pub = False
        
        #need to find if version / master / publish is selected
        if cur_index == 0:
            if self.asset_versions.selectedItems() == []:
                self.selected_master_pub = True
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), 'master', self.asset_masters.currentItem().text())

            elif self.asset_masters.selectedItems() == []:
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'scenes', self.asset_combo_category.currentText(), self.asset_combo_asset.currentText(), self.asset_versions.currentItem().text())

        elif cur_index == 1:
            if self.shot_versions.selectedItems() == []:
                self.selected_master_pub = True
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'cache', self.shot_publishes.currentItem().text())

            elif self.shot_publishes.selectedItems() == []:
                found_file = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shot_combo.currentText(), 'scenes', self.shot_versions.currentItem().text())
        
        if os.path.isfile(found_file):
            print 'Found File : %s' % found_file
            self.found_file = found_file
            return self.found_file
        else:
            return False

    #open scene
    def save(self):
        #print 'save'
        x = cmds.file(q=True, sn=True)
        if not x:
            self.save_as()
            self.refresh()
        else:
            cmds.file(s=True)
            self.statusBar().showMessage('Save : %s' % x, timeout=4000)
        self.refresh()

    def save_as(self):
        #print 'save as'
        cur_index = self.layout_tabs.currentIndex()
        import maya_jeeves.ui.save_as#;reload(maya_jeeves.ui.save_as)
        maya_jeeves.ui.save_as.run(self.jobdict, self.job, self.asset_categories, self.assets, self.shots, cur_index)
        self.refresh()
        #return True
        #x = cmds.file(q=True, sn=True)
        #self.statusBar().showMessage('Save As : %s' % x, timeout=4000)

        
    def version(self):
        #print 'version'
        import maya_jeeves.version
        version = maya_jeeves.version.version_save()
        self.statusBar().showMessage('Version : %s' % version.new_filepath, timeout=4000)
        #self.change_asset()
        self.refresh()
        
    def master(self):
        #print 'master'
        import maya_jeeves.master
        master = maya_jeeves.master.master_save()
        text = os.path.join(master.masterpath, master.mastername)
        self.statusBar().showMessage('Master : %s' % text, timeout=4000)
        self.change_asset()

    def publish(self):
        #print 'publish'
        import maya_jeeves.publish.publisher_setup#;reload(maya_jeeves.publish.publisher_setup)
        publish = maya_jeeves.publish.publisher_setup.publish_save()

        text = os.path.join(publish.publishpath, publish.publishname)
        self.statusBar().showMessage('Publish : %s' % text, timeout=4000)

    def shader_export(self):
        #print 'shader export'
        import maya_jeeves.tools.shaders#; reload(maya_jeeves.tools.shaders)
        maya_jeeves.tools.shaders.shader_export()

    def shader_assign(self):
        cur_index = self.layout_tabs.currentIndex()
        import maya_jeeves.tools.shaders#; reload(maya_jeeves.tools.shaders)
        maya_jeeves.tools.shaders.shader_ui(self.jobdict, self.job, self.asset_categories, self.assets, self.shots, cur_index)

    def add_shot(self):
        print 'add shot'
        result = cmds.promptDialog(title='Create Shot', message='Shot number:', button=['OK', 'Cancel'], defaultButton='OK', cancelButton='Cancel', dismissString='Cancel')

        if result == 'OK':
            text = cmds.promptDialog(query=True, text=True)
            if shot.shot_add(self.job, text):
                print 'shot made'
                #prob should redo the dict
                self.populate_shots()
    
    def add_asset(self):
        #print 'add asset'
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
                pass
                self.statusBar().showMessage('Asset exists : %s' % text, timeout=4000)

                #print 'asset exists'

    def export_selection_sets(self):
        pass

''' Run functions '''
''' --------------------------------------------------------------------------------------------------------------------------------------------------------- '''

def runStandalone():
    app = QtGui.QApplication(sys.argv)
    global gui
    gui = Jeeves()
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

def runMaya():
    if cmds.window(windowObject, q=True, exists=True):
        cmds.deleteUI(windowObject)
    if cmds.dockControl( 'MayaWindow|'+windowTitle, q=True, ex=True):
        cmds.deleteUI( 'MayaWindow|'+windowTitle )
    global gui
    gui = Jeeves( maya_main_window() )

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
        gui = Jeeves()
        gui.show()

if runMode == 'standalone':
    runStandalone()
#elif runMode == 'maya':
    #runMaya()
#elif runMode == 'nuke':
    #runNuke()