/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_scalar_to_boolean_sl
#define __sib_scalar_to_boolean_sl

void sib_scalar_to_boolean(
	float i_input;
	float i_threshold;
	output float o_result; )
{
	o_result = i_input > i_threshold ? 1 : 0;
}

#endif 
