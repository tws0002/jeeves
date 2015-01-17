/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sitoon_paint_highlight_sl
#define __sitoon_paint_highlight_sl

#include "sitoon_utils.h"

float sitoon_highlight(
	RGBA_COLOR( i_color );
	float i_cover, i_softness;
	uniform float i_highlight_mode;
	uniform float i_use_illuminance;

	output color o_result;
	output float o_result_a )
{
	float threshold = sqrt(1 - i_cover);
	float softness_half = i_softness/2;

	float t_in = threshold - softness_half;
	float t_out = threshold + softness_half;

	extern point P;
	extern normal N;
	extern vector I;
	normal Nf = ShadingNormal( normalize(N) );
	vector R = reflect( normalize(I), Nf );

	o_result = o_result_a = 0;

	illuminance( P, Nf, PI/2 )
	{
		float factor;

		vector Ln = normalize( L );

		if( i_highlight_mode == highlight_mode_DIFFUSE )
			factor = Ln.Nf;
		else if( i_highlight_mode == highlight_mode_GLOSSY )
		{
			/* FIXME: highlight is smaller than mi_phong_specular */
			factor = Ln.R;
		}
		
		if( t_out > t_in )
			factor = smoothstep( t_in, t_out, factor );
		else
			factor = filterstep( t_in, factor );

		if( Cl != 0 ) /* FIXME: anti-alias this condition */
		{
			o_result += factor * i_color * Cl;
			o_result_a += factor;
		}
	}

	if( i_use_illuminance==0 )
	{
		o_result_a = (o_result_a > 1) ? 1 : o_result_a;
		o_result = i_color * o_result_a;
	}

	return o_result_a;
}

void sitoon_paint_highlight(
	RGBA_COLOR( i_color );
	float i_cover, i_softness;
	uniform float i_highlight_mode;
	uniform float i_mix_mode;
	uniform float i_use_illuminace;
	RGBA_COLOR( i_surface );

	output color o_result;
	output float o_result_a; )
{
	RGBA_ASSIGN( o_result, i_surface );

	RGBA_COLOR( highlight );
	highlight = highlight_a = 0;

	float res =  sitoon_highlight(i_color, i_color_a, i_cover, i_softness, i_highlight_mode,
		i_use_illuminace, highlight, highlight_a);

	if( res != 0 )
	{
		sitoon_color_mix( 
			RGBA_COLOR_PARAM(o_result),
			RGBA_COLOR_PARAM(highlight),
			RGBA_COLOR_PARAM(i_surface),
			highlight_a*i_color_a, i_mix_mode );
	}
}
#endif
