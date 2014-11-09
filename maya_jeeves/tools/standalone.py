print '> importing maya_jeeves.tools.standalone'
import sys, subprocess



def spawn():
    print 'spawn'
    mayapy = r'C:\Program Files\Autodesk\Maya2014\bin\mayapy.exe'
    script = r'\\resources\resources\vfx\pipeline\jeeves_dev\maya_jeeves\tools\spawn_alembic.py'
    
    #maya = subprocess.Popen([mayapy, script, stdout=subprocess.PIPE, stderr=subprocess.PIPE])
    maya = subprocess.Popen(mayapy + ' ' + script + ' ', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = maya.communicate()
    exitcode = maya.returncode
    
    print str(exitcode)
    
    if str(exitcode) != '0':
        print err
    else:
        print out
    






#
#
#mayapy = "/Applications/Autodesk/maya2015/Maya.app/Contents/bin/mayapy"
#
#def spawn_subprocess(cmd):
#    print '> importing maya_jeeves.standalone.spawn_subprocess'
#    print '\t', cmd
#
#
#
#import sys
#import maya.standalone as std
#std.initialize(name='python')
#import maya.cmds as cmds
#filename = sys.argv[1]
#layername = sys.argv[2]
#
#
#
#
#def addRenderLayer(filename,layername):
#    try:
#        cmds.file(filename,o=1,f=1)
#        newLyr = cmds.createRenderLayer(n=layername,empty=1,makeCurrent=1)
#        meshes = cmds.ls(type='mesh')
#        xforms = []
#        for i in meshes:
#            xf = cmds.listRelatives(i,p=1)[0]
#            xforms.append(xf)
#            cmds.editRenderLayerMembers(layername,xforms)
#        cmds.file(s=1,f=1)
#        sys.stdout.write(newLyr)
#        return newLyr
#    except Exception, e:
#        sys.stderr.write(str(e))
#        sys.exit(-1)
# 
#addRenderLayer(filename,layername)
#
#
#
#
#
#
#import maya.cmds as cmds
#import subprocess
#
## replace mayaPath with the path on your system to mayapy.exe
#mayaPath = 'c:/program files/autodesk/maya2011/bin/mayapy.exe'
## replace scriptPath with the path to the script you just saved
#scriptPath = 'c:/users/henry/desktop/addRenderLayer.py'
#
#
#def massAddRenderLayer(filenames,layername):
#    for filename in filenames:
#        maya = subprocess.Popen(mayaPath+' '+scriptPath+' '+filename+' '+layername, stdout=subprocess.PIPE,stderr=subprocess.PIPE)
#        out,err = maya.communicate()
#        exitcode = maya.returncode
#        if str(exitcode) != '0':
#            print(err)
#            print 'error opening file: %s' % (filename)
#        else:
#            print 'added new layer %s to %s' % (out,filename)
#
#
#
## define a list of filenames to iterate through
#filenames = ['file1','file2','file3']
#renderLayerToAdd = 'someNewLayer'
# 
## run procedure, assuming you've already defined it
#massAddRenderLayer(filenames, renderLayerToAdd)
#
