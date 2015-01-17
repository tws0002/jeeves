/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_color_intensity_sl
#define __mib_color_intensity_sl

void mib_color_intensity(
	RGBA_COLOR( i_input );
	float i_factor;

	output color o_result;
	output float o_result_a; )
{
	o_result_a = i_factor * vector(i_input).(0.299, 0.587, 0.114);
	o_result = o_result_a;
}
#endif
