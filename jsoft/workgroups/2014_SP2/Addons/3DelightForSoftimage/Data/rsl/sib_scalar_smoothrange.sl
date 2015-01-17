/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Developers. 2012                              */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

#ifndef __sib_scalar_smoothrange_sl
#define __sib_scalar_smoothrange_sl

void sib_scalar_smoothrange(
		float i_input;
		float i_min_thresh;
		float i_max_thresh;
		float i_min_delta;
		float i_max_delta;
		float i_inside_value;
		float i_outside_value;
		bool i_invert;
		float i_out; )
{
	float min_value = smoothstep(i_min_thresh - i_min_delta, i_min_thresh, i_input);
	float max_value = smoothstep(i_max_thresh, i_max_thresh + i_max_delta, i_input);
	max_value = 1-max_value;

	float value = min_value * max_value;

	if( i_invert == true )
	{
		value = 1-value;
	}

	i_out = mix( i_outside_value, i_inside_value, value);
}

#endif

