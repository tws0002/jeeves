

proc AE_CameraImport {args} {

  if [catch {panel -w500 "Paste After Effects Camera Data" {
    {"Load" loadOpt e "Clipboard File" }
    {"Clipboard" AE_Data n20}
    {"File" fileChanAE f }
  }}] {return}

  if {$loadOpt == "File"} {
    #FIXME - Add File Support
#    error "File Opt Not Support Yet"
    
    if [catch {open $fileChanAE r} fd] {
      error "ERROR: Can not open file\n$fileChanAE"
    } else {
      set AE_Data [read $fd]
    }
    
  }

#  if ![regexp {Adobe After Effects 7.0 Keyframe Data.*End of Keyframe Data} $AE_Data] {error "ERROR(regexp): Missing After Effects 7.0 Keyframe Data" } 

  if ![regexp {Source\sWidth\t(.*?)\n} $AE_Data tmp sourceWidth] {error "ERROR(regexp):Source Width"}
  if ![regexp {Source\sHeight\t(.*?)\n} $AE_Data tmp sourceHeight] {error "ERROR(regexp):Source Height"}
  if ![regexp {Comp\sPixel\sAspect\sRatio\t(.*?)\n} $AE_Data tmp aspectRatio] {error "ERROR(regexp):Source Pixel Aspect Ratio"}
  
  if ![regexp {Camera\sOptions\tZoom\n.*?\n(.*?)\n\n} $AE_Data tmp data_CameraZoom] {error "ERROR(regexp):Camera Zoom"}

  if ![regexp {Transform\sPoint\sof\sInterest\n.*?\n(.*?)\n\n} $AE_Data tmp data_PointOfInterest] {error "ERROR(regexp):Transform	Point of Interest"}
  if ![regexp {Transform\sPosition\n.*?\n(.*?)\n\n} $AE_Data tmp data_TransformPosition] {error "ERROR(regexp):Transform	Position"} 
  if ![regexp {Transform\sOrientation\n.*?\n(.*?)\n\n} $AE_Data tmp data_TransformOrientation] {error "ERROR(regexp):Transform	Orientation"}
  
  if ![regexp {Camera\sOptions\tFocus\sDistance\n.*?\n(.*?)\n\n} $AE_Data tmp data_FocusDistance] {error "ERROR(regexp):Focus Distance"}
  

set horzontalFilmBack 3.3867
  panel "FOV Caculations" {
    {"Horzontal Film Back (mm) " horzontalFilmBack }
  }
  
  #Set The Name and Lables for Camera and Target
  set N 1
  set cameraTargetName CameraTarget$N
  while { [catch {knob $cameraTargetName.name} ] == 0}  {
  incr N
  set cameraTargetName CameraTarget$N
  }

  set N 1
  set cameraName Camera$N
  while { [catch {knob $cameraName.name} ] == 0}  {
  incr N
  set cameraName Camera$N
  }

  set cameraLabel AfterEffect_Import


  #Create New Camera
  push 0
  Camera -new name $cameraName label $cameraLabel  addUserKnob {20 "" "Look At"} addUserKnob {1 axisName "Axis Name" t "Enter the Name of the Axis or Object for the Camera to look at"} axisName $cameraTargetName rotate {{"-degrees(atan2((translate.y-\[knob axisName].translate.y),sqrt(pow2(translate.z-\[knob axisName].translate.z)+pow2(translate.x-\[knob axisName].translate.x) ) ) )" i} {"degrees(atan2((translate.x-\[knob axisName].translate.x),(translate.z-\[knob axisName].translate.z)))" i} {curve}} selected false

  #Creates New CameraTarget
  push 0
  Axis -new name $cameraTargetName label $cameraLabel selected false


  knob $cameraName.haperture $horzontalFilmBack 

  knob $cameraName.vaperture [expression ($horzontalFilmBack/($sourceWidth*$aspectRatio))*$sourceHeight]

  foreach dataLine [split $data_CameraZoom \n] {
    set frameNumber [lindex [split $dataLine \t] 1 ]
    set cameraZoom [lindex [split $dataLine \t] 2 ]

    #calculate focalLeght 
    set focalLegth [expression ($cameraZoom/($sourceWidth*$aspectRatio))*$horzontalFilmBack]  

    #calculate FOV for AE camera 
#   set horzontalFOV [expression (degrees(atan2((($sourceWidth*$aspectRatio)/2),$cameraZoom))*2)]

    #If frame Number is empty then set knob else set keyframe    
    if {$frameNumber == ""} {
      knob $cameraName.focal $focalLegth
    } else { 
      setkey $cameraName.focal $frameNumber $focalLegth
    }
  }

  foreach dataLine [split $data_FocusDistance \n] {
    set data [split $dataLine \t]
    
    #If frame Number is empty then set knob else set keyframe
    if {[lindex $data 1] == ""} {
      knob $cameraName.focal_point [lindex $data 2]
    } else { 
      setkey $cameraName.focal_point [lindex $data 1] [lindex $data 2]
    }
  }

  #Focus Distance
  foreach dataLine [split $data_FocusDistance \n] {
    set data [split $dataLine \t]
    
    #If frame Number is empty then set knob else set keyframe
    if {[lindex $data 1] == ""} {
      knob $cameraName.focal_point [lindex $data 2]
    } else { 
      setkey $cameraName.focal_point [lindex $data 1] [lindex $data 2]
    }
  }


  foreach dataLine [split $data_TransformPosition \n] {
    set data [split $dataLine \t] 
    set frameNumber [lindex $data 1]
    set posX  [lindex $data 2]
    set posY  [expr [lindex $data 3]*-1]
    set posZ  [expr [lindex $data 4]*-1]

#alert "frameNumber: $frameNumber\nposX: $posX\nposY: $posY\nposZ: $posZ\n"
    
    if {$frameNumber == ""} {
      knob $cameraName.translate.x $posX
      knob $cameraName.translate.y $posY
      knob $cameraName.translate.z $posZ
alert "not key data"
    } else {
      setkey $cameraName.translate.x $frameNumber $posX
      setkey $cameraName.translate.y $frameNumber $posY
      setkey $cameraName.translate.z $frameNumber $posZ
    }
  } 

  foreach dataLine [split $data_PointOfInterest \n] {
    set data [split $dataLine \t]
    set frameNumber [lindex $data 1]
    set posX  [lindex $data 2]
    set posY  [expr [lindex $data 3]*-1]
    set posZ  [expr [lindex $data 4]*-1]
    
    if {$frameNumber == ""} {
      knob $cameraTargetName.translate.x $posX
      knob $cameraTargetName.translate.y $posY
      knob $cameraTargetName.translate.z $posZ
    } else {    
	    setkey $cameraTargetName.translate.x $frameNumber $posX
      setkey $cameraTargetName.translate.y $frameNumber $posY
      setkey $cameraTargetName.translate.z $frameNumber $posZ
    }
  }

}

