print '> importing maya_jeeves.tools.spawn_alembic'
import sys
import maya.standalone as std
std.initialize(name='python')
import maya.cmds as cmds

cmds.polySphere()

save_to_file = '/Users/unitadmin/Desktop/script.mb'
cmds.file(rename=save_to_file)

try:
    cmds.file(save=1)
    print 'scucces'
    sys.stdout.write('SUCCESS : %s' % save_to_file)
except:
    print 'fail'
    sys.stderr.write('FAIL : %s' % save_to_file)
