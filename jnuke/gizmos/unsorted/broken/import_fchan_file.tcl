## -*- mode: tcl -*-

# Read fchan camera file

proc import_fchan_file { {filename ""} } {

  global env
#  global JOB
  global SHOT
  
set JOB //Isilon/ifs/SFX_SERVER/
set SHOT FILM

  if {$filename == ""} {

#Delete Me
set CAMERAPATH "$JOB/"
#Delete Me

    if [catch {set filename [get_filename "IMPORT: 3Ds Max Fchan File" "*.fchan" $CAMERAPATH ]}] {return 1}
  }

	set cameraNote [file tail $filename]
	
#  set ha 20.120
#  set filmBackMult .909306099322
#  set angleMultiplier 1

set dataFormat ""

  set f [open $filename r]

puts "File Open: $filename \nFile IO: $f"
  
	# parse tags until "Data" tag
	while {[gets $f line]>=0} {
puts "DATA LINE($f):$line"
		switch [lindex $line 0] {
			"Data:" { break }
			"AngleRepresentation:" { set angleRepresentation [lindex $line 1]}
			"CameraUp:" {set cameraUp [lindex $line 1]}
			"CameraForward:" {set cameraForward [lindex $line 1]}
			"HorizontalAperture:" {set horizontalAperture [lindex $line 1]}
			"VerticalAperture:" {set verticalAperture [lindex $line 1]}			
			"TransformOrder:" {set transformOrder [lindex $line 1]}
			"RotationOrder:" {set rotationOrder [lindex $line 1]}
                        "FramesPerSecond:" {}	# [FIXME]
			"Format:" { set dataFormat [lrange $line 1 end] }
		}
	}

	 puts "Data Break Successful"


  #deselect all nodes in the script
  foreach n [nodes] {knob $n.selected false}

  #creates Camera Node
#  Camera -new name Camera_3DSMax  tile_color 0xd6fffb00 label $cameraNote note_font_color 0xffffff00 selected true  addUserKnob {20 "" "Field of View"} addUserKnob {7 fov "Field of View" R 0.1 179} focal {{"(haperture / 2) / tan ( ((fov/2) / 57.295779513082320876798154814105) ) "}}
  Camera -new name Camera_3DSMax  tile_color 0xd6fffb00 label $cameraNote note_font_color 0xffffff00 selected true 


  # remember the camera and deselect it
  set camera_node [selected_node]


  switch $angleRepresentation {
	Radians { set angleMultiplier 1 }
	Degrees { set angleMultiplier 57.295779513082320876798154814105 }
	default { set angleMultiplier 57.295779513082320876798154814105 }
  }

puts "FORMAT ORDER: $dataFormat"
#puts "FRAME POSITIONX POSITIONY POSITIONZ EULERX EULERY EULERZ HFOV"

	set dataLocFRAME [lsearch $dataFormat FRAME]
puts "dataLocFRAME: $dataLocFRAME"
	set dataLocPOSITIONX [lsearch $dataFormat POSITIONX]
puts "dataLocPOSITIONX: $dataLocPOSITIONX"
	set dataLocPOSITIONY [lsearch $dataFormat POSITIONY]
puts "dataLocPOSITIONY: $dataLocPOSITIONY"
	set dataLocPOSITIONZ [lsearch $dataFormat POSITIONZ]
puts "dataLocPOSITIONZ: $dataLocPOSITIONZ"
	set dataLocEULERX [lsearch $dataFormat EULERX]
puts "dataLocEULERX: $dataLocEULERX"
	set dataLocEULERY [lsearch $dataFormat EULERY]
puts "dataLocEULERY: $dataLocEULERY"
	set dataLocEULERZ [lsearch $dataFormat EULERZ]
puts "dataLocEULERZ: $dataLocEULERZ"
	set dataLocHFOV [lsearch $dataFormat HFOV]
puts "dataLocHFOV: $dataLocHFOV"
	 
  if ![catch {set transformOrder}] {
puts "TransformOrder: $transformOrder"
     switch $transformOrder {
         "SRT" { knob $camera_node.xform_order $transformOrder }
         "STR" { knob $camera_node.xform_order $transformOrder }
         "RST" { knob $camera_node.xform_order $transformOrder }
         "RTS" { knob $camera_node.xform_order $transformOrder }
         "TRS" { knob $camera_node.xform_order $transformOrder }
         "TSR" { knob $camera_node.xform_order $transformOrder }
         default { knob $camera_node.xform_order SRT}
     }
  }

  if ![catch {set rotationOrder}] {
puts "Rotation Order: $rotationOrder"
    switch $rotationOrder {
         "XYZ" { knob $camera_node.rot_order XZY }
         "XZY" { knob $camera_node.rot_order XYZ }
         "ZXY" { knob $camera_node.rot_order YXZ }
         "ZYX" { knob $camera_node.rot_order YZX }
         "YXZ" { knob $camera_node.rot_order ZXY }
         "YZX" { knob $camera_node.rot_order ZYX }
         default { knob $camera_node.rot_order XYZ}
    }
  }

  if ![catch {set horizontalAperture}] {knob $camera_node.haperture $horizontalAperture}
  if ![catch {set verticalAperture}] {knob $camera_node.vaperture  $verticalAperture}
	
puts "CameraUp: $cameraUp CameraFoward: $cameraForward"

if {$cameraForward != "Y"} {
	puts "Converting camera pivot"
	if {$rotationOrder != "XYZ" && $rotationOrder != "XZY"} {
		error "!!! Conversion not supported yet because rotation order doesn't start with X !!!"
	}
	if {$cameraForward != "-Z"} {
		error "!!! Conversion to $cameraForward not supported yet !!!"
	}
}

puts "\n\n\nCamera Node: $camera_node"	

	set n 0
	while {[gets $f line]>=0} {
		if {[llength $line] < 4} continue
		incr n

		#Set Frame
		set fr [lindex $line $dataLocFRAME]

		setkey $camera_node.translate.x $fr [lindex $line $dataLocPOSITIONX]
		setkey $camera_node.translate.y $fr [lindex $line $dataLocPOSITIONZ]
		setkey $camera_node.translate.z $fr [expr -1 * [lindex $line $dataLocPOSITIONY] ]

		if {[llength $line] < 7} continue

		# handle Max files vs. LightWave files.. other cases are harder
		if {$cameraForward == "-Z"} {
			setkey $camera_node.rotate.x $fr [expr [lindex $line $dataLocEULERX] - 90 ]
		} else {
			setkey $camera_node.rotate.x $fr [lindex $line $dataLocEULERX]
		}
		setkey $camera_node.rotate.y $fr [lindex $line $dataLocEULERZ]
		setkey $camera_node.rotate.z $fr [expr -1 * [lindex $line $dataLocEULERY] ]

		if {[llength $line] < 8} continue

		if {$dataLocHFOV != -1} {
		setkey $camera_node.focal $fr [expr ($horizontalAperture / 2) / tan ( (([lindex $line $dataLocHFOV] / 2 ) / $angleMultiplier) )  ]		}

	}
	close $f

	# Turn off selectable flag so user doesn't destroy animation accidently:
	catch {knob gl_selectable false}

	# Save the filename into the node's label so user knows
	# where data came from.  This concats onto the existing label currently.
	catch {knob label [file tail $filename]}

return
}
