/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_color_to_vector_old_sl
#define __sib_color_to_vector_old_sl

#include "sib_color_to_vector.sl"

void sib_color_to_vector_old(
	RGBA_COLOR( i_input );
	float i_modeR, i_modeG, i_modeB, i_modeA;
	float i_math_op;

	output point o_result; )
{
	sib_color_to_vector(
		RGBA_USE(i_input),
		i_modeR, i_modeG, i_modeB, i_modeA,
		i_math_op,
		o_result);
}
#endif 
