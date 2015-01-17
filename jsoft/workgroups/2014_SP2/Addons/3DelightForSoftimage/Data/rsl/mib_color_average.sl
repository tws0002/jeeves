/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_color_average_sl
#define __mib_color_average_sl

void mib_color_average(
	RGBA_COLOR( i_input );
	float i_factor;

	output color o_result;
	output float o_result_a; )
{
	o_result_a = i_factor * (i_input[0]+i_input[1]+i_input[2])/3;
	o_result = o_result_a;
}
#endif
