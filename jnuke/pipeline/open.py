'''
opens scripts selected from jeeves_ui, is passed that file to be opened as an arg

check to see if the user wants / needs to save the current script before opening

no method of canceling operation, either save current or dont
'''
print '> importing jnuke.pipeline.open'
import nuke

def run(found_file):
    #check if scene is modified
    if nuke.Root().modified() == True:
        #prompt user to save
        if nuke.ask('Unsaved script\n\nWould you like to save?'):
            if nuke.Root().name() == 'Root':
                #run up the save_as module as this script hasnt been saved yet, then clear and open
                import jnuke.pipeline.save_as
                jnuke.pipeline.save_as.run()
                
                nuke.scriptClear()
                nuke.scriptOpen(found_file)
            else:
                #save the script, clear and open selected script
                nuke.scriptSave("")
                nuke.scriptClear()
                nuke.scriptOpen(found_file)
        else:
            #they dont want to save, so just clear the script and open the selected script
            nuke.scriptClear()
            nuke.scriptOpen(found_file)
                        
    else:
        #not modified, simply clear and open
        nuke.scriptClear()
        nuke.scriptOpen(found_file)