'''
generates a thumbnail by hooking up a write node to the current viewer, resizing to 256x144 and rendering out a jpg

after render, it deletes the write and reformat nodes

is passed job and shot vars to build thumbpath
'''
print '> importing jnuke.pipeline.thumbnail'
import nukescripts, os, core, nuke

def run(job, shot):
    #thumbnail path, only one per shot - could alter this to one per version
    thumbpath = os.path.join(core.jobsRoot, job, 'vfx', 'nuke', shot, 'scripts', 'thumb.jpg')
    
    ### getting active node
    curViewer = nuke.activeViewer()
    curNode = curViewer.node()
    acticeVinput = curViewer.activeInput()
    curN = curNode.input(acticeVinput)
    
    #create the reformat
    r = nuke.createNode("Reformat")
    r.setName("tempReformat")
    r.setInput(0, curN)
    
    newFormat = nuke.addFormat('256 144 thumb') 
    r['format'].setValue('thumb')
    
    ### creating temp write
    w = nuke.createNode("Write")
    w.setName("tempWrite")
    w.setInput(0, r)
    w['file'].setValue(thumbpath)
    
    ### reformat and write options
    
    w['_jpeg_sub_sampling'].setValue(2)
    w['_jpeg_quality'].setValue(1)
    w['channels'].setValue('rgba')
    
    ### setting current frame for render
    result = nuke.frame()
    if result =="":
        result = result
    
    ### execute write node
    nuke.execute(nuke.selectedNode(), (int(result)), result)
    name = w.knob('file').value()
    nukescripts.node_delete(popupOnError=True)
    name = r.knob('format').value()
    nukescripts.node_delete(popupOnError=True)