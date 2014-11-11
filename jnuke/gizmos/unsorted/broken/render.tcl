# Written by Ali 2008
# www.2d3d.by
# Version 2.0.1
#
# get_node_source.tcl is required
# save_copy_as.tcl is required


proc render {_list} {
	
	global WIN32
 	global env
 	global program_name
	global threads
	set isLocal false
	set CPUs $threads
	if [info exists env(NUMBER_OF_PROCESSORS)] {set CPUs $env(NUMBER_OF_PROCESSORS)}
	
	
	#add render settings to Root
	add_render_settings
	#filter values
	knob render_Threads [expression abs(int([value root.render_Threads]))]
	knob render_TaskFrames [expression abs(int([value root.render_TaskFrames]))]
	
	#save settings in variables
	set rLaunchMode [value root.render_LaunchMode]
	set rPriority [value root.render_Priority]
	set rGlobalRange [value root.first_frame],[value root.last_frame]
	set rFrameRange [value root.render_FrameRange]
	set rThreads [value root.render_Threads]
	if {$rThreads==0} {set rThreads $threads}
	set rTaskFrames [value root.render_TaskFrames]
	set rPause [value root.render_Pause]
	set rLicense [value root.render_License]
	set rLicArg ""
	if {$rLicense} {set rLicArg "-i "}

	#element manager data gathering
	foreach n $_list {
		if {[class $n]=="Write" && ![value $n.disable]} {
			lappend write_list [knob $n.name]
			#check if path is local
			if {!$isLocal} {set isLocal [isPathLocal [file normalize [filename $n]]]}
		}
	}
	#check if script path is local
	if {!$isLocal} {set isLocal [isPathLocal [file normalize [knob root.name]]]}
	
	if {![info exists write_list]} {
		message "No Write nodes"
		return 
	}

	#alphabet sorting
	set write_list [lsort -dictionary $write_list]
	
	set writeno 0
	foreach n $write_list {
		# add info to array and increase counter
		set write($writeno) [knob $n.name]
		incr writeno
	}

	#render order sorting
	if {[array size write]>1} {
		for {set y 0} {$y < [array size write]} {incr y} {
			set ok 1
			for {set x 0} {$x < [expr [array size write]-1]} {incr x} {
				set node [lindex [array get write $x] 1]
				set next_node [lindex [array get write [expr $x+1]] 1]
				if {[value $node.render_order]>[value $next_node.render_order]} {
					set write($x) $next_node
					set write([expr $x+1]) $node
					set ok 0 
				}
			}
			if {$ok} break;
		}
	}
	
	#build GUI
	set args ""
	set totalframes 0	
	for {set x 0} {$x < [array size write]} {incr x} {
		
		set node [lindex [array get write $x] 1]
		#add writeframes array alements
		if {$rFrameRange!="Input"} {
			#set ranges to global
			set writeframes($x) $rGlobalRange
		} else {
			#set ranges to input
			set writeframes($x) [expr int([value $node.first_frame])],[expr int([value $node.last_frame])]
		}
		set writefile($x) [filename $node]
		lappend args "\"<caption align=right>$node: [file tail [filename $node]] \" writeframes($x)"
	}
	lappend args {buttons "Cancel" "Save" "Ok"}
	
	set button	0
	#build title
	set title "Render with $rLaunchMode"
	if {$isLocal} {append title " (local paths)"}
	
	#show panel
	if [catch {set button [panel $title $args]}] {return}

############################################################################################################################################
	# Launch Modes switch
	switch -glob -- $rLaunchMode {	

############################# NukeGUI Launch Script Mode ####################################################################################
	"NukeGUI" {
		if {$button!=2} {return}
		set oldThreads $threads
		set threads $rThreads
				
		for {set x 0} {$x < [array size write]} {incr x} {
 			
 			set node [lindex [array get write $x] 1]
			
			#make dir if not exist
			catch {file mkdir [file dirname [filename $node]]}
			
			#execution
			if [catch {eval [concat execute $node [lindex [array get writeframes $x] 1]]} errmsg] {
				if [extract_cancel $errmsg] {return}
				puts $errmsg
			}

		}
		set threads $oldThreads
		
		
	}


############################# Shell Launch Script Mode ######################################################################################
	"Shell" {
		if {![file exist [file normalize [knob root.name]]]} {message "Non-GUI render isn't work with unsaved script!"; return}
		
		set nuke_exe [file tail $program_name]
		
		#save current frame
		set cur_frame [frame]
		# set current frame to -1 so readers and writers won't conflict
		frame -1
		
		#create script copy
		set nk_script [file normalize [file rootname [knob root.name]]]_[date %y][date %m][date %d]_[date %H][date %M][date %S]
		append cmd_script $nk_script ".cmd"
		append nk_script ".nk"
		save_copy_as $nk_script
		
		# set current frame to the saved one
		frame $cur_frame
		
		
		#build script lines
		set line "\@echo off\n"
		append line "echo Nuke render checkpoint [date %Y]/[date %m]/[date %d] [date %k]:[date %M]:[date %S]\n"
		append line "\n"
		
		for {set x 0} {$x < [array size write]} {incr x} {
			
			set node [lindex [array get write $x] 1] 		
			
			#make dir if not exist
			catch {file mkdir [file dirname [filename $node]]}

			# executions...
			set last 0
			set step 1
			scan [lindex [array get writeframes $x] 1] %d%c%d%c%d first {} last {} step
			if {$first > $last} {set last $first}
			
			if {$rTaskFrames < 1} {
				append line "start \"$node\" /[value root.render_Priority] /b /wait \"$program_name\" -t $rLicArg-m $rThreads -X [lindex [array get write $x] 1] \"$nk_script\" $first,$last,$step\n"
				continue
			}
			
			for {set task_first $first} {$task_first <= $last} {incr task_first $rTaskFrames} {
			
				set task_last [expr $task_first + $rTaskFrames - 1]
				if {$task_last>$last} {set task_last $last}
				
				append line "start \"Nuke_Render: [file tail [knob root.name]]\" /[value root.render_Priority] /b /wait \"$program_name\" -t $rLicArg-m $rThreads -X $node \"$nk_script\" $task_first,$task_last\n"
			}
			
		}
		append line "\n"
		
		
		#delete temp files...
		append line "\ndel /f \"[regsub -all "\/" $nk_script "\\\\"]\"\n"
		append line "del /f \"[regsub -all "\/" $cmd_script "\\\\"]\"\n"
		
		append line "exit"
		
		#append script lines to saved script
		set fileid [open $cmd_script w]	
		puts $fileid $line
		close $fileid
		
		#convert slashes
		set cmd_script [regsub -all "\/" $cmd_script "\\\\\\"]
		
		#execute script...
		if {$button==2} {
			eval "exec cmd /c start \"Nuke \" \"$cmd_script\" &"
		}
	}


############################# Alfred Launch Script Mode #####################################################################################
	"Alfred" {
		if {![file exist [file normalize [knob root.name]]]} {message "Non-GUI render isn't work with untitled script!" ;return}
		
		set nuke_exe [file tail $program_name]
		set alfred_path $env(RATTREE)
		append alfred_path "/bin/alfred"
		set alfred_path [regsub -all "\\\\" $alfred_path "\/"]
		set alfred_path [file normalize $alfred_path]
		set alf_command RemoteCmd
		if {$isLocal} {set alf_command Cmd}
		
		#save current frame
		set cur_frame [frame]
		# set current frame to -1 so readers and writers won't conflict
		frame -1
		
		#create script copy
		set nk_script [file normalize [file rootname [knob root.name]]]_[date %y][date %m][date %d]_[date %H][date %M][date %S]
		append alf_script $nk_script ".alfred"
		append nk_script ".nk"
		save_copy_as $nk_script
		
		#set current frame to the saved one
		frame $cur_frame
		
		set shortname [file rootname [file tail [knob root.name]]]
		
		#build script lines
		set line "\#\#"
		append line "AlfredToDo 3.0 checkpoint [date %Y]/[date %m]/[date %d] [date %k]:[date %M]:[date %S]\n"
		append line "\# spooled as: $alf_script\n"
		append line "\# last estimated time remaining: +0:00:10\n\n"
		append line "Job -title {$shortname\(nuke render job\)}\\\n"
		append line "    -comment {Created by render script} \\\n"
		append line "    -elapsed 2 -etalevel 0 \\\n"
		append line "    -atleast 1 -atmost 3 -pbias 0 \\\n"
		append line "    -service {} -tags {} \\\n"
		append line "    -init \{\n"
		append line "	 Assign txCmd {txmake}\n"
		append line "	 Assign txSvc {}\n"
		append line "	 Assign txTag {}\n"
		append line "    \} \\\n"
		append line "-subtasks \{\n"
		
		for {set x 0} {$x < [array size write]} {incr x} {
		
			set node [lindex [array get write $x] 1]
			
			#make dir if not exist
			catch {file mkdir [file dirname [filename $node]]}
					
			#executions...
			set last 0
			set step 1
			scan [lindex [array get writeframes $x] 1 ] %d%c%d%c%d first {} last {} step
			if {$first > $last} {set last $first}
			
			if {$rTaskFrames < 1} {
				append line "	Task {$shortname.$first-$last} -id Frm1  -service \{nuke\} -tags \{nuke\} -subtasks \{\n"
				append line "	\} -cmds \{\n"
				append line "		$alf_command \{$nuke_exe -t $rLicArg-m $rThreads -X [lindex [array get write $x] 1]"
				append line " \"$nk_script\" $first,$last,$step\} -refersto Frm1\n \} -chaser \{\n"
				append line "  \}\n"
				continue
			} else {
				for {set task_first $first} {$task_first <= $last} {incr task_first $rTaskFrames} {
			
					set task_last [expr $task_first + $rTaskFrames - 1 ]
					if {$task_last>$last} {set task_last $last}
				
					append line "	Task {$shortname.$task_first-$task_last} -id Frm1  -service \{nuke\} -tags \{nuke\} -subtasks \{\n"
					append line "	\} -cmds \{\n"
					append line "		$alf_command \{$nuke_exe -t $rLicArg-m $rThreads -X [lindex [array get write $x] 1]"
					append line " \"$nk_script\" $task_first,$task_last\} -refersto Frm1\n \} -chaser \{\n"
					append line "  \}\n"
			
				}
			}			
		}
		append line "\}"

		append line " -cleanup \{\n"
		append line " 	Cmd {Alfred} -msg {File delete \"$nk_script\"}\n"
		append line " 	Cmd {Alfred} -msg {File delete \"$alf_script\"}\n"
		append line "\}"			
		
		append line "\n"
		append line "\#\# --- End of Job '$shortname\(nuke render job\)'\n"
		
		#append script lines to saved script
		if {[catch {set fileid [open $alf_script w]} result_alf_script_save ]} {error $result_alf_script_save; return}
		puts $fileid $line
		close $fileid
		
		#execute script...
		puts "\nSave nuke script copy as $nk_script"
		puts "\nSave alfred script as $alf_script"
		if {$button==2} {
			set alf_execute "exec cmd.exe /c $alfred_path.exe "	  
			if {$rPause} {append alf_execute "-paused "}
			append alf_execute $alf_script
			append alf_execute " &"	
			if {[eval $alf_execute]} {puts "Render with Alfred..."}			
		}
	}

	}
	
	return
}


###########################################################################################################################
#add render settings to root
proc add_render_settings {} {
	in root {
	addUserKnob {20 Render}
	
	if ![exists render_Button] {
		
		addUserKnob {32 render_Button l "                RENDER                " T "if \[catch \{set seln \[selected_nodes]\}] \{\nrender \[nodes]\n\} else \{\nrender \$seln \n\} "}
	}
	
	if ![exists render_LaunchMode] {
		addUserKnob {4 render_LaunchMode "launch script mode" M {"NukeGUI" "Shell" "Alfred"}}
	}
	
	if ![exists render_Priority] {
		addUserKnob {4 render_Priority " " M {"Normal" "Low"} -STARTLINE}
		knob render_Priority "Normal"
	}
	
	if ![exists render_FrameRange] {
		addUserKnob {4 render_FrameRange "frame range" M {"Input" "Global"}}
		knob render_FrameRange "Global" 
	}
	
	if ![exists render_Threads] {
		addUserKnob {3 render_Threads "render threads (0 to use number of CPUs)"}
		knob render_Threads 0
	}
	if ![exists render_TaskFrames] {
		addUserKnob {3 render_TaskFrames "frames per task (0 to use one task per writer)"}
		knob render_TaskFrames 0
	}
	if ![exists render_Pause] {
		addUserKnob {6 render_Pause "start render manager paused" +STARTLINE}
		knob render_Pause 0
	}
	
	if ![exists render_License] {
		addUserKnob {6 render_License "use interactive (not render) license" +STARTLINE}
		knob render_License 0
	}
	}
	return
}


###########################################################################################################################
#checks if path is local
proc isPathLocal {path} {
		if {[string compare -nocase -length 2 $path "//"] == 0 } {return false} else {return true}
}


###########################################################################################################################
#get the frame number out of cancelled error message
proc extract_cancel {msg} {
    if ![string match "Cancel*" $msg] {return 0}
    if [llength $msg]<2 {return 0}
    return [lindex $msg 1]
}

