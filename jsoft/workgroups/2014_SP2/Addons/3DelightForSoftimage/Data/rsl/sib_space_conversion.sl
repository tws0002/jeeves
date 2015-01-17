/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_space_conversion_sl
#define __sib_space_conversion_sl

void sib_space_conversion(
	float i_type;
	float i_transform;
	point i_vector_input;
	matrix i_transform_input;
	output point o_result; )
{
#define TRANSFORM_LOGIC( cast, trs ) \
	if( i_transform == 0 ) \
		o_result = i_vector_input; \
	else if( i_transform == 1 ) \
		o_result = point( trs( "world", "camera", cast(i_vector_input) ) ); \
	else if( i_transform == 2 ) \
		o_result = point( trs( "world", "object", cast(i_vector_input) ) ); \
	else if( i_transform == 3 ) \
		o_result = i_vector_input;  \
	else if( i_transform == 4 ) \
		o_result = point( trs( "camera", "world", cast(i_vector_input) ) ); \
	else if( i_transform == 5 ) \
		o_result = point( trs( "object", "world", cast(i_vector_input) ) ); \
	else if( i_transform == 6 ) \
		o_result = point( trs( i_transform_input, cast(i_vector_input) ) );

	if( i_type == 0 )
	{
		TRANSFORM_LOGIC( point, transform )
	}
	else if( i_type == 1 )
	{
		TRANSFORM_LOGIC( vector, vtransform )
	}
	else if( i_type == 2 )
	{
		TRANSFORM_LOGIC( normal, ntransform )
	}
	else
		o_result = i_vector_input;
}

void sib_space_conversion(
	float i_type;
	float i_transform;
	point i_vector_input;
	output point o_result; )
{
	sib_space_conversion(i_type, i_transform, i_vector_input, matrix(1), o_result);
}

#endif
