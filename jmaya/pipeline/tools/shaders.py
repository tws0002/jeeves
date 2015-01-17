import maya.cmds as cmds
import pickle, os

def shader_export():
    mayafile = os.path.normpath(cmds.file(q=True, sn=True).replace('scenes','Scenes'))
    print mayafile
    pklpath = os.path.join(os.path.sep.join(mayafile.split(os.path.sep)[:-1]), 'shaders.pkl')
    print pklpath
    
    shader_dict = {}
    shaders = cmds.ls(mat=True)
    
    for shader in shaders:
        shader_dict[shader] = {}
        print '\nSHADER : %s' % shader
        shading_group = cmds.listConnections(shader, t = 'shadingEngine')
        print 'SHADING_GROUP : ', shading_group
        if not shading_group == None:
            #print 'non empty group'
            for sh_group in shading_group:
                shader_dict[shader][sh_group] = []
                trans = cmds.listConnections(shading_group, t = 'shape')
                print 'TRANS : ', trans
                shape = cmds.listRelatives(trans, s=True)
                print 'SHAPE : ', shape
                shader_dict[shader][sh_group].append(shape)
    
    pklfile = open(pklpath, 'w')
    pickle.dump(shader_dict, pklfile)
    pklfile.close()

def shader_ui(jobdict, job, cat,ass, shots, cur_index):
    import jmaya.pipeline.tools.shader_ui#;reload(maya_jeeves.ui.shader_ui)
    jmaya.pipeline.tools.shader_ui.run(jobdict, job, cat,ass, shots, cur_index)
    mayafile = cmds.file(q=True, sn=True).replace('scenes','Scenes')

def shader_assign(pklpath, geo_nm, shad_nm):
    print pklpath
    #print geo_nm
    #print shad_nm
    
    pklfile = open(pklpath, 'r')
    shader_dict = pickle.load(pklfile)
    pklfile.close()
    
    #print shader_dict
    
    scene_names = cmds.ls(l=True)
    scene_shaders_list = cmds.ls(l=True, mat=True)
    scene_shaders_group = []
    
    exclude = ['lambert1', 'particleCloud1', 'shaderGlow1']
    
    for ss in scene_shaders_list:
        if not ss in exclude:
            print ss
            if shad_nm in ss:
                print '\t', ss
                #print shad_nm
                tmp = cmds.listConnections(ss, t = 'shadingEngine')
                print '\t\t', tmp
                if not tmp == None:
                    if len(tmp) == 1:
                        scene_shaders_group.append(tmp[0])
                    else:
                        print 'shader is a member of multiple shading groups - do something cleverer'
    
    print scene_shaders_group
    #return 
    
    for shader in shader_dict:
        print '\nSHADER : ', shader
        for shader_group in shader_dict[shader]:
            print 'SHADER GROUP : ', shader_group
            for ss in scene_shaders_group:
                if ss.endswith(shader_group):
                    print 'FOUND SG : ', ss
                    found_shader = ss
                #else:
                 #   found_shader = None
            for shape_grp in shader_dict[shader][shader_group]:
                print 'SHAPE_GRP :', shape_grp
                if shape_grp:
                    for shape in shape_grp:
                        shape = shape.split(':')[-1]
                        print 'SHAPE : ', shape
                        for each in scene_names:
                            if geo_nm in each:
                                #print each
                                if shape in each:
                                    #print '\t',shape, '>>>', each
                                    print 'ASSIGN : ', each, '>>', found_shader
                                    cmds.select(each)
                                    cmds.hyperShade(assign = found_shader)
                                    print '\n'
    
    print 'SHADER ASSIGNMENT FINISHHED'