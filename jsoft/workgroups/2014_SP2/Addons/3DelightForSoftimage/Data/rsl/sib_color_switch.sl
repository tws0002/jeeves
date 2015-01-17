/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_switch_sl
#define __sib_color_switch_sl

void sib_color_switch(
	RGBA_COLOR( i_color1 );
	RGBA_COLOR( i_color2 );
	float i_toggle;

	output color o_result;
	output float o_result_a;)
{
	if( i_toggle == 1 )
	{
		RGBA_ASSIGN( o_result, i_color2 );	
	}
	else
	{
		RGBA_ASSIGN( o_result, i_color1 );	
	}
}
#endif
