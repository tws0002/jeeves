/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt2d_terrain_sl
#define __txt2d_terrain_sl

#include "sib_texture2d_terrain.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

/* Softimage 2013 */
void txt2d_terrain(
	SIB_TEXTURE2D_TERRAIN_PARAMS;
	XSI_TEXTURE_COMMON_PARAMS;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

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

	if( i_alpha_output == true )
	{
		sib_texture2d_terrain(
			coord,
			SIB_TEXTURE2D_TERRAIN_PARAMS_LIST_COPYALPHA,
			i_noise_type,
			XSI_TEXTURE_USE(i_permfiledat),
			XSI_TEXTURE_USE(i_valfiledat),
			RGBA_COLOR_PARAM(o_result) );
	}
	else
	{
		sib_texture2d_terrain(
			coord,
			SIB_TEXTURE2D_TERRAIN_PARAMS_LIST,
			i_noise_type,
			XSI_TEXTURE_USE(i_permfiledat),
			XSI_TEXTURE_USE(i_valfiledat),
			RGBA_COLOR_PARAM(o_result) );
	}

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt2d_terrain(
	SIB_TEXTURE2D_TERRAIN_PARAMS;
	XSI_TEXTURE_COMMON_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	txt2d_terrain(
			SIB_TEXTURE2D_TERRAIN_PARAMS_LIST,
			XSI_TEXTURE_COMMON_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}
#endif
