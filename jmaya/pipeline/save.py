'''
is called from the the main jeeves_ui module and is passed variables relating to the scene, job, shot etc

if the scene has already been saved, we simply do a save. if the scene has not been saved yet, we run up the save_as
module, so that the user can specifcy where it should be saved
'''

print '> importing jmaya.pipeline.save'
import maya.cmds as cmds

def save(jobdict, job, asset_categories, assets, shots, cur_index):
    print '> importing jmaya.pipeline.save.save'
    
    #returns false if the scene has not been saved yet
    filename = cmds.file(q=True, sn=True)
    
    if not filename:
        import save_as
        filename = save_as.run(jobdict, job, asset_categories, assets, shots, cur_index)
        return filename

    else:
        cmds.file(s=True)
        return filename