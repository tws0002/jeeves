proc get_node_source {} {

    global env
    
    node_copy [getenv home]/.node_source
    
    set fileid [open [getenv home]/.node_source r]
    set cursource ""
    
    # get first two lines so we don't see em
    # they are only for version info anyway.
    gets $fileid
    gets $fileid
   
    #remove "push $cut_paste_input" or "push 0"
    set n [gets $fileid str]
    if {$str!="push 0" && $str!="push \$cut_paste_input"} {seek $fileid [expr -$n-2] current}

    #remove "push $cut_paste_input" or "push 0" again
    set n [gets $fileid str]
    if {$str!="push 0" && $str!="push \$cut_paste_input"} {seek $fileid [expr -$n-2] current}
    
    #read file to variable
    set cursource [read $fileid]
    
    close $fileid
    file delete -force [getenv home]/.node_source

    return $cursource

}