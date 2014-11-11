print '> importing jmaya.pipeline.version'
import os, re, sys
import core
import core.job as job
import core.assets as assets
import core.shots as shots
import maya.cmds as cmds
import jmaya.pipeline.workspace

class version_save(object):
    def __init__(self):
        print '\t> jmaya.pipeline.version'
        
        # first things first lets check the workspace        
        if not jmaya.pipeline.workspace.check_workspace():
            return
        
        #lets save the current scene and get the full filepath
        #cmds.file(s=True)
        self.mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        self.mayafile = os.path.normpath(self.mayafile)

        if self.version_vars():
            if self.version_file():
                print '\t> VERSION SAVED'
            else:
                print '\t> VERSION NOT SAVED'
        else:
            print '\t> VERSION NOT SAVED - no vars'

    def version_file(self):
        print '\t> jmaya.pipeline.version.version_file'
        try:
            # this looks for a 'v' in the version name and versions up
            #version_string = re.search('[_|.]v|V[0-9]+',self.version.lower()).group(0)
            version_string = re.search('[_|.][v|V][0-9]+',self.version).group(0)

            if version_string[1] == 'v':
                #print 'lower'
                case = 'lower'
                current_number = version_string.split('v')[-1]
            elif version_string[1] == 'V':
                #print 'upper'
                case = 'upper'
                current_number = version_string.split('V')[-1]
                
            #print version_string
            #print current_number
            #return
        
            current_int = int(current_number)
    
            fileSaved = False
            while not fileSaved:
                if len(current_number) == 1:
                    new_number = '%s' % current_int
                elif len(current_number) == 2:
                    new_number = '%02d' % current_int
                elif len(current_number) == 3:
                    new_number = '%03d' % current_int
                
                if case == 'lower':
                    new_version = '_v' + new_number
                elif case == 'upper':
                    new_version = '_V' + new_number
                
                new_filename = self.version.replace(version_string, new_version)
    
                tmp = self.mayafile.split(os.path.sep)[:-1]
                version_path = os.path.sep.join(tmp)
                self.new_filepath = os.path.join(version_path, new_filename)
                
                # if file exists, we version up
                if os.path.isfile(self.new_filepath):
                    current_int += 1
                    continue
    
                # save the script
                cmds.file( rename=self.new_filepath  )
                cmds.file( save=True, type='mayaBinary' )
                fileSaved = True
            return True
 
        except:
            # if there isn't a 'v' in the version, it appends one
            current_int = 1
            fileSaved = False
            while not fileSaved:
                new_number = '%02d' % current_int
                new_version = '_v' + new_number
                vtmp = self.version.split('.')
                new = vtmp[0] + new_version + '.' + vtmp[-1]
                
                tmp = self.mayafile.split(os.path.sep)[:-1]
                version_path = os.path.sep.join(tmp)
                new_filepath = os.path.join(version_path, new)

                # if file exists, we version up
                if os.path.isfile(new_filepath):
                    current_int += 1
                    continue

                # save the script
                cmds.file( rename=new_filepath  )
                cmds.file( save=True, type='mayaBinary' )
                fileSaved = True
            return True

    def version_vars(self):
        print '\t> jmaya.pipeline.version.version_vars'
        self.assetproj = False
        self.shotproj = False
        #we have the mayafile, with correct workspace - this is all we need
        mayafile = self.mayafile.split(os.path.sep)

        #known quantity
        jobrootsplit = core.jobsRoot.split(os.path.sep)

        #remove jobs root from list
        for each in jobrootsplit:
            mayafile.remove(each)
        
        #index 0 should be the job - check with core.job and get a dict if valid job
        if job.lookup(mayafile[0]).job:
            self.job = mayafile[0]
            
            #index 2 should be the dept - we already have nuke and 3d keys in dict - nothing more needed
            if mayafile[2] == '3d':
                self.dept = mayafile[2]
                
                #index 3 should be the 3d_assets or shot folder
                # ASSETS
                if mayafile[3] == '3d_assets':
                    self.assetproj = True
                    
                    #index 5 and 6 should be the category and asset name, respectively
                    self.category = mayafile[5]
                    self.asset = mayafile[6]
                    
                    try:                    
                        #index 7 will be either the task or verison
                        if len(mayafile) == 9:
                            self.task = mayafile[7]
                            self.version = mayafile[8]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, self.task, self.version )
    
                        elif len(mayafile) == 8:
                            self.task = 'loose'
                            self.version = mayafile[7]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, self.version )

                        if rebuild == self.mayafile:
                            return True
                        else:
                            return False
                    except:
                        return False

                # SHOTS
                elif 'sh_' in mayafile[3]:
                    self.shot = mayafile[3]
                    self.shotproj = True

                    try:
                        if len(mayafile) == 7:
                            self.task = mayafile[5]
                            self.version = mayafile[6]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.task, self.version )
                        elif len(mayafile) == 6:
                            self.task = 'loose'
                            self.version = mayafile[5]
                            rebuild = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes', self.version )
                        if rebuild == self.mayafile:
                            return True
                        else:
                            return False
                    except:
                        return False