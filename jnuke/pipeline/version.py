'''
simple versioning tool, uses core.locate to establish vars, prompts user for script name and loops
until it finds a version not on the filesystem
'''
print '> importing jnuke.pipeline.version'
import nuke, os
import core

def version_save():
    script = nuke.Root().name()
    #checks if the script has been save before
    if not script == 'Root':
        import core.locate
        x = core.locate.find()
        job = x.job
        shot = x.shot
        task = x.task
        user = x.task
        version = x.version
    
        scriptsDir = os.path.join(core.jobsRoot, job, 'vfx', 'nuke', shot, 'scripts', user)
        description = nuke.getInput( 'script description', 'slapcomp').replace( ' ', '_' )
        initial = core.userlist[core.user]['int']
     
        fileSaved = False
        version = int(1)
        
        while not fileSaved:
            scriptName = '%s_%s_%s_v%02d.nk' % ( shot, description, initial, version )
            fullPath = os.path.join( scriptsDir, scriptName )
            # if file exists, we version up
            if os.path.isfile(fullPath):
                version += 1
                continue
            # save the script
            nuke.scriptSaveAs( fullPath )
            fileSaved = True
    else:
        #run save_as if its unsaved
        import jnuke.pipeline.save_as
        jnuke.pipeline.save_as.run()