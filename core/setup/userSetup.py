'''
- copy or symlink this file to either ~/maya/scripts/userSetup.py or ~/maya/2015-x64/scripts/userSetup.py

- this userSetup.py sets the sys.path to jeeves, dev or stable release and creates a jeeves menu within maya
that the gui can be launched from.

- it's also where i autoload some plugins such as alembic.

- the command bound to the menu item, also reloads the 'core.ui.jeeves_ui' module so that changes can be made on the fly
without the user having to relaunch maya.

- subsequent functions / modules that the ui calls will not be reloaded automatically, but can  be done so from the
script editor

'''

print 'userSetup.py -sv'
import sys
import maya.utils as utils
import maya.cmds as cmds

cmds.loadPlugin( 'AbcExport' )

dev = False

#DEVELOPMENT
if dev:
    if sys.platform == 'win32':
	sys.path.append('//resources/resources/vfx/pipeline/jeeves_dev')

    elif sys.platform == 'linux2':
	sys.path.append('/mnt/resources/vfx/pipeline/jeeves_dev')

    elif sys.platform == 'darwin':
	sys.path.append('/Volumes/resources/vfx/pipeline/jeeves_dev')

#STABLE
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
    cmds.menuItem(p=scriptsMenu, l="Launch Jeeves", c='import core.ui.jeeves_ui;reload(core.ui.jeeves_ui)')

utils.executeDeferred('createScriptsMenu()')
print 'finished userSetup.py'