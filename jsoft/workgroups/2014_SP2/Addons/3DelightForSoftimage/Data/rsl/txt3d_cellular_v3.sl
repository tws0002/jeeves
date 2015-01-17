/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt3d_cellular_v3_sl
#define __txt3d_cellular_v3_sl

#include "mib_texture_remap.sl"
#include "sib_texture_cell.sl"
#include "mib_bump_map.sl"

/*
 * Generates an organic cell-like texture.
 * The texture is comprised of two color inputs.
 * 
 * PARAMETERS:
 * i_noise_type: the algorithm for the pattern: 
 * - Legacy produces the same pattern as in versions prior to Softimage 2013
 * - Default produces the same pattern as shown in High Quality display mode
 */

/* Softimage 2013 */
void txt3d_cellular_v3(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);
	point i_coord;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_bump_inuse;
	uniform float i_alpha_output;
	float i_alpha_factor;

	float i_noise_type;
	float i_seed;

	XSI_TEXTURE_DECLARE(i_tex);

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

	float cell, index;
	sib_texture_cell(
			coord,
			i_noise_type,
			i_seed,
			XSI_TEXTURE_USE(i_tex),
			cell,
			index );

	if( i_alpha_output == 1 )
	{
		o_result = mix( i_color1_a, i_color2_a, cell ) * i_alpha_factor;
	}
	else
	{
		RGBA_MIX( o_result, i_color1, i_color2, cell );
	}

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt3d_cellular_v3(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);
	point i_coord;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_bump_inuse;
	uniform float i_alpha_output;
	float i_alpha_factor;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	txt3d_cellular_v3(
			RGBA_USE(i_color1),
			RGBA_USE(i_color2),
			i_coord,
			i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			i_min, i_max,
			i_step,
			i_factor,
			i_torus_u, i_torus_v,
			i_alpha,
			i_bump_inuse,
			i_alpha_output,
			i_alpha_factor,

			0,
			0,

			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

#endif
