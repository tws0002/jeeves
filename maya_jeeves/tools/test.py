import sys, subprocess

mayapy = r'C:\Program Files\Autodesk\Maya2014\bin\mayapy.exe'

def pass_script():
    print '> importing maya_jeeves.tools.test'
    script = r'C:\Users\unitadmin\Desktop\test_script.py'
    maya = subprocess.Popen(mayapy + ' ' + script + ' ', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    out, err = maya.communicate()
    exitcode = maya.returncode
    
    print str(exitcode)
    if str(exitcode) != '0':
        print(err)
        print 'error : %s' % (err)
    else:
        print '%s' % (out)

    #print str(exitcode)
    #print out
    #print err




def pass_cmd():
    print '>cmd'
    save_to_file = '/Users/unitadmin/Desktop/script3.mb'
    cmd = "import maya.standalone as std;std.initialize(name='python');import maya.cmds as cmds;cmds.polySphere();cmds.file(rename='%s');cmds.file(save=1)" % save_to_file
    
    print cmd
    
    maya = subprocess.Popen([mayapy, "-c" , cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    out, err = maya.communicate()
    exitcode = maya.returncode
    
    print str(exitcode)
    if str(exitcode) != '0':
        print(err)
        print 'error : %s' % (err)
    else:
        print '%s' % (out)

#pass_script()
pass_cmd()