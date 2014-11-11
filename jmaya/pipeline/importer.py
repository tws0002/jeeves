print '> importing jmaya.pipeline.importer'

import pickle
import maya.cmds as cmds

class importer(object):
    def __init__(self, found_file):
        print '\t> jmaya.pipeline.importer.importer'
        self.found_file = found_file
        self.import_type()
    
    def import_type(self):
        print '\t> jmaya.pipeline.importer.import_type'
        self.ext = self.found_file.split('.')[-1]
        
        if self.ext == 'mb':
            self.maya_import()
        
        elif self.ext == 'ma':
            self.maya_import()
        
        elif self.ext == 'abc':
            self.abc_add_namespaces()
            self.abc_import()
        
        elif self.ext == 'fbx':
            self.fbx_import()
        
        else:
            pass
    
    def fbx_import(self):
        pass
    
    def maya_import(self):
        print '\t> jmaya.pipeline.importer.maya_import'
        print self.found_file
        print 'NEED TO FINISH THIS'
        
    
    def abc_add_namespaces(self):
        print '\t> jmaya.pipeline.importer.abc_add_namespaces'
        #import namespaces and then abc improt
        
        x = self.found_file.split('.')
        nmpkl = x[0] + '_namespces.txt'
        try:
            f = open(nmpkl, 'r')
            nm = pickle.load(f)
            f.close()
            
            #print nm
            
            for each in nm:
                if not cmds.namespace(ex = each):
                    cmds.namespace( add=each )
        except:
            pass
        
    def abc_import(self):
        print '\t> jmaya.pipeline.importer.abc_import'
        #probably should write a gui for the options
        cmds.AbcImport(self.found_file)
        