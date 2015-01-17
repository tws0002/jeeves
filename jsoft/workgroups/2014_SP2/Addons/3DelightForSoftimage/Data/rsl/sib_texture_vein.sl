/*
	Copyright (c) 2007 TAARNA Studios International.
*/


#ifndef __sib_texture_vein_sl
#define __sib_texture_vein_sl

#define SIB_TEXTURE_VEIN_PARAMS \
	float i_thickness, i_complexity; \
	float i_falloff; \
	float i_sharpness; \
	float i_intensity; \
	float i_time

#define SIB_TEXTURE_VEIN_PARAMS_LIST \
	i_thickness, i_complexity, i_falloff, i_sharpness, i_intensity, i_time

void sib_texture_vein(
	point i_coord; 
	SIB_TEXTURE_VEIN_PARAMS;
	output float o_result; )
{
	float i_noise_type = 0;
	float i_absolute = 0;
	float i_iter_max = i_complexity;
	float i_level_min = 0;
	float i_level_decay = 0.707;
	float i_freq_mul = 2;

	float vein = sibu_fractal_4d(
		i_coord, i_time, SIBU_FRACTAL_PARAMS_LIST )/2.0 + 0.5;

	float thickness = i_thickness/(10.0*i_iter_max);
	float falloff = i_falloff/2.0;

	float abs_vein = abs( vein - 0.5 );

	if( abs_vein < thickness )
		vein = 1.0;
	else if( abs_vein<(thickness+falloff) )
	{
		vein = (1.0-i_sharpness) *
				sibu_interpolate(
					INTERP_COSINE_UP, 0, falloff,
					abs_vein-thickness, 1, 0);
	}
	else
		vein = 0.0;

	o_result = vein * i_intensity;
}

/* Softimage 2014 SP1 */
void sib_texture_vein(
	point i_coord;
	SIB_TEXTURE_VEIN_PARAMS;

	XSI_TEXTURE_DECLARE( i_permfiledat );
	XSI_TEXTURE_DECLARE( i_valfiledat );

	output float o_result;)
{
	sib_texture_vein(
			i_coord,
			SIB_TEXTURE_VEIN_PARAMS_LIST,

			o_result);
}
#endif
