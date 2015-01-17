/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_math_basic_sl
#define __sib_color_math_basic_sl

void sib_color_math_basic(
	RGBA_COLOR(i_input1);
	RGBA_COLOR(i_input2);
	float i_op;
	float i_alpha;

	output color o_result;
	output float o_result_a; )
{
	float R = doscalarmathbasic( comp(i_input1, 0), comp(i_input2,0), i_op );
	float G = doscalarmathbasic( comp(i_input1, 1), comp(i_input2,1), i_op );
	float B = doscalarmathbasic( comp(i_input1, 2), comp(i_input2,2), i_op );

	o_result = color( R, G, B );

	if( i_alpha != 0 )
		o_result_a = doscalarmathbasic( i_input1_a, i_input2_a, i_op );
	else
		o_result_a = i_input1_a;
}

#endif
