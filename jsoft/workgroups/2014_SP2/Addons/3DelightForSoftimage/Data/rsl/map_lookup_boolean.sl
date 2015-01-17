/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __map_lookup_boolean_sl
#define __map_lookup_boolean_sl

void map_lookup_boolean(
	float i_s;
	float i_thresh;
	
	output float o_result;)
{
	o_result = filterstep( i_thresh, i_s );
}

void map_lookup_boolean(
	point i_p;
	float i_thresh;
	
	output float o_result;)
{
	o_result = (i_p[0] + i_p[1] + i_p[2]) * 1/3;
	o_result = filterstep( i_thresh, o_result );
}

void map_lookup_boolean(
	RGBA_DECLARE( i_c );
	float i_thresh;

	output float o_result; )
{
	o_result = (i_c[0] + i_c[1] + i_c[2]) * 1/3;
	o_result = filterstep( i_thresh, o_result );
}
#endif
