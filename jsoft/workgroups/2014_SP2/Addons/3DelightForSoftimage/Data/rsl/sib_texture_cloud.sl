/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texture_cloud_sl
#define __sib_texture_cloud_sl

#define SIB_TEXTURE_CLOUD_PARAMS \
	RGBA_COLOR( i_color1 ); \
	RGBA_COLOR( i_color2 ); \
	float i_contrast; \
	float i_trans_range, i_trans_amp, i_center_thresh, i_edge_thresh; \
	SIBU_FRACTAL_PARAMS

#define SIB_TEXTURE_CLOUD_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_color1), RGBA_COLOR_PARAM(i_color2),	\
	i_contrast, i_trans_range, i_trans_amp, \
	i_center_thresh, i_edge_thresh, \
	SIBU_FRACTAL_PARAMS_LIST

#define SIB_TEXTURE_CLOUD_PARAMS_LIST_COPYALPHA \
	i_color1_a*i_alpha_factor, i_color1_a, \
	i_color2_a*i_alpha_factor, i_color2_a, \
	i_contrast, i_trans_range, i_trans_amp, \
	i_center_thresh, i_edge_thresh, \
	SIBU_FRACTAL_PARAMS_LIST

void sib_texture_cloud(
	point i_coord;
	SIB_TEXTURE_CLOUD_PARAMS;
	float i_time;

	float i_incalpha;
	float i_edgetrans;

	output color o_result;
	output float o_result_a; )
{
	extern normal N;
	extern vector I;

	RGBA_COLOR( tmpcol );
	float blend;
	float trans_range=0, trans_amp=0;
	float center_thresh=0, edge_thresh=0;

	if( i_edgetrans!=0 )
	{
		trans_range = i_trans_range;;
		trans_amp =	i_trans_amp;
		center_thresh =	i_center_thresh;
		edge_thresh = i_edge_thresh;
	}

	if( i_incalpha!=0 ) 
	{
		/* Mix the alpha of the two colours as well. */
		if(i_contrast==0) 
		{
			/* No need to get a fractal, contrast is zero */
			RGBA_MIX(o_result, i_color1, i_color2, 0.5 );
		}
		else 
		{
			/* indeed, we need a fractal */
			blend = sibu_fractal_4d(i_coord, i_time, SIBU_FRACTAL_PARAMS_LIST );
				
			RGBA_CONTRAST( tmpcol, i_color1, i_color2, i_contrast );
			RGBA_CONTRAST( o_result, i_color2, i_color1, i_contrast );
			RGBA_MIX( o_result, o_result, tmpcol, blend+0.5 );
		}
	}
	else 
	{
		/* Don't mix the alpha. */
		if( i_contrast==0 ) 
		{
			 /* No need to get a fractal, contrast is zero */
			RGB_MIX(o_result, i_color1, i_color2, 0.5);
		}
		else 
		{
			/* indeed, we need a fractal */
			float blend = sibu_fractal_4d(i_coord, i_time, SIBU_FRACTAL_PARAMS_LIST);

			RGB_CONTRAST(tmpcol, i_color1, i_color2, i_contrast);
			RGB_CONTRAST(o_result, i_color2, i_color1, i_contrast);
			RGB_MIX(o_result, o_result, tmpcol, blend+0.5);
		}

		o_result_a = 1;  /* fully opaque */
	}

	if( i_edgetrans!=0 ) 
	{
		/* Handle the transparency near the edges.
		 * get absolute value of dot product of surface normal and incident
		 */
		// TODO: can remove a SQRT here (FIXME)
		float blend = abs(N.I) / (length(N)*length(I) ); 

		/* turn into distance from centre on linear 0-1 scale (cos to sin)*/
		blend = sqrt(1.0-clamp(sqr(blend), 0.0, 1.0));

		/* use to calculate offset of fractal */
		if( trans_range!=0 )
		{
			blend = (blend-0.5)/trans_range + 0.5;
			blend = clamp(blend, 0.0, 1.0);	
			blend = (1.0-blend)*center_thresh + blend*edge_thresh;
		}
		else
		{
			blend = blend<0.5 ? center_thresh : edge_thresh;
		}

		/* okay, now we have the thresholds. */
		/* now, get the fractal and add to threshold*/
		if( trans_amp!=0 )
		{
			point coord = i_coord + vector( 233.64, -741.12, 198.92 );
			blend += trans_amp *
				sibu_fractal_4d(coord, i_time, SIBU_FRACTAL_PARAMS_LIST);
		}

		/* clamp the result and use for alpha */
		blend = clamp(blend, 0.0, 1.0);
		o_result_a *= blend;
	}
}

/* Softimage 2014 SP1 */
void sib_texture_cloud(
	point i_coord;
	SIB_TEXTURE_CLOUD_PARAMS;
	float i_time;

	float i_incalpha;
	float i_edgetrans;

	XSI_TEXTURE_DECLARE( i_permfiledat );
	XSI_TEXTURE_DECLARE( i_valfiledat );

	output color o_result;
	output float o_result_a; )
{
	sib_texture_cloud(
			i_coord,
			SIB_TEXTURE_CLOUD_PARAMS_LIST,
			i_time,

			i_incalpha,
			i_edgetrans,

			o_result,
			o_result_a);
}

#endif
