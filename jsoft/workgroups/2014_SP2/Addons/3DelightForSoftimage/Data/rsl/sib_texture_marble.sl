/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_marble_sl
#define __sib_texture_marble_sl

#define SIB_TEXTURE_MARBLE_PARAMS \
	RGBA_COLOR( i_filler_col ); \
	RGBA_COLOR( i_vein_col1 ); \
	RGBA_COLOR( i_vein_col2 ); \
\
	float i_vein_width, i_diffusion; \
\
	RGBA_COLOR( i_spot_col ); \
	float i_spot_bias, i_spot_scale, i_spot_density; \
\
	float i_amplitude, i_ratio, i_complexity; \
	point i_frequencies; \
	float i_absolute

#define SIB_TEXTURE_MARBLE_PARAMS_LIST \
	RGBA_COLOR_PARAM( i_filler_col ), \
	RGBA_COLOR_PARAM( i_vein_col1 ), \
	RGBA_COLOR_PARAM( i_vein_col2 ), \
	i_vein_width, i_diffusion, \
	RGBA_COLOR_PARAM( i_spot_col ), \
	i_spot_bias, i_spot_scale, i_spot_density, \
	i_amplitude, i_ratio, i_complexity, \
	i_frequencies, i_absolute

#define SIB_TEXTURE_MARBLE_PARAMS_LIST_COPYALPHA \
	i_filler_col_a*i_alpha_factor, i_filler_col_a, \
	i_vein_col1_a*i_alpha_factor, i_vein_col1_a, \
	i_vein_col2_a*i_alpha_factor, i_vein_col2_a, \
	i_vein_width, i_diffusion, \
	i_spot_col_a*i_alpha_factor, i_spot_col_a, \
	i_spot_bias, i_spot_scale, i_spot_density, \
	i_amplitude, i_ratio, i_complexity, \
	i_frequencies, i_absolute

/* Softimage 2013 */
void sib_texture_marble( 
	point i_point;

	SIB_TEXTURE_MARBLE_PARAMS;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a;)
{	
	float height = ozlib_fractal3D1D(
		i_point, i_absolute, i_frequencies, i_amplitude, i_ratio, i_complexity );

	height += i_point[1];
	
	float layer = floor( height );
	height = height - layer - i_vein_width;

	RGBA_COLOR(vcol1);
	RGBA_COLOR(vcol2);

	if( mod(layer, 2) != 0 ) 
	{
		RGBA_ASSIGN( vcol1, i_vein_col1 );
		RGBA_ASSIGN( vcol2, i_vein_col2 );
	} 
	else 
	{
		RGBA_ASSIGN( vcol1, i_vein_col2 );
		RGBA_ASSIGN( vcol2, i_vein_col1 );
	}
	
	if( height < 0 ) 
	{
		RGBA_ASSIGN( o_result, vcol1 );
	}
	else if( height > 1.0 - i_vein_width)
	{
		RGBA_ASSIGN( o_result, vcol2 );
	}
	else if(i_diffusion == 0)
	{
		RGBA_ASSIGN( o_result, i_filler_col );
	}
	else 
	{
		/* calculate the mixing */
		float intensa = exp(-height/i_diffusion);
		float intensb = exp(-(1.0 - i_vein_width - height)/i_diffusion);
		float intensf = 1.0-intensa-intensb;
			
		RGBA_ASSIGN( o_result, i_filler_col );
		RGBA_SMULT(o_result, intensf);
	
		RGBA_COLOR( tempcol );
	
		RGBA_ASSIGN( tempcol, vcol1 );
		RGBA_SMULT( tempcol, intensa);
		RGBA_ADD(o_result, o_result, tempcol);
		
		RGBA_ASSIGN( tempcol, vcol2 );
		RGBA_SMULT( tempcol, intensb );
		RGBA_ADD( o_result, o_result, tempcol );
	}
	
	if( i_spot_bias!=0 && i_spot_density!=0 && i_spot_scale!=0 )
	{
		float scale = pow(i_spot_scale, -3.0);
		point ns = (
			i_point[0] + NOISE_2DL(i_point[2], i_point[1]) * scale,
			i_point[1] + NOISE_2DL(i_point[0], i_point[2]) * scale, 
			i_point[2] + NOISE_2DL(i_point[1], i_point[0]) * scale );
		
		float bright = sibu_noise_3d_uni( ns );
		float level = 1.0-i_spot_density;
		
		if( bright > level ) {
			/* normalize brightness */
			bright = (bright-level)/(1.0-level);
			if(i_spot_bias != 0.5 )
				bright = pow(bright, log(i_spot_bias)/log(0.5));

			RGBA_MIX(o_result, o_result, i_spot_col, bright);
		}
	}
}

/* Old Softimage */
void sib_texture_marble( 
	point i_point;

	SIB_TEXTURE_MARBLE_PARAMS;

	output color o_result;
	output float o_result_a;)
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_marble( 
			i_point,

			SIB_TEXTURE_MARBLE_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a);
}

#endif

