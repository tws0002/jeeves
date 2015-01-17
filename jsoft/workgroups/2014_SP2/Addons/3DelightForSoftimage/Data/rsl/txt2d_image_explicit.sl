/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_image_explicit_sl
#define __txt2d_image_explicit_sl

#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

void txt2d_image_explicit(
	RGBA_DECLARE(i_tex);
	point i_coord;
	
	uniform matrix i_transform;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	float i_torus_x, i_torus_y, i_torus_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_bump_inuse;
	float i_alpha_output;
	float i_alpha_factor;

	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear;
	float i_filtered;
	float i_bump_filtered;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	o_result_a = i_tex_a;

	if( i_alpha_output == 1 )
		o_result = o_result_a * i_alpha_factor;
	else
		o_result = i_tex;
}

void txt2d_image_explicit(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;
	
	uniform matrix i_transform;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_bump_inuse;
	float i_alpha_output;
	float i_alpha_factor;

	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear;
	float i_filtered;
	float i_bump_filtered;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	point coord;
	uniform point i_offset = 0;
	uniform float i_torus_x=1, i_torus_y=1, i_torus_z=1;
	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord );

	o_result_a = xsi_textureLookupA(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);

	if( i_alpha_output == 1 )
		o_result = o_result_a * i_alpha_factor;
	else
	{	
		o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);
	}

	XSI_TEXTURE_DO_BUMP;
}

void txt2d_image_explicit(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;

	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_bump_inuse;
	float i_alpha_output;
	float i_alpha_factor;

	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear;
	float i_filtered;
	float i_bump_filtered;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	uniform matrix trs = 1;

	txt2d_image_explicit( XSI_TEXTURE_USE(i_tex), i_coord, trs,
		i_repeats,
		i_alt_x, i_alt_y, i_alt_z,
		i_min, i_max,
		i_step, i_factor, i_torus_u, i_torus_v, i_alpha,
		i_bump_inuse, i_alpha_output, i_alpha_factor,
		i_eccmax, i_maxminor, i_disc_r, i_bilinear, i_filtered, i_bump_filtered,
		RGBA_USE(o_result));
}

#endif