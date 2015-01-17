'''
probably the most used module of the maya pipe, so useful, not sure why its not built into maya

two functions, oe to check the workspace, the other to set it correctly
'''
print '> importing jmaya.pipeline.workspace'
import os
import maya.cmds as cmds

def check_workspace():
    '''
    simply checks to see if the maya project path is in the maya filepath, if it is, all is ok, else, we
    attempt to set it
    '''
    print '\t> jmaya.workspace.check_workspace'

    mayaproject = cmds.workspace( q=True, sn=True )
    mayaproject = os.path.normpath(mayaproject)

    mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
    mayafile = os.path.normpath(mayafile)

    #check if there is a file open
    if not mayafile:
        return False
    
    #check if there is a non default project
    if not mayaproject == '':
        #if the maya project is in the file, then the workspace is correct, return True
        if mayaproject in mayafile:
            #print '\t> Workspace valid\n\t> project : %s\n\t> file    : %s' % (mayaproject, mayafile)
            return True
        else:
            #if not, we set the workspace, if that returns True, so do we
            if set_workspace(mayafile):
                #print '\t> Workspace valid\n\t> project : %s\n\t> file    : %s' % (head, mayafile)
                return True
            else:
                print '\t> Workspace invalid\n\t> project : %s\n\t> file    : %s' % (mayaproject, mayafile)
                return False
    else:
        #if the project is not set, we set it and return True if all went ok
        if set_workspace(mayafile):
            #print '\t> Workspace valid\n\t> project : %s\n\t> file    : %s' % (head, mayafile)
            return True
        else:
            print '\t> Workspace invalid\n\t> project : %s\n\t> file    : %s' % (mayaproject, mayafile)
            return False

def set_workspace(mayafile):
    '''
    this splits the open file on 'Scenes' and assumes the parent folder is the project
    then asks if the user wants to change it, if they do we proceed, if not we return False as this
    is essential
        
    '''
    print '\t> jmaya.workspace.set_workspace'
    global head
    head = mayafile.split('Scenes')[0]
    
    #user prompt
    change_workspace = False
    
    result = cmds.confirmDialog( title='Confirm Workspace Change', message='%s\n\nAre you sure?' % head, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
    if result == 'Yes':
        change_workspace = True
    
    if change_workspace:
        #change the workspace / project
        cmds.workspace(head, o= True)
        return True
    else:
        return False