print '> importing jmaya.pipeline.pub_class'
import os, pickle, sys
import maya.cmds as cmds

class publish():
    def __init__(self, start, end, file_name, strip_namespaces, whole_frame_geo, world_space, export_selected, uv_write, mayafile):

        self.start = start
        self.end = end
        self.strip_namespaces = strip_namespaces
        self.whole_frame_geo = whole_frame_geo
        self.world_space = world_space
        self.export_selected = export_selected
        self.uv_write = uv_write
        self.mayafile = mayafile
        print self.export_selected

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

        self.cmd = self.cmd + self.make_cmds()
        
        #final cmd
        self.cmd = self.cmd + " -file '%s'" % self.file_name
        self.exec_cmd(self.cmd)
    
        self.save_namespaces()
    
    def make_cmds(self):
        print 'make_cmds'
        geometries = ''
        if self.export_selected:
            selected = cmds.ls(selection=True, l=True)
        
            if not len(selected) > 0:
                print 'NO OBJECTS SELECTED'
                return None
            
            else:
                for each in selected:
                    add = ' -root %s' % each
                    geometries = geometries + add
        
        return geometries

    def exec_cmd(self, cmd):
        print 'exec'
        cmds.AbcExport(j = cmd)

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