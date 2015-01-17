'''
uses the playblast utility to render a single frame from the current maya viewport

is pssed the thumbnail path as an arg
'''

print '> importing jmaya.pipeline.thumbnail'

import os, core
import maya.cmds as cmds


def run(job, shot, thumbpath):
    #store the current imageFormat global
    x = cmds.getAttr("defaultRenderGlobals.imageFormat")
    #get the current frame
    cur_frame = int(cmds.currentTime(q=True))
    #set the imageFormat to jpg (8)
    cmds.setAttr("defaultRenderGlobals.imageFormat", 8)
    #playblast thes single image, turn window ornaments off and resize for jeeves ui 
    cmds.playblast( frame=cur_frame, format="image", orn=False, v=False, cf = thumbpath, fo = True, p = 100, wh = [256, 144])
    #set the original imageFormatback
    cmds.setAttr("defaultRenderGlobals.imageFormat", x)
