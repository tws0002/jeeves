# BatScriptRenderLight v.1.3 for Nuke
# Written by Andrey Salnikov 14.07.2009
# Modified 03.08.2009
# http://www.avsgraphica.com/

import os
import nuke
def BatScriptRenderLight():
    # Save Script
    nuke.scriptSave()
    # Variables of Script
    nukescript = nuke.value("root.name")
    start = nuke.knob("first_frame")
    end = nuke.knob("last_frame")
    cmdLineVar = "nuke5.1" + " " + "-x" + " " + '"' + nukescript + '"' + " " + start + "," + end
    path = nukescript + ".bat"
    # Cmd Message
    nuke.tprint("\nBatScriptRender\nSave Script " + nukescript)
    # Bat File Panel
    myPanel = nuke.Panel("BatScriptRenderLight - Parameters", 338)
    myPanel.addSingleLineInput("Line: ", cmdLineVar)
    myPanel.addSingleLineInput("File: ", path)
    myPanel.addButton("Quit")
    myPanel.addButton("Create")
    myPanel.addButton("Execute")
    result = myPanel.show()
    # Add Button's action & Cmd Message
    if result == 0:
        nuke.tprint("Bat File don't Create")
    elif result == 1:
        # Create Bat File
        cmdLine = myPanel.value("Line: ")
        cmdFile = myPanel.value("File: ")
        file = open(cmdFile, 'w')
        file.write(cmdLine)
        file.close()
        nuke.tprint("Create Bat File " + cmdFile)
    elif result == 2:
        # Execute Bat File
        cmdLine = myPanel.value("Line: ")
        cmdFile = myPanel.value("File: ")
        file = open(cmdFile, 'w')
        file.write(cmdLine)
        file.close()
        os.startfile(cmdFile)
        nuke.tprint("Execute Bat File " + cmdFile)