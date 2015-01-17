/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_vector_math_vector_sl
#define __sib_vector_math_vector_sl

#define VECTOR_NEGATE 0
#define VECTOR_ADD 1
#define VECTOR_CROSS 2
#define VECTOR_NORMALIZE 3
#define VECTOR_MIN 4
#define VECTOR_MAX 5
#define VECTOR_MUL 6
#define VECTOR_DIV 7
#define VECTOR_SUBTRACT 8

void sib_vector_math_vector(
	float i_mode;
	point i_vector_input1;
	point i_vector_input2;
	float i_scalar_input1;
	output point o_result; )
{
	if(i_mode == VECTOR_NEGATE)
	{
		o_result = -i_vector_input1;
	}
	else if(i_mode == VECTOR_ADD)
	{
		o_result = i_vector_input1 + i_vector_input2;
	}
	else if(i_mode == VECTOR_CROSS)
	{
		o_result = i_vector_input1 ^ i_vector_input2;
	}
	else if(i_mode == VECTOR_NORMALIZE)
	{
		o_result = normalize(i_vector_input1);
	}
	else if(i_mode == VECTOR_MIN)
	{
		o_result = min(i_vector_input1, i_vector_input2);
	}
	else if(i_mode == VECTOR_MAX)
	{
		o_result = max(i_vector_input1, i_vector_input2);
	}
	else if(i_mode == VECTOR_MUL)
	{
		o_result = i_vector_input1 * i_scalar_input1;
	}
	else if(i_mode == VECTOR_DIV)
	{
		o_result = i_vector_input1 / i_scalar_input1;
	}
	else if(i_mode == VECTOR_SUBTRACT)
	{
		o_result = i_vector_input1 - i_vector_input2;
	}
	else
	{
		o_result = point(0, 0, 0);
	}
}

#undef VECTOR_NEGATE
#undef VECTOR_ADD
#undef VECTOR_CROSS
#undef VECTOR_NORMALIZE
#undef VECTOR_MIN
#undef VECTOR_MAX
#undef VECTOR_MUL
#undef VECTOR_DIV
#undef VECTOR_SUBTRACT

#endif
