/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_grid_sl
#define __txt2d_gris_sl

#include "sib_texture2d_grid.sl"
#include "mib_bump_map.sl"
#include "mib_texture_remap.sl"

/*
	This is the more elaborate version of sib_texture2d_grid shader.
*/
void txt2d_grid(
	SIB_TEXTURE2D_GRID_PARAMS;
	
	point i_coord;

	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha, i_bump_inuse;

	uniform float i_alpha_output;
	float i_alpha_factor;

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

	if( i_alpha_output == 1 )
	{
		sib_texture2d_grid( coord,
			SIB_TEXTURE2D_GRID_PARAMS_LIST_COPYALPHA,
			RGBA_COLOR_PARAM(o_result) );
	}
	else
	{
		sib_texture2d_grid( coord,
			SIB_TEXTURE2D_GRID_PARAMS_LIST,
			RGBA_COLOR_PARAM(o_result) );
	}

	XSI_TEXTURE_DO_BUMP
}
#endif
