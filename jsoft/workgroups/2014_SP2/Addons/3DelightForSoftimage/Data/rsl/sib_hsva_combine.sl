/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_hsva_combine_sl
#define __sib_hsva_combine_sl

void sib_hsva_combine(
	float i_hue, i_saturation, i_value, i_alpha;

	output color o_result;
	output float o_result_a; )
{
	o_result = ctransform( "hsv", "rgb", color(i_hue, i_saturation, i_value) );
	o_result_a = i_alpha;
}
#endif
