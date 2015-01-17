'''
- this module includes the lookup class which attempts to match a job the search text and return a dict for further
population by subsequent calls to other modules in jeeves.core

- there is also the class check_schema, which checks what kind of schema the job is using. currently, we are using the
default schema, but for other more complex jobs, this can be extended to load in custom dictionary schemas or db calls.

'''

print '> importing core.job'
import core
import os, sys

class lookup(object):
    '''
    this takes some search text and tries to return a dictionary with the job num, 3d and nuke keys. it also creates
    the self.job var which can be used once the class is instanced instead of having to go looking for the job number
    simply in the jobdict
    '''
    def __init__(self, searchtext ):
        self.jobdict = {}
        self.job(searchtext)
        #or
        #lookup from db

    def job(self, searchtext):
        searchtext = searchtext.lower()
        joblist = []
        
        for job in os.listdir(core.jobsRoot):
            if searchtext in job.lower():
                if job[0] not in '._':
                    joblist.append(job)
        
        if joblist == []:
            self.job = None
            return False
        else:
            if len(joblist):
                # we'll take the fist one we get
                self.job = joblist[0]
                self.jobdict[self.job] = {}
                self.jobdict[self.job]['nuke'] = {}
                self.jobdict[self.job]['3d'] = {}

def job_schema_lookup(job):
    if job == '0999955_UNI_quick':
        job_schema = 'simple'
        job_schema = 'complex'
        job_schema = 'fromdisk'
        #job_schema = 'fromdatabase'
    else:
        job_schema = 'default'
    
    return job_schema

#***************************************************************************************************************
# CHECK SCHEMA - could move this to separate module - still keep it exiting on non default
#***************************************************************************************************************
class check_schema(object):
    '''
    - this checks to see if the job is a default schema - if not it exits
    - not in a position to deal with other scenarios just yet
    '''
    def __init__(self, job):
        self.job_schema = job_schema_lookup(job)
        if not self.job_schema == 'default':
            print 'non default schema - exiting'
            sys.exit()


sys.dont_write_bytecode = True