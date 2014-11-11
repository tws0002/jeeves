print '> importing jnuke.pipeline.version'

class version_save(object):
    def __init__(self):
        pass


def easySave():
    scriptsDir = os.path.join(jeevesStatic.jobsRoot, os.getenv('JOB'), 'vfx', 'nuke', os.getenv('SHOT'), os.getenv('SCENEROOT'), os.getenv('TASK'))
    
    # strip white space from user input description
    description = nuke.getInput( 'script description', os.environ['NUKE_DESC'] ).replace( ' ', '_' )
    
    # build the elements
    os.environ['NUKE_DESC'] = description
    job = os.environ['JOB'].rsplit('_', 1)[-1]
    initial = jeevesStatic.getUserInitial()
    
    fileSaved = False
    version = int(1)
    
    while not fileSaved:
	scriptName = '%s_%s_%s_v%02d.nk' % ( os.getenv('SHOT'), description, initial, version )
	fullPath = os.path.join( scriptsDir, scriptName )
        # if file exists, we version up
        if os.path.isfile(fullPath):
            version += 1
            continue
        # save the script
        nuke.scriptSaveAs( fullPath )
        fileSaved = True
    freshLables()