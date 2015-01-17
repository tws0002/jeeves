/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_attribute_vector_sl
#define __sib_attribute_vector_sl

void sib_attribute_vector(
	float i_input[3];
	float i_index;	/* unused for now */
	point i_default;
	output point o_result; )
{
	o_result = point(i_input[0], i_input[1], i_input[2]);
}

void sib_attribute_vector(
	string i_input;	/* dummy parameter */
	float i_index;	/* unused for now */
	point i_default;
	output point o_result; )
{
	o_result = i_default;
}

#endif 
