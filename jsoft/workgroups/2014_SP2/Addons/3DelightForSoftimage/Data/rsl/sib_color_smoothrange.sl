/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_smooth_range_sl
#define __sib_color_smooth_range_sl

void sib_color_smoothrange(

	float i_input;
	float i_min_thresh, i_max_thresh;
	float i_min_delta, i_max_delta;
	
	RGBA_COLOR( i_in_value );
	RGBA_COLOR( i_out_value );

	float i_invert; 

	output color o_result;
	output float o_result_a; )
{
	float min_delta = i_min_thresh - i_min_delta;
	float max_delta = i_max_thresh + i_max_delta;

	float min_thresh = i_min_thresh;
	float max_thresh = i_max_thresh;

	if( min_thresh > max_thresh )
		min_thresh = max_thresh;

	if( min_thresh < min_delta )
	{
		/* swap if min_delta is larger than min_thresh */
		float tmp = min_thresh;
		min_thresh = min_delta;
		min_delta = tmp;
	}
	
	if( max_thresh > max_delta  )
	{
		/* swap if max_thresh is larger than max_delta */
		float tmp = max_thresh;
		max_thresh = max_delta;
		max_delta = tmp;
	}

	if( i_input >= min_thresh && i_input <= max_thresh  )
	{  
		/* We are completely inside */
		if ( i_invert==0 )
		{
			RGBA_ASSIGN( o_result, i_in_value );
		}
		else
		{
			RGBA_ASSIGN( o_result, i_out_value );
		}
	}
	else if ( i_input <= min_delta || i_input >= max_delta )
	{
		/* We are completely outside */
		if ( i_invert==0 )
		{
			RGBA_ASSIGN( o_result, i_out_value );
		}
		else
		{
			RGBA_ASSIGN( o_result, i_in_value );
		}
	}
	else
	{	
		float weight;

		if ( i_input<i_min_thresh )
		{
			weight = smoothstep( min_delta, min_thresh, i_input );
		}
		else
		{
			weight = 1 - smoothstep( max_thresh, max_delta, i_input );
		}

		if( i_invert )
		{
			RGBA_MIX( o_result , i_in_value, i_out_value, weight);
		}
		else
		{
			RGBA_MIX( o_result, i_out_value, i_in_value, weight);
		}
	}
}

#endif
