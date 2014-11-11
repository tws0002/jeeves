print '> importing jmaya.pipeline.open'
import maya.cmds as cmds
import jmaya.pipeline.workspace as workspace


def run(found_file, selected_master_pub):
    if cmds.file(q=True, modified=True):
        result = cmds.confirmDialog( title='Modified Scene', message='This scene has been modified, do you wish to save?', button=['Save', 'No', 'Cancel'], defaultButton='Yes', cancelButton='No', dismissString='No' )
        if result == 'Save':
            cmds.file(s=True)
    
    if selected_master_pub:
        cmds.confirmDialog( title='Forbidden', message='You cannot open a master or published file', button=['Close'], defaultButton='Yes', cancelButton='No', dismissString='No' )
    else:
        cmds.file(found_file, open=True, force = True)
        workspace.check_workspace()