/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_vector_math_scalar_sl
#define __sib_vector_math_scalar_sl

#define VECTOR_LENGTH 0
#define VECTOR_DOT 1
#define VECTOR_DISTANCE 2

void sib_vector_math_scalar(
	float i_mode;
	point i_vector_input1;
	point i_vector_input2;
	output float o_result; )
{
	if(i_mode == VECTOR_LENGTH)
	{
		o_result = length(i_vector_input1);
	}
	else if(i_mode == VECTOR_DOT)
	{
		o_result = i_vector_input1 . i_vector_input2;
	}
	else if(i_mode == VECTOR_DISTANCE)
	{
		o_result = length(i_vector_input1 - i_vector_input2);
	}
	else
	{
		o_result = 0;
	}
}

#undef VECTOR_LENGTH
#undef VECTOR_DOT
#undef VECTOR_DISTANCE

#endif
