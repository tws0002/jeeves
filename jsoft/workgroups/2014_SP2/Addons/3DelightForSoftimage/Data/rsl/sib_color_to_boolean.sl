/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_color_to_boolean_sl
#define __sib_color_to_boolean_sl

void sib_color_to_boolean(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_threshold);
	float i_alpha;
	output float o_result; )
{
	o_result = false;
	
	if(i_input[0] > i_threshold[0] ||
		i_input[1] > i_threshold[1] ||
		i_input[2] > i_threshold[2])
	{
		o_result = true;
	}

	if(i_alpha == true && i_input_a > i_threshold_a)
	{
		o_result = true;
	}
}

#endif 
