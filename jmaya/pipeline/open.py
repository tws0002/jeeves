'''
module consisting of one function. we check to see if the current scene has been modified and prompts the user to save if it
is modified

we then save open the selected file that is passed to the module from the main jeeves ui and check that the current workspace
is correct by calling the jmaya.pipeline.workspace module
'''
print '> importing jmaya.pipeline.open'
import maya.cmds as cmds
import jmaya.pipeline.workspace as workspace


def run(found_file, selected_master_pub):
    if cmds.file(q=True, modified=True):
        result = cmds.confirmDialog( title='Modified Scene', message='This scene has been modified, do you wish to save?', button=['Save', 'No', 'Cancel'], defaultButton='Yes', cancelButton='No', dismissString='No' )
        if result == 'Save':
            cmds.file(s=True)
        elif result == 'Cancel':
            return
    
    if selected_master_pub:
        cmds.confirmDialog( title='Forbidden', message='You cannot open a master or published file', button=['Close'], defaultButton='Yes', cancelButton='No', dismissString='No' )
    else:
        cmds.file(found_file, open=True, force = True)
        workspace.check_workspace()