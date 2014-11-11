#Presets for Particles gizmo
#this is used by GenerateParticles.tcl

proc LoadParticlePresets {presetName} {
	set cur_suffix [lindex [split $presetName "."] end]
	if {$cur_suffix != "preset"} {
		set new_name [append presetName ".preset"]
		} else {
			set new_name $presetName
			}
	set input "/Users/patrickwong/.nuke/gizmos/ParticlePresets/$new_name"
	puts ">> loading knob values from $input:"
	set chan [open $input r]
	array set knob_values {}
	while {[gets $chan line] >= 0} {
		lappend knob_values([lindex $line 0]) [lrange $line 1 end]
		}
	close $chan
	foreach cur_knob [array names knob_values] {
		puts "  >> knob $cur_knob --> $knob_values($cur_knob)"
		knob this.$cur_knob [string trim $knob_values($cur_knob) "{}"]
		}
}
