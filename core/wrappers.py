'''
this is really the module that wraps the job, shots, assets and renders modules together in one, so that you can
pass it various combinations of arguements and receive back a dictionary. if you give lots of arguements, you'll
recieve back a dict with very specific data in. if you only give it the job number, you'll receive back a dict
with loads of data in.

there are three main classes: get_scenes, get_renders and get_assets. fairly self explanatory.

this module is used by the jeeves gui to populate drop downs and list boxes of the shots, scripts etc.
'''
print '> importing core.wrappers'
import core.shots as shots
import core.renders as renders
import core.assets as assets

#***************************************************************************************************************
# SCENES / SHOTS / SCRIPTS
#***************************************************************************************************************

class get_scenes(object):
    '''
    this should perhaps be called get_shots, but it's not.
    at the very least you need to give a jobdict, additional args such as dept, shot and task can also be given.
    the __init__ method determines what args are given and calls the relevant classes in the shots module
    '''
    def __init__(self, jobdict, dept = '', shot = '', task = ''):
        self.jobdict = jobdict
        self.job = self.jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.task = task
        
        if self.dept and self.shot and self.task:
            # GIVEN A DEPT AND A SHOT AND A TASK
            if self.dept == '3d':
                self.jobdict = shots.shotslookup(self.jobdict, dept = '3d').jobdict
                self.jobdict = shots.taskslookup(self.jobdict, dept = '3d', shot = shot).jobdict
                self.jobdict = shots.versionslookup(self.jobdict, dept = '3d', shot = shot, task = task).jobdict
                self.jobdict = shots.publisheslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            
            elif self.dept == 'nuke':
                self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict
                self.jobdict = shots.taskslookup(self.jobdict, dept = 'nuke', shot = shot).jobdict
                self.jobdict = shots.versionslookup(self.jobdict, dept = 'nuke', shot = shot, task = task).jobdict

        elif self.dept and self.shot:
            # GIVEN A DEPT AND A SHOT
            if self.dept == '3d':
                self.jobdict = shots.shotslookup(self.jobdict, dept = '3d').jobdict
                self.jobdict = shots.taskslookup(self.jobdict, dept = '3d', shot = shot).jobdict
                
                for task in self.jobdict[self.job]['3d']['shots'][shot]['scenes']:
                    self.jobdict = shots.versionslookup(self.jobdict, dept = '3d', shot = shot, task = task).jobdict
                    self.jobdict = shots.publisheslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            
            elif self.dept == 'nuke':
                self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict
                self.jobdict = shots.taskslookup(self.jobdict, dept = 'nuke', shot = shot).jobdict
                
                for task in self.jobdict[self.job]['nuke']['shots'][shot]['scripts']:
                    self.jobdict = shots.versionslookup(self.jobdict, dept = 'nuke', shot = shot, task = task).jobdict
        
        elif self.dept:
            # GIVEN A DEPT - NO SHOT
            if self.dept == '3d':
                self.jobdict = shots.shotslookup(self.jobdict, dept = '3d').jobdict
                
                for shot in self.jobdict[self.job]['3d']['shots']:
                    self.jobdict = shots.taskslookup(self.jobdict, dept = '3d', shot = shot).jobdict
                    for task in self.jobdict[self.job]['3d']['shots'][shot]['scenes']:
                        self.jobdict = shots.versionslookup(self.jobdict, dept = '3d', shot = shot, task = task).jobdict
                        self.jobdict = shots.publisheslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            elif self.dept == 'nuke':
                self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict
                
                for shot in self.jobdict[self.job]['nuke']['shots']:
                    self.jobdict = shots.taskslookup(self.jobdict, dept = 'nuke', shot = shot).jobdict
                    for task in self.jobdict[self.job]['nuke']['shots'][shot]['scripts']:
                        self.jobdict = shots.versionslookup(self.jobdict, dept = 'nuke', shot = shot, task = task).jobdict
        
        elif self.shot:
            # GIVEN A SHOT - NO DEPT
            self.jobdict = shots.shotslookup(self.jobdict, dept = '3d').jobdict
            self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict
            self.jobdict = shots.taskslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            self.jobdict = shots.taskslookup(self.jobdict, dept = 'nuke', shot = shot).jobdict
            
            for task in self.jobdict[self.job]['3d']['shots'][shot]['scenes']:
                self.jobdict = shots.versionslookup(self.jobdict, dept = '3d', shot = shot, task = task).jobdict
                self.jobdict = shots.publisheslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            
            for task in self.jobdict[self.job]['nuke']['shots'][shot]['scripts']:
                self.jobdict = shots.versionslookup(self.jobdict, dept = 'nuke', shot = shot, task = task).jobdict
        
        else:
            # JUST A JOB DICT
            self.jobdict = shots.shotslookup(self.jobdict, dept = '3d').jobdict
            self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict
            
            for shot in self.jobdict[self.job]['3d']['shots']:
                self.jobdict = shots.taskslookup(self.jobdict, dept = '3d', shot = shot).jobdict
                for task in self.jobdict[self.job]['3d']['shots'][shot]['scenes']:
                    self.jobdict = shots.versionslookup(self.jobdict, dept = '3d', shot = shot, task = task).jobdict
                    self.jobdict = shots.publisheslookup(self.jobdict, dept = '3d', shot = shot).jobdict
            
            for shot in self.jobdict[self.job]['nuke']['shots']:
                self.jobdict = shots.taskslookup(self.jobdict, dept = 'nuke', shot = shot).jobdict
                for task in self.jobdict[self.job]['nuke']['shots'][shot]['scripts']:
                    self.jobdict = shots.versionslookup(self.jobdict, dept = 'nuke', shot = shot, task = task).jobdict

#***************************************************************************************************************
# RENDERS
#***************************************************************************************************************

class get_renders(object):
    '''
    at the very least you need to give a jobdict, additional args such as dept and shot can also be given.
    the __init__ method determines what args are given and calls a subsequent class in this module, one for
    3d and other for nuke. the __init__ methods in those classes then fire off calls to the renders module for
    the lookup
    '''
    def __init__(self, jobdict, dept = '', shot = ''):
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept  = dept
        self.shot = shot
        
        if dept and shot:
            if dept == '3d':
                self.jobdict = get_renders_3d(self.jobdict, self.shot).jobdict
            elif dept == 'nuke':
                self.jobdict = get_renders_nuke(self.jobdict, self.shot).jobdict
        
        elif dept:
            if dept == '3d':
                self.jobdict = get_renders_3d(self.jobdict).jobdict
            elif dept == 'nuke':
                self.jobdict = get_renders_nuke(self.jobdict).jobdict
        
        elif shot:
            self.jobdict = get_renders_3d(self.jobdict, self.shot).jobdict
            self.jobdict = get_renders_nuke(self.jobdict, self.shot).jobdict
        
        else:            
            self.jobdict = get_renders_3d(self.jobdict).jobdict
            self.jobdict = get_renders_nuke(self.jobdict).jobdict

#***************************************************************************************************************
# RENDERS NUKE
#***************************************************************************************************************

class get_renders_nuke(object):
    def __init__(self, jobdict, shot = '', direction = '', category = '', version = ''):
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        
        self.dept = 'nuke'
        self.shot = shot
        self.direction = direction
        self.category = category
        self.version = version
        
        #***************************************************************************************************************
        if self.shot and self.direction and self.category and self.version:
            print '\t> %s > %s > %s > %s > core.wrappers.get_renders_nuke' % (self.shot, self.direction, self.category, self.version)
            
            self.jobdict = shots.shotslookup(self.jobdict, dept = self.dept).jobdict    
            self.jobdict = renders.render_nuke_direction(self.jobdict, dept = 'nuke', shot = shot).jobdict
            self.jobdict = renders.render_nuke_categories(self.jobdict, dept = 'nuke', shot = shot, direction = direction).jobdict
            self.jobdict = renders.render_nuke_versions(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category).jobdict
            self.jobdict = renders.render_nuke_passes(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category, version = version).jobdict

        #***************************************************************************************************************
        elif self.shot and self.direction and self.category:
            print '\t> %s > %s > %s > core.wrappers.get_renders_nuke' % (self.shot, self.direction, self.category)
            self.jobdict = shots.shotslookup(self.jobdict, dept = self.dept).jobdict    
            self.jobdict = renders.render_nuke_direction(self.jobdict, dept = 'nuke', shot = shot).jobdict
            self.jobdict = renders.render_nuke_categories(self.jobdict, dept = 'nuke', shot = shot, direction = direction).jobdict
            self.jobdict = renders.render_nuke_versions(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category).jobdict
            
            for version in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction][category]:
                self.jobdict = renders.render_nuke_passes(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category, version = version).jobdict

        #***************************************************************************************************************
        elif self.shot and self.direction:
            print '\t> %s > %s > core.wrappers.get_renders_nuke' % (self.shot, self.direction)
            self.jobdict = shots.shotslookup(self.jobdict, dept = self.dept).jobdict
            self.jobdict = renders.render_nuke_direction(self.jobdict, dept = 'nuke', shot = shot).jobdict
            self.jobdict = renders.render_nuke_categories(self.jobdict, dept = 'nuke', shot = shot, direction = direction).jobdict
            
            for category in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction]:
                self.jobdict = renders.render_nuke_versions(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category).jobdict
                for version in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction][category]:
                    self.jobdict = renders.render_nuke_passes(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category, version = version).jobdict
                
        #***************************************************************************************************************
        elif self.shot:
            print '\t> %s > core.wrappers.get_renders_nuke' % (self.shot)
            self.jobdict = shots.shotslookup(self.jobdict, dept = self.dept).jobdict  
            self.jobdict = renders.render_nuke_direction(self.jobdict, dept = 'nuke', shot = shot).jobdict
            
            for direction in self.jobdict[self.job]['nuke']['shots'][shot]['renders']:
                self.jobdict = renders.render_nuke_categories(self.jobdict, dept = 'nuke', shot = shot, direction = direction).jobdict
                for category in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction]:
                    self.jobdict = renders.render_nuke_versions(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category).jobdict
                    for version in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction][category]:
                        self.jobdict = renders.render_nuke_passes(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category, version = version).jobdict
        
        #***************************************************************************************************************
        else:
            print '\t> %s > core.wrappers.get_renders_nuke' % (self.job)
            self.jobdict = shots.shotslookup(self.jobdict, dept = 'nuke').jobdict

            for shot in self.jobdict[self.job]['nuke']['shots']:
                self.jobdict = renders.render_nuke_direction(self.jobdict, dept = 'nuke', shot = shot).jobdict
                for direction in self.jobdict[self.job]['nuke']['shots'][shot]['renders']:
                    self.jobdict = renders.render_nuke_categories(self.jobdict, dept = 'nuke', shot = shot, direction = direction).jobdict
                    for category in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction]:
                        self.jobdict = renders.render_nuke_versions(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category).jobdict
                        for version in self.jobdict[self.job]['nuke']['shots'][shot]['renders'][direction][category]:
                            self.jobdict = renders.render_nuke_passes(self.jobdict, dept = 'nuke', shot = shot, direction = direction, category = category, version = version).jobdict

#***************************************************************************************************************
# RENDERS 3D
#***************************************************************************************************************

class get_renders_3d(object):
    def __init__(self, jobdict, shot = '', version = '', layer = ''):
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = '3d'
        self.shot = shot
        self.version = version
        self.layer = layer
        
        #***************************************************************************************************************
        if self.shot and self.version and self.layer:
            print '\t> %s > %s > %s > %s > core.wrappers.get_renders_3d' % (self.dept, self.shot, self.version, self.layer)
            self.jobdict = shots.shotslookup(self.jobdict, self.dept).jobdict
            self.jobdict = renders.render_3d_versions(self.jobdict, dept = self.dept, shot = shot).jobdict
            self.jobdict = renders.render_3d_layers(self.jobdict, dept = '3d', shot = shot, version = version).jobdict
            self.jobdict = renders.render_3d_passes(self.jobdict, dept = '3d', shot = shot, version = version, layer = layer).jobdict
        
        #***************************************************************************************************************
        elif self.shot and self.version:
            print '\t> %s > %s > %s > core.wrappers.get_renders_3d' % (self.dept, self.shot, self.version)
            self.jobdict = shots.shotslookup(self.jobdict, self.dept).jobdict
            self.jobdict = renders.render_3d_versions(self.jobdict, dept = self.dept, shot = shot).jobdict
            self.jobdict = renders.render_3d_layers(self.jobdict, dept = '3d', shot = shot, version = version).jobdict
            
            for layer in self.jobdict[self.job]['3d']['shots'][shot]['renders'][version]:
                self.jobdict = renders.render_3d_passes(self.jobdict, dept = '3d', shot = shot, version = version, layer = layer).jobdict

        #***************************************************************************************************************
        elif self.shot:
            print '\t> %s > %s > core.wrappers.get_renders_3d' % (self.dept, self.shot)
            self.jobdict = shots.shotslookup(self.jobdict, self.dept).jobdict
            self.jobdict = renders.render_3d_versions(self.jobdict, dept = self.dept, shot = shot).jobdict
            
            for version in self.jobdict[self.job]['3d']['shots'][shot]['renders']:
                self.jobdict = renders.render_3d_layers(self.jobdict, dept = '3d', shot = shot, version = version).jobdict
                for layer in self.jobdict[self.job]['3d']['shots'][shot]['renders'][version]:
                    self.jobdict = renders.render_3d_passes(self.jobdict, dept = '3d', shot = shot, version = version, layer = layer).jobdict

        #***************************************************************************************************************
        else:
            print '\t> %s > core.wrappers.get_renders_3d' % (self.job)
            self.jobdict = shots.shotslookup(self.jobdict, self.dept).jobdict

            for shot in self.jobdict[self.job][self.dept]['shots']:            
                self.jobdict = renders.render_3d_versions(self.jobdict, self.dept, shot = shot).jobdict
                for version in self.jobdict[self.job]['3d']['shots'][shot]['renders']:
                    self.jobdict = renders.render_3d_layers(self.jobdict, self.dept, shot = shot, version = version).jobdict
                    for layer in self.jobdict[self.job]['3d']['shots'][shot]['renders'][version]:
                        self.jobdict = renders.render_3d_passes(self.jobdict, self.dept, shot = shot, version = version, layer = layer).jobdict

#***************************************************************************************************************
# ASSETS
#***************************************************************************************************************

class get_assets(object):
    '''
    at the very least you need to give a jobdict, additional args such as category, asset and task can also be given.
    the __init__ method determines what args are given and calls the relevant classes in the assets module
    '''
    def __init__(self, jobdict, category = '', asset = '', task = ''):
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.category = category
        self.asset = asset
        self.task = task
        
        if self.category and self.asset and self.task:
            print '\t> %s > %s > %s > core.wrappers.get_assets' % (self.category, self.asset, self.task)
            self.jobdict = assets.categorylookup(self.jobdict).jobdict
            self.jobdict = assets.assetlookup(self.jobdict, self.category).jobdict
            self.jobdict = assets.tasklookup(self.jobdict, self.category, self.asset).jobdict
            self.jobdict = assets.versionlookup(self.jobdict, self.category, self.asset, self.task).jobdict
            self.jobdict = assets.masterlookup(self.jobdict, self.category, self.asset).jobdict


        elif self.category and self.asset:
            print '\t> %s > %s > core.wrappers.get_assets' % (self.category, self.asset)
            self.jobdict = assets.categorylookup(self.jobdict).jobdict
            self.jobdict = assets.assetlookup(self.jobdict, self.category).jobdict
            self.jobdict = assets.tasklookup(self.jobdict, self.category, self.asset).jobdict
            self.jobdict = assets.masterlookup(self.jobdict, self.category, self.asset).jobdict

            for task in self.jobdict[self.job]['3d']['assets'][self.category][self.asset]:
                if not task == 'masters':
                    self.jobdict = assets.versionlookup(self.jobdict, self.category, self.asset, task).jobdict

        elif self.category:
            print '\t> %s > core.wrappers.get_assets' % (self.category)
            self.jobdict = assets.categorylookup(self.jobdict).jobdict
            self.jobdict = assets.assetlookup(self.jobdict, self.category).jobdict

            for asset in self.jobdict[self.job]['3d']['assets'][self.category]:
                self.jobdict = assets.tasklookup(self.jobdict, self.category, asset).jobdict
                self.jobdict = assets.masterlookup(self.jobdict, self.category, asset).jobdict

                for task in self.jobdict[self.job]['3d']['assets'][self.category][asset]:
                    if not task == 'masters':
                        self.jobdict = assets.versionlookup(self.jobdict, self.category, asset, task).jobdict

        else:
            print '\t> %s > core.wrappers.get_assets' % (self.job)
            self.jobdict = assets.categorylookup(self.jobdict).jobdict
            
            for category in self.jobdict[self.job]['3d']['assets']:
                self.jobdict = assets.assetlookup(self.jobdict, category).jobdict
                for asset in self.jobdict[self.job]['3d']['assets'][category]:
                    self.jobdict = assets.tasklookup(self.jobdict, category, asset).jobdict
                    self.jobdict = assets.masterlookup(self.jobdict, category, asset).jobdict
                    for task in self.jobdict[self.job]['3d']['assets'][category][asset]:
                        if not task == 'masters':
                            self.jobdict = assets.versionlookup(self.jobdict, category, asset, task).jobdict
