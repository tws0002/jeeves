print 'userSetup.py'
import sys
import maya.utils as utils
import maya.cmds as cmds

cmds.loadPlugin( 'AbcExport' )

dev = True
home = True

if dev:
    if sys.platform == 'win32':
        sys.path.append('//resources/resources/vfx/pipeline/jeeves_dev')
    
    elif sys.platform == 'linux2':
        sys.path.append('/mnt/resources/vfx/pipeline/jeeves_dev')
    
    elif sys.platform == 'darwin':
        
        if not home:
            sys.path.append('/Volumes/resources/vfx/pipeline/jeeves_dev')
        
        else:
            sys.path.append('/Users/elliott/Google Drive/pipeline/jeeves_dev')
else:
    if sys.platform == 'win32':
        sys.path.append('//resources/resources/vfx/pipeline/jeeves')
    elif sys.platform == 'linux2':
        sys.path.append('/mnt/resources/vfx/pipeline/jeeves')
    elif sys.platform == 'darwin':
        sys.path.append('/Volumes/resources/vfx/pipeline/jeeves')   

def createScriptsMenu():
    if cmds.menu('Jeeves', exists=1):
        cmds.deleteUI('Jeeves')

    scriptsMenu = cmds.menu('Jeeves', p='MayaWindow', to=1, aob=1, l='Jeeves')
    cmds.menuItem(p=scriptsMenu, l="Launch Jeeves", c='import maya_jeeves.ui.jeeves_ui;reload(maya_jeeves.ui.jeeves_ui);maya_jeeves.ui.jeeves_ui.runMaya()')

utils.executeDeferred('createScriptsMenu()')
print 'finished userSetup.py'