/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_attribute_color_sl
#define __sib_attribute_color_sl

void sib_attribute_color(
	float i_input[4];
	float i_index;	/* unused for now */
	RGBA_DECLARE(i_default);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN_VALUEA(o_result, i_input);
}

void sib_attribute_color(
	string i_input;	/* dummy parameter */
	float i_index;	/* unused for now */
	RGBA_DECLARE(i_default);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_default);
}

#endif 
