/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __Color4Passthrough_sl
#define __Color4Passthrough_sl

void Color4Passthrough(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_input);	
}

void Color4Passthrough(
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
