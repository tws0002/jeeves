print '> importing maya_jeeves.reference'
import maya.cmds as cmds

def make_cmd(path, lock, resolve, nmsp, merge):
    print path
    print lock
    print resolve
    print nmsp
    print merge
    ext = path.split('.')[-1]
    if ext == 'mb':
        ext = 'mayaBinary'
    elif ext == 'ma':
        ext = 'mayaAscii'
    
    if nmsp:
        print cmds.file(path, reference=True, lockReference=lock, type=ext, mergeNamespacesOnClash=merge, namespace=nmsp, options='v0')
    
    if resolve:
        print cmds.file(path, reference=True, lockReference=lock, type=ext, mergeNamespacesOnClash=merge, renamingPrefix=resolve, options='v0')