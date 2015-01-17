/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_to_scalar_sl
#define __sib_color_to_scalar_sl

void sib_color_to_scalar(
	RGBA_COLOR( i_input );
	float i_alpha;

	output float o_result; )
{
	o_result = i_input[0] + i_input[1] + i_input[2];

	if( i_alpha )
	{
		o_result += i_input_a;
		o_result *= 0.25;
	}
	else
		o_result /= 3.0;
}

void sib_color_to_scalar(
	RGBA_DECLARE(i_input);
	output float o_result; )
{
	o_result = RGB_INT(i_input);
}

#endif 
