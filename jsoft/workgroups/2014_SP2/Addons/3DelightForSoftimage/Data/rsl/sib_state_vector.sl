/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_state_vector_sl
#define __sib_state_vector_sl

void sib_state_vector(
	float i_mode;

	output point o_result )
{
	extern point P;
	extern vector I, dPdtime;
	extern normal N, Ng;
	extern float s, t;

	if( i_mode == 0 )
	{
		o_result = point( normalize(vtransform("world",I)));
	}
	else if( i_mode == 1 )
		o_result = transform( "world", P - I );
	else if( i_mode == 2 )
		o_result = transform( "world", P );
	else if( i_mode == 3 )
		o_result = point( normalize(ntransform("world", N)) );
	else if( i_mode == 4 )
		o_result = point( normalize(ntransform("world", Ng)) );
	else if( i_mode == 5 )
		o_result = point( vtransform("world", dPdtime) );
	else if( i_mode == 6 )
		o_result = point( s, t, 0 );
	else
		o_result = 0;
}
#endif
