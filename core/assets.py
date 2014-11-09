print '> importing core.assets'
import core
import os, sys

#***************************************************************************************************************
# CATEGORIES
#***************************************************************************************************************

class categorylookup(object):
    def __init__(self, jobdict):
        print '\t> core.assets.categorylookup'
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.asset_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes')
        
        self.validcategories = ['props', 'environments', 'characters', 'Props', 'Environments', 'Characters']
        self.get_categories()
    
    def get_categories(self):
        self.jobdict[self.job]['3d']['assets'] = {}
        
        self.asset_categories = []
        for category in os.listdir(self.asset_root):
            if os.path.isdir(os.path.join(self.asset_root, category)):
                if category in self.validcategories:
                    self.asset_categories.append(category)
                    self.jobdict[self.job]['3d']['assets'][category] = {}

#***************************************************************************************************************
# ASSETS
#***************************************************************************************************************

class assetlookup(object):
    def __init__(self, jobdict, category):
        print '\t> %s > core.assets.assetlookup' % category
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.category = category
        self.category_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.category)
        
        self.get_assets()
    
    def get_assets(self):
        self.jobdict[self.job]['3d']['assets'][self.category] = {}
        
        self.assets = []
        self.loose = []
        for asset in os.listdir(self.category_root):
            if os.path.isdir(os.path.join(self.category_root, asset)):
                if not os.path.join(self.category_root, asset).startswith('.'):
                    if not asset == '.mayaSwatches':
                        self.assets.append(asset)
                        self.jobdict[self.job]['3d']['assets'][self.category][asset] = {}
            elif os.path.isfile(os.path.join(self.category_root, asset)):
                if not os.path.join(self.category_root, asset).startswith('.'):
                    self.loose.append(asset)
        
        #print self.loose
        
        try:
            self.jobdict[self.job]['3d']['assets'][self.category]['loose']['working'] = self.loose
        except:
            pass
#***************************************************************************************************************
# TASKS
#***************************************************************************************************************

class tasklookup(object):
    def __init__(self, jobdict, category, asset):
        print '\t> %s > %s > core.assets.tasklookup' % (category, asset)
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.category = category
        self.asset = asset
        self.asset_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.category, self.asset)
        
        self.validtasks =  ['ani','lig','lay','sim','rig', 'mod', 'base', 'animation', 'lighting', 'layout', 'simulation', 'modelling', 'tracking', 'rigging']
        self.get_tasks()
    
    def get_tasks(self):
        self.tasks = []
        
        if os.path.isdir(self.asset_root):
            for task in os.listdir(self.asset_root):
                if os.path.isdir(os.path.join(self.asset_root, task)):
                    if task in self.validtasks:
                        self.tasks.append(task)
                        self.jobdict[self.job]['3d']['assets'][self.category][self.asset][task] = {}
                elif os.path.isfile(os.path.join(self.asset_root, task)):
                    if not task.startswith('.'):
                        if not self.jobdict[self.job]['3d']['assets'][self.category][self.asset].has_key('loose'):  
                            self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['loose'] = {}

#***************************************************************************************************************
# VERSIONS
#***************************************************************************************************************

class versionlookup(object):
    def __init__(self, jobdict, category, asset, task):
        print '\t> %s > %s > %s > core.assets.versionlookup' % (category, asset, task)
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.category = category
        self.asset = asset
        self.task = task
        self.exts = ('ma','mb','nk')
        
        if self.task == 'loose':
            self.task_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.category, self.asset)
        else:
            self.task_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.category, self.asset, self.task)
    
        self.get_versions()

    def get_versions(self):
        self.versions = []
        self.jobdict[self.job]['3d']['assets'][self.category][self.asset][self.task]['working'] = []
        
        for version in os.listdir(self.task_root):
            if version.endswith(self.exts):
                self.versions.append(version)
                self.jobdict[self.job]['3d']['assets'][self.category][self.asset][self.task]['working'].append(version)
        return self.versions

#***************************************************************************************************************
# MASTERS
#***************************************************************************************************************
   
class masterlookup(object):
    def __init__(self, jobdict, category, asset):
        print '\t> %s > %s > core.assets.masterlookup' % (category, asset)
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.category = category
        self.asset = asset
        self.exts = ('ma','mb','nk')
        
        self.master_root = os.path.join(core.jobsRoot, self.job, 'vfx', '3d', '3d_assets', 'Scenes', self.category, self.asset, 'master')
            
        #check for master path
        if os.path.isdir(self.master_root):
            self.get_masters()

    def get_masters(self):
        self.masters = []
        self.previous = []
        self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['masters'] = {}
        self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['masters']['current'] = []
        
        for master in os.listdir(self.master_root):
            if master.endswith(self.exts):
                self.masters.append(master)
                self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['masters']['current'].append(master)
        
        #check for old folder
        if os.path.isdir(os.path.join(self.master_root, 'old')):
            self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['masters']['previous'] = []
            for previous in os.listdir(os.path.join(self.master_root, 'old')):
                if previous.endswith(self.exts):
                    self.previous.append(previous)
                    self.jobdict[self.job]['3d']['assets'][self.category][self.asset]['masters']['previous'].append(previous)

        return self.masters

def asset_add():
    pass

def asset_delete():
    pass