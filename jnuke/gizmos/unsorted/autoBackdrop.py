# Copyright (c) 2009 The Foundry Visionmongers Ltd.  All Rights Reserved.
#
# This example will automatically put a backdrop behind the selected nodes
#

import nuke, operator, random

def autoBackdrop():
 selNodes = nuke.selectedNodes()
 if not selNodes:
   return nuke.nodes.BackdropNode()

 # find min and max of positions
 positions = [(i.xpos(), i.ypos()) for i in selNodes]
 xPos = sorted(positions, key = operator.itemgetter(0))
 yPos = sorted(positions, key = operator.itemgetter(1))
 xMinMaxPos = (xPos[0][0], xPos[-1:][0][0])
 yMinMaxPos = (yPos[0][1], yPos[-1:][0][1])

 n = nuke.nodes.BackdropNode(xpos = xMinMaxPos[0]-10,
                             bdwidth = xMinMaxPos[1]-xMinMaxPos[0]+110,
                             ypos = yMinMaxPos[0]-85,
                             bdheight = yMinMaxPos[1]-yMinMaxPos[0]+160,
                             tile_color = int((random.random()*(13-11)))+11,
                             note_font_size = 42)
 n['selected'].setValue(False)

 # revert to previous selection
 [i['selected'].setValue(True) for i in selNodes]
 
 return n
