/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt3d_checkerboard_sl
#define __txt3d_checkerboard_sl

#include "mib_texture_remap.sl"
#include "mib_texture_checkerboard.sl"
#include "mib_bump_map.sl"

void txt3d_checkerboard(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);

	float i_xsize, i_ysize, i_zsize;

	XSI_TEXTURE_COMMON_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	point coord;
	uniform float i_torus_x=0, i_torus_y=0, i_torus_z=0;
	uniform point i_offset = 0;
	uniform matrix i_transform = 1;
	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord );

	if( i_alpha_output )
	{
		mib_texture_checkerboard(
			coord,
			i_xsize, i_ysize, i_zsize,
			i_color1_a, i_color2_a, i_color2_a, i_color1_a,
			i_color2_a, i_color1_a, i_color1_a, i_color2_a,
			o_result_a );
		o_result = o_result_a * i_alpha_factor;
	}
	else
	{
		mib_texture_checkerboard(
			coord,
			i_xsize, i_ysize, i_zsize,
			RGBA_COLOR_PARAM(i_color1),
			RGBA_COLOR_PARAM(i_color2),
			RGBA_COLOR_PARAM(i_color2),
			RGBA_COLOR_PARAM(i_color1),
			RGBA_COLOR_PARAM(i_color2),
			RGBA_COLOR_PARAM(i_color1),
			RGBA_COLOR_PARAM(i_color1),
			RGBA_COLOR_PARAM(i_color2),
			o_result, o_result_a );
	}

	XSI_TEXTURE_DO_BUMP	
}
#endif


