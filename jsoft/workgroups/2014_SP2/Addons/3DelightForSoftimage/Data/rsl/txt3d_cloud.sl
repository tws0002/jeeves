/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt3d_cloud_sl
#define __txt3d_cloud_sl

#include "sib_texture_cloud.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

/* Softimage 2013 */
void txt3d_cloud(
	SIB_TEXTURE_CLOUD_PARAMS;
	float i_time;
	point i_coord; 
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v; 
	float i_alpha, i_bump_inuse;
	float i_incalpha, i_edgetrans;
	uniform float i_alpha_output;
	float i_alpha_factor;

	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

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

	if( i_alpha_output == 1 )
	{
		sib_texture_cloud(
			coord, SIB_TEXTURE_CLOUD_PARAMS_LIST_COPYALPHA,
			i_time, i_incalpha, i_edgetrans,
			RGBA_COLOR_PARAM(o_result) );
	}
	else
	{
		sib_texture_cloud(
			coord, SIB_TEXTURE_CLOUD_PARAMS_LIST,
			i_time, i_incalpha, i_edgetrans,
			RGBA_COLOR_PARAM(o_result) );
	}

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt3d_cloud(
	SIB_TEXTURE_CLOUD_PARAMS;
	float i_time;
	point i_coord; 
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v; 
	float i_alpha, i_bump_inuse;
	float i_incalpha, i_edgetrans;
	uniform float i_alpha_output;
	float i_alpha_factor;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	txt3d_cloud(
			SIB_TEXTURE_CLOUD_PARAMS_LIST,
			i_time,
			i_coord,
			i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			i_min, i_max,
			i_step,
			i_factor,
			i_torus_u, i_torus_v,
			i_alpha, i_bump_inuse,
			i_incalpha, i_edgetrans,
			i_alpha_output,
			i_alpha_factor,

			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}


#endif
