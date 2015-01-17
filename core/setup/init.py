'''
- use environment variables or some other method of launch control to set the NUKE_PATH variable to jeeves/core/setup

- this module sets the sys paths to jeeves, much like the userSetup.py module for maya

- the module also walks down the jnuke folder and adds those dirs to the sys.path and nuke plugins path

- it also sets some defaults, such as frame rate and colourspace

- the next script to be called is the menu.py, which of course sets up the menu in nuke

- we also import jnuke. the __init__ of this module then import 'pipeline' and 'pipeline.tools' which inturn import
all the other modules

- toolsets dir in jeeves/jnuke needs to be symlinked to the same location as NUKE_PATH and called 'ToolSets' in
order for it to show up in nuke - ln -s jeeves/jnuke/toolsets jeeves/core/setup/ToolSets
'''

print '> importing core.setup.init.py'
import nuke, os, sys, nukescripts

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

############################################################################################################
# Set the plugin paths and sys paths and callbacks
############################################################################################################

#Get all folders in NUKE_PATH and add them to sys and plugin path

import core
import jnuke
import jnuke.pipeline

for root, dirs, files in os.walk(os.path.join(core.jeevesRoot, 'jnuke')):
    for folder in dirs:
	gizmodir = os.path.join(root, folder).replace('\\', '/')
	sys.path.append(gizmodir)
	nuke.pluginAddPath(gizmodir)

nuke.addBeforeRender(jnuke.pipeline.callbacks.createWriteDir)

############################################################################################################
# Project defaults
############################################################################################################

s = nuke.root()
name  = s.name()
nuke.knobDefault('Root.fps', '25')
nuke.knobDefault('Root.format', 'HD_1080')
nuke.knobDefault('Viewer.viewerProcess', 'sRGB')
nuke.knobDefault('Root.name', name)
