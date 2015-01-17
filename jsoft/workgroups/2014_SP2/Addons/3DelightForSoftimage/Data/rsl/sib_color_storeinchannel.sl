/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_storeinchannel_sl
#define __sib_color_storeinchannel_sl

void sib_color_storeinchannel(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE_OUTPUT(o_channel); /* This is declared in the shader params */
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_input);
	RGBA_ASSIGN(o_channel, o_result);
}

/* XSI 7.0 signature */
void sib_color_storeinchannel(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE_OUTPUT(o_channel); /* This is declared in the shader params */
	float i_raytype, i_component;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN(o_result, i_input);
	RGBA_ASSIGN(o_channel, o_result);
}

#endif
