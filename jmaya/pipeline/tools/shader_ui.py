from PySide import QtCore, QtGui
import traceback, sys, os
from shiboken import wrapInstance

import maya.OpenMayaUI as omui
import maya.cmds as cmds
import core
import core.assets as assets 

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
    
    def __init__(self, jobdict, job, cat,ass, shots, cur_index, parent=maya_main_window()):
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
        self.setWindowTitle("Select Shader")
        self.setWindowFlags(QtCore.Qt.Tool)
        
        self.tasks = ['none', 'lay', 'mod', 'tex', 'rig', 'ani', 'sim', 'lig']
        self.get_namespaces()
        self.create_controls()
        self.create_layout()
        self.create_connections()
        
        self.look_pkl()
        
    def create_controls(self):
        self.setObjectName("Dialog")
        self.resize(600, 250)
        
        self.tabWidget = QtGui.QTabWidget()
       
        self.Assets = QtGui.QWidget()
        self.assets_vertical_widget = QtGui.QWidget(self.Assets)
        self.assets_vertical_widget.setGeometry(QtCore.QRect(10, 20, 550, 150))
        self.assets_combo_category = QtGui.QComboBox()
        self.assets_combo_category.addItems(self.cat)
        self.assets_combo_assets = QtGui.QComboBox()
        self.assets_combo_assets.addItems(self.ass)
        
        self.assets_geo_nm_label = QtGui.QLabel('Geo Namespaces')
        self.assets_shader_nm_label = QtGui.QLabel('Shader Namespaces')
        
        self.assets_combo_geo_nm = QtGui.QComboBox()
        self.assets_combo_geo_nm.addItems(self.namespaces)
        
        self.assets_combo_shader_nm = QtGui.QComboBox()
        self.assets_combo_shader_nm.addItems(self.namespaces)

        self.assets_spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.assets_label = QtGui.QLabel()
        self.assets_label.setText("")
        #self.assets_name_entry = QtGui.QLineEdit()
        self.tabWidget.addTab(self.Assets, "Assets")
        
        self.Shots = QtGui.QWidget()
        self.shots_vertical_widget = QtGui.QWidget(self.Shots)
        self.shots_vertical_widget.setGeometry(QtCore.QRect(10, 20, 550, 150))
        self.shots_combo = QtGui.QComboBox()
        self.shots_combo.addItems(self.shots)

        self.shots_geo_nm_label = QtGui.QLabel('Geo Namespaces')
        self.shots_shader_nm_label = QtGui.QLabel('Shader Namespaces')
        
        self.shots_combo_geo_nm = QtGui.QComboBox()
        self.shots_combo_geo_nm.addItems(self.namespaces)
        
        self.shots_combo_shader_nm = QtGui.QComboBox()
        self.shots_combo_shader_nm.addItems(self.namespaces)

        self.shots_spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.shots_label = QtGui.QLabel()
        self.shots_label.setText("")
        #self.shots_name_entry = QtGui.QLineEdit()
        self.tabWidget.addTab(self.Shots, "Shots")

        self.btn_saveas = QtGui.QPushButton()
        self.btn_saveas.setText('Assign Shaders')

        self.tabWidget.setCurrentIndex(self.cur_index)

    def create_layout(self):
        assets_verticalLayout = QtGui.QVBoxLayout(self.assets_vertical_widget)
        assets_verticalLayout.addWidget(self.assets_combo_category)
        assets_verticalLayout.addWidget(self.assets_combo_assets)
        
        assets_geo_layout = QtGui.QVBoxLayout()
        assets_shader_layout = QtGui.QVBoxLayout()
        assets_geo_layout.addWidget(self.assets_geo_nm_label)
        assets_geo_layout.addWidget(self.assets_combo_geo_nm)
        assets_shader_layout.addWidget(self.assets_shader_nm_label)
        assets_shader_layout.addWidget(self.assets_combo_shader_nm)
        assets_nmLayout = QtGui.QHBoxLayout()
        assets_nmLayout.addLayout(assets_geo_layout)
        assets_nmLayout.addLayout(assets_shader_layout)
        assets_verticalLayout.addLayout(assets_nmLayout)
        assets_verticalLayout.addItem(self.assets_spacerItem)
        assets_verticalLayout.addWidget(self.assets_label)

        shots_verticalLayout = QtGui.QVBoxLayout(self.shots_vertical_widget)
        shots_verticalLayout.addWidget(self.shots_combo)
        shots_geo_layout = QtGui.QVBoxLayout()
        shots_shader_layout = QtGui.QVBoxLayout()
        shots_geo_layout.addWidget(self.shots_geo_nm_label)
        shots_geo_layout.addWidget(self.shots_combo_geo_nm)
        shots_shader_layout.addWidget(self.shots_shader_nm_label)
        shots_shader_layout.addWidget(self.shots_combo_shader_nm)
        shots_nmLayout = QtGui.QHBoxLayout()
        shots_nmLayout.addLayout(shots_geo_layout)
        shots_nmLayout.addLayout(shots_shader_layout)
        shots_verticalLayout.addLayout(shots_nmLayout)
  
        shots_verticalLayout.addItem(self.shots_spacerItem)
        shots_verticalLayout.addWidget(self.shots_label)
        
        main_layout = QtGui.QVBoxLayout()
        main_layout.setContentsMargins(6, 6, 6, 6)
        
        main_layout.addWidget(self.tabWidget)
        main_layout.addWidget(self.btn_saveas)
        self.setLayout(main_layout)

    def create_connections(self):
        self.assets_combo_category.activated.connect(self.category_changed)
        self.assets_combo_assets.activated.connect(self.asset_changed)
        self.shots_combo.activated.connect(self.change_shot)
        self.btn_saveas.clicked.connect(self.assign)
        self.tabWidget.currentChanged.connect(self.look_pkl)


####################################################################################################################################  
    
    def get_namespaces(self):
        #self.namespaces = []
        self.namespaces = cmds.namespaceInfo( lon=True )
        #self.namespaces.insert(0, ':(root)')
        self.namespaces.remove('shared')
        self.namespaces.remove('UI')

    def assign(self):
        print 'assign'
        if self.pklpath:
            cur_index = self.tabWidget.currentIndex()
            
            if cur_index == 0:
                geo_nm = self.assets_combo_geo_nm.currentText()
                shad_nm = self.assets_combo_shader_nm.currentText() 
            elif cur_index == 1:
                geo_nm = self.shots_combo_geo_nm.currentText()
                shad_nm = self.shots_combo_shader_nm.currentText() 
            else:
                return

            import jmaya.pipeline.tools.shaders#;reload(maya_jeeves.tools.shaders)
            jmaya.pipeline.tools.shaders.shader_assign(self.pklpath, geo_nm, shad_nm)
            self.reject()
        
    def change_shot(self):
        print 'change shot'
        self.look_pkl()

    def category_changed(self):
        print 'cat changed'
        self.jobdict = assets.assetlookup(jobdict = self.jobdict, category = self.assets_combo_category.currentText())
        self.assets = self.jobdict.assets
        self.assets = sorted(self.assets, key=lambda s: s.lower())
        self.jobdict = self.jobdict.jobdict
        
        self.assets_combo_assets.clear()
        self.assets_combo_assets.addItems(self.assets)
        
        self.look_pkl()

    def asset_changed(self):
        print 'asset changed'
        self.look_pkl()
    
    def look_pkl(self):
        cur_index = self.tabWidget.currentIndex()

        x = os.path.join(self.job, 'vfx', '3d')

        if cur_index == 0:
            path = os.path.join(x, '3d_assets', 'Scenes', self.assets_combo_category.currentText(), self.assets_combo_assets.currentText(), 'shaders.pkl')
            if self.check(path):    
                self.assets_label.setText(path)
            else:
                self.assets_label.setText('No pickle file found')
        elif cur_index == 1:
            path = os.path.join(x, self.shots_combo.currentText(), 'Scenes', 'shaders.pkl')
            if self.check(path):
                self.shots_label.setText(path)
            else:
                self.shots_label.setText('No pickle file found')
        
        print path

    def check(self, path):
        if os.path.isfile(os.path.join(core.jobsRoot, path)):
            self.pklpath = os.path.join(core.jobsRoot, path)
            return True
        else:
            self.pklpath = None
            return False

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
        test_ui = Ui_Save(jobdict, job, cat,ass, shots, cur_index)
        
        # Delete the UI if errors occur to avoid causing winEvent
        # and event errors (in Maya 2014)
        try:
            test_ui.create()
            test_ui.show()
        except:
            test_ui.deleteLater()
            traceback.print_exc()