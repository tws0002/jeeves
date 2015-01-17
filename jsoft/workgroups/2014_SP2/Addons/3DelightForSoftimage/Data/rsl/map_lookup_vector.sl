/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __map_lookup_vector_sl
#define __map_lookup_vector_sl

void map_lookup_vector(
	point i_p;
	float i_factor;
	
	output point o_result;)
{
	o_result = i_p;
}

void map_lookup_vector(
	RGBA_DECLARE( i_c );
	float i_factor;

	output point o_result; )
{
	o_result = point( i_c[0], i_c[1], i_c[2] );
}
#endif
