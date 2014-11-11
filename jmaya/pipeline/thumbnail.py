print '> importing jmaya.pipeline.thumbnail'

import os, core
import maya.cmds as cmds


def run(job, shot, thumbpath):
    x = cmds.getAttr("defaultRenderGlobals.imageFormat")

    cur_frame = int(cmds.currentTime(q=True))
    cmds.setAttr("defaultRenderGlobals.imageFormat", 8)
        
    cmds.playblast( frame=cur_frame, format="image", orn=False, v=False, cf = thumbpath, fo = True, p = 100, wh = [256, 144])
    cmds.setAttr("defaultRenderGlobals.imageFormat", x)