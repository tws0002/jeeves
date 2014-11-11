# Copyright (c) 2009 Howard Jones.  All Rights Reserved.
#
# multi read node - creates a  list of files to read in
#

import nuke

def multiRead():
    readList=[]
    wasMov=False

    files=nuke.getClipname('multi Read',multiple=True)

    while files:
        for f in files:
            readList.append(f)
        files=nuke.getClipname('add more clips - cancel to quit',multiple=True)

    print readList

    ## create the Reads
    for r in readList:
        rn=nuke.createNode('Read')
        rn['file'].setValue(r.split(' ')[0])
        if str(r.split(' ')[0][-3:])== 'mov':
            wasMov=True
            rn['selected'].setValue( True )      #select movs
        else:
            rn['first'].setValue(int(r.split(' ')[1].split('-')[0]))
            rn['last'].setValue(int(r.split(' ')[1].split('-')[1]))
    if wasMov:
        nuke.message('Quicktimes detected...\nrepoint these to the source files\nto get correct frame range')
        
