/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_bump_sl
#define __sib_bump_sl

void sib_bump(
	point i_bump;
	RGBA_COLOR(i_input);
	float i_inuse;
	
	output color o_result;
	output float o_result_a; )
{
	if( i_inuse == true )
	{
		extern normal N;

		if( i_bump != 0 )
		{
			vector bump = vtransform( "world", "current", vector(i_bump) );
			N = normal(N + bump);
		}
	}
	else
	{
		RGBA_ASSIGN( o_result, i_input );
	}
}
#endif
