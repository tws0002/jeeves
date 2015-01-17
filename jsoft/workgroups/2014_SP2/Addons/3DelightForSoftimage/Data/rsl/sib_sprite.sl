/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_sprite_sl
#define __sib_sprite_sl

#define ALPHAMODE		0
#define INTENSITYMODE	1
#define MINIMUMMODE		2
#define MAXIMUMMODE		3
#define AVERAGEMODE		4

#define bool float

void sib_sprite(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_matte);
	float i_alpha_threshold;
	float i_mode;
	bool i_invert;
	bool i_use_matte;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern color Oi;

	color c = i_use_matte ? i_matte : i_input;

	if(i_mode == INTENSITYMODE)
	{
		o_result_a = RGB_INT(c);
	}
	else if(i_mode == MAXIMUMMODE)
	{
		o_result_a = max(c[0], c[1], c[2]);
	}
	else if(i_mode == MINIMUMMODE)
	{
		o_result_a = min(c[0], c[1], c[2]);
	}
	else if(i_mode == AVERAGEMODE)
	{
		o_result_a = (c[0] + c[1] + c[2])/3;
	}
	else
	{
		o_result_a = i_use_matte ? i_matte_a : i_input_a;
	}
	
	if(i_invert)
	{
		o_result_a = 1 - o_result_a;
	}

	o_result = i_input*o_result_a;
	Oi *= o_result_a;
}

#endif
