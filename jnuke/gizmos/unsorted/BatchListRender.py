# BatchListRender v.1.2 for Nuke
# Written by Andrey Salnikov 16.07.2009
# Modified 07.08.2009
# http://www.avsgraphica.com/

import os
import nuke
def BatchListRender():
    # Cmd Message
    nuke.tprint("\nBatchListRender")
    # Add script file Panel
    myPanel = nuke.Panel("Loader", 300)
    myPanel.addSingleLineInput("Output File: ", "E:\\BatchListRender.bat")
    myPanel.addSingleLineInput("Nuke Version: ", "nuke5.1")
    myPanel.addFilenameSearch("Add script 01: ", "")
    myPanel.addFilenameSearch("Add script 02: ", "")
    myPanel.addFilenameSearch("Add script 03: ", "")
    myPanel.addFilenameSearch("Add script 04: ", "")
    myPanel.addFilenameSearch("Add script 05: ", "")
    myPanel.addFilenameSearch("Add script 06: ", "")
    myPanel.addFilenameSearch("Add script 07: ", "")
    myPanel.addFilenameSearch("Add script 08: ", "")
    myPanel.addFilenameSearch("Add script 09: ", "")
    myPanel.addFilenameSearch("Add script 10: ", "")
    myPanel.addButton("Quit")
    myPanel.addButton("Create")
    myPanel.addButton("Execute")
    result = myPanel.show()
    # List
    version = myPanel.value("Nuke Version: ")
    a = version + " " + "-x "
    b = "\n"
    nk01 = myPanel.value("Add script 01: ")
    nk02 = myPanel.value("Add script 02: ")
    nk03 = myPanel.value("Add script 03: ")
    nk04 = myPanel.value("Add script 04: ")
    nk05 = myPanel.value("Add script 05: ")
    nk06 = myPanel.value("Add script 06: ")
    nk07 = myPanel.value("Add script 07: ")
    nk08 = myPanel.value("Add script 08: ")
    nk09 = myPanel.value("Add script 09: ")
    nk10 = myPanel.value("Add script 10: ")
    if nk01 == "":
       list = ""
    else:
       list = a + '"' + nk01 + '"' + b
    if nk02 == "":
       list += ""
    else:
       list += a + '"' + nk02 + '"' + b
    if nk03 == "":
       list += ""
    else:
       list += a + '"' + nk03 + '"' + b
    if nk04 == "":
       list += ""
    else:
       list += a + '"' + nk04 + '"' + b
    if nk05 == "":
       list += ""
    else:
       list += a + '"' + nk05 + '"' + b
    if nk06 == "":
       list += ""
    else:
       list += a + '"' + nk06 + '"' + b
    if nk07 == "":
       list += ""
    else:
       list += a + '"' + nk07 + '"' + b
    if nk08 == "":
       list += ""
    else:
       list += a + '"' + nk08 + '"' + b
    if nk09 == "":
       list += ""
    else:
       list += a + '"' + nk09 + '"' + b
    if nk10 == "":
       list += ""
    else:
       list += a + '"' + nk10 + '"' + b
    # Add Button's action & Cmd Message
    if result == 0:
        nuke.tprint("BatchListRender File don't Create")
    elif result == 1:        
        # Create Bat File
        filePath = myPanel.value("Output File: ")
        file = open(filePath,"w")
        file.writelines(list)
        file.close()
        nuke.tprint("Create BatchListRender File " + filePath)
    elif result == 2:
        # Execute Bat File
        filePath = myPanel.value("Output File: ")
        file = open(filePath,"w")
        file.writelines(list)
        file.close()
        os.startfile(filePath)
        nuke.tprint("Execute BatchListRender File " + filePath)