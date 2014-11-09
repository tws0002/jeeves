print '> importing maya_jeeves.publish.publisher_cmds'
import os, pickle, sys
import maya.cmds as cmds

class publish():
    def __init__(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, subprocess, mayafile):
        pass

class publish_sets():
    def __init__(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, uv_write, subprocess, mayafile, sets):
        pass


def make_cmd(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, subprocess, mayafile):
    print '\t> maya_jeeves.publish.publisher_cmds.make_cmd'
    
    cmd = "-frameRange %s %s" % (start, end)
    
    if strip_namespaces:
        cmd = cmd + ' -stripNamespaces'

    if uv_write:
        cmd = cmd + ' -uvWrite'

    if whole_frame_geo:
        cmd = cmd + ' -wholeFrameGeo'

    if world_space:
        cmd = cmd + ' -worldSpace'

    if export_selected:
        #print 'Export Selected'
        selected = cmds.ls(selection=True, l=True)
        print 'Number of selected objects : %s' % len(selected)
        
        if not len(selected) > 0:
            print 'NO OBJECTS SELECTED'
            return
        
        new = ''
        for each in selected:
            add = ' -root %s' % each
            new = new + add
        
        cmd = cmd  + new
    
    file_name = file_name.replace('\\', '/')
    
    if not file_name.endswith('.abc'):
        file_name = file_name + '.abc'

    if subprocess:
        cmd = cmd + " -file '%s'" % file_name
        spawn(cmd, file_name)
        #return cmd, file_name
    else:
        cmd = cmd + ' -file "%s"' % file_name
        exec_cmd(cmd, file_name)
        #return cmd, file_name

def make_set_cmd(start, end, file_name, strip_namespaces, whole_frame_geo, world_space, uv_write, subprocess, mayafile, sets):
    print '\t> maya_jeeves.publish.publisher_cmds.make_set_cmd'
    
    cmd = "-frameRange %s %s" % (start, end)
    
    if strip_namespaces:
        cmd = cmd + ' -stripNamespaces'

    if uv_write:
        cmd = cmd + ' -uvWrite'

    if whole_frame_geo:
        cmd = cmd + ' -wholeFrameGeo'

    if world_space:
        cmd = cmd + ' -worldSpace'

    #make set cmds
    #print sets
    cmds.select(sets)
    selected = cmds.ls(selection=True, l=True)
    
    #print 'Number of selected objects : %s' % len(selected)
        
    if not len(selected) > 0:
        return
        #print 'NO OBJECTS SELECTED'
        #return
        
    new = ''
    for each in selected:
        add = ' -root %s' % each
        new = new + add
    
    #print new
    cmd = cmd + new
    
    
    file_name = file_name.replace('\\', '/')
    
    if not file_name.endswith('.abc'):
        file_name = file_name + '.abc'

    if subprocess:
        cmd = cmd + " -file '%s'" % file_name
        #spawn(cmd, file_name)
        #return cmd, file_name
    else:
        cmd = cmd + ' -file "%s"' % file_name
        #exec_cmd(cmd, file_name)
        #return cmd, file_name

def spawn():
    pass

def exec_cmd(cmd, file_name):
    print '\t> maya_jeeves.publish.publisher_cmds.exec_cmd'

    cmds.AbcExport(j = cmd)
    print '\t\t > %s' % file_name
    
    all_namespaces = cmds.namespaceInfo( lon=True )
    all_namespaces.remove('shared')
    all_namespaces.remove('UI')
    
    x = file_name.split('.')
    nmpkl = x[0] + '_namespaces.txt'
    f = open(nmpkl, 'w')
    pickle.dump(all_namespaces, f)
    f.close()
    
    print '\t\t > %s' % nmpkl