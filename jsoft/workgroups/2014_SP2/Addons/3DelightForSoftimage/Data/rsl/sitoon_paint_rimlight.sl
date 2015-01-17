/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sitoon_paint_rimlight_sl
#define __sitoon_paint_rimlight_sl

#include "sitoon_utils.h"

void sitoon_paint_rimlight(
	RGBA_COLOR( i_color );
	float i_cover, i_softness;
	uniform float i_invert;
	uniform float i_mix_mode;
	uniform float i_vec_select;
	uniform float i_space_select;
	point i_vec;
	RGBA_COLOR( i_surface );

	output color o_result;
	output float o_result_a; )
{
	vector vec = vector(i_vec);
	sitoon_which_dir( i_vec_select, i_space_select, vec );

	float factor = sitoon_incidence_vector(
		sqrt(1-i_cover), i_softness, vec, i_invert );

	RGBA_ASSIGN( o_result, i_surface );

	if( factor != 0 )
	{
		sitoon_color_mix(
			o_result, o_result_a,
			i_color, i_color_a,
			o_result, o_result_a,
			i_color_a * factor,
			i_mix_mode );
	}
}
#endif
