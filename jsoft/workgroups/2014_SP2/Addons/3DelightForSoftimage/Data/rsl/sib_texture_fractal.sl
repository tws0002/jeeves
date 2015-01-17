/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texture_fractal_sl
#define __sib_texture_fractal_sl

#define SIB_TEXTURE_FRACTAL_PARAMS \
	float i_time; \
	SIBU_FRACTAL_PARAMS; \
	float i_threshold; \
	float i_upper_bound, i_diffusion

#define SIB_TEXTURE_FRACTAL_PARAMS_LIST \
	i_time, SIBU_FRACTAL_PARAMS_LIST, i_threshold, i_upper_bound, i_diffusion

void sib_texture_fractal(
	point i_coord;
	SIB_TEXTURE_FRACTAL_PARAMS;

	output float o_result;)
{
	/* Remember that the fractal functions return values
	   between -1.0 and 1.0 unlike the mi_* functions */

	o_result = sibu_fractal_4d(i_coord,i_time,SIBU_FRACTAL_PARAMS_LIST)/2.0+0.5;
	
	if( o_result < i_threshold )
	{
		if(i_diffusion!=0)
			o_result = i_threshold*exp((o_result - i_threshold) / i_diffusion);
		else
			o_result = 0.0;
	}
	else if( o_result > i_upper_bound )
	{
		o_result = i_upper_bound;
	}	
}

/* Softimage 2014 SP1 */
void sib_texture_fractal(
	point i_coord;
	SIB_TEXTURE_FRACTAL_PARAMS;

	XSI_TEXTURE_DECLARE( i_permfiledat );
	XSI_TEXTURE_DECLARE( i_valfiledat );

	output float o_result;)
{
	sib_texture_fractal(
			i_coord,
			SIB_TEXTURE_FRACTAL_PARAMS_LIST,

			o_result);
}

#endif
