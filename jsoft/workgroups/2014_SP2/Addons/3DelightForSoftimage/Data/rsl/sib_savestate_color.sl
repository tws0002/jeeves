/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __save_state_color_sl
#define __save_state_color_sl

/* I really do not know what to do here */
void sib_savestate_color(
	RGBA_COLOR( i_input );
	output color o_result;
	output float o_result_a; )
{
	RGBA_ASSIGN( o_result, i_input );
}
#endif
