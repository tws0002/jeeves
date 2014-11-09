from PySide import QtCore, QtGui
import traceback, sys, os
from shiboken import wrapInstance

import maya.cmds as cmds
import maya.OpenMayaUI as omui

import core
import core.assets as assets
import maya_jeeves.workspace

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
        
        self.tasks = ['none', 'layout', 'modelling', 'texturing', 'rigging', 'animation', 'simulation', 'lighting']
        
        self.create_controls()
        self.create_layout()
        self.create_connections()
        
        self.set_string()
        
    def create_controls(self):
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

        #self.tabWidget.setCurrentIndex(self.cur_index)
        self.set_defaults()

    def create_layout(self):
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
        self.setLayout(main_layout)

    def create_connections(self):
        self.assets_combo_category.activated.connect(self.category_changed)
        self.assets_combo_assets.activated.connect(self.asset_changed)
        self.shots_combo.activated.connect(self.change_shot)
        #self.assets_name_entry.textChanged.connect(self.filename_change)
        #self.shots_name_entry.textChanged.connect(self.filename_change)
        self.btn_saveas.clicked.connect(self.save_as)
        self.tabWidget.currentChanged.connect(self.set_string)
        self.assets_combo_tasks.activated.connect(self.set_string)
        self.shots_combo_tasks.activated.connect(self.set_string)
        self.assets_subfolder_check.stateChanged.connect(self.set_string)
        self.shots_subfolder_check.stateChanged.connect(self.set_string)

####################################################################################################################################  

    def set_defaults(self):
        mayaproject = os.path.normpath(cmds.workspace( q=True, sn=True )).split(os.path.sep)[-1]
        print mayaproject
        
        if mayaproject == '3d_assets':
            self.tabWidget.setCurrentIndex(0)
            mayafile = os.path.normpath(cmds.file(q=True, sn=True).replace('scenes','Scenes'))
            #mayafile = os.path.normpath(mayafile)
            
            if mayafile:
                x = mayafile.split('Scenes' + os.path.sep)
                keep = x[-1]

                cat = keep.split(os.path.sep)[0]
                ass = keep.split(os.path.sep)[1]
                
                cat_index = self.cat.index(cat)
                ass_index = self.ass.index(ass)
                
                self.assets_combo_category.setCurrentIndex(cat_index)
                self.assets_combo_assets.setCurrentIndex(ass_index)
            
            else:
                pass
                print 'no open file'
            
        else:
            self.tabWidget.setCurrentIndex(1)
            index = self.shots.index(mayaproject)
            self.shots_combo.setCurrentIndex(index)
            
    def change_shot(self):
        print 'change shot'
        self.set_string()
    
    def filename_change(self):
        print 'filename change'
    
    def save_as(self):
        print 'save as'
        if self.save_path():
            if self.save_file():
                if maya_jeeves.workspace.check_workspace():              
                    self.reject()
            else:
                return False
        else:
            return False

        #save file
        #need to check workspace
        #refresh main gui?
    
    def save_file(self):
        print self.savepath
        print self.filename
        
        if os.path.isfile(os.path.join(self.savepath, self.filename)):
            print 'file already exists'
            text = os.path.join(self.savepath, self.filename)
            
            result = cmds.confirmDialog( title='Confirm Overwrite' ,  message=text, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            
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
        print 'cat changed'
        self.jobdict = assets.assetlookup(jobdict = self.jobdict, category = self.assets_combo_category.currentText())
        self.assets = self.jobdict.assets
        self.assets = sorted(self.assets, key=lambda s: s.lower())
        self.jobdict = self.jobdict.jobdict

        self.assets_combo_assets.clear()
        self.assets_combo_assets.addItems(self.assets)
        
        self.set_string()
    
    def set_string(self):
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
        asset = asset[:3]
        return asset

    def category_short(self, category):       
        cat_dict = {'Characters' : 'cha',
                    'Environments' : 'env',
                    'Props' : 'pro',
                    'characters' : 'cha',
                    'environments' : 'env',
                    'props' : 'pro'
                    }
        
        return cat_dict[category]
    
    def task_short(self, task):
        
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

    def asset_changed(self):
        print 'asset changed'
        self.set_string()

#######################################################################################################################
   
def run(jobdict, job, cat,ass, shots, cur_index):
    #print __name__

    if __name__ == "__main__" or 'maya_jeeves.publish_ui':
        #print 
        
        # Development workaround for PySide winEvent error (in Maya 2014)
        # Make sure the UI is deleted before recreating
        try:
            test_ui.deleteLater()
        except:
            pass
        
        # Create minimal UI object
        test_ui = Ui_Save(jobdict, job, cat, ass, shots, cur_index)
        
        # Delete the UI if errors occur to avoid causing winEvent
        # and event errors (in Maya 2014)
        try:
            test_ui.create()
            test_ui.show()
        except:
            test_ui.deleteLater()
            traceback.print_exc()