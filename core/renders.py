'''
this really isnt used at the moment, but it's ready to have some sort of custom nuke read node attached to it so that
new renders can be brought in automatically.

much like the 3d / nuke scenes lookup, it takes the jobdict as an arguement, plus additional arguements so that it
can return a dict with the renders for a specific shot

this could be a fun way to make jeeves your own, a nuke read node thingy

it uses the pyseq module, to return a string which can later be reversed to give the individual frames rather than a
string simply describing the sequence.
'''

print '> importing core.renders'
import core
import os, sys
import pyseq

#***************************************************************************************************************
# 3D > FOLLOWS CONVENTION OF - Render_Picutures > Version > Layer > Passes
#***************************************************************************************************************

class render_3d_versions(object):
    def __init__(self, jobdict, dept, shot):
        print '\t> %s > %s > core.renders.render_3d_versions' % (dept, shot)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        
        self.jobdict[self.job][self.dept]['shots'][shot]['renders'] = {}
        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Render_Pictures')
        
        self.versions = []
        
        for version in os.listdir(self.renderroot):
            if os.path.isdir(os.path.join(self.renderroot, version)):
                if not version == 'tmp':
                    self.versions.append(version)
                    self.jobdict[self.job][self.dept]['shots'][shot]['renders'][version] = {}

class render_3d_layers(object):
    def __init__(self, jobdict, dept, shot, version):
        print '\t> %s > %s > %s > core.renders.render_3d_layers' % (dept, shot, version)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.version = version
        
        self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.version] = {}
        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Render_Pictures', self.version)
        
        self.layers = []
        self.files = []
        
        for layer in os.listdir(self.renderroot):
            if os.path.isdir(os.path.join(self.renderroot, layer)):
                self.layers.append(layer)
                self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.version][layer] = []
            else:
                self.files.append(layer)
        
        if self.files:
            self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.version]['loose'] = self.files

class render_3d_passes(object):
    def __init__(self, jobdict, dept, shot, version, layer):
        print '\t> %s > %s > %s > %s > core.renders.render_3d_passes' % (dept, shot, version, layer)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.version = version
        self.layer = layer
        
        
        if self.layer == 'loose':
            self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Render_Pictures', self.version)
        else:
            self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'Render_Pictures', self.version, self.layer)
        # the getSequences class returns a list - not an object
        seq_class = pyseq.getSequences(self.renderroot)
        
        self.passes = []
        for each in seq_class:
            self.passes.append(each.split(' ')[-1])

        self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.version][self.layer] = self.passes

#***************************************************************************************************************
# NUKE > FOLLOWS CONVENTION OF - Plates > Direction > Category > Version
#***************************************************************************************************************

class render_nuke_direction(object):
    '''
    - im just going to make the input and output keys - they always exist
    '''
    
    def __init__(self, jobdict, dept, shot):
        print '\t> %s > %s > core.renders.render_nuke_direction' % (dept, shot)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot

        self.jobdict[self.job][self.dept]['shots'][shot]['renders'] = {}
        self.jobdict[self.job][self.dept]['shots'][shot]['renders']['input'] = {}
        self.jobdict[self.job][self.dept]['shots'][shot]['renders']['output'] = {}
        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'plates')

class render_nuke_categories(object):
    def __init__(self, jobdict, dept, shot, direction):
        print '\t> %s > %s > %s > core.renders.render_nuke_categories' % (dept, shot, direction)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.direction = direction
        
        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'plates', self.direction)
        for category in os.listdir(self.renderroot):
            if os.path.isdir(os.path.join(self.renderroot, category)):
                self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.direction][category] = {}
        
class render_nuke_versions(object):
    def __init__(self, jobdict, dept, shot, direction, category):
        print '\t> %s > %s > %s > %s > core.renders.render_nuke_versions' % (dept, shot, direction, category)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.direction = direction
        self.category = category

        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'plates', self.direction, self.category)
        
        for version in os.listdir(self.renderroot):
            if os.path.isdir(os.path.join(self.renderroot, version)):
                self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.direction][self.category][version] = []

class render_nuke_passes(object):
    def __init__(self, jobdict, dept, shot, direction, category, version):
        print '\t> %s > %s > %s > %s > %s > core.renders.render_nuke_passes' % (dept, shot, direction, category, version)
        
        #lets set up some vars
        self.jobdict = jobdict
        self.job = jobdict.keys()[0]
        self.dept = dept
        self.shot = shot
        self.direction = direction
        self.version = version
        self.category = category

        self.renderroot = os.path.join(core.jobsRoot, self.job, 'vfx', self.dept, self.shot, 'plates', self.direction, self.category, self.version)

        seq_class = pyseq.getSequences(self.renderroot)
        
        new = []
        for each in seq_class:
            new.append(each.split(' ')[-1])
            

        self.jobdict[self.job][self.dept]['shots'][shot]['renders'][self.direction][self.category][self.version] = seq_class