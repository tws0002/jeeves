#ifndef __sib_color_hsv_to_rgb
#define __sib_color_hsv_to_rgb

void sib_color_hsv_to_rgb(
	RGBA_DECLARE(i_input);

	output color o_result;
	output float o_result_a; )
{
	o_result = ctransform( "hsv", "rgb", i_input );
	o_result_a = i_input_a;
}
#endif
