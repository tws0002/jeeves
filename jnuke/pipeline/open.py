print '> importing jnuke.pipeline.open'
import nuke

def run(found_file):
    #if needs saving - do that here
    #needs work
    
    if nuke.Root().name() == 'Root': 
        print 'new script is not yet saved'
        print 'choice'
        choice = False
        if choice:
            print 'saving script'
            path = ''
            nuke.scriptSaveAs(path)
        
        nuke.scriptClear()
        nuke.scriptOpen(found_file)       
    
    else: 
        if nuke.Root().modified() == True: 
            print 'current changes have not yet been saved!'
            print 'choice'
            choice = False
            if choice:
                print 'saving script'
                path = ''
                nuke.scriptSaveAs(path)
            
            nuke.scriptClear()
            nuke.scriptOpen(found_file) 
                
        else:
            print 'just open it'
            nuke.scriptClear()
            nuke.scriptOpen(found_file)

    if not nuke.root().name() == 'Root':
        nuke.scriptSave("")
    nuke.scriptClear()
    nuke.scriptOpen(found_file)