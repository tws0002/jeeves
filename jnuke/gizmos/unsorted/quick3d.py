# Copyright (c) 2009 The Foundry Visionmongers Ltd.  All Rights Reserved.
# 
# Example that shows how to hook up nodes to create a simple 3d setup
#

import nuke

def quick3d():
  ## create the three nodes
  cam = nuke.nodes.Camera2()
  render = nuke.nodes.ScanlineRender()
  scene = nuke.nodes.Scene()
  
  ## hook them up
  render.setInput(1, scene )
  render.setInput(2, cam )

  
