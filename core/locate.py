'''
- this contains only one class, the locate class, which tries to ascertain where the currenty open file is on the filesystem
adn therefore, what job, shot / asset, task and version you are working with. it's used primarily when opening, versioning,
saving and mastering files, just as a quick to check to ensure jeeves knows where you are.
'''

print '> importing core.locate'
import os
import core

class find(object):
    '''
    - the jeeves.core.locate.find class, takes on arguements.
    - if possible it will return self.job, self.dept, self.shot, self.user etc etc
    - used for versioning and saving modules to build names
    - vars extacted from the open file are then used to rebuild the filepath of the open scene and if they match, then
    jeeves knows where you are and you can proceeed. if they fail to match up, the file must be in some other place and im
    not going to deal with that.
    '''
    def __init__(self, ):
        print '\t> core.locate.find'
        
        self.openfile = ''
        self.success = False
        
        try:
            import maya.cmds as cmds
            import maya.OpenMayaUI as omui
            import shiboken
            self.runMode = 'maya'
            self.openfile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
            self.openfile = os.path.normpath(self.openfile)
            
            # first things first lets check the workspace
            import jmaya.pipeline.workspace
            if not jmaya.pipeline.workspace.check_workspace():
                return
        except:
            pass
    
        try:
            import nuke
            from nukescripts import panels
            self.runMode = 'nuke'
            self.openfile = nuke.Root().name()
        except:
            pass
        
        if self.openfile:
            if self.rebuild():
                print '\t> core.locate.find.rebuild > pass'
                self.success = True
            else:
                print '\t> core.locate.find.rebuild > fail'
        else:
            print '\t> core.locate.find.rebuild > fail'
    
    def rebuild(self):
        print '\t> core.locate.find.rebuild'
        #print '\t> %s' % self.openfile
        self.assetproj = False
        self.shotproj = False
        
        self.openfilesplits = self.openfile.split(os.path.sep)
        
        #known quantity
        jobrootsplit = core.jobsRoot.split(os.path.sep)
        
        #remove jobs root from list
        for each in jobrootsplit:
            self.openfilesplits.remove(each)
        
        #index 0 should be the job - check with core.job and get a dict if valid job
        if core.job.lookup(self.openfilesplits[0]).job:
            self.job = self.openfilesplits[0]
            
            ################################################################################################################
            #NUKE - SHOTS ONLY
            if self.openfilesplits[2] == 'nuke':
                self.shotproj = True
                self.dept = 'nuke'
                
                if 'sh_' in self.openfilesplits[3]:
                    self.shot = self.openfilesplits[3]
                    self.user = self.openfilesplits[5]
                    self.task = self.openfilesplits[5]
                    self.version = self.openfilesplits[6]
                    
                    rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'scripts', self.task, self.version)
                    if rebuild == self.openfile:
                            return True
                    else:
                        return False
            ################################################################################################################

            #3D - SHOTS AND ASSETS
            if self.openfilesplits[2] == '3d':
                self.dept = self.openfilesplits[2]
                
                #index 3 should be the 3d_assets or shot folder
                # ASSETS
                if self.openfilesplits[3] == '3d_assets':
                    self.assetproj = True
                    
                    #index 5 and 6 should be the category and asset name, respectively
                    self.category = self.openfilesplits[5]
                    self.asset = self.openfilesplits[6]
                    
                    try:                    
                        #index 7 will be either the task or verison
                        if len(self.openfilesplits) == 9:
                            self.task = self.openfilesplits[7]
                            self.version = self.openfilesplits[8]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, self.task, self.version )
    
                        elif len(self.openfilesplits) == 8:
                            self.task = 'loose'
                            self.version = self.openfilesplits[7]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, self.version )
                        
                        #THE TEST
                        print rebuild
                        print self.openfile
                        if rebuild == self.openfile:
                            return True
                        else:
                            return False
                    except:
                        return False

                # SHOTS
                elif 'sh_' in self.openfilesplits[3]:
                    self.shot = self.openfilesplits[3]
                    self.shotproj = True

                    try:
                        if len(self.openfilesplits) == 7:
                            self.task = self.openfilesplits[5]
                            self.version = self.openfilesplits[6]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.task, self.version )
                        elif len(self.openfilesplits) == 6:
                            self.task = 'loose'
                            self.version = self.openfilesplits[5]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.version )
                        
                        #THE TEST
                        if rebuild == self.openfile:
                            return True
                        else:
                            return False
                    except:
                        return False