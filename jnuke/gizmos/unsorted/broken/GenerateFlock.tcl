### (c) 2008 Created by Alexander Antoshuk (Ali)
### www.2d3d.by
### Script executed inside Flock.gizmo

proc GenerateFlock {} {
	foreach node [nodes] {
		if {[string first "_" [knob $node.name]]==0} {delete $node}
	}

	for {set i 1} {$i<=[value num]} {incr i} {

		TimeOffset {name "_TimeOffset"}
		set offset [stack 0]
		
		NoTimeBlur {name "_NoTimeBlur"}
		
		Transform {name "_Transform"}
		set trans [stack 0]
		
		
		set n [expr $i*10]
		
		knob $offset.time_offset "{random($n+parent.seed+100)*(parent.offset.v-parent.offset.u)+parent.offset.u}"
		
		addUserKnob node $trans 7 x0
		knob $trans.x0 "{random($n+parent.seed+150)*(parent.bounds.r-parent.bounds.x)+parent.bounds.x-center.x}"
		addUserKnob node $trans 7 y0
		knob $trans.y0 "{random($n+parent.seed+200)*(parent.bounds.t-parent.bounds.y)+parent.bounds.y-center.y}"
		addUserKnob node $trans 7 grid_x0
		knob $trans.grid_x0 "{parent.bounds.x-center.x+(ceil($i/sqrt([value num]))-1)*(parent.bounds.r-parent.bounds.x)/(sqrt([value num])-1)}"
		addUserKnob node $trans 7 grid_y0
		knob $trans.grid_y0 "{parent.bounds.y-center.y+($i-1-(ceil($i/sqrt([value num]))-1)*sqrt([value num]))*(parent.bounds.t-parent.bounds.y)/(sqrt([value num])-1)}"
		addUserKnob node $trans 7 s0
		knob $trans.s0 "{random($n+parent.seed)*(parent.scale.v-parent.scale.u)+parent.scale.u}"
		addUserKnob node $trans 7 r0
		knob $trans.r0 "{random($n+parent.seed+250)*(parent.rotate.v-parent.rotate.u)+parent.rotate.u}"
		addUserKnob node $trans 7 ampx
		knob $trans.ampx "{random($n+parent.seed+300)*(parent.ax.v-parent.ax.u)+parent.ax.u}"
		addUserKnob node $trans 7 freqx
		knob $trans.freqx "{random($n+parent.seed+350)*(parent.fx.v-parent.fx.u)+parent.fx.u}"
		addUserKnob node $trans 7 ampy
		knob $trans.ampy "{random($n+parent.seed+400)*(parent.ay.v-parent.ay.u)+parent.ay.u}"
		addUserKnob node $trans 7 freqy
		knob $trans.freqy "{random($n+parent.seed+450)*(parent.fy.v-parent.fy.u)+parent.fy.u}"
		addUserKnob node $trans 7 ampr
		knob $trans.ampr "{random($n+parent.seed+500)*(parent.ar.v-parent.ar.u)+parent.ar.u}"
		addUserKnob node $trans 7 freqr
		knob $trans.freqr "{random($n+parent.seed+550)*(parent.fr.v-parent.fr.u)+parent.fr.u}"
		addUserKnob node $trans 7 amps
		knob $trans.amps "{random($n+parent.seed+600)*(parent.as.v-parent.as.u)+parent.as.u}"
		addUserKnob node $trans 7 freqs
		knob $trans.freqs "{random($n+parent.seed+650)*(parent.fs.v-parent.fs.u)+parent.fs.u}"
		
		knob $trans.center "{width/2} {height/2}"
		knob $trans.translate "{(1-parent.grid_rand)*grid_x0+parent.grid_rand*x0+parent.noise_t*ampx*noise(t*freqx+10*random($n+parent.seed+700))} {(1-parent.grid_rand)*grid_y0+parent.grid_rand*y0+parent.noise_t*ampy*noise(t*freqy+10*random($n+parent.seed+750))}"
		knob $trans.rotate "{r0+parent.noise_r*ampr*noise(t*freqr+10*random($n+parent.seed+800))}" 
		knob $trans.scale "{(s0+parent.noise_s*amps*noise(t*freqs+10*random($n+parent.seed+850)))*(parent.horizmirror?2*step(random($n+parent.seed+900),0.5)-1:1)} {(s0+parent.noise_s*amps*noise(t*freqs+10*random($n+parent.seed+950)))*(parent.vertmirror?2*step(random($n+parent.seed+1000),0.5)-1:1)}" 
		
		input $offset 0 IN
		
		set merge_input $i
		if {$i>1} {incr merge_input}

		input MAIN_MERGE $merge_input $trans
	}
	
}