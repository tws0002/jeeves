/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_scalar_math_unary_sl
#define __sib_scalar_math_unary_sl

void sib_scalar_math_unary(
	float i_input;
	float i_op;
	output float o_result; )
{
	o_result = doscalarmathunary(i_input, i_op);
}

#endif
