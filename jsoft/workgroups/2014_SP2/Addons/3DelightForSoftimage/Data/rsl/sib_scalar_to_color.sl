/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_scalar_to_color_sl
#define __sib_scalar_to_color_sl

void sib_scalar_to_color(
	float i_scalar;
	float i_alpha;

	output color o_result;
	output float o_result_a; )
{
	o_result = i_scalar;
	o_result_a = i_alpha;
}

#endif
