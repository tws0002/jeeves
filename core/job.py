print '> importing core.job'
import core
import os, sys

class lookup(object):
    #this just returns a dict with the job number, shots and asset keys, plus the self.job var
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