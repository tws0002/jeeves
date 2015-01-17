/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __sib_color_passthrough_sl
#define __sib_color_passthrough_sl

void sib_color_passthrough(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_input);	
}

void sib_color_passthrough(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_channel1); /* dummy */
	RGBA_DECLARE(i_channel2); /* dummy */
	RGBA_DECLARE(i_channel3); /* dummy */
	RGBA_DECLARE(i_channel4); /* dummy */
	RGBA_DECLARE(i_channel5); /* dummy */
	RGBA_DECLARE(i_channel6); /* dummy */
	RGBA_DECLARE(i_channel7); /* dummy */
	RGBA_DECLARE(i_channel8); /* dummy */
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_input);	
}

#endif
