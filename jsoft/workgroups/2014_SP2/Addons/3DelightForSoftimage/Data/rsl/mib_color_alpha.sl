/*
	Copyright (c) 2012 DNA Research
*/

#ifndef __mib_color_alpha_sl
#define __mib_color_alpha_sl

void mib_color_alpha(
	RGBA_COLOR( i_input );
	float i_factor;
	RGBA_DECLARE_OUTPUT( o_out ); )
{
	o_out_a = i_input_a * i_factor;
	o_out = o_out_a;
}

#endif

