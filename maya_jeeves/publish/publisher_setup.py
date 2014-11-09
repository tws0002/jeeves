print '> importing maya_jeeves.publish.publisher_setup'
import os, pickle, sys
import core
import core.job as job
import core.shots as shots
import maya.cmds as cmds
import maya_jeeves.workspace

class publish_save(object):
    def __init__(self):
        print '\t> maya_jeeves.publish.publisher_setup.publish_save'
        
        self.publishtype = 'abc'
        
        # first things first lets check the workspace        
        if not maya_jeeves.workspace.check_workspace():
            return
        
        # these are the vars were after
        self.job = None
        self.dept = None
        self.shot = None
        self.task = None
        self.version = None
        self.publish = None

        #lets save the current scene and get the full filepath
        cmds.file(s=True)
        self.mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
        self.mayafile = os.path.normpath(self.mayafile)
        
        self.cmd_list = []
        
        #publish_options()
        
        if self.publish_vars():
            self.publish_paths()
            self.publish_dirs()
            #self.publish_file()
            if self.publish_ui():
                print '\t> PUBLISH SAVED'
        else:
            print '\t> PUBLISH NOT SAVED'

    def publish_ui(self):
        print '\t> maya_jeeves.publish.publisher_setup.publish_ui'
        
        self.frame_start = cmds.playbackOptions(query=True, minTime=True)
        self.frame_end = cmds.playbackOptions(query=True, maxTime=True)
        self.sets = []
        #self.file_name = os.path.join(self.publishpath, self.publishname)

        import maya_jeeves.publish.publisher_ui;reload(maya_jeeves.publish.publisher_ui)
        maya_jeeves.publish.publisher_ui.runMaya(self)

    def publish_paths(self):
        print '\t> maya_jeeves.publish.publisher_setup.publish_paths'
        
        if self.publishtype == 'abc':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'alembic')
        
        elif self.publishtype == 'fbx':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'fbx')

        elif self.publishtype == 'geo':
            self.publishpath = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'cache', 'geo')

        self.validtasks = {'ani' : 'animation',
                           'sim' : 'simulation',
                           'rig' : 'rigging',
                           'mod' : 'modelling',
                           'lay' : 'layout',
                           }

        if self.task == 'loose':
            self.publishname = '%s_pub.%s' % (self.shot, self.publishtype)
            for each in self.validtasks.keys():
                if each in self.version:
                    task = self.validtasks[each]
                    self.publishname = '%s_%s_pub.%s' % (self.shot, task, self.publishtype)

        else:
            self.publishname = '%s_%s_pub.%s' % (self.shot, self.task, self.publishtype)

        #print self.publishpath
        #print self.publishname

    def publish_dirs(self):
        print '\t> maya_jeeves.publish.publisher_setup.publish_dirs'
        
        #if 'old' exists, retrun need to do nothing
        if os.path.isdir(os.path.join(self.publishpath, 'old')):
            return

        #if publish exists, but old doenst
        if os.path.isdir(self.publishpath):
            if not os.path.isdir(os.path.join(self.publishpath, 'old')):
                os.makedirs(os.path.join(self.publishpath, 'old'))
                #make_pub_old = ['mkdir', '%s' % os.path.join(self.publishpath, 'old')]
                #self.cmd_list.append(make_pub_old)
        
        #if the pub dir doenst exist - make it and old
        else:
            os.makedirs(os.path.join(self.publishpath, 'old'))
            #make_pub = ['mkdir', '%s' % self.publishpath]
            #make_pub_old = ['mkdir', '%s' % os.path.join(self.publishpath, 'old')]
            #self.cmd_list.append(make_pub)
            #self.cmd_list.append(make_pub_old)

    def publish_vars(self):
        print '\t> maya_jeeves.publish.publisher_setup.publish_vars'
        
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
                if 'sh_' in mayafile[3]:
                    self.shot = mayafile[3]
                    try:                    
                        #index 5 will be either the task or verison
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
                if mayafile[3] == '3d_assets':
                    print '\t> CANNOT PUBLISH AN ASSET'
                    cmds.confirmDialog( title='Publish' ,  message='Cannot publish an asset scene', button=['Ok'], defaultButton='Yes', cancelButton='No', dismissString='No' )

                    return False