'''

- this is called from nuke on startup, after the init.py

- the init.py adds all relevant paths to the the nuke.pluginPath(), from the menu.py, we loop through them and add
all gizmos to a dictionary and then add them to the custom gizmos menu

- we also add the three main tools, deadline, write node and the jeeves ui

'''

import nuke, os, re, nukescripts
nuke.tprint('> importing core.setup.menu.py')

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
jeevesMenu = nukeMenu.addMenu('Jeeves')
jeevesMenu.addCommand('Launch Jeeves', "import core.ui.jeeves_ui", "+R" )
jeevesMenu.addSeparator()
jeevesMenu.addCommand("Deadline", jnuke.pipeline.tools.deadline.run, "")
jeevesMenu.addSeparator()
jeevesMenu.addCommand( 'Linear_Write', jnuke.pipeline.tools.lin_write.run)
jeevesMenu.addCommand( 'sRGB_Write', jnuke.pipeline.tools.srgb_write.run)
jeevesMenu.addCommand( 'RAW_Write', jnuke.pipeline.tools.raw_write.run)
jeevesMenu.addSeparator()
pluginsMenu = jeevesMenu.addMenu('Gizmos')

#Add menus and scripts from nukeDict

for every in nukeDict:
    subMenus = pluginsMenu.addMenu(every)
    for each in nukeDict[every]:
        cmd = each[0]
        subMenus.addCommand(cmd, 'nuke.createNode' + '("' + cmd + '")')