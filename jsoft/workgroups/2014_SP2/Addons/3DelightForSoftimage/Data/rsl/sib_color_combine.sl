/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_rgba_combine_sl
#define __sib_rgba_combine_sl

void sib_color_combine(
	float i_r, i_g, i_b, i_a;

	output color o_result;
	output float o_result_a; )
{
	o_result = color( i_r, i_g, i_b );
	o_result_a = i_a;
}
#endif
