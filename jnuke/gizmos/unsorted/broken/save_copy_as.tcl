# get_node_source.tcl is required

proc save_copy_as {newfile} {
	
	if {$newfile==""} {	
	
		# add the copy thing in there
		set newfile [file rootname [knob root.name]]_copy.nk
		# call a filename dialog and have it default with the 
		# new filename we created above
		if [catch {set newfile [get_filename "Copy to" "*" $newfile]}] return
	}
	
	# select all nodes
	foreach n [nodes] {
		knob $n.selected true
	}
	
	#copy nodes to $source varible
	set source [get_node_source]
	
	# create new file and append root settings
	set fileid [open $newfile w]
	puts $fileid "Root \{[knobs -avw root]\n\}"
	
	#append source nodes
	puts $fileid $source
	close $fileid
	
	# deselect to make purty
	foreach n [nodes] {
		knob $n.selected false
	}
	
	return
}