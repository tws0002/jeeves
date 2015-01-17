/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_get_color_sl
#define __pt_get_color_sl

#define bool float

void pt_get_color(
	RGBA_DECLARE(i_overrideColor);
	bool i_overrideRGB;
	bool i_overrideAlpha;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	if(i_overrideRGB)
	{
		o_result = i_overrideColor;
	}
	else
	{
		o_result = Cs;
	}
	
	if(i_overrideAlpha)
	{
		o_result_a = i_overrideColor_a;
	}
	else
	{
		o_result_a = RGB_INT(Os);
	}
}

#endif
