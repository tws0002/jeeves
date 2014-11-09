print '> importing maya_jeeves.tools.spawn_alembic'
import sys
import maya.standalone as std
std.initialize(name='python')
import maya.cmds as cmds

cmds.polySphere()
cmds.file(rename='/Users/unitadmin/Desktop/test2.mb')

try:
    cmds.file(save=1)
    sys.stdout.write('SUCCESS')
except:
    sys.stderr.write('FAIL')
