'''

- when the jeeves.core package is imported, this file runs. it sets the sys paths and creates some other required varibales
that differ from os to os.

- it also makes the local ~/.jeeves folder, used to store details of previously searched for jobs

- also contains a dictionary of users, their initials and the department they are in. when new people join, they need
to be added here. the name that is used to match against this dictionary is the name of the currently logged in user

'''

print '> importing core'
import sys, os
import pyseq as pyseq
sys.dont_write_bytecode = True

dev = False

#jeeves version
jeeves_version = 'v2.6'

#DEVELOPMENT
if dev:
    if sys.platform == 'win32':
        sys.path.append('//resources/resources/vfx/pipeline/jeeves_dev')
        user = os.getenv('USERNAME')
        home = os.path.expanduser('~')
        jobsRoot = r'\\bertie\bertie\Jobs'
        jeevesRoot = r'\\resources\resources\vfx\pipeline\jeeves_dev'
        jeeves_ui = r'\\resources\resources\vfx\pipeline\jeeves_dev\core\ui'

    elif sys.platform == 'linux2':
        sys.path.append('/mnt/resources/vfx/pipeline/jeeves_dev')
        user = os.getenv('USER')
        home = os.getenv('HOME')
        jobsRoot = '/mnt/bertie/Jobs'
        jeevesRoot = '/mnt/resources/vfx/pipeline/jeeves_dev'
        jeeves_ui = '/mnt/resources/vfx/pipeline/jeeves_dev/core/ui'

    elif sys.platform == 'darwin':
        sys.path.append('/Volumes/resources/vfx/pipeline/jeeves_dev')
        user = os.getenv('USER')
        home = os.getenv('HOME')
        jobsRoot = '/Volumes/Bertie/Jobs'
        jeevesRoot = '/Volumes/Resources/vfx/pipeline/jeeves_dev'
        jeeves_ui = '/Volumes/Resources/vfx/pipeline/jeeves_dev/core/ui'

#STABLE
else:
    if sys.platform == 'win32':
        sys.path.append('//resources/resources/vfx/pipeline/jeeves')
        user = os.getenv('USERNAME')
        home = os.path.expanduser('~')
        jobsRoot = r'\\bertie\bertie\Jobs'
        jeevesRoot = r'\\resources\resources\vfx\pipeline\jeeves'
        jeeves_ui = r'\\resources\resources\vfx\pipeline\jeeves\core\ui'
        
    elif sys.platform == 'linux2':
        sys.path.append('/mnt/resources/vfx/pipeline/jeeves')
        user = os.getenv('USER')
        home = os.getenv('HOME')
        jobsRoot = '/mnt/bertie/Jobs'
        jeevesRoot = '/mnt/resources/vfx/pipeline/jeeves'
        jeeves_ui = '/mnt/resources/vfx/pipeline/jeeves/core/ui'

    elif sys.platform == 'darwin':
        sys.path.append('/Volumes/resources/vfx/pipeline/jeeves')
        user = os.getenv('USER')
        home = os.getenv('HOME')
        jobsRoot = '/Volumes/Bertie/Jobs'
        jeevesRoot = '/Volumes/Resources/vfx/pipeline/jeeves'
        jeeves_ui = '/Volumes/Resources/vfx/pipeline/jeeves/core/ui'

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