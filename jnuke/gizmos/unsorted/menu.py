	# Copyright (c) 2009 The Foundry Visionmongers Ltd.  All Rights Reserved.
#
# Master class menu.py example
#
# This is where you put your user interface customisations pythons

import nodeOps
import quick3d
import panAndTile
import autoBackdrop
import fixPaths
import customNode
import sys
import iFilter03
import nuke

#### add menu item to existing Nuke menu

nodeMenu = nuke.menu('Nuke').findItem('Edit/Node')
nodeMenu.addCommand('Toggle Viewer Pipes', 'nodeOps.toggleViewerPipes()', 'alt+t')

#### add menu items to FXPHD toolbar 

#### add menu items to existing Nodes toolbar (Masterclass)

toolbar = nuke.menu('Nodes')
mcMenu = toolbar.addMenu('MasterClass', icon='mcIcon.png')
mcMenu.addCommand('Quick 3d', 'quick3d.quick3d()', '+d')
mcMenu.addCommand('HealBrush', 'nuke.nodes.HealBrush()')
mcMenu.addCommand('Pan And Tile', 'panAndTile.panAndTile()')
mcMenu.addCommand('Auto Backdrop', 'autoBackdrop.autoBackdrop()', 'alt+b')
mcMenu.addCommand('Fix Paths', 'fixPaths.fixPaths()')


###alternative method with icons
##toolbar = nuke.toolbar('Nodes')
###toolbar.addCommand("MyMenu/alphaEdge", "nuke.createNode(\"alphaEdge\")",  icon="alphaEdge.png")

#If it's a Python script*:





#Code:
#---------
#toolbar = nuke.toolbar('Nodes')
#toolbar.addCommand("MyMenu/Slate", "nukescripts.slate()",  icon="slate.png")
#---------
#* this will vary depending on how you have your environment setu

#unit 3D STEREO


toolbar = nuke.toolbar("Nodes")

m = toolbar.addMenu("UNIT_3D_STEREO", "unitpost_stereo.png")
m.addCommand("DepthGrade", "nuke.createNode(\"DepthGrade\")")

a='HD'
nuke.addFormat(a)
nuke.knobDefault('Root.format',a)

nuke.knobDefault("Root.fps", "25")
nuke.knobDefault("Viewer.fps", "25")


#unit


toolbar = nuke.menu('Nodes')
UnitPost = toolbar.addMenu('UnitPost', icon='unitpost.png')
#Effects
UnitPost.addCommand('Effects/H_Vignette', 'nuke.nodes.H_Vignette()')
UnitPost.addCommand('Effects/Tile', 'nuke.nodes.Tile()')
UnitPost.addCommand('Effects/Wipe', 'nuke.nodes.Wipe()')
UnitPost.addCommand('Effects/OnionSkin', 'nuke.nodes.BandPass()')
UnitPost.addCommand('Effects/BG_Passthru', 'nuke.nodes.BG_Passthru()')
UnitPost.addCommand('Effects/Glass', 'nuke.nodes.Glass()')
UnitPost.addCommand('Effects/Retro_', 'nuke.nodes.Retro_()')
UnitPost.addCommand("Effects/tile", "nuke.createNode(\"tile\")",icon="tile.png")
UnitPost.addCommand("Effects/wipe", "nuke.createNode(\"wipe\")",icon="wipe.png")
UnitPost.addCommand("Effects/streaks", "nuke.createNode(\"streaks\")",icon="streaks.xpm")
UnitPost.addCommand("Effects/vignette", "nuke.createNode(\"vignette\")",icon="vignette.xpm")
UnitPost.addCommand("Effects/loupe", "nuke.createNode(\"loupe\")",icon="loupe.png")
#3D
UnitPost.addCommand('3D/MV2Nuke', 'nuke.nodes.MV2Nuke()')
UnitPost.addCommand('3D/Particles2', 'nuke.nodes.Particles2()')
UnitPost.addCommand('3D/LP_Shadow3D', 'nuke.nodes.LP_Shadow3D()')
UnitPost.addCommand('3D/Duplicator', 'nuke.nodes.Duplicator()')
UnitPost.addCommand('3D/shadow3D2', 'nuke.nodes.shadow3D2()')
UnitPost.addCommand('3D/RenderBoth', 'nuke.nodes.RenderBoth()')
UnitPost.addCommand('3D/MT_Relight', 'nuke.nodes.MT_Relight()')
UnitPost.addCommand('3D/CopyGeo', 'nuke.nodes.CopyGeo()')
UnitPost.addCommand("3D/Duplicator", "nuke.createNode('Duplicator')")
UnitPost.addCommand("3D/imagePlane", "nuke.createNode(\"imagePlane\")",icon="imagePlane.png")
UnitPost.addCommand("3D/LM_2DMV2Nuke123", "nuke.createNode(\"LM_2DMV2Nuke\")",icon="LM_2DMV2Nuke.png")
UnitPost.addCommand("3D/Tracker3Dto2D", "nuke.createNode(\"Tracker3Dto2D\")", icon="Tracker3Dto2D.png")
UnitPost.addCommand("3D/projector", "nuke.createNode(\"projector\")",icon="projector.png")
UnitPost.addCommand("3D/readGeoPlus", "nuke.createNode(\"readGeoPlus\")",icon="readGeoPlus.png")
UnitPost.addCommand("3D/reLighting", "nuke.createNode(\"relight\")",icon="relighting.png")
UnitPost.addCommand("3D/normalLighting", "nuke.createNode(\"normalLighting\")",icon="normalLighting.png")
UnitPost.addCommand("3D/projector", "nuke.createNode(\"projector\")",icon="projector.png")
UnitPost.addCommand("3D/readGeoPlus", "nuke.createNode(\"readGeoPlus\")",icon="readGeoPlus.png")
#Keying
UnitPost.addCommand('keying/alphaEdge', 'nuke.nodes.alphaEdge()')
UnitPost.addCommand('Keying/aePremult', 'nuke.nodes.aePremult()')
UnitPost.addCommand('Keying/Linear_Keyer', 'nuke.nodes.Linear_Keyer()')
UnitPost.addCommand('Keying/KeyerCurves', 'nuke.nodes.KeyerCurves()')
#Channels
UnitPost.addCommand('Channels/ChannelRange', 'nuke.nodes.ChannelRange()')
UnitPost.addCommand('Channels/iDMattePro', 'nuke.nodes.iDMattePro()')
UnitPost.addCommand("Channels/reorder", "nuke.createNode(\"reorder\")",icon="reorder.png")
UnitPost.addCommand("Channels/common", "nuke.createNode(\"common\")",icon="common.png")
#Filter
UnitPost.addCommand('Filter/KillOutline', 'nuke.nodes.KillOutline()')
UnitPost.addCommand('Filter/SoftenSharpen', 'nuke.nodes.SoftenSharpen()')
UnitPost.addCommand('Filter/pats_erode', 'nuke.nodes.pats_erode()')
UnitPost.addCommand('Filter/iDilateErode', 'nuke.nodes.iDilateErode()')
UnitPost.addCommand('Filter/SoftErode', 'nuke.nodes.SoftErode()')
UnitPost.addCommand('Filter/HighPass', 'nuke.nodes.HighPass()')
UnitPost.addCommand('Filter/aKromatism', 'nuke.nodes.aKromatism()')
UnitPost.addCommand('Filter/Dreamy_Soft_Look', 'nuke.nodes.Dreamy_Soft_Look()')
UnitPost.addCommand('Filter/Flock', 'nuke.nodes.Flock()')
UnitPost.addCommand('Filter/FastSupress', 'nuke.nodes.FastSupress()')
UnitPost.addCommand('Filter/MrJ_Bleach', 'nuke.nodes.MrJ_Bleach()')
UnitPost.addCommand('Filter/BetterErode', 'nuke.nodes.BetterErode()')
UnitPost.addCommand("Filter/iDilateErode", "nuke.createNode(\"iDilateErode\")",icon="iDilateErode.png")
UnitPost.addCommand("Filter/zFaker", "nuke.createNode(\"zFaker\")",icon="zFaker.xpm")
UnitPost.addCommand("Filter/depthSlice", "nuke.createNode(\"depthSlice\")",icon="depthSlice.png")
#Distort
UnitPost.addCommand('Distort/WaveDistortion', 'nuke.nodes.WaveDistortion()')
UnitPost.addCommand('DistortRippleDistortion', 'nuke.nodes.RippleDistortion()')
#Transform
UnitPost.addCommand("Transform/PlanarTrack", "nuke.createNode.PlanarTrack()")
UnitPost.addCommand("Transform/CamQuake!", "nuke.createNode(\"CamQuake\")", icon="CamQuake.png")
UnitPost.addCommand("Transform/iTransform", "nuke.createNode(\"iTransform\")",icon="iTransform.png")
#Cc
UnitPost.addCommand('ColorCorrect/MatchGrade', 'nuke.nodes.MatchGrade()')
UnitPost.addCommand("ColorCorrect/chromaticAberration", "nuke.createNode(\"chromaticAberration\")",icon="chromaticAberration.png")
UnitPost.addCommand("ColorCorrect/telecine", "nuke.createNode(\"telecine\")",icon="telecine.png")
UnitPost.addCommand("ColorCorrect/invertTelecine", "nuke.createNode(\"invertTelecine\")",icon="invertTelecine.png")
#Image

UnitPost.addCommand("Image/multi Read", "nuke.load(\"multiRead\"), multiRead()",'ctrl+r' ,icon='Read.png')
UnitPost.addCommand('Image/slate', 'nuke.nodes.slate()')
UnitPost.addCommand('Image/Unit_Slate_v03', 'nuke.nodes.Unit_Slate_v03()')
UnitPost.addCommand('Image/aspectMCG', 'nuke.nodes.aspectMCG()')
UnitPost.addCommand('Image/Regrain', 'nuke.nodes.Regrain()')
UnitPost.addCommand('Image/FieldsKit', 'nuke.nodes.FieldsKit()')
UnitPost.addCommand('Image/GridOverlay', 'nuke.nodes.GridOverlay()')
UnitPost.addCommand('Image/CurveCalculator', 'nuke.nodes.CurveCalculator()')
UnitPost.addCommand('Image/Guides', 'nuke.nodes.Guides()')
UnitPost.addCommand("Image/ramper", "nuke.createNode(\"ramper\")",icon="ramper.png")
UnitPost.addCommand("Image/Imagelice", "nuke.createNode(\"slice\")",icon="slice.png")
UnitPost.addCommand('Image/FlareFactoryPlus', 'nuke.nodes.FlareFactory_Plus()')
UnitPost.addCommand("Image/turbulate", "nuke.createNode(\"turbulate\")",icon="turbulate.png")
#Import
UnitPost.addCommand("Import/importPhotoshop", "nuke.createNode(\"importPhotoshop\")",icon="importPhotoshop.png")
#Time
UnitPost.addCommand("Time/timeCode", "nuke.createNode(\"timeCode\")",icon="timeCode.png")


#mcMenu

mcMenu = toolbar.addMenu('MasterClass', icon='mcIcon.png')
mcMenu.addCommand('Quick 3d', 'quick3d.quick3d()', '+d')
mcMenu.addCommand('HealBrush', 'nuke.nodes.HealBrush()')
mcMenu.addCommand('Pan And Tile', 'panAndTile.panAndTile()')
mcMenu.addCommand('HealBrush', 'nuke.nodes.HealBrush()')
mcMenu.addCommand('Auto Backdrop', 'autoBackdrop.autoBackdrop()', 'alt+b')
mcMenu.addCommand('Fix Paths', 'fixPaths.fixPaths()')





#If it's a TCL script:



# Importers

toolbar = nuke.toolbar('Nodes')
UnitPost.addCommand("Import/AE_CameraImport", "nuke.tcl('AE_CameraImport')",  icon="AE_CameraImport.png")
UnitPost.addCommand("Import/import_boujou", "nuke.tcl('import_boujou')",  icon="import_boujou.png")
UnitPost.addCommand("Import/import_fchan_file", "nuke.tcl('import_fchan_file')",  icon="import_fchan_file.png")
UnitPost.addCommand("Import/import_synth", "nuke.tcl('import_synth')",  icon="import_synth.png")




#### custom write node example
# by default this example is disabled.  Uncomment the lines below by removing
# the '#' to enable the custom write node and the "shot setter" panel
#customNode.attachCustomCreateNode()
#customNode.promptForJob()


menubar = nuke.menu("Nuke");

#This adds a new path to look for plugins
#nuke.pluginAddPath("./user");

#loads the py function
nuke.load ("CornerPin2DPY.py")



#Modifies the "Transform" menu
m = toolbar.addMenu("Transform", "ToolbarTransform.png")
#Modifies the CornerPin2D creation
m.addCommand( "CornerPin", "nuke.createNode('CornerPin2D', 'addUserKnob {20 values} addUserKnob {26 "" l Copy_and_set} addUserKnob {22 from--->to T ''CornerPin2DPY(0)'' +STARTLINE} addUserKnob {22 to--->from T ''CornerPin2DPY(1)''} addUserKnob {26 "" l Copy_from +STARTLINE} addUserKnob {22 from T ''CornerPin2DPY(3)'' +STARTLINE} addUserKnob {22 to T ''CornerPin2DPY(4)''} addUserKnob {26 "" l Paste_to +STARTLINE} addUserKnob {22 from T ''CornerPin2DPY(5)'' +STARTLINE} addUserKnob {22 to T ''CornerPin2DPY(6)''} addUserKnob {26 "" l Invert +STARTLINE} addUserKnob {22 invert T ''CornerPin2DPY(2)'' +STARTLINE} addUserKnob {26 "" l Set_key +STARTLINE} addUserKnob {22 from T ''CornerPin2DPY(7)'' +STARTLINE} addUserKnob {22 to T ''CornerPin2DPY(8)''} addUserKnob {26 "" l Info} addUserKnob {1 in_buffer} addUserKnob {3 varCopy INVISIBLE} addUserKnob {12 buf1 INVISIBLE} addUserKnob {12 buf2 INVISIBLE} addUserKnob {12 buf3 INVISIBLE} addUserKnob {12 buf4 INVISIBLE}', True)", icon = "CornerPin.png");



import os
import re

import nuke

def nfxMenu(menu='NFX', panel='Nodes'):
	'''
	Adds NFXPlugins to the menu in panel.
	'''

	pluginList = []

	plugins = nuke.plugins(nuke.ALL | nuke.NODIR, 'N_*.py', 'N_*.so', 'N_*.dylib', 'N_*.dll')

	for i in plugins:
		(root, ext) = os.path.splitext(i)

		if root is None or len(root) == 0:
			continue

		pluginList.append(root)

	if pluginList:
		pluginList.sort()

		m = nuke.menu(panel)

		if not m:
			raise RuntimeError, 'nfxMenu() argument 2 not found'

		for n in pluginList:
			m.addCommand(menu + '/' + n[2:], 'nuke.createNode("%s")' % n)


