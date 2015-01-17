/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_scalar_inrange_sl
#define __sib_scalar_inrange_sl

void sib_scalar_inrange(
	float i_input;

	float i_min_thresh, i_max_thresh;
	float i_negate;

	output float o_result; )
{
	o_result = (i_input>=i_min_thresh && i_input<=i_max_thresh) ? 1 : 0;

	if( i_negate )
		o_result = 1 - o_result;
}

#endif
