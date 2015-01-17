/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_twosided_sl
#define __mib_twosided_sl

void mib_twosided(
	RGBA_COLOR(i_front);
	RGBA_COLOR(i_back);
	
	output color o_result;
	output float o_result_a; )
{
	extern normal N;
	extern vector I;

	if( N.I < 0 )
	{
		RGBA_ASSIGN( o_result, i_front );
	}
	else
	{
		RGBA_ASSIGN( o_result, i_back );
	}
}
#endif
