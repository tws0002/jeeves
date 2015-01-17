/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_attribute_transform_sl
#define __sib_attribute_transform_sl

void sib_attribute_transform(
	float i_input[16];
	float i_index;	/* unused for now */
	matrix i_default;
	output matrix o_result; )
{
	o_result = matrix(
		i_input[0], i_input[1], i_input[2], i_input[3], 
		i_input[4], i_input[5], i_input[6], i_input[7], 
		i_input[8], i_input[9], i_input[10], i_input[11], 
		i_input[12], i_input[13], i_input[14], i_input[15]);
}

void sib_attribute_transform(
	string i_input;	/* dummy parameter */
	float i_index;	/* unused for now */
	matrix i_default;
	output matrix o_result; )
{
	o_result = i_default;
}

#endif 
