/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_attribute_integer_sl
#define __sib_attribute_integer_sl

void sib_attribute_integer(
	float i_input;
	float i_index;	/* unused for now */
	float i_default;
	output float o_result; )
{
	o_result = i_input;
}

void sib_attribute_integer(
	string i_input;	/* dummy parameter */
	float i_index;	/* unused for now */
	float i_default;
	output float o_result; )
{
	o_result = i_default;
}

#endif 
