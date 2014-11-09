print '> importing maya_jeeves.master'
import os, shutil
import core
import core.job as job
import core.assets as assets
import maya.cmds as cmds
import maya_jeeves.workspace

from xmlrpclib import ServerProxy
server = ServerProxy("http://192.168.0.9:9000",)
server.allow_none=True

class master_cleanup(object):
    def __init__(self, ):
        print '\t> maya_jeeves.master.master_cleanup'
        
        #options
        self.namespaces = False
        self.shaders = False
        self.nodes = False
        self.fps = True
        self.units = True
        
        if self.fps:
            self.set_fps()
        
        if self.units:
            self.set_units()
                
        if self.namespaces:
            self.del_namespaces()
        
        if self.shaders:
            self.del_shaders()
        
        if self.nodes:
            self.del_unknowns()
    
    def del_unknowns(self):
        unknown_nodes = cmds.ls(type='unknown')
        for node in unknown_nodes:
            cmds.delete(node)
    
    def del_shaders(self ):
        mel.eval('hyperShadePanelMenuCommand("hyperShadePanel1", "deleteUnusedNodes");')
    
    def del_namespaces(self ):
        all_namespaces = cmds.namespaceInfo( lon=True )
        excl_namespaces = ['UI', 'shared']

        for each in all_namespaces:
            if each not in excl_namespaces:
                cmds.namespace( removeNamespace=each, mergeNamespaceWithRoot=True)
    
    def set_units(self):
        self.current_units = cmds.currentUnit(q = True, linear=True )
        if not self.current_units == 'cm':
            cmds.currentUnit(linear='cm')
    
    def set_fps(self, ):
        self.current_framerate = cmds.currentUnit(q = True, time=True )
        if not self.current_framerate == 'pal':
            cmds.currentUnit(time='pal')

class master_save(object):
    def __init__(self):
        print '\t> maya_jeeves.master'
        
        # first things first lets check the workspace        
        if not maya_jeeves.workspace.check_workspace():
            return
        
        # these are the vars were after
        self.job = None
        self.dept = None
        self.category = None
        self.asset = None
        self.task = None
        self.version = None
        self.masters = None
        
        #lets save the current scene and get the full filepath
        cmds.file(s=True)
        self.mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        self.mayafile = os.path.normpath(self.mayafile)
        
        self.cmd_list = []
        
        if self.master_vars():
            self.master_paths()
            self.master_dirs()
            if self.master_file():
                print '\t> MASTER SAVED'
            else:
                print '\t> MASTER NOT SAVED'
        else:
            print '\t> MASTER NOT SAVED'        

    def master_file(self):
        print '\t> maya_jeeves.master.master_file'
        
        #lets check for a master file and for its corresponding dot file       
        master_version = ''
        try:
            if os.path.isfile(os.path.join(self.masterpath, self.mastername)):          
                for each in os.listdir(self.masterpath):
                    if each.startswith('.'):
                        if not each == '.DS_Store':
                            master_version = each
                
                #check for dot file            
                if master_version:
                    current_master = os.path.join(self.masterpath, master_version)
                    old_master = os.path.join(self.masterpath, 'old', master_version[1:])
                    
                    text = '%s\n\nExisting master will move to :\n\n%s\n\nAre you sure?' % (os.path.join(self.masterpath, self.mastername), old_master)
                    result = cmds.confirmDialog( title='Confirm Master File :' ,  message=text, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
                    
                    if result == 'Yes':
                        #move the current_master to old and take off the dot
                        shutil.move(current_master, old_master)
                        os.remove(os.path.join(self.masterpath, self.mastername))
    
            #make the current masters - inform of new master 
            shutil.copy2(self.mayafile, os.path.join(self.masterpath, '.%s' % self.version))
            shutil.copy2(self.mayafile, os.path.join(self.masterpath, self.mastername))
            return True
        
        except:
            return False

    def master_paths(self):
        print '\t> maya_jeeves.master.master_paths'
        
        cat_abr = {'characters' : 'cha',
           'Characters' : 'cha',
           'environments' : 'env',
           'Environments' : 'env',
           'props' :'pro',
           'Props' :'pro'}
        
        self.masterpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, 'master')
        self.mastername = '%s_%s.mb' % (cat_abr[self.category], self.asset)
        
    def master_dirs(self):
        print '\t> maya_jeeves.master.master_dirs'
        
        masterpath = os.path.normpath(self.masterpath)
        masterpath = masterpath.replace(core.jobsRoot, '/mnt/bertie/Jobs').replace('\\','/')
        
        #if 'old' exists, retrun need to do nothing
        if os.path.isdir(os.path.join(self.masterpath, 'old')):
            return

        #if master exists, but old doenst
        if os.path.isdir(self.masterpath):
            if not os.path.isdir(os.path.join(self.masterpath, 'old')):
                os.makedirs(os.path.join(self.masterpath, 'old'))
        
        #if the master dir doenst exist - make it and old
        else:
            os.makedirs(os.path.join(self.masterpath, 'old'))


    def master_dict(self):
        print '\t> maya_jeeves.master.master_dict'
        self.jobdict = job.lookup(searchtext = self.job).jobdict
        self.jobdict = assets.categorylookup(self.jobdict).jobdict
        self.jobdict = assets.assetlookup(self.jobdict, self.category).jobdict
        #self.jobdict = assets.tasklookup(self.jobdict, self.category, self.asset).jobdict
        #self.jobdict = assets.versionlookup(self.jobdict, self.category, self.asset, self.task).jobdict
        self.jobdict = assets.masterlookup(self.jobdict, self.category, self.asset).jobdict

    def master_vars(self):
        print '\t> maya_jeeves.master.master_vars'
        
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
                
                #index 3 should be the 3d_assets folder
                if mayafile[3] == '3d_assets':
                    
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
                
                elif 'sh_' in mayafile[3]:
                    print '\t> CANNOT MASTER A SHOT'
                    cmds.confirmDialog( title='Master' ,  message='Cannot master a shot scene', button=['Ok'], defaultButton='Yes', cancelButton='No', dismissString='No' )

                    return False