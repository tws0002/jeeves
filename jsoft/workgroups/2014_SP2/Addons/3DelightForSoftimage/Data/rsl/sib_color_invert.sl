/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_invert_sl
#define __sib_color_invert_sl

void sib_color_invert(
	RGBA_COLOR( i_input );
	bool i_alpha;

	output color o_result;
	output float o_result_a; )
{
	o_result = 1 - i_input;
	o_result_a  = i_alpha!=0 ? 1 - i_input_a : i_input_a;
}

#endif
