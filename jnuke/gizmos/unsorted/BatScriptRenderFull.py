# BatScriptRender v.1.6 for Nuke
# Written by Andrey Salnikov 14.07.2009
# Modified 03.08.2009
# http://www.avsgraphica.com/

import os
import nuke
def BatScriptRenderFull():
    # Save Script
    nuke.scriptSave()
    # Variables of Script
    nukescript = nuke.value("root.name")
    start = nuke.knob("first_frame")
    end = nuke.knob("last_frame")
    path = nukescript + ".bat"
    # Cmd Message
    nuke.tprint("\nBatScriptRender\nSave Script " + nukescript)
    # Bat File Panel
    swt = ['-x', '-X']
    nfr = ['""', ',2', ',5', ',10', ',15', ',20']
    myPanel = nuke.Panel("BatScriptRender - Parameters", 338)
    myPanel.addSingleLineInput("nuke version: ", "nuke5.1")
    myPanel.addEnumerationPulldown("switches: ", ' ' .join(swt))
    myPanel.addSingleLineInput("node: ", "")
    myPanel.addSingleLineInput("script: ", nukescript)
    myPanel.addSingleLineInput("start frame: ", start)
    myPanel.addSingleLineInput("end frame: ", end)
    myPanel.addEnumerationPulldown("every n frame: ", ' ' .join(nfr))
    myPanel.addSingleLineInput("file path: ", path)
    myPanel.addButton("Quit")
    myPanel.addButton("Create")
    myPanel.addButton("Execute")
    result = myPanel.show()
    # Add Button's action & Cmd Message
    if result == 0:
        nuke.tprint("Bat File don't Create")
    elif result == 1:
        # Create Bat File
        curVersion = myPanel.value("nuke version: ")
        curSwitches = myPanel.value("switches: ")
        curNode = myPanel.value("node: ")
        curScript = myPanel.value("script: ")
        curStart = myPanel.value("start frame: ")
        curEnd = myPanel.value("end frame: ")
        curEvery = myPanel.value("every n frame: ")
        cmdLine = curVersion + " " + curSwitches + " " + curNode + " " + '"' + curScript + '"' + " " + curStart + "," + curEnd + curEvery
        cmdFile = myPanel.value("file path: ")
        file = open(cmdFile, 'w')
        file.write(cmdLine)
        file.close()
        nuke.tprint("Create Bat File " + cmdFile)
    elif result == 2:
        # Execute Bat File
        curVersion = myPanel.value("nuke version: ")
        curSwitches = myPanel.value("switches: ")
        curNode = myPanel.value("node: ")
        curScript = myPanel.value("script: ")
        curStart = myPanel.value("start frame: ")
        curEnd = myPanel.value("end frame: ")
        curEvery = myPanel.value("every n frame: ")
        cmdLine = curVersion + " " + curSwitches + " " + curNode + " " + '"' + curScript + '"' + " " + curStart + "," + curEnd + curEvery
        cmdFile = myPanel.value("file path: ")
        file = open(cmdFile, 'w')
        file.write(cmdLine)
        file.close()
        os.startfile(cmdFile)
        nuke.tprint("Execute Bat File " + cmdFile)