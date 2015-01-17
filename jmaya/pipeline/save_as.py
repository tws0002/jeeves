'''
this modules helps the op choose where to save the scene to with a gui. unlike, jeeves, publish and import, this gui
is written directly with pyside, simply becuase it's so small and easy to manage

the ui has two tabs, one for shots, the other for assets. in each of them, they have drop downs so the user can
choose the shot, category and asset that they want to save into. for both of them, there is a final drop down, the
task dropdown, this includes options to save it as a lighting, modelling etc scene.there is a checkbox to next
it under a lighting, modelling sub folder also.

lastly,the name of the file you are writing out is exposed. it is built from the drop down selections, but can be
overwritten directly, including making custom folder with the use of a path sep in the filename string
'''

print '> importing jmaya.pipeline.save_as'

from PySide import QtCore, QtGui
import traceback, sys, os
from shiboken import wrapInstance

import maya.cmds as cmds
import maya.OpenMayaUI as omui

import core
import core.assets as assets
import jmaya.pipeline.workspace

sys.dont_write_bytecode = True

####################################################################################################################################

def maya_main_window():
    '''
    Return the Maya main window widget as a Python object
    '''
    main_window_ptr = omui.MQtUtil.mainWindow()
    return wrapInstance(long(main_window_ptr), QtGui.QWidget)

####################################################################################################################################

class Ui_Save(QtGui.QDialog):
    '''
    single class of the save_as module, builds the ui from pyside
    the 'create' method is called from 'run' function which sets up the ui and signals / slots
    
    is passed lists of shots, categories, assets ect to populate the ui with, could have pulled them out of the jobdict
    though, meh
    '''
    
    test_signal = QtCore.Signal()
    
    def __init__(self, jobdict, job, cat, ass, shots, cur_index, parent=maya_main_window()):
        super(Ui_Save, self).__init__(parent)
        self.jobdict = jobdict
        self.job = job
        self.cat = cat
        self.ass = ass
        self.shots = shots
        self.cur_index = cur_index
    
    def create(self):
        '''
        Set up the UI prior to display
        '''
        self.setWindowTitle("Save As")
        self.setWindowFlags(QtCore.Qt.Tool)
        
        #possible task choices
        self.tasks = ['none', 'layout', 'modelling', 'texturing', 'rigging', 'animation', 'simulation', 'lighting']
        
        #set up the controls, layout and connections of the ui
        self.create_controls()
        self.create_layout()
        self.create_connections()
        
        self.set_string()
        
    def create_controls(self):
        '''
        set up the widgets and controls
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.create_controls'

        self.setObjectName("Dialog")
        self.resize(310, 300)
        
        self.tabWidget = QtGui.QTabWidget()
       
        self.Assets = QtGui.QWidget()
        self.assets_vertical_widget = QtGui.QWidget(self.Assets)
        self.assets_vertical_widget.setGeometry(QtCore.QRect(10, 20, 260, 200))
        self.assets_combo_category = QtGui.QComboBox()
        self.assets_combo_category.addItems(self.cat)
        self.assets_combo_assets = QtGui.QComboBox()
        self.assets_combo_assets.addItems(self.ass)
        self.assets_combo_tasks = QtGui.QComboBox()
        self.assets_combo_tasks.addItems(self.tasks)
        self.assets_subfolder_check = QtGui.QCheckBox('save to subfolder')
        self.assets_spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.assets_label = QtGui.QLabel()
        self.assets_label.setText("example: rig/char_columbus_rig_es_v01.mb")
        self.assets_name_entry = QtGui.QLineEdit()
        self.tabWidget.addTab(self.Assets, "Assets")
        
        self.Shots = QtGui.QWidget()
        self.shots_vertical_widget = QtGui.QWidget(self.Shots)
        self.shots_vertical_widget.setGeometry(QtCore.QRect(10, 20, 260, 200))
        self.shots_combo = QtGui.QComboBox()
        self.shots_combo.addItems(self.shots)
        self.shots_combo_tasks = QtGui.QComboBox()
        self.shots_combo_tasks.addItems(self.tasks)
        self.shots_subfolder_check = QtGui.QCheckBox('save to subfolder')
        self.shots_spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.shots_label = QtGui.QLabel()
        self.shots_label.setText("example: anim/sh_001_animation_es_v01.mb")
        self.shots_name_entry = QtGui.QLineEdit()
        self.tabWidget.addTab(self.Shots, "Shots")

        self.btn_saveas = QtGui.QPushButton()
        self.btn_saveas.setText('Save As')
        #set the defaults
        self.set_defaults()

    def create_layout(self):
        '''
        layout for the widgets and dropdowns
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.create_layout'
        assets_verticalLayout = QtGui.QVBoxLayout(self.assets_vertical_widget)
        assets_verticalLayout.addWidget(self.assets_combo_category)
        assets_verticalLayout.addWidget(self.assets_combo_assets)
        assets_verticalLayout.addWidget(self.assets_combo_tasks)
        assets_verticalLayout.addWidget(self.assets_subfolder_check)
        assets_verticalLayout.addItem(self.assets_spacerItem)
        assets_verticalLayout.addWidget(self.assets_label)
        assets_verticalLayout.addWidget(self.assets_name_entry)

        shots_verticalLayout = QtGui.QVBoxLayout(self.shots_vertical_widget)
        shots_verticalLayout.addWidget(self.shots_combo)
        shots_verticalLayout.addWidget(self.shots_combo_tasks)
        shots_verticalLayout.addWidget(self.shots_subfolder_check)
        shots_verticalLayout.addItem(self.shots_spacerItem)
        shots_verticalLayout.addWidget(self.shots_label)
        shots_verticalLayout.addWidget(self.shots_name_entry)
        
        main_layout = QtGui.QVBoxLayout()
        main_layout.setContentsMargins(6, 6, 6, 6)
        
        main_layout.addWidget(self.tabWidget)
        main_layout.addWidget(self.btn_saveas)
        #set the layout
        self.setLayout(main_layout)

    def create_connections(self):
        '''
        create the connections between the buttons and actions and methods
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.create_connections'
        self.assets_combo_category.activated.connect(self.category_changed)
        self.assets_combo_assets.activated.connect(self.set_string)
        self.shots_combo.activated.connect(self.set_string)
        self.btn_saveas.clicked.connect(self.save_as)
        self.tabWidget.currentChanged.connect(self.set_string)
        self.assets_combo_tasks.activated.connect(self.set_string)
        self.shots_combo_tasks.activated.connect(self.set_string)
        self.assets_subfolder_check.stateChanged.connect(self.set_string)
        self.shots_subfolder_check.stateChanged.connect(self.set_string)

####################################################################################################################################  

    def set_defaults(self):
        '''
        set the defaults for the ui. if the op was on the shots tab in jeeves, it will default to shots on the save_as ui
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.set_defaults'
        #grab the current scene names project name
        mayaproject = os.path.normpath(cmds.workspace( q=True, sn=True )).split(os.path.sep)[-1]
        
        #set the current save_as tab to either assets or shots
        if mayaproject == '3d_assets':
            self.tabWidget.setCurrentIndex(0)
            mayafile = os.path.normpath(cmds.file(q=True, sn=True).replace('scenes','Scenes'))
            try:
                if mayafile:
                    x = mayafile.split('Scenes' + os.path.sep)
                    keep = x[-1]
    
                    cat = keep.split(os.path.sep)[0]
                    ass = keep.split(os.path.sep)[1]
                    
                    cat_index = self.cat.index(cat)
                    ass_index = self.ass.index(ass)
                    
                    self.assets_combo_category.setCurrentIndex(cat_index)
                    self.assets_combo_assets.setCurrentIndex(ass_index)
            except:
                pass
            
            else:
                print '\t> jmaya.pipeline.save_as.Ui_save.set_defaults > no open file'            
        else:
            self.tabWidget.setCurrentIndex(1)
            index = self.shots.index(mayaproject)
            self.shots_combo.setCurrentIndex(index)
    
    def save_as(self):
        print '\t> jmaya.pipeline.save_as.Ui_save.save_as'
        if self.save_path():
            if self.save_file():
                if jmaya.pipeline.workspace.check_workspace():
                    #close the save_as ui
                    self.reject()
            else:
                return False
        else:
            return False
    
    def save_file(self):
        '''
        checks to see if the file exists already and prompts the user to confirm an overwrite, if not, it just returns to ui
        
        if all is good, we save the current scene to the new path and rename accordingly
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.save_file'
        
        if os.path.isfile(os.path.join(self.savepath, self.filename)):
            #scene already exists - run up a confirm dialog
            text = os.path.join(self.savepath, self.filename)
            result = cmds.confirmDialog( title='Confirm Overwrite' ,  message=text, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            
            #check the result
            if result == 'Yes':
                cmds.file( rename=os.path.join(self.savepath, self.filename))
                cmds.file( save=True, type='mayaBinary' )
                return True
            else:
                return False
        else:
            cmds.file( rename=os.path.join(self.savepath, self.filename))
            cmds.file( save=True, type='mayaBinary' )
            return True

    def save_path(self):
        '''
        creates the self.savepath varibale and makes that dir if it doesnt exist
        '''
        print '\t> jmaya.pipeline.save_as.Ui_save.save_path'
        
        #get the current index of the save_as ui to determine the paths
        cur_index = self.tabWidget.currentIndex()
        
        if cur_index == 0:
            filename = self.assets_name_entry.text()
            scenepath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.assets_combo_category.currentText(), self.assets_combo_assets.currentText())

        else:
            filename = self.shots_name_entry.text()
            scenepath = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', self.shots_combo.currentText(), 'Scenes' )
        
        filename = filename.replace('\\', '/')
        
        #check the savepath
        if os.path.isdir(scenepath):
            #check for a slash
            if '/' in filename:
                filename = filename.split('/')
                #add the dir to savepath
                savepath = os.path.join(scenepath, filename[0])
                filename = filename[-1]
                #check if the savepath exists, if not create it
                if not os.path.isdir(savepath):
                    os.mkdir(savepath)
                self.savepath = savepath
            
            else:
                self.savepath = scenepath
                
            self.filename = filename
            return True
        else:
            return False

    def category_changed(self):
        '''
        triggered when the asset category combo box is changed
        '''
        self.jobdict = assets.assetlookup(jobdict = self.jobdict, category = self.assets_combo_category.currentText())
        self.assets = self.jobdict.assets
        #sorts the list alphabetically
        self.assets = sorted(self.assets, key=lambda s: s.lower())
        self.jobdict = self.jobdict.jobdict

        self.assets_combo_assets.clear()
        self.assets_combo_assets.addItems(self.assets)
        
        self.set_string()
    
    def set_string(self):
        '''
        THIS METHOD GENERATES THE SUGGESTED NAME OF THE FILE AND IS THEREFORE QUITE IMPORTANT
        
        it takes the current selection of the drop down boxes, the user initials adn other known variables
        
        by default we save to maya binary
        
        it then udates the entry box in the ui where the scene name is set
        '''
        cur_index = self.tabWidget.currentIndex()
        
        if cur_index == 0:
            if self.assets_combo_tasks.currentText() == 'none':
                text = '%s_%s_%s_v01.mb' % (self.category_short(self.assets_combo_category.currentText()), self.asset_short(self.assets_combo_assets.currentText()), core.userlist[os.getenv('USER')]['int'])
            else:
                if self.assets_subfolder_check.isChecked():
                    text = '%s/%s_%s_%s_%s_v01.mb' % (self.assets_combo_tasks.currentText(), self.category_short(self.assets_combo_category.currentText()), self.asset_short(self.assets_combo_assets.currentText()), self.task_short(self.assets_combo_tasks.currentText()), core.userlist[os.getenv('USER')]['int'])
                else:
                    text = '%s_%s_%s_%s_v01.mb' % (self.category_short(self.assets_combo_category.currentText()), self.asset_short(self.assets_combo_assets.currentText()), self.task_short(self.assets_combo_tasks.currentText()), core.userlist[os.getenv('USER')]['int'])

            #print text
            self.assets_name_entry.setText(text)
        else:
            if self.shots_combo_tasks.currentText() == 'none':
                text = '%s_%s_v01.mb' % (self.shots_combo.currentText(), core.userlist[os.getenv('USER')]['int'])
            else:
                if self.shots_subfolder_check.isChecked():    
                    text = '%s/%s_%s_%s_v01.mb' % (self.shots_combo_tasks.currentText(), self.shots_combo.currentText(), self.task_short(self.shots_combo_tasks.currentText()), core.userlist[os.getenv('USER')]['int'])
                else:
                    text = '%s_%s_%s_v01.mb' % (self.shots_combo.currentText(), self.task_short(self.shots_combo_tasks.currentText()), core.userlist[os.getenv('USER')]['int'])

            self.shots_name_entry.setText(text)

    def asset_short(self, asset):
        '''
        returns a string of the first three characters of the string passed, called to abbreviate an asset when building the
        scenename. this may be an area of contention, maybe try the first 4?
        '''
        asset = asset[:3]
        return asset

    def category_short(self, category):
        '''
        returns a dictionary of category abbreviations
        
        used to build suggested scenename
        '''
        cat_dict = {'Characters' : 'cha',
                    'Environments' : 'env',
                    'Props' : 'pro',
                    'characters' : 'cha',
                    'environments' : 'env',
                    'props' : 'pro'
                    }
        
        return cat_dict[category]
    
    def task_short(self, task):
        '''
        returns a dictionary of task abbreviations
        
        used to build suggested scenename

        '''
        task_dict = {'lighting' : 'lig',
                     'layout' : 'lay',
                     'texturing' : 'tex',
                     'rigging' : 'rig',
                     'animation' : 'ani',
                     'simulation' : 'sim',
                     'modelling' : 'mod',
                     'none' : 'none'
        }

        return task_dict[task]

#######################################################################################################################
   
def run(jobdict, job, cat,ass, shots, cur_index):
    '''
    called from jeeves_ui and is passed args such as job, the current index of jeeves tabs, assets or shots etc etc
    '''
    #print __name__    
    if __name__ == "__main__" or 'jmaya.pipeline.save_as':
        try:
            test_ui.deleteLater()
        except:
            pass
        
        # Create minimal UI object and initialise
        test_ui = Ui_Save(jobdict, job, cat, ass, shots, cur_index)
        
        # Delete the UI if errors occur to avoid causing winEvent
        # and event errors (in Maya 2014)
        try:
            #call the create method
            test_ui.create()
            test_ui.show()
        except:
            test_ui.deleteLater()
            traceback.print_exc()