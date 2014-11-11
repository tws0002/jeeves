#Presets for Particles gizmo
#this is used by GenerateParticles.tcl

proc SaveParticlePresets {presetName} {
	set cur_suffix [lindex [split $presetName "."] end]
	if {$cur_suffix != "preset"} {
		set new_name [append presetName ".preset"]
		} else {
			set new_name $presetName
			}
	set cur_file "./ParticlePresets/$new_name"
	if [file exists $cur_file] {
		if ![ask "Overwrite the following file?\n$cur_file"] {return}
		}
	set chan [open $cur_file w]
	set skip_knobs {name label tile_color gl_color note_font note_font_size note_font_color lock_connections knob knob_1 preset_file presets}

	for {set cur_knob 0} {$cur_knob < [llength [knobs -v this]]} {incr cur_knob 2} {
		if {[lsearch $skip_knobs [lindex [knobs -v this] $cur_knob]] == -1} {
			puts "saving: [lindex [knobs -v this] $cur_knob] [lindex [knobs -v this] [expr $cur_knob+1]]"
			puts $chan "[lindex [knobs -v this] $cur_knob] [lindex [knobs -v this] [expr $cur_knob+1]]"
			}
		}
	close $chan
}
