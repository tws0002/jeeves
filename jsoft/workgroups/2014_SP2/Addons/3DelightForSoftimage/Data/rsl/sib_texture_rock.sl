/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_rock_sl
#define __sib_texture_rock_sl

/* Softimage 2013 */
void sib_texture_rock(
	point i_coord;
	float i_grain_size, i_diffusion, i_mix_ratio;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output float o_result; )
{
	/* NOTE: the x2 factor here on the grain size is a fudge to
	   match mental delay's look */
	point coord = i_coord;

	if( i_grain_size )
		coord /= (i_grain_size*2.0);
	
	float c = mi_noise_3d( coord ) - i_mix_ratio;

	float t = c/i_diffusion;	

	if( i_diffusion )
		o_result = c>0.0 ? 0.5-0.5*(exp(-t)-1) : 0.5*exp(t);
	else
		o_result = c>0.0 ? 1.0 : 0.0;
}

/* Old Softimage */
void sib_texture_rock(
	point i_coord;
	float i_grain_size, i_diffusion, i_mix_ratio;

	output float o_result; )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_rock(
			i_coord,
			i_grain_size, i_diffusion, i_mix_ratio,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result );
}

#endif
