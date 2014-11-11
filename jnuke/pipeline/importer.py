print '> importing jnuke.pipeline.importer'
import nuke

def run(found_file):
    nuke.nodePaste(found_file)