/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt3d_flagstone_v3_sl
#define __txt3d_flagstone_v3_sl

#include "mib_texture_remap.sl"
#include "sib_texture_flagstone.sl"
#include "mib_bump_map.sl"

/* Softimage 2013 */
void txt3d_flagstone_v3(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);
	float i_mortar_width;
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
	XSI_TEXTURE_DECLARE(i_permfiledat);

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

	float mortar, stone_color;
	sib_texture_flagstone(
		coord,
		i_mortar_width,

		i_noise_type,
		i_seed,
		XSI_TEXTURE_USE(i_permfiledat),

		mortar,
		stone_color );

	if( mortar == 1 )
	{
		if( i_alpha_output == true )
			o_result = i_color1_a * i_alpha_factor;
		else
		{
			RGBA_ASSIGN( o_result, i_color1 );
		}
	}
	else
	{
		if( i_alpha_output == 1 )
		{
			o_result_a = mix(i_color2_a, i_color1_a, mortar );
			o_result = mix( o_result_a, i_color1_a, stone_color );
			o_result *= i_alpha_factor;
		}
		else
		{
			RGBA_MIX( o_result, i_color2, i_color1, mortar );
			RGBA_MIX( o_result, o_result, i_color1, stone_color );
		}
	}

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt3d_flagstone_v3(
	RGBA_COLOR(i_color1);
	RGBA_COLOR(i_color2);
	float i_mortar_width;
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

	txt3d_flagstone_v3(
			RGBA_USE(i_color1),
			RGBA_USE(i_color2),
			i_mortar_width,
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
			o_result_a);
}

#endif
