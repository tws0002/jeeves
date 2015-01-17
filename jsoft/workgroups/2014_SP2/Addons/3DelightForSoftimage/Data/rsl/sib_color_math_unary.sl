/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_math_unary_sl
#define __sib_color_math_unary_sl

void sib_color_math_unary(
	RGBA_COLOR(i_input);
	float i_op;
	float i_alpha;

	output color o_result;
	output float o_result_a; )
{
	float R = doscalarmathunary( i_input[0], i_op );
	float G = doscalarmathunary( i_input[1], i_op );
	float B = doscalarmathunary( i_input[2], i_op );

	o_result = color( R, G, B );

	if( i_alpha )
		o_result_a = doscalarmathunary( i_input_a, i_op );
	else
		o_result_a = i_input_a;
}

#endif
