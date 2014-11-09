print '> importing core'
import sys, os
import pyseq as pyseq
sys.dont_write_bytecode = True

at_home = True

if sys.platform == 'darwin':
    if at_home == True:
        jobsRoot = '/Users/elliott/Documents/Jobs'
        resourcesRoot = '/Volumes/Resources'
    else:
        jobsRoot = '/Volumes/Bertie/Jobs'
        resourcesRoot = '/Volumes/Resources'
    user = os.getenv('USER')
    jeevesRoot = '/Volumes/Resources/vfx/pipeline/jeeves'
    home = os.getenv('HOME')

elif sys.platform == 'win32':
    jobsRoot = r'\\bertie\bertie\Jobs'
    resourcesRoot = r'\\resources\resources'
    user = os.getenv('USERNAME')
    jeevesRoot = r'\\resources\resources\vfx\pipeline\jeeves'
    home = os.path.expanduser('~')

elif sys.platform == 'linux2':
    jobsRoot = '/mnt/bertie/Jobs'
    resourcesRoot = '/mnt/resources'
    user = os.getenv('USER')
    jeevesRoot = '/mnt/resources/vfx/pipeline/jeeves'
    home = os.getenv('HOME')

#local user jeeves
if not os.path.isdir(os.path.join(home, '.jeeves')):
    os.mkdir(os.path.join(home, '.jeeves'))

userlist = {'martin' : {'int' : 'ma',
                        'dept' : '3d'},
            'will' : {'int' : 'wd',
                      'dept' : '3d'},
            'ville' : {'int' : 'vn',
                      'dept' : '3d'},
            'lummers' : {'int' : 'cl',
                      'dept' : '3d'},
            'scott' : {'int' : 'ss',
                      'dept' : 'nuke'},
            'stirling' : {'int' : 'sa',
                      'dept' : 'nuke'},
            'paddy' : {'int' : 'pl',
                      'dept' : 'design'},
            'lloyd' : {'int' : 'lf',
                      'dept' : 'design'},
            'mark' : {'int' : 'mf',
                      'dept' : 'design'},
            'elliott' : {'int' : 'es',
                      'dept' : 'nuke'},
            'unitadmin' : {'int' : 'un',
                      'dept' : 'admin'},
            'freelance' : {'int' : 'fr',
                      'dept' : '3d'},
            }

sys.dont_write_bytecode = True