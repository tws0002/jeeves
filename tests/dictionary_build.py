import pprint
import core
import core.job as job
import core.shots as shot
import core.assets as assets
import core.renders as renders
import core.wrappers as wrappers

# INITIATE A BASIC DICT
jobdict = job.lookup(searchtext = 'jeeves').jobdict
#jobdict = job.lookup(searchtext = '11826').jobdict

#***************************************************************************************************************
# SHOTS
#***************************************************************************************************************

# NUKE EXAMPLE
#jobdict = shot.shotslookup(jobdict, dept = 'nuke').jobdict
#jobdict = shot.taskslookup(jobdict, dept = 'nuke', shot = 'sh_001').jobdict
#jobdict = shot.versionslookup(jobdict, dept = 'nuke', shot = 'sh_001', task = 'elliott').jobdict

#jobdict = renders.render_nuke_direction(jobdict, dept = 'nuke', shot = 'sh_001').jobdict
#jobdict = renders.render_nuke_categories(jobdict, dept = 'nuke', shot = 'sh_001', direction = 'output').jobdict
#jobdict = renders.render_nuke_versions(jobdict, dept = 'nuke', shot = 'sh_001', direction = 'output', category = 'slapcomp').jobdict
#jobdict = renders.render_nuke_passes(jobdict, dept = 'nuke', shot = 'sh_001', direction = 'output', category = 'slapcomp', version = 'sh_001_slapcomp_ss_v06').jobdict

# 3D EXAMPLE
#jobdict = shot.shotslookup(jobdict, dept = '3d').jobdict

# COMPLEX
#jobdict = shot.taskslookup(jobdict, dept = '3d', shot = 'sh_001').jobdict
#jobdict = shot.versionslookup(jobdict, dept = '3d', shot = 'sh_001', task = 'animation').jobdict
# SIMPLE
#jobdict = shot.taskslookup(jobdict, dept = '3d', shot = 'sh_002').jobdict
#jobdict = shot.versionslookup(jobdict, dept = '3d', shot = 'sh_002', task = None).jobdict

#jobdict = shot.publisheslookup(jobdict, dept = '3d', shot = 'sh_001').jobdict

#jobdict = renders.render_3d_versions(jobdict, dept = '3d', shot = 'sh_001').jobdict
#jobdict = renders.render_3d_layers(jobdict, dept = '3d', shot = 'sh_001', version = 'sh_001_animation_v01').jobdict
#jobdict = renders.render_3d_passes(jobdict, dept = '3d', shot = 'sh_001', version = 'sh_001_animation_v01', layer = 'masterLayer').jobdict

#***************************************************************************************************************
# SHOTS WRAPPERS
#**********************************************************************************************************

# 3D RENDERS
#jobdict = wrappers.get_renders_3d(jobdict = jobdict).jobdict
#jobdict = wrappers.get_renders_3d(jobdict = jobdict, shot = 'sh_001').jobdict
#jobdict = wrappers.get_renders_3d(jobdict = jobdict, shot = 'sh_001', version = 'sh_001_animation_v01').jobdict
#jobdict = wrappers.get_renders_3d(jobdict = jobdict, shot = 'sh_001', version = 'sh_001_animation_v01', layer = 'masterLayer').jobdict

# NUKE RENDERS
#jobdict = wrappers.get_renders_nuke(jobdict = jobdict).jobdict
#jobdict = wrappers.get_renders_nuke(jobdict = jobdict, shot = 'sh_001').jobdict
#jobdict = wrappers.get_renders_nuke(jobdict = jobdict, shot = 'sh_001', direction = 'output').jobdict
#jobdict = wrappers.get_renders_nuke(jobdict = jobdict, shot = 'sh_001', direction = 'output', category = 'slapcomp').jobdict
#jobdict = wrappers.get_renders_nuke(jobdict = jobdict, shot = 'sh_001', direction = 'output', category = 'slapcomp', version = 'sh_001_slapcomp_ss_v03').jobdict

# ALL RENDERS - NEEDS A DICT AND CAN TAKE DEPT AND SHOT AS VARS
# GET ALL SH_001/NUKE RENDERS, ALL SH_001 RENDERS OR ALL 3D RENDERS - FLEXIBLE
#jobdict = wrappers.get_renders(jobdict = jobdict).jobdict
#jobdict = wrappers.get_renders(jobdict = jobdict, shot = 'sh_002').jobdict
#jobdict = wrappers.get_renders(jobdict = jobdict, dept = '3d', shot = 'sh_001').jobdict
#jobdict = wrappers.get_renders(jobdict = jobdict, dept = 'nuke').jobdict

# jobdict = wrappers.get_scenes(jobdict = jobdict).jobdict # this gets everything
# jobdict = wrappers.get_scenes(jobdict = jobdict, dept = 'nuke').jobdict # this gets all nuke
#jobdict = wrappers.get_scenes(jobdict = jobdict, shot = 'sh_001').jobdict # this gets all of sh_001
jobdict = wrappers.get_scenes(jobdict = jobdict, dept = '3d', shot = 'sh_001').jobdict # this gets shot 1 for 3d
#jobdict = wrappers.get_scenes(jobdict = jobdict, dept = 'nuke', shot = 'sh_001', task = 'elliott').jobdict
#jobdict = wrappers.get_scenes(jobdict = jobdict, dept = '3d', shot = 'sh_001', task = 'lighting').jobdict


#ADD AND DELETE SHOTS
#import sys
#sys.path.append('/mnt/resources/vfx/pipeline/jeeves')
#shots.shot_add('999955_UNIT_jeeves_test', 'sh_003')
#shots.shot_delete('999955_UNIT_jeeves_test', 'sh_003')


#***************************************************************************************************************
# ASSETS
#***************************************************************************************************************

#jobdict = assets.categorylookup(jobdict = jobdict).jobdict

#jobdict = assets.assetlookup(jobdict = jobdict, category = 'Characters').jobdict
#
#jobdict = assets.tasklookup(jobdict = jobdict, category = 'Characters', asset = 'adult').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'Characters', asset = 'adult', task = 'loose').jobdict
#jobdict = assets.masterlookup(jobdict = jobdict, category = 'Characters', asset = 'adult').jobdict

#jobdict = assets.tasklookup(jobdict = jobdict, category = 'Characters', asset = 'columbus').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'Characters', asset = 'columbus', task = 'rigging').jobdict
#jobdict = assets.masterlookup(jobdict = jobdict, category = 'Characters', asset = 'columbus', task = 'modelling').jobdict

#jobdict = assets.tasklookup(jobdict = jobdict, category = 'Characters', asset = 'mother').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'Characters', asset = 'mother', task = 'lighting').jobdict
#jobdict = assets.masterlookup(jobdict = jobdict, category = 'Characters', asset = 'columbus', task = 'modelling').jobdict

#jobdict = assets.tasklookup(jobdict = jobdict, category = 'characters', asset = 'columbus').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'characters', asset = 'mother', task = 'rigging').jobdict

#jobdict = assets.assetlookup(jobdict = jobdict, category = 'Environments').jobdict
#jobdict = assets.tasklookup(jobdict = jobdict, category = 'Environments', asset = 'house_interior').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'Environments', asset = 'house_interior', task = 'loose').jobdict
#jobdict = assets.masterlookup(jobdict = jobdict, category = 'Environments', asset = 'house_interior', task = 'loose').jobdict
#jobdict = assets.versionlookup(jobdict = jobdict, category = 'Environments', asset = 'house_interior', task = 'modelling').jobdict
#jobdict = assets.masterlookup(jobdict = jobdict, category = 'Environments', asset = 'house_interior', task = 'modelling').jobdict

#***************************************************************************************************************
# ASSETS WRAPPERS
#***************************************************************************************************************

#jobdict = wrappers.get_assets(jobdict = jobdict).jobdict
#jobdict = wrappers.get_assets(jobdict = jobdict, category = 'Props').jobdict
#jobdict = wrappers.get_assets(jobdict = jobdict, category = 'Characters', asset = 'adult').jobdict
#jobdict = wrappers.get_assets(jobdict = jobdict, category = 'Characters', asset = 'adult', task = 'loose').jobdict

#import master_publish

#mayaproject = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/3d_assets'
#mayaproject = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/sh_001'

#mayafile = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/3d_assets/Scenes/Characters/adult/lighting/env_house_exterior_ma_v01.mb'
#mayafile = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/3d_assets/Scenes/Characters/adult/loose_1.mb'
#mayafile = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/sh_001/Scenes/simulation/sh_001_simulation_ma_v05.mb'
#mayafile = '/Users/elliott/Documents/Jobs/999955_UNIT_jeeves_test/vfx/3d/sh_001/Scenes/sh_001_simulation_ma_v02.mb'
#master = master_publish.do_maya(mayaproject = mayaproject, mayafile = mayafile).jobdict
#master = master_publish.do_maya(mayaproject = mayaproject, mayafile = mayafile)

#print ''
#print master
#print 'mayafile >', master.mayafile
#print 'mayaproj >', master.mayaproject
#print master.assetproj
#print master.shotproj



print '\n----PRINTOUT----\n'
#pprint.pprint(jobdict['999955_UNIT_jeeves_test'])
pprint.pprint(jobdict)
#pprint.pprint(master.jobdict)

#print ''
#print master.job
#print master.dept
#print master.shotproj
#print master.shot

#print master.assetproj
#print master.category
#print master.asset

#print master.task
#print master.version

