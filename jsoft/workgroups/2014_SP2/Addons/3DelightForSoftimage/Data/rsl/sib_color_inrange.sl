/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __sib_color_inrange_sl
#define __sib_color_inrange_sl

void sib_color_inrange(
	RGBA_COLOR(i_min);
	RGBA_COLOR(i_input);
	RGBA_COLOR(i_max);

	uniform bool i_include_alpha;
	uniform float i_negate;

	output float o_result; )
{
	bool result;

	if( i_input[0]<i_min[0] || i_input[1]<i_min[1] || i_input[2]<i_min[2] ||
		i_input[0]>=i_max[0] || i_input[1]>=i_max[1] || i_input[2]>=i_max[2] ||
		i_input_a<i_min_a || i_input_a>=i_max_a )
	{	
		result = false;
	}
	else
	{
		result = ( i_include_alpha == 1 ) ? false : true;
	}

	if( i_negate )
		o_result = 1 - o_result;
}

#endif
