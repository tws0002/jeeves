/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_ripple_v3_sl
#define __txt2d_ripple_v3_sl

#include "sib_texture2d_ripple.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

void txt2d_ripple_v3(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);
	SIB_TEXTURE2D_RIPPLE_PARAMS;
	XSI_TEXTURE_COMMON_PARAMS;	
	output color o_result;
	output float o_result_a; )
{
	point coord;
	uniform float i_torus_x=0, i_torus_y=0, i_torus_z = 0;
	uniform point i_offset = 0;
	uniform matrix i_transform = 1;
	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord );

	float ripple;
	sib_texture2d_ripple( coord,
		SIB_TEXTURE2D_RIPPLE_PARAMS_LIST,
		ripple );

	if( i_alpha_output == 1 )
	{
		o_result = mix( i_color1_a, i_color2_a, ripple ) * i_alpha_factor;
	}
	else
	{
		RGBA_MIX( o_result, i_color1, i_color2, ripple );
	}

	XSI_TEXTURE_DO_BUMP;
}

#endif
