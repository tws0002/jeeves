print '> importing jnuke.pipeline.save'

import nuke

def run():
    if nuke.Root().name() == 'Root':
        print 'no save'
    else:
        nuke.scriptSave("")
        print 'saved'