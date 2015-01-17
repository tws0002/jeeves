#ifndef __sib_color_rgb_to_hsv
#define __sib_color_rgb_to_hsv

void sib_color_rgb_to_hsv(
	RGBA_DECLARE(i_input);
	
	output color o_result;
	output float o_result_a; )
{
	o_result = ctransform( "rgb", "hsv", i_input );
	o_result_a = i_input_a;
}
#endif
