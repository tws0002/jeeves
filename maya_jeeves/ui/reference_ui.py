from PySide import QtCore, QtGui
import traceback, sys, os
from shiboken import wrapInstance

import maya.cmds as cmds
import maya.OpenMayaUI as omui

sys.dont_write_bytecode = True

def maya_main_window():
    '''
    Return the Maya main window widget as a Python object
    '''
    main_window_ptr = omui.MQtUtil.mainWindow()
    return wrapInstance(long(main_window_ptr), QtGui.QWidget)

class Ui_Reference(QtGui.QDialog):
    
    test_signal = QtCore.Signal()
    
    def __init__(self, path, parent=maya_main_window()):
        super(Ui_Reference, self).__init__(parent)
        self.path = path
    
    def create(self):
        '''
        Set up the UI prior to display
        '''
        self.setWindowTitle("Reference Import")
        self.setWindowFlags(QtCore.Qt.Tool)
        
        self.create_controls()
        self.create_layout()
        self.create_connections()
        
    def create_controls(self):
        self.setObjectName("Reference Import")
        self.resize(800, 350)

        self.label_ref_path = QtGui.QLabel(self.path)

        self.line_top = QtGui.QFrame()
        self.line_top.setFrameShape(QtGui.QFrame.HLine)
        self.line_top.setFrameShadow(QtGui.QFrame.Sunken)

        self.chk_lock = QtGui.QCheckBox('Lock')
        #self.chk_lock.setText("Lock")

        self.line_middle = QtGui.QFrame()
        self.line_middle.setFrameShape(QtGui.QFrame.HLine)
        self.line_middle.setFrameShadow(QtGui.QFrame.Sunken)
        self.line_middle.setObjectName("line_middle")
        
        self.label_resolve = QtGui.QLabel('Resolve all nodes with')
        self.combo_resolve_type = QtGui.QComboBox()
        self.combo_resolve_type.addItems(["the file name", "this string"])
        self.resolve_string = QtGui.QLineEdit('')
        self.resolve_string.setEnabled(False)
        
        self.line_bottom = QtGui.QFrame()
        self.line_bottom.setFrameShape(QtGui.QFrame.HLine)
        self.line_bottom.setFrameShadow(QtGui.QFrame.Sunken)
        
        self.chk_use_namespaces = QtGui.QCheckBox('Use Namespaces')

        self.list_namespaces = QtGui.QListWidget()
        self.list_namespaces.setEnabled(False)
        self.list_namespaces.setMaximumSize(QtCore.QSize(175, 16777215))
        
        self.radio_selected_namespace = QtGui.QRadioButton('Use selected namespace as parent and add new namespace (file name)')
        self.radio_selected_namespace.setEnabled(False)

        self.radio_selected_namespace_string = QtGui.QRadioButton('Use selected namespace as parent and add new namespace string')
        self.radio_selected_namespace_string.setEnabled(False)
        self.namespace_string = QtGui.QLineEdit()
        self.namespace_string.setEnabled(False)

        self.radio_merge = QtGui.QRadioButton('Merge into selected namespace and rename incoming objects that match')
        self.radio_merge.setEnabled(False)
        
        self.spacerItem1 = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)

        self.btn_import_ref = QtGui.QPushButton('Reference_Import')

    def create_layout(self):      
        layout_horizontal = QtGui.QHBoxLayout()
        layout_resolve_vertical = QtGui.QVBoxLayout()
        layout_namespace_vertical = QtGui.QVBoxLayout()
        
        layout_resolve_vertical.addWidget(self.label_resolve)
        layout_resolve_vertical.addWidget(self.combo_resolve_type)
        layout_resolve_vertical.addWidget(self.resolve_string)
        layout_resolve_vertical.addItem(self.spacerItem1)
        
        layout_namespace_vertical.addWidget(self.chk_use_namespaces)
        layout_namespace_vertical.addWidget(self.radio_selected_namespace)
        layout_namespace_vertical.addWidget(self.radio_selected_namespace_string)
        layout_namespace_vertical.addWidget(self.namespace_string)
        layout_namespace_vertical.addWidget(self.radio_merge)
        layout_namespace_vertical.addItem(self.spacerItem1)
        
        layout_horizontal.addLayout(layout_resolve_vertical)
        layout_horizontal.addWidget(self.list_namespaces)
        layout_horizontal.addLayout(layout_namespace_vertical)

        main_layout = QtGui.QVBoxLayout()
        main_layout.setContentsMargins(10, 10, 10, 10)
        main_layout.addWidget(self.label_ref_path)
        main_layout.addWidget(self.line_top)
        main_layout.addWidget(self.chk_lock)
        main_layout.addWidget(self.line_middle)
        main_layout.addLayout(layout_horizontal)
        main_layout.addWidget(self.btn_import_ref)
        main_layout.addStretch()
        self.setLayout(main_layout)

    def create_connections(self):
        self.chk_use_namespaces.clicked.connect(self.use_namespaces)
        self.combo_resolve_type.activated.connect(self.combo_change)
        
        #radios
        self.radio_selected_namespace.clicked.connect(self.radio_toggle)
        self.radio_selected_namespace_string.clicked.connect(self.radio_toggle)
        self.radio_merge.clicked.connect(self.radio_toggle)
        self.btn_import_ref.clicked.connect(self.publish)

#######################################################################################################################

    def publish(self):
        #print 'publish'
        self.lock = False
        self.resolve = False
        self.namespace = False
        self.mergeNamespacesOnClash = False
        
        if self.chk_lock.isChecked():
            self.lock = True
        
        if self.chk_use_namespaces.isChecked():
            #self.namespace = True
            #print 'name'
            if self.radio_selected_namespace.isChecked():
                print 'nm selected'
                self.namespace = self.path.split(os.path.sep)[-1].split('.')[0]
            elif self.radio_selected_namespace_string.isChecked():
                self.namespace = self.namespace_string.text()
                print 'nm string'
            else:
                print 'merge'
                if self.list_namespaces.currentRow() == ':(root)':
                    self.namespace = ':'
                else:
                    self.namespace = ':%s' % self.list_namespaces.currentRow()
                self.mergeNamespacesOnClash = True
        
        else:
            print 'resolve'
            if self.combo_resolve_type.currentText() == 'the file name':
                print'file name'
                self.resolve = self.path.split(os.path.sep)[-1].split('.')[0]
            else:
                self.resolve = self.resolve_string.text()
        
        import maya_jeeves.reference
        maya_jeeves.reference.make_cmd(self.path, self.lock, self.resolve, self.namespace, self.mergeNamespacesOnClash)
        self.reject()

    def radio_toggle(self):
        sender = self.sender()
        radio_btn = sender.text()
        
        if radio_btn == 'Use selected namespace as parent and add new namespace (file name)':
            self.namespace_string.setEnabled(False)
        elif radio_btn == 'Merge into selected namespace and rename incoming objects that match':
            self.namespace_string.setEnabled(False)
        elif radio_btn == 'Use selected namespace as parent and add new namespace string':
            self.namespace_string.setEnabled(True)
    
    def combo_change(self):
        print self.combo_resolve_type.currentText()
        if self.combo_resolve_type.currentText() == 'the file name':
            self.resolve_string.setEnabled(False)
        if self.combo_resolve_type.currentText() == 'this string':
            self.resolve_string.setEnabled(True)

    def use_namespaces(self):
        if self.chk_use_namespaces.isChecked():
            self.list_namespaces.setEnabled(True)
            self.radio_selected_namespace.setEnabled(True)
            self.radio_selected_namespace.toggle()
            self.radio_merge.setEnabled(True)
            self.radio_selected_namespace_string.setEnabled(True)
            self.list_namespaces.clear()
            self.list_namespaces.addItems(self.find_namespaces())
            self.list_namespaces.setCurrentRow(0)
            
            self.resolve_string.setEnabled(False)
            self.combo_resolve_type.setEnabled(False)
        else:
            self.list_namespaces.setEnabled(False)
            self.radio_selected_namespace.setEnabled(False)
            self.radio_merge.setEnabled(False)
            self.radio_selected_namespace_string.setEnabled(False)
            self.namespace_string.setEnabled(False)
            
            self.combo_change()
            if self.combo_resolve_type.currentText() == 'this string':
                self.resolve_string.setEnabled(True)
            self.combo_resolve_type.setEnabled(True)
    
    def find_namespaces(self):
        all_namespaces = cmds.namespaceInfo( lon=True )
        all_namespaces.insert(0, ':(root)')
        all_namespaces.remove('shared')
        all_namespaces.remove('UI')

        return all_namespaces
   
def run(path):
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
        test_ui = Ui_Reference(path)
        
        # Delete the UI if errors occur to avoid causing winEvent
        # and event errors (in Maya 2014)
        try:
            test_ui.create()
            test_ui.show()
        except:
            test_ui.deleteLater()
            traceback.print_exc()