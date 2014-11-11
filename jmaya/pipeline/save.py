print '> importing jmaya.pipeline.save'
import maya.cmds as cmds

def save():
    print '> importing jmaya.pipeline.save.save'
    
    filename = cmds.file(q=True, sn=True)
    
    if not filename:
        filename = self.save_as()
        return filename

    else:
        cmds.file(s=True)
        return filename