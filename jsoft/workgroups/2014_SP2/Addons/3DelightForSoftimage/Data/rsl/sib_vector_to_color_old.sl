/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_vector_to_color_old_sl
#define __sib_vector_to_color_old_sl

#include "sib_vector_to_color.sl"

void sib_vector_to_color_old(
	point i_input;
	float i_modeX, i_modeY, i_modeZ;
	float i_math_op;

	output color o_result;
	output float o_result_a; )
{
	sib_vector_to_color(
		i_input,
		i_modeX, i_modeY, i_modeZ,
		i_math_op,
		RGBA_USE(o_result));
}
#endif 
