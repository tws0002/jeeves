print '> importing core.setup.init.py'
import nuke, os, sys, nukescripts

#only edit the dev at home
dev = True
home = True

#DEVELOPMENT
if dev:
    if home:
        sys.path.append('/Users/elliott/Google Drive/pipeline/jeeves_dev')
    else:
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

import core

############################################################################################################
# Set the plugin paths and sys paths                                                                     
############################################################################################################

#Get all folders in NUKE_PATH and add them to sys and plugin path

for root, dirs, files in os.walk(os.path.join(core.jeevesRoot, 'jnuke', 'gizmos')):
    for folder in dirs:
	gizmodir = os.path.join(root, folder).replace('\\', '/')
	if folder.startswith('nuke.') or folder.startswith('menus.'):
	    nuke.pluginAddPath(gizmodir)
	    sys.path.append(gizmodir)

############################################################################################################
# Callbacks                                                                                            
############################################################################################################

#nuke.addFilenameFilter(jeevesNukeModules.filenameFix)
#nuke.addAutoSaveFilter( jeevesNukeModules.onAutoSave )
#nuke.addAutoSaveRestoreFilter( jeevesNukeModules.onAutoSaveRestore )
#nuke.addAutoSaveDeleteFilter( jeevesNukeModules.onAutoSaveDelete )
#nuke.addBeforeRender(jeevesNukeModules.createWriteDir)
#nuke.addKnobChanged(jeevesNukeModules.findChangedKnob, nodeClass='Write')

############################################################################################################
# Project defaults                                                                                       
############################################################################################################

s = nuke.root()
name  = s.name()
#s.knob('project_directory').setValue(os.path.join(jeevesStatic.jobsRoot, os.getenv('JOB'), 'vfx', 'nuke', os.getenv('SHOT')))
nuke.knobDefault('Root.fps', '25')
nuke.knobDefault('Root.format', 'HD')
nuke.knobDefault('Viewer.viewerProcess', 'sRGB')
nuke.knobDefault('Root.name', name)
#nuke.knobDefault('Root.project_directory', '')
#nuke.knobDefault('Read.cached', '1')
#nuke.knobDefault('Read.postage_stamp', 'False')
