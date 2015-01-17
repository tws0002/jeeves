'''
weird, version _v10, the zero gets chopped off, all other version numbers are fine, need to exmine the fileName tcl expression
'''
print '> importing jnuke.pipeline.tools.write'
import nuke, os
import core
import core.locate

def run():
    file_open = nuke.Root().name()
    x = core.locate.find()
    
    job = x.job
    shot= x.shot
    user = x.user
    script = x.version
    
    w = nuke.createNode('Write', inpanel=True)
    count = 1
    while nuke.exists('Jeeves_Write' + str(count)):
        count += 1
    w.knob('name').setValue('Jeeves_Write' + str(count))
    
    t = nuke.Tab_Knob("Output Write")
    w.addKnob(t)
    feedback = """
    [value dirName]
    """
    w.addKnob(nuke.EvalString_Knob('fileName', 'fileName', '[string trimright [string trimright [file tail [value root.name]] .nk] _thread0]'))
    w.addKnob(nuke.EvalString_Knob('dirName', 'dirName', os.path.join(core.jobsRoot, job, 'vfx', 'nuke', shot, 'plates', 'output' ).replace('\\', '/')))
    w.addKnob(nuke.Enumeration_Knob('renderType', 'render_dir', ['slapcomp', 'cleanup', 'prerender', 'matte', 'final']))
    output_path = "[value dirName]/[value renderType]/[value fileName]/[value fileName].%04d.dpx"
    w.knob('file').fromScript(output_path)
    w.knob('colorspace').setValue('linear')
    w.knob('file_type').setValue('dpx')
    w.knob('datatype').setValue('10')