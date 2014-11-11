# (c) 2003 Robert Nederhorst - throb@throb.net
# Function called from the "import SynthEyes camera track" 

# read data from a Scene Eyes text file:
# format is: TX TY TZ RX RY RZ VFOV

proc import_synth {} {
  global env
  global JOB
  global SHOT
  global filename
  global spheres
  global objout
  global firstchar
  global curnode
  global range
  
# call a panel that asks the user for the camera txt file
if [catch {set filename [get_filename "SynthEyes Nuke Text File" "*.txt" ]}] {return}

# check to see if the file really exists
if [file exists $filename] {

if [catch {set curnode [selected_node]}] {
  Camera -New {
	  icon node_camera.xpm
	  selected true
	  }
}

# create the camera if one is not selected
	if { [catch {set camnode [selected_node] } ] || [class $camnode] != "Camera"} {
		
		Camera -New {
			icon node_camera.xpm
			}
		
		# we need to get the node name
		set camnode [stack 0]
		
	} else {
		set camnode [selected_node]
		set gotcam true
	}
	# label the node accordingly so the user knows which track they pulled in
	knob $camnode.name "SynthEyesCamera"
	knob $camnode.label [basename $filename]

	  set f [open $filename r]
	  set n 0
	  set pointcount 0

#create obj file
set filename [string trimright $filename txt]obj

	if [catch {
	  panel "Save OBJ File" {
	  		{"OBJ Path  " filename}
			}
		} result] return
		
set objout [open $filename w]
    
	  
	  while { ![eof $f] } {
	      gets $f line
	      set firstchar [string index $line 0]

		# Find Vertical and Horizontal Aperture data & apply to NUKE camera.
		      if { ([lindex $line 0] == "#Filmback") } {
		         knob $camnode.vaperture [lindex $line 3]
		         knob $camnode.haperture [lindex $line 2]
		      }
		
		# Find translation and rotation data and apply to NUKE camera.
		      if { ([llength $line] == 7) && ($firstchar != "#") } {
		         incr n
		         set fr $n
		         # translation
			 setkey $camnode.translate.x $fr [lindex $line 0]
		         setkey $camnode.translate.y $fr [lindex $line 1]
		         setkey $camnode.translate.z $fr [lindex $line 2]
		         
			 # rotation
		         setkey $camnode.rotate.x $fr [lindex $line 3]
		         setkey $camnode.rotate.y $fr [lindex $line 4]
		         setkey $camnode.rotate.z $fr [lindex $line 5]
			 
			 #focal
			 setkey $camnode.focal $fr [lindex $line 6]
		      
		}
         

    
#write points to obj file

		if { ([llength $line] == 3) && ($firstchar != "#") } {
			incr pointcount
			set tx [lindex $line 0] 
			set ty [lindex $line 1] 
			set tz [lindex $line 2]
			set my "v $tx $ty $tz"
			puts $objout $my
	
			}

	  }
		
}
		
	
close $objout

if {$pointcount != 0} {
  #Extend script frame range if not already longer than 1.
  set range [knob root.last_frame]
  if { $range < $n } {
	  knob root.last_frame $n
  }
  
  
      #create scene
      Constant {
	color {1 0 0 1}
	name Constant1
	selected true
      
      }
      DecalMat {
	inputs 2
	name DecalMat1
	selected true
      }
      QuadricGeo {
	radius {1 1 1}
	rows 2
	columns 2
	name QuadricGeo1
	selected true
      }
      TransformGeo {
	uniform_scale 0.17
	name TransformGeo1
	selected true
	tile_color 0x3a14aa00
      }
      push 0
      objReaderGeo "
	file $filename
	name objReaderGeo1
	selected true
      "
      InstanceGeo {
	inputs 2
	name InstanceGeo1
	selected true
      }
      MaterialGeo {
	inputs 2
	name MaterialGeo1
	selected true
      }
      push 0
      GeoObject {
	inputs 2
	scaling {1 1 1}
	name GeoObject1
	selected true
      }
      push $camnode
      Scene {
	inputs 2
	name Scene1
	selected true
	icon node_scene.xpm
      }
      push 0
      ScanlineRender {
	inputs 3
	name ScanlineRender1
	filtering_enabled false
	selected true
	tile_color 0x9c000000
      }
}
message "Loaded $n frames and $pointcount points."



}



