/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_gradient_v2_sl
#define __txt2d_gradient_v2_sl

#include "sib_color_gradient.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

void txt2d_gradient_v2(
	SIB_COLOR_GRADIENT_PARAMS_DECLARE;
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

	sib_color_gradient(
		0,
		coord,
		VECTOR_INPUT,
		SIB_COLOR_GRADIENT_PARAMS_USE,
		RGBA_COLOR_PARAM(o_result) );

	XSI_TEXTURE_DO_BUMP;
}

#endif
