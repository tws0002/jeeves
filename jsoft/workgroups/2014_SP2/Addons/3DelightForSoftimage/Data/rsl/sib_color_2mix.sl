/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_2mix_sl
#define __sib_color_2mix_sl

#include "sib_color_8mix.sl"

void sib_color_2mix(
	float i_mixersize;
	RGBA_COLOR(i_basecolor);

	MIXER_LAYER_PARAM(1);
	MIXER_LAYER_PARAM(2);
	MIXER_LAYER_PARAM(3);
	MIXER_LAYER_PARAM(4);
	MIXER_LAYER_PARAM(5);
	MIXER_LAYER_PARAM(6);
	MIXER_LAYER_PARAM(7);

	output color o_result;
	output float o_result_a; )
{
	RGBA_COLOR( accum );
	RGBA_ASSIGN( accum, i_basecolor );

	MIX_LAYER( 1 );

	RGBA_ASSIGN( o_result, accum );
}
#endif
