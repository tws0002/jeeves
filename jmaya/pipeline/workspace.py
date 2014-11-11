print '> importing jmaya.pipeline.workspace'
import os
import maya.cmds as cmds

def check_workspace():
    print '\t> jmaya.workspace.check_workspace'
    mayaproject = cmds.workspace( q=True, sn=True )
    mayaproject = os.path.normpath(mayaproject)
    mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')
    mayafile = os.path.normpath(mayafile)

    #print mayaproject
    #print mayafile
    if mayaproject == '':
        print 'no project set'

    if not mayafile:
        return False
    
    if not mayaproject == '':
        if mayaproject in mayafile:
            #print '\t> Workspace valid\n\t> project : %s\n\t> file    : %s' % (mayaproject, mayafile)
            return True
        else:
            if set_workspace(mayafile):
                #print '\t> Workspace valid\n\t> project : %s\n\t> file    : %s' % (head, mayafile)
                return True
            else:
                print '\t> Workspace invalid\n\t> project : %s\n\t> file    : %s' % (mayaproject, mayafile)
                return False
    else:
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
    
    this will probably be utilised by various callbacks to keep checking
    
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
        cmds.workspace(head, o= True)
        return True
    else:
        return False