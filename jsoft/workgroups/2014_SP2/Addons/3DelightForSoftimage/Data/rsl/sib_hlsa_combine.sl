/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_hlsa_combine_sl
#define __sib_hlsa_combine_sl

void sib_hlsa_combine(
	float i_hue, i_luminence, i_saturation;
	float i_alpha;

	output color o_result;
	output float o_result_a; )
{
	o_result = ctransform( "hsl", "rgb", color(i_hue, i_saturation, i_luminence) );
	o_result_a = i_alpha;
}
#endif
