#
# Copyright (c) 2003 Digital Domain Inc.  All Rights Reserved.
#

########################################################################################
#
# autocrop.tcl
# Feb 19 2003 - 
# v 1.0 
# works with henrich CurveTool to create autocrop information
# important is that the user re-do the autocrop if elements are re-rendered 
#
# May 03 03 - added node indicator and -New for panel code
# May 04 03 - Added warning icon to node so user can see that this node could be trouble
# May 10 03 - Node now places itself in the stream.
# Jun 23 03 - added ROI support for full frame eval
# Sep 15 03 - support cropping many nodes at once (henrich@d2.com)
# Apr 26 04 - bugfix for 4.2
#
# Apr 10 07 - modified by Frank Rueter
#		adding panel to select channel
#		adding user knob to tweak resulting bbox
########################################################################################

proc autocrop2 {} {
	global extra_plugs
		
#keep original node information...we'll need this
set originalnodes [selected_nodes]


#adding channel selector
	set channelList {}
	foreach curNode [selected_nodes] {
		set channelList [concat $channelList [channels $curNode]]
		}
	set cleanList [lsort -dictionary -unique $channelList]
	if [catch {panel "Auto Crop" "{\"Analyze channel\" srcChannel e [list $cleanList]}"} errorMsg] {puts $errorMsg;return}
	


#deselect everything
foreach n [nodes] {knob $n.selected false}

foreach cropmenode $originalnodes {

    knob $cropmenode.selected true

    CurveTool -New "
    operation \"Auto Crop\"
     ROI {0 0 input.width input.height}
    channels $srcChannel
    name \"Processing Crop...\"
    selected true
    "

    #let's get the node info for the curvewriter (we'll need this too)
    set autocropper [stack 0]

    #execute the curvewriter thru all the frames
    execute $autocropper [knob root.first_frame],[knob root.last_frame]
    
    #deselect everything
    foreach n [nodes] {knob $n.selected false}
    
    #select the curvewriter
    knob $autocropper.selected true
    # node_delete
    
    #add crop node
    Crop -New {label AutoCrop}
    
    #get new name of cropnode
    set cropnode [stack 0]
#add user knobs to tweak the bounding box
	in $cropnode {
	addUserKnob {20 "" User}
	addUserKnob {3 tweakBbox tweakBbox}
	}
    
    #put the new data from the autocrop into the new crop
    knob $cropnode.box [knob $autocropper.autocropdata]

#link user knob to curve
animation $cropnode.box.x expression curve-tweakBbox
animation $cropnode.box.y expression curve-tweakBbox
animation $cropnode.box.r expression curve+tweakBbox
animation $cropnode.box.t expression curve+tweakBbox
knob $cropnode.tweakBbox 5

    #turn on the animated flag
    knob $cropnode.indicators 1
    knob $cropnode.icon warning.xpm
    
    #deselect everything
    foreach n [nodes] {knob $n.selected false}
    
    #select the curvewriter and delete that mother
    knob $autocropper.selected true
    
    #delete the autocropper to make it all clean
    node_delete 
    
    #deselect everything
    foreach n [nodes] {knob $n.selected false}
    
    #select the new crop
    knob $cropnode.selected true
    
    #place it in a nice spot
    eval [concat autoplace [selected_nodes]]
    
    #De-Select it
    knob $cropnode.selected false
    }

}

