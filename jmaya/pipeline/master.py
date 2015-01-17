'''
this module concerns the mastering of asset scenes. only assets can be mastered, not shots.

we dont need any complicated ui's, so i'm using simple maya.cmds to pop open a confirm dialog.

the master dir is located at the root of the asset, for example,
/mnt/bertie/Jobs/999955_UNIT_jeeves/vfx/3d/3d_assets/Scenes/Characters/adult/master

'''
print '> importing jmaya.pipeline.master'
import os, shutil, sys
import core
import core.job as job
import core.assets as assets
import maya.cmds as cmds
import jmaya.pipeline.workspace

sys.dont_write_bytecode = True

class master_cleanup(object):
    '''
    this class is unused at the moment, it is intended that it be used to cleanup a scene prior to mastering,
    because there is currently no option in the ui to select it and becuase i dont want to alter the scene without
    the ops knowledge, it isnt called, but everything is here to do that cleanup, such as setting the fps and scene units
    '''
    def __init__(self, ):
        print '\t> jmaya.pipeline.master.master_cleanup'
        
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
    '''
    this is the class that is called from the jeeves ui
    
    it is passed no arguements, it simply takes the currently opened scene and masters it out and if required
    moves an existing master to an archive folder
    
    firstly, we initiate some vars we need eg self.job, self.asset etc etc
    
    we then save the scene
    
    we then take the filepath, split it up and rebuild it so that we can be sure that we know where we are on the
    filesystem, self.master_vars. if that completes fine, we have our vars
    
    then we build the path to the master dir and master file, self.master_paths
    
    we then make sure that the master dir exists and if not, we create it, self.master_dirs
    
    finally, we copy the opened scene into the master dir and name it accordingly. if a master in that dir exists, we
    move it to an old folder. prior to confirming any of this a simple dialog opens up to confirm that the user wants to
    proceeed.
    
    in addition to copying the file to the master path / name, we also copy the current scene to that location and retain
    the name so that we always know what file made that master
    '''
    def __init__(self):
        print '\t> jmaya.pipeline.master'
        
        # first things first lets check the workspace        
        if not jmaya.pipeline.workspace.check_workspace():
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
        '''
        we prompt the user to confirm the action of saving out the master file, copying the version to the same dir
        and if required moving a current master to old
        '''
        print '\t> jmaya.pipeline.master.master_file'
        
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
        '''
        we build the path the to master dir and the master name.
        
        the dictionary is used to abbreviate the asset categories to a 3 letter acronym
        '''
        print '\t> jmaya.pipeline.master.master_paths'
        
        cat_abr = {'characters' : 'cha',
           'Characters' : 'cha',
           'environments' : 'env',
           'Environments' : 'env',
           'props' :'pro',
           'Props' :'pro'}
        
        self.masterpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, '3d_assets', 'Scenes', self.category, self.asset, 'master')
        self.mastername = '%s_%s.mb' % (cat_abr[self.category], self.asset)
        
    def master_dirs(self):
        '''
        checking to make sure that the master dir exists, if not we create it
        '''
        print '\t> jmaya.pipeline.master.master_dirs'
        
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
        '''
        this isnt currently used, but the method can be called to update the dictionary with the new data concerning
        the master files
        '''
        print '\t> jmaya.pipeline.master.master_dict'
        self.jobdict = job.lookup(searchtext = self.job).jobdict
        self.jobdict = assets.categorylookup(self.jobdict).jobdict
        self.jobdict = assets.assetlookup(self.jobdict, self.category).jobdict
        self.jobdict = assets.masterlookup(self.jobdict, self.category, self.asset).jobdict

    def master_vars(self):
        '''
        this method splits up the current scene filepath on os.path.sep, and then picks out indexes and then binds them to
        self.vars so that we can then rebuild the filepath. if the rebuilt path and known scene file match, we have rebuilt it
        correctly, meaning to know everything about the file. we can then proceed.
        
        we need those vars to create the master path and master name
        '''
        print '\t> jmaya.pipeline.master.master_vars'
        
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