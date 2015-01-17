/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sitoon_paint_ambient_sl
#define __sitoon_paint_ambient_sl

#include "sitoon_utils.h"

void sitoon_paint_ambient(
	RGBA_DECLARE(i_ambience);
	float i_amount;
	uniform float i_mix_mode;
	uniform float i_shadows_only;
	RGBA_DECLARE(i_surface);

	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN( o_result, i_surface );
	float amount = i_amount;

	if( i_shadows_only != 0 )
		amount *= sitoon_ambient();

	if( amount != 0 )
	{
		sitoon_color_mix(
			RGBA_USE(o_result),
			RGBA_USE(i_ambience),
			RGBA_USE(o_result),
			amount,
			i_mix_mode );
	}
}

void sitoon_paint_ambient(
	float i_amount;
	uniform float i_mix_mode;
	uniform float i_shadows_only;
	RGBA_DECLARE(i_surface);

	RGBA_DECLARE_OUTPUT(o_result); )
{
	sitoon_paint_ambient(
		color(0, 0, 0), 1,
		i_amount,
		i_mix_mode,
		i_shadows_only,
		RGBA_USE(i_surface),
		RGBA_USE(o_result));
}

#endif
