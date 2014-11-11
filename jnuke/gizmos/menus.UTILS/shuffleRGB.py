## Shuffle RGB created by Chris Glew Ltd. April 25 2013
## Version 2.0

import nuke

def shuffleRGB():
    for x in nuke.selectedNodes(): 
        print x.name() 
        node = nuke.selectedNodes()
        a = nuke.createNode('Dot', inpanel = False)
        a.setName('ShuffleRGB_Dot') 
        a.setInput(0, x) 
    
        DotX = a.xpos() 
        DotY = a.ypos()
    
    ## Green Channel
    
        shG = nuke.createNode("Shuffle", inpanel = False) 
        shG['alpha'].setValue('green') 
        shG['red'].setValue('green') 
        shG['green'].setValue('green') 
        shG['blue'].setValue('green') 
        shG['tile_color'].setValue(16711935)
        shG['label'].setValue('GREEN')
        shG['postage_stamp'].setValue(True)
    
        shG['xpos'].setValue(int(DotX-34))
        shG['ypos'].setValue(int(DotY+100))
        
    ## Red Channel
    
        shR = nuke.createNode("Shuffle", inpanel = False) 
        shR['alpha'].setValue('red') 
        shR['red'].setValue('red') 
        shR['green'].setValue('red') 
        shR['blue'].setValue('red') 
        shR['tile_color'].setValue(4278190335)
        shR['label'].setValue('RED')
        shR['postage_stamp'].setValue(True)
        shR.setInput(0, a) 
    
        shR['xpos'].setValue(int(DotX-134)) 
        shR['ypos'].setValue(int(DotY+100))
    
    ## Blue Channel
    
        shB = nuke.createNode("Shuffle", inpanel = False) 
        shB['alpha'].setValue('blue') 
        shB['red'].setValue('blue') 
        shB['green'].setValue('blue') 
        shB['blue'].setValue('blue') 
        shB['tile_color'].setValue(65535)
        shB['label'].setValue('BLUE')
        shB['postage_stamp'].setValue(True)
        shB.setInput(0, a) 
        
        shB['xpos'].setValue(int(DotX+66)) 
        shB['ypos'].setValue(int(DotY+100))
        
    else:
        pass
        
shuffleRGB()