print '> importing core.shots'
import core
import os, sys

from xmlrpclib import ServerProxy
server = ServerProxy("http://192.168.0.9:9000",)
server.allow_none=True

#***************************************************************************************************************
# SHOTS
#***************************************************************************************************************
class shotslookup(object):
    '''
    - this is used by both scenes classes and renders classes
    - this receives jobdict with nuke and 3d keys in
    - it adds to either the nuke or 3d keys of jobdict, populated with shots - never both depts
    - it simply matches dirs if they start 'sh_'
    - could easily be replaced by a db call for shots
    '''
    
    def __init__(self, jobdict, dept):
        print '\t> %s > core.shots.shotslookup' % dept
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.dept = dept
        
        self.getshots()

    def getshots(self):
        self.shots = []
        self.jobdict[self.job][self.dept]['shots'] = {}
        self.deptroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept)

        for shot in os.listdir(self.deptroot):
            if shot.startswith('sh_'):
                if os.path.isdir(os.path.join(self.deptroot, shot)):
                    self.shots.append(shot)
                    self.jobdict[self.job][self.dept]['shots'][shot] = {}

#***************************************************************************************************************
# TASKS
#***************************************************************************************************************
class taskslookup(object):
    '''
    - we use the config to say if its a complex or simple shot - then listdir to add the tasks
    - first we set up some vars
    - here, user folders for nuke are treated like tasks, may as well...
    - receives the jobdict, the dept and the shot
    - this is the first time there is potential for things to break
    - the default method is to listdir the shot for tasks - if they match valid tasks, we add them to jobdict - so there is some checking going on
    - there is provision for the tasks to be added from a true disk read, a db call or from a cfg file
    - complex or simple schemas available for 3d, not for nuke, not needed
    '''
    
    def __init__(self, jobdict, dept, shot):
        print '\t> %s > %s > core.shots.taskslookup' % (dept, shot)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        
        if self.dept == '3d':
            self.shotroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Scenes')
            self.validtasks =  ['ani','lig','lay','sim','rig', 'base', 'animation', 'lighting', 'layout', 'simulation', 'modelling', 'tracking', 'rigging', 'light']
            
            self.jobdict[self.job][self.dept]['shots'][self.shot]['scenes'] = self.tasks_3d()

        elif self.dept == 'nuke':
            self.shotroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'scripts')
            
            self.validtasks = []
            for each in core.userlist:
                if core.userlist[each]['dept'] == 'nuke':
                    self.validtasks.append(each)
            
            self.jobdict[self.job][self.dept]['shots'][self.shot]['scripts'] = self.tasks_nuke()

    def tasks_3d(self):
        taskdict = {}
        self.exts = ('ma','mb','nk')

        self.tasks = []
        self.loose = []
        taskdict['loose'] = []
        
        for task in os.listdir(self.shotroot):
            if os.path.isdir(os.path.join(self.shotroot, task)):
                if task in self.validtasks:
                    taskdict[task] = {}
                    self.tasks.append(task)
            elif os.path.isfile(os.path.join(self.shotroot, task)):
                if not task.startswith('.'):
                    if task.endswith(self.exts):
                        taskdict['loose'].append(task)
                        self.loose.append(task)
        
        return taskdict

    def tasks_nuke(self):
        taskdict = {}
        self.tasks = []
        for task in os.listdir(self.shotroot):
            if os.path.isdir(os.path.join(self.shotroot, task)):
                if task in self.validtasks:
                    taskdict[task] = []
                    self.tasks.append(task)
        
        return taskdict

#***************************************************************************************************************
# VERSIONS
#***************************************************************************************************************
class versionslookup(object):
    '''
    - match by extension and if it is a file
    '''
    def __init__(self, jobdict, dept, shot, task):
        print '\t> %s > %s > %s > core.shots.versionslookup' % (dept, shot, task)
        #if task == 'loose':
        #    print 'loose'
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.task = task
        self.exts = ('ma','mb','nk')

        if dept == 'nuke':
            self.taskroot = os.path.join(core.jobsRoot, self.job, 'vfx', dept, shot, 'scripts', task)
            self.jobdict[self.job][dept]['shots'][shot]['scripts'][task] = self.find_versions()
        elif dept == '3d':
            if not self.task == 'loose':
                self.taskroot = os.path.join(core.jobsRoot, self.job, 'vfx', dept, shot, 'Scenes', task)
                self.jobdict[self.job][dept]['shots'][shot]['scenes'][self.task] = self.find_versions()
        
    def find_versions(self):
        self.versions = []
        for each in os.listdir(self.taskroot):
            if each.endswith(self.exts):
                self.versions.append(each)
        return self.versions

#***************************************************************************************************************
# PUBLISHES
#***************************************************************************************************************
class publisheslookup(object):
    '''
    - match by extension and if it is a file
    - valid only for 3d at the mo - looks in the cache folder of the maya / soft project and adds keys for alembic and fbx etc
    '''
    def __init__(self, jobdict, dept, shot):
        print '\t> %s > %s > core.shots.publisheslookup' % (dept, shot)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.exts = ('abc', 'fbx')
        
        self.jobdict[self.job][dept]['shots'][shot]['publishes'] = {}
        
        if dept == 'nuke':
            pass
        elif dept == '3d':
            try:
                self.cache_root = os.path.join(core.jobsRoot, self.job, 'vfx', dept, shot, 'cache')
                for cachetype in os.listdir(self.cache_root):
                    if os.path.join(self.cache_root, cachetype) and cachetype in ['alembic', 'fbx']:
                        self.cache = os.path.join(self.cache_root, cachetype)
                        self.cache_old = os.path.join(self.cache_root, cachetype, 'old')
                        self.jobdict[self.job][dept]['shots'][shot]['publishes'][cachetype] = {}
                        self.jobdict[self.job][dept]['shots'][shot]['publishes'][cachetype]['current'] = self.find_3d_pubs(self.cache)
                        self.jobdict[self.job][dept]['shots'][shot]['publishes'][cachetype]['old'] = self.find_3d_pubs(self.cache_old)
            except:
                return
        
    def find_3d_pubs(self, pub):
        self.pub_curr  = []
        try:
            for publish in os.listdir(pub):
                if publish.endswith(self.exts):
                    # check if the task is in the name of the pub 
                    #if self.task in publish:
                    self.pub_curr.append(publish)
        except:
            pass
        return self.pub_curr

#***************************************************************************************************************
# MODIFY SHOTS
#***************************************************************************************************************
def shot_add(job, rawshot):
    if rawshot.startswith('sh_'):
        rawshot = rawshot.split('sh_')[1]
    newshot = 'sh_' + rawshot.replace(' ', '_')
    
    if os.path.isdir(os.path.join(core.jobsRoot, job, 'vfx', '3d', newshot)) or os.path.isdir(os.path.join(core.jobsRoot, job, 'vfx', 'nuke', newshot)):
        pass
        #print 'SHOT EXISTS'
    else:
        #print 'MAKING SHOT'

        nuke_shot = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'nuke', newshot).replace('\\', '/')
        soft_shot = os.path.join('/mnt/bertie/Jobs', job, 'vfx', '3d', newshot).replace('\\', '/')
        track_shot = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'tracking', newshot).replace('\\', '/')
    
        #NUKE
        nuke_base = ['mkdir', '%s' % nuke_shot]
        nuke_plates = ['mkdir', '%s/plates' % nuke_shot]
        nuke_scripts = ['mkdir', '%s/scripts' % nuke_shot]
        nuke_plates_output = ['mkdir', '%s/plates/output' % nuke_shot]
        nuke_plates_input = ['mkdir', '%s/plates/input' % nuke_shot]
    
        #SOFT
        soft_base = ['cp', '-r', '%s' % '/mnt/resources/vfx/pipeline/jeeves/core/3d_shot', '%s' %  soft_shot]
        soft_pictures = ['ln', '-s','%s' % os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'assets', 'sourceimages').replace('\\','/'), '%s/Pictures' % soft_shot]
        soft_models = ['ln', '-s', '%s' % os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'assets', 'models').replace('\\','/'), '%s/Models' % soft_shot]
    
        #TRACK
        track_base = ['mkdir', '%s' % track_shot]
        track_project = ['mkdir', '%s/project' % track_shot]
        track_data = ['mkdir', '%s/solve' % track_shot]
        
        #CHMOD
        chmod_dir = ['chmod', '-R', '777', '%s' % nuke_shot, '%s' % track_shot, '%s' % soft_shot, '%s'  % os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'assets').replace('\\','/')]
        chgrp_dir = ['chgrp', '-R', 'games', '%s' % nuke_shot, '%s' % track_shot, '%s' % soft_shot, '%s' % os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'assets').replace('\\','/')]
        chown_dir = ['chown', '-R', 'unitadmin', '%s' % nuke_shot, '%s' % track_shot, '%s' % soft_shot, '%s' % os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'assets').replace('\\','/')]
                
        #COMMAND LIST
        cmd_list = [track_base, track_project, track_data, nuke_base, nuke_plates, nuke_plates_output, nuke_plates_input, nuke_scripts, soft_base, soft_pictures, soft_models, chmod_dir, chgrp_dir, chown_dir]
        
        for i in cmd_list:
            print i
        
        if not server.make_shot(cmd_list):
            #print 'FAILED'
            return False
        else:
            #print 'SUCCESS'
            return True

def shot_delete(job, shot):
    if os.path.isdir(os.path.join(core.jobsRoot, job, 'vfx', '3d', shot)):
        #print 'SHOT EXISTS'
        nuke = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'nuke', shot)
        hidenuke = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'nuke', '.%s' % shot)
        maya = os.path.join('/mnt/bertie/Jobs', job, 'vfx', '3d', shot)
        hidemaya = os.path.join('/mnt/bertie/Jobs', job, 'vfx', '3d', '.%s' % shot)
        track = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'tracking', shot)
        hidetrack = os.path.join('/mnt/bertie/Jobs', job, 'vfx', 'tracking', '.%s' % shot)

        del_nuke = ['rm', '-rf', '%s' % nuke]
        del_maya = ['rm', '-rf', '%s' % maya]
        del_track = ['rm', '-rf', '%s' % track]
        
        mv_track = ['mv', '%s' % track, '%s' % hidetrack]
        mv_nuke = ['mv', '%s' % nuke, '%s' % hidenuke]
        mv_maya = ['mv', '%s' % maya, '%s' % hidemaya]
        
        cmd_list = [mv_nuke, mv_maya, mv_track]
        
        #for each in cmd_list:
        #    print each
        
        if not server.make_shot(cmd_list):
            #print 'FAILED'
            return False
        else:
            #print 'SUCCESS'
            return True
    else:
        #print 'SHOT DOES NOT EXIST'
        pass

sys.dont_write_bytecode = True