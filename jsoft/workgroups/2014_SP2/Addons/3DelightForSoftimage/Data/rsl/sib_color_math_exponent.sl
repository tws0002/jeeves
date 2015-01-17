/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_color_math_exponent_sl
#define __sib_color_math_exponent_sl

#define bool float

void sib_color_math_exponent(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_factor);
	float i_op;
	bool i_alpha;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	o_result[0] = doscalarmathexponent(i_input[0], i_factor[0], i_op);
	o_result[1] = doscalarmathexponent(i_input[1], i_factor[1], i_op);
	o_result[2] = doscalarmathexponent(i_input[2], i_factor[2], i_op);
	
	o_result_a =
		i_alpha ? doscalarmathexponent(i_input_a, i_factor_a, i_op) : i_input_a;
}

#endif
