'''
checks if the script has been saved before, if it has, it saves it, if not, it runs up the save_as module
'''
print '> importing jnuke.pipeline.save'

import nuke

def run():
    if nuke.Root().name() == 'Root':
        import jnuke.pipeline.save_as
        jnuke.pipeline.save_as.run()
    else:
        nuke.scriptSave("")
    
    return nuke.Root().name()