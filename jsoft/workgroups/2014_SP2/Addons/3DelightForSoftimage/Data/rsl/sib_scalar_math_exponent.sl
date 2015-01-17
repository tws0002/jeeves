/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_scalar_math_exponent_sl
#define __sib_scalar_math_exponent_sl

void sib_scalar_math_exponent(
	float i_input;
	float i_factor;
	float i_op;
	output float o_result; )
{
	o_result = doscalarmathexponent(i_input, i_factor, i_op);
}

#endif
