/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_image_sl
#define __txt2d_image_sl

#include "mib_texture_remap.sl"

void txt2d_image(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;
	uniform matrix i_transform;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	float i_alpha_output;
	float i_alpha_factor;

	output color o_result;
	output float o_result_a; )
{
	point coord;
	uniform float i_torus_x = 0, i_torus_y = 0, i_torus_z = 0;
	uniform point i_offset = 0;
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
}

void txt2d_image(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	float i_alpha_output;
	float i_alpha_factor;

	output color o_result;
	output float o_result_a; )
{
	uniform matrix trs = 1;

	txt2d_image(
		XSI_TEXTURE_USE(i_tex), i_coord, trs,
		i_repeats, i_alt_x, i_alt_y, i_alt_z,
		i_min, i_max,
		i_alpha_output, i_alpha_factor,
		o_result, o_result_a );
}
#endif
