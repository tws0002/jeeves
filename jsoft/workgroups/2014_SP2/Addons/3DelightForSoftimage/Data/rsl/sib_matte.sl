/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_matte_sl
#define __sib_matte_sl

void sib_matte(
	RGBA_COLOR( i_color );
	float i_transp;

	output color o_result;
	output float o_result_a; )
{
	o_result = i_color;
	o_result_a = clamp( 1-i_transp, 0, 1 );
}
#endif
