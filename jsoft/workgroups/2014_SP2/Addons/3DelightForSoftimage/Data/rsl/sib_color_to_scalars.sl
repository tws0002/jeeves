/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_color_to_scalars_sl
#define __sib_color_to_scalars_sl

void sib_color_to_scalars(
	output float o_r;
	output float o_g;
	output float o_b;
	output float o_a;

	RGBA_DECLARE( i_input ); )
{
	o_r = i_input[0];
	o_g = i_input[1];
	o_b = i_input[2];
	o_a = i_input_a;
}

void sib_color_to_scalars(
	RGBA_DECLARE( i_input );
	output float o_r;
	output float o_g;
	output float o_b;
	output float o_a; )
{
	sib_color_to_scalars(o_r, o_g, o_b, o_a, RGBA_USE(i_input));
}

#endif 
