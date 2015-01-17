'''
nuke callbacks, set up from the core/setup/init.py in the NUKE_PATH
'''
print '> importing jnuke.pipeline.callbacks'

def createWriteDir():
    print '> importing jnuke.pipeline.callbacks.createWriteDir'
    import nuke, os, errno
    file = nuke.filename(nuke.thisNode())
    dir = os.path.dirname( file )
    osdir = nuke.callbacks.filenameFilter( dir )
    # cope with the directory existing already by ignoring that exception
    try:
      os.makedirs( osdir )
    except OSError, e:
      if e.errno != errno.EEXIST:
        raise