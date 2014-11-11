import nuke, os, re, nukescripts
import jnuke.pipeline.deadline
nuke.tprint('> importing core.setup.menupy')

############################################################################################################
# Jeeves menu dictionary                                                                                          
############################################################################################################

nukeDict = {}
suffix = ('gizmo', 'py', 'tcl', 'dylib')

for filepath in nuke.pluginPath():
    menuName=os.path.split(filepath)[1]
    if menuName.startswith('menus.'):
        if not menuName == 'menus.ICONS':
            if not len(os.listdir(filepath)) == 0:
                menuName = menuName.split('menus.')[-1]
                menuName = menuName.lower()
                nukeDict[menuName] = []
                for scripts in os.listdir(filepath):
                    if not scripts.startswith('.'):
                        if scripts.endswith(suffix):
                            nukeDict[menuName].append((os.path.splitext(scripts)[0], scripts))
            
############################################################################################################
# Add Menus                                                                                             
############################################################################################################

nukeMenu = nuke.menu('Nuke')
jeevesMenu = nukeMenu.addMenu('JEEVES')
jeevesMenu.addCommand('Launch Jeeves', "import core.ui.jeeves_ui", "+R", icon='Yellow.png' )

jeevesMenu.addCommand("Deadline", jnuke.pipeline.deadline.main, "", icon='deadline.png')
#jeevesMenu.addSeparator()
#jeevesMenu.addCommand( 'Output_Write', jeevesNukeModules.outputWrite, icon='Blue.png')
#jeevesMenu.addCommand('Find Node', 'jeevesNukeModules.findnode()', icon='Purple.png')
#jeevesMenu.addSeparator()
pluginsMenu = jeevesMenu.addMenu('Gizmos', icon='unit.png')
#pyMenu = pluginsMenu.addMenu('PYTHON', icon='unit.png')
#pyMenu.addCommand('reloadReads', 'jeevesNukeModules.refreshReads()')
#pyMenu.addCommand('printReads', 'jeevesNukeModules.printReads()')
#pyMenu.addCommand('swapoutz', 'jeevesNukeModules.swapoutz()')
#pyMenu.addCommand('findMissingReads', 'jeevesNukeModules.missingFrames()')
#pyMenu.addCommand('multiNodeTweak', 'jeevesNukeModules.multiNodeTweaker()')
#pyMenu.addCommand('shuffleRGB', 'jeevesNukeModules.shuffleRGB()')
#pyMenu.addCommand('c4d_autocomp', 'import C4dAutoComp')
#jeevesMenu.addSeparator()
#import kiss
#pyMenu.addCommand('toggle kiss', 'kiss.toggleKiss()', 'u', icon='kiss.png')


#Add menus and scripts from nukeDict

for every in nukeDict:
    subMenus = pluginsMenu.addMenu(every, icon="unit.png")
    for each in nukeDict[every]:
        cmd = each[0]
        subMenus.addCommand(cmd, 'nuke.createNode' + '("' + cmd + '")')
