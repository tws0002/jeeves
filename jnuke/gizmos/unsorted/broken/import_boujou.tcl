#
# Copyright (c) 2003 Digital Domain Inc.  All Rights Reserved.
#
# rewritten on Sep 9 to work better and not generate geometry

## -*- mode: tcl -*-

# Function called from the "import Boujou camera track" user knob of a Boujou Camera gizmo.



# read data from a Boujou text file:
# format is: FRAME TX TY TZ RX RY RZ VFOV
# this version will read fewer columns

proc import_boujou {} {
  global env
  global JOB
  global SHOT
  global filename
  global spheres
  global objout
  global firstchar
  global range
  global axisparent
  global pointcount
  global constantnode
    
# call a panel that asks the user for the camera txt file
if [catch {set filename [get_filename "Boujou Text File" "*.txt" ]}] {return}

# check to see if the file really exists
if [file exists $filename] {

# create the camera
		
		Camera -New {
			icon node_camera.xpm
			}
		
		# we need to get the node name
		set camnode [stack 0]

	# label the node accordingly so the user knows which track they pulled in
	knob $camnode.name "BoujouCamera"
	knob $camnode.label [basename $filename]
	  set f [open $filename r]
	  set n 0
	  set pointcount 0
	  
 #Jay's little addition - Set the rotation order to ZYX 
  knob $camnode.rot_order "ZYX"
#create a new group with user knobs we can twiddle...	  
Group -New {
	addUserKnob { 20 "" User } 
	addUserKnob { 7 tracker_size "Tracker Size" R 0.001 1 } 
  	addUserKnob { 18 tracker_color "Tracker Color" R 0 1 }	
	inputs 1
	name BoujouTrackers
	tracker_size .025
	tracker_color 1
}

#no input for this guy
push 0
Axis -New {
	name BoujouTrackParent
}

#keep the axis parent name around so we can use it later
set axisparent [stack 0]

Constant -New {
	color {{parent.tracker_color.r} {parent.tracker_color.g} {parent.tracker_color.b} 0}
}

#keep this sucker too
set constantnode [stack 0]
#create obj file
     
	  
	  while { ![eof $f] } {
	      gets $f line
	      set firstchar [string index $line 0]

		# Find Vertical and Horizontal Aperture data & apply to NUKE camera.
		      if { ([lindex $line 0] == "#Filmback") } {
		         knob $camnode.vaperture [lindex $line 3]
		         knob $camnode.haperture [lindex $line 2]
		      }
		
		# Find translation data and apply to NUKE camera.
		      if { ([llength $line] == 13) && ($firstchar != "#") } {
		         incr n
		         set fr $n
		         setkey $camnode.translate.x $fr [lindex $line 9]
		         setkey $camnode.translate.y $fr [lindex $line 10]
		         setkey $camnode.translate.z $fr [lindex $line 11]
		         setkey $camnode.focal $fr [lindex $line 12]

		# Find rotation data and convert to Euler.
		         set rot00 [lindex $line 0]
		         set rot01 [lindex $line 1]
		         set rot02 [lindex $line 2]
		         set rot10 [lindex $line 3]
		         set rot11 [lindex $line 4]
		         set rot12 [lindex $line 5]
		         set rot20 [lindex $line 6]
		         set rot21 [lindex $line 7]
		         set rot22 [lindex $line 8]
		      if { ($rot00 == 0) && ($rot10 == 0) } {
		          setkey $camnode.rotate.x $fr degrees(atan2(-$rot01,-$rot02))
		          setkey $camnode.rotate.y $fr 0.5*pi
		          setkey $camnode.rotate.z $fr 0
		      } else {
		          setkey $camnode.rotate.x $fr degrees(atan2($rot21,-$rot22))
		          setkey $camnode.rotate.y $fr degrees(-asin($rot20))
		          setkey $camnode.rotate.z $fr degrees(atan2($rot10,$rot00))
		      }
		}
         
     
#write points to obj file

                		
		if { ([llength $line] == 3) && ($firstchar != "#") } {
			incr pointcount
			set tx [lindex $line 0] 
			set ty [lindex $line 1] 
			set tz [lindex $line 2]
			set my "v $tx $ty $tz"
			#puts $objout $my
			push 0
			SphereObj -New " 
			 translate {$tx $ty $tz}
			 rows 2
			 columns 2
			 uniform_scale {{.1}}
			"
			# set inputs to the axis and colors
			input [stack 0] 0 $axisparent
			input [stack 0] 1 $constantnode
	
			}
	}
		
}
		
		
#close $objout

#Extend script frame range if not already longer than 1.
set range [knob root.last_frame]
if { $range < $n } {
	knob root.last_frame $n
}

# create a new input for the camera
Input -New {}
#create scene
Scene "
  inputs [expr $pointcount+1]
  name Scene1
  selected true
  icon node_scene.xpm
"
set scenenode [stack 0]

# go thru all the points and hook in the tracking markers
for {set x 1} {$x<=$pointcount} {incr x} {
 input $scenenode $x SphereObj$x	
}

Output -New {
    name Output1
  }

end_group

#set the input of the group to the camera
input BoujouTrackers 0 $camnode

push 0
ScanlineRender {
  inputs 3
  name ScanlineRender1
  selected true
  tile_color 0x9c000000
}

message "Loaded $n frames and $pointcount points."



}


