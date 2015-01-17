/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt3d_fractal_v2_sl
#define __txt3d_fractal_v2_sl

#include "sib_texture_fractal.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

/*
*/
void txt3d_fractal_v2(
	SIB_TEXTURE_FRACTAL_PARAMS;
	
	point i_coord;
	uniform matrix i_transform;

	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha, i_bump_inuse;

	output color o_result;
	output float o_result_a; )
{
	point coord;
	uniform float i_torus_x=0, i_torus_y=0, i_torus_z=0;
	uniform point i_offset = 0;
	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord );
	
	float fractal;
	sib_texture_fractal( coord,
		SIB_TEXTURE_FRACTAL_PARAMS_LIST,
		fractal );

	o_result = fractal;
	o_result_a = fractal;

	XSI_TEXTURE_DO_BUMP
}

/* Softimage 2013 SP1 */
void txt3d_fractal_v2(
	SIB_TEXTURE_FRACTAL_PARAMS;

	point i_coord;

	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha, i_bump_inuse;

	RGBA_DECLARE_OUTPUT( o_result ) )
{
	txt3d_fractal_v2(
			i_time,
			i_noise_type,
			i_absolute,
			i_iter_max,
			i_level_min,
			i_level_decay,
			i_freq_mul,
			i_threshold,
			i_upper_bound,
			i_diffusion,

			i_coord,
			matrix(1),

			i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			i_min, i_max,

			i_step,
			i_factor,
			i_torus_u, i_torus_v,
			i_alpha, i_bump_inuse,

			RGBA_USE( o_result ) );
}

#endif
