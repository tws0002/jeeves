print '> importing jnuke.pipeline.save_as'
import nuke, os
def run(jobdict, job, shotlist):
    print jobdict
    print job
    print shotlist
    
    
    #import core.job
    #import core.locate
    #x = core.locate.find()
    #
    #job = x.job
    #
    #jobdict = core.job.lookup(job)
    #
    #print jo
    #shot = x.shots
    #task = x.task
    #user = x.task
    #version = x.version
    #
    #scriptsDir = os.path.join(core.jobsRoot, x.job, 'vfx', 'nuke', shot, 'scripts', user)
    ##description = nuke.getInput( 'script description', 'slapcomp').replace( ' ', '_' )
    #
    #shots = 'sh_001 sh_002'
    #users = 'elliott scott'
    #p = nuke.Panel('Save As')
    #p.addEnumerationPulldown('Shots : ', shots)
    #p.addEnumerationPulldown('Users : ', users)
    #p.addSingleLineInput('Description', 'slapcomp')
    #ret = p.show()
    
    
    #
    #initial = core.userlist[core.user]['int']
    #
    #fileSaved = False
    #version = int(1)
    #
    #while not fileSaved:
    #    scriptName = '%s_%s_%s_v%02d.nk' % ( shot, description, initial, version )
    #    fullPath = os.path.join( scriptsDir, scriptName )
    #    # if file exists, we version up
    #    if os.path.isfile(fullPath):
    #        version += 1
    #        continue
    #    final = fullPath
    #    fileSaved  = True
    #
    #print final
    
    
    #nuke.scriptSaveAs(path)