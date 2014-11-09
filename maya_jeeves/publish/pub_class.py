print '> importing maya_jeeves.publish.pub_class'
import os, pickle, sys
import maya.cmds as cmds

class publish():
    def __init__(self, start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, subprocess, mayafile, sets, queue):

        self.start = start
        self.end = end
        self.strip_namespaces = strip_namespaces
        self.whole_frame_geo = whole_frame_geo
        self.world_space = world_space
        self.export_selected = export_selected
        self.uv_write = uv_write
        self.subprocess = subprocess
        self.mayafile = mayafile
        self.sets = sets
        self.queue = queue
        
        #filename
        self.file_name = file_name.replace('\\', '/')
        
        if not self.file_name.endswith('.abc'):
            self.file_name = self.file_name + '.abc'
        
        #cmd
        self.cmd = "-frameRange %s %s" % (self.start, self.end)
        
        #generic options
        if strip_namespaces:
            self.cmd = self.cmd + ' -stripNamespaces'

        if uv_write:
            self.cmd = self.cmd + ' -uvWrite'

        if whole_frame_geo:
            self.cmd = self.cmd + ' -wholeFrameGeo'

        if world_space:
            self.cmd = self.cmd + ' -worldSpace'
        
        #add geometry to args
        if sets:
            self.cmd = self.cmd + self.make_set_cmds()
        else:        
            self.cmd = self.cmd + self.make_cmds()
        
        #final cmd
        self.cmd = self.cmd + " -file '%s'" % self.file_name
    
        #print self.cmd
        
        if not self.queue:
            #subprocess or not
            if subprocess:
                self.spawn(self.cmd)
            else:
                self.exec_cmd(self.cmd)
    
        #self.save_namespaces()
    
    def make_cmds(self):
        print 'make_cmds'
        geometries = ''
        if self.export_selected:
            selected = cmds.ls(selection=True, l=True)
        
            if not len(selected) > 0:
                #print 'NO OBJECTS SELECTED'
                return None
            
            else:
                for each in selected:
                    add = ' -root %s' % each
                    geometries = geometries + add
        
        return geometries
    
    def make_set_cmds(self):
        print 'make_set_cmds'
        geometries = ''
        
        cmds.select(self.sets)
        selected = cmds.ls(selection=True, l=True)
            
        if not len(selected) > 0:
            return

        for each in selected:
            add = ' -root %s' % each
            geometries = geometries + add
        
        return geometries
    
    def spawn(self, cmd):
        print 'spawn'
    
    def exec_cmd(self, cmd):
        print 'exec cmd'

    def save_namespaces(self):
        print 'save namespaces'
        all_namespaces = cmds.namespaceInfo( lon=True )
        all_namespaces.remove('shared')
        all_namespaces.remove('UI')
        
        x = self.file_name.split('.')
        nmpkl = x[0] + '_namespaces.txt'
        f = open(nmpkl, 'w')
        pickle.dump(all_namespaces, f)
        f.close()