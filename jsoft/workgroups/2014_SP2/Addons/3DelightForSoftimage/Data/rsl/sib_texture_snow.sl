/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_snow_sl
#define __sib_texture_snow_sl

#define SIB_TEXTURE_SNOW_PARAMS \
	RGBA_COLOR(i_snow_col); \
	RGBA_COLOR(i_surface_col); \
	float i_threshold, i_depth_decay, i_thickness, i_randomness, i_rand_freq

#define SIB_TEXTURE_SNOW_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_snow_col), \
	RGBA_COLOR_PARAM(i_surface_col), \
	i_threshold, i_depth_decay, i_thickness, i_randomness, i_rand_freq

#define SIB_TEXTURE_SNOW_PARAMS_LIST_COPYALPHA \
	i_snow_col_a*i_alpha_factor, i_snow_col_a, \
	i_surface_col_a*i_alpha_factor, i_surface_col_a, \
	i_threshold, i_depth_decay, i_thickness, i_randomness, i_rand_freq

/* Softimage 2013 */
void sib_texture_snow(
	point i_coord;

	SIB_TEXTURE_SNOW_PARAMS;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a; )
{
	extern normal N;

	vector world_up = vector(0, 1, 0);
	normal dir = ntransform( "world", normalize(N) );

	float dot = dir.world_up;

	if( i_randomness!=0 )
	{
		dot -= mi_noise_3d(i_coord*i_rand_freq) * i_randomness;
	}
	
	dot = dot - 1.0 + i_threshold;
	if(dot <= 0.0)
		dot = 0.0;
	else 
	{
		dot *= i_depth_decay;
		if(dot > 1.0)
			dot = 1.0;
		dot *= i_thickness;
	}
	
	RGBA_MIX( o_result, i_surface_col, i_snow_col, dot );
}

/* Old Softimage */
void sib_texture_snow(
	point i_coord;

	SIB_TEXTURE_SNOW_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_snow(
			i_coord,

			SIB_TEXTURE_SNOW_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

#endif
