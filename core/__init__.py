print '> importing core'
import sys, os
import pyseq as pyseq
sys.dont_write_bytecode = True

jeeves_version = 'v2.6'

#only edit the dev at home
dev = True
home = True

#DEVELOPMENT
if dev:
    if home:
        if sys.platform == 'darwin':
            sys.path.append('/Users/elliott/Google Drive/pipeline/jeeves_dev')
            jeeves_ui = '/Users/elliott/Google Drive/pipeline/jeeves_dev/core/ui'
            jobsRoot = '/Users/elliott/Documents/Jobs'
            jeevesRoot = '/Users/elliott/Google Drive/pipeline/jeeves_dev'
            user = os.getenv('USER')
            home = os.getenv('HOME')
    else:
        if sys.platform == 'win32':
            sys.path.append('//resources/resources/vfx/pipeline/jeeves_dev')
            jeeves_ui = '//resources/resources/vfx/pipeline/jeeves_dev/core/ui'
            jobsRoot = r'\\bertie\bertie\Jobs'
            user = os.getenv('USERNAME')
            home = os.path.expanduser('~')
            
        elif sys.platform == 'linux2':
            sys.path.append('/mnt/resources/vfx/pipeline/jeeves_dev')
            jeeves_ui = '/mnt/resources/vfx/pipeline/jeeves_dev/core/ui'
            jobsRoot = '/mnt/bertie/Jobs'
            user = os.getenv('USER')
            home = os.getenv('HOME')
            
        elif sys.platform == 'darwin':
            sys.path.append('/Volumes/resources/vfx/pipeline/jeeves_dev')
            jeeves_ui = '/Volumes/resources/vfx/pipeline/jeeves_dev/core/ui'
            jobsRoot = '/Volumes/Bertie/Jobs'
            user = os.getenv('USER')
            home = os.getenv('HOME')

#STABLE
else:
    if sys.platform == 'win32':
        sys.path.append('//resources/resources/vfx/pipeline/jeeves')
        jeeves_ui = '//resources/resources/vfx/pipeline/jeeves/core/ui'
        jobsRoot = r'\\bertie\bertie\Jobs'
        user = os.getenv('USERNAME')
        home = os.path.expanduser('~')
        
    elif sys.platform == 'linux2':
        sys.path.append('/mnt/resources/vfx/pipeline/jeeves')
        jeeves_ui = '/mnt/resources/vfx/pipeline/jeeves/core/ui'
        jobsRoot = '/mnt/bertie/Jobs'
        user = os.getenv('USER')
        home = os.getenv('HOME')
        
    elif sys.platform == 'darwin':
        sys.path.append('/Volumes/resources/vfx/pipeline/jeeves')
        jeeves_ui = '/Volumes/resources/vfx/pipeline/jeeves/core/ui'
        jobsRoot = '/Volumes/Bertie/Jobs'
        user = os.getenv('USER')
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