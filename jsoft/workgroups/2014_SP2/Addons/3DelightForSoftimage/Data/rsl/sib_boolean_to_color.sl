/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __sib_boolean_to_color_sl
#define __sib_boolean_to_color_sl

void sib_boolean_to_color(
	bool i_input;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	o_result = color(i_input);
	o_result_a = 1.0;
}

#endif

