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
########################################################################################

proc autocrop {} {
	global extra_plugs

#keep original node information...we'll need this
set originalnodes [selected_nodes]

#deselect everything
foreach n [nodes] {knob $n.selected false}

foreach cropmenode $originalnodes {

    knob $cropmenode.selected true

    CurveTool -New {
    operation "Auto Crop"
     ROI {0 0 input.width input.height}
    Layer rgba
    name "Processing Crop..."
    selected true
    }

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
    set cropnode [knob [stack 0].name]
    
    #put the new data from the autocrop into the new crop
    knob $cropnode.box [knob $autocropper.autocropdata]
    
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

