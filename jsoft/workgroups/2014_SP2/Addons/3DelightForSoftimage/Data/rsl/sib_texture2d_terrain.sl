/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef _sib_texture2d_terrain_sl
#define _sib_texture2d_terrain_sl

#define TERRAIN_FRACTAL_PARAMETERS \
	float i_amplitude, i_u_freq, i_v_freq, i_ratio, i_iter_l, i_ruggedness
#define TERRAIN_FRACTAL_PARAMETERS_LIST \
	i_amplitude, i_u_freq, i_v_freq, i_ratio, i_iter_l, i_ruggedness

/* this is essentially the function from the core, modified to accept a
 * ruggedness parameter. TODO: clamp to pixel size
 */
float frac(
	point pos;
	TERRAIN_FRACTAL_PARAMETERS;)
{
	float res = 0;

	if( i_amplitude != 0 ) 
	{
		float u = xcomp(pos) * i_u_freq;
		float v = ycomp(pos) * i_v_freq;

		res += NOISE_2DL(u, v);
		u += u;
		v += v;
		float a = i_ratio;

		/* adjust the iteration level accordingly */
		float n_iter_l = 1.0 + (1.0 - pow(1.0-res, i_ruggedness)) * (i_iter_l - 1.0);
		n_iter_l = i_iter_l;
		float wh = floor( n_iter_l );
		
		res -= 0.5;
		
		if( wh!=0 )
		{
			float i;
			for(i=1; i < wh; i=i+1 )
			{
				res += a * (NOISE_2DL(u, v) - 0.5);
				u += u;
				v += v;
				a *= i_ratio;
			}
		}

		float fr = i_iter_l - wh;
		if( fr != 0.0 )
			res += fr * a * (NOISE_2DL(u, v) - 0.5);
	}

	return res + 0.5;	
}

#define SIB_TEXTURE2D_TERRAIN_PARAMS\
	RGBA_COLOR(i_snow_col); \
	RGBA_COLOR(i_rock_col);\
	RGBA_COLOR(i_grass_col);\
	float i_snow_rock_bound;\
	float i_rock_grass_bound;\
	float i_boundary_rugg, i_boundary_blend; \
	TERRAIN_FRACTAL_PARAMETERS

#define SIB_TEXTURE2D_TERRAIN_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_snow_col), \
	RGBA_COLOR_PARAM(i_rock_col), \
	RGBA_COLOR_PARAM(i_grass_col), \
	i_snow_rock_bound, i_rock_grass_bound, i_boundary_rugg, \
	i_boundary_blend, TERRAIN_FRACTAL_PARAMETERS_LIST

#define SIB_TEXTURE2D_TERRAIN_PARAMS_LIST_COPYALPHA \
	i_snow_col_a*i_alpha_factor, i_snow_col_a, \
	i_rock_col_a*i_alpha_factor, i_rock_col_a, \
	i_grass_col_a*i_alpha_factor, i_grass_col_a, \
	i_snow_rock_bound, i_rock_grass_bound, i_boundary_rugg, \
	i_boundary_blend, TERRAIN_FRACTAL_PARAMETERS_LIST

/* Softimage 2013 */
void sib_texture2d_terrain(
	point i_coord;
	SIB_TEXTURE2D_TERRAIN_PARAMS;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a; )
{
	/* The returned value should be balanced [0,1] (or [0,1 + 1^iter_l] )
	 * (don't know haven't tried to find out)
	 */
	float h = frac( i_coord, TERRAIN_FRACTAL_PARAMETERS_LIST );

	/* Add blending function */
	float ht = h + SNOISE_2DL(xcomp(i_coord) * 50 + 231, ycomp(i_coord) * 50 - 17.32 ) *
			i_boundary_rugg;
	
	float rgb = i_rock_grass_bound;
	float srb = i_snow_rock_bound;
	
	if( srb < rgb )
	{
		float tmp = srb; srb = rgb; rgb = tmp;
	}
	
	if( ht < rgb )
	{
		float pbb = i_boundary_blend * rgb;

		if( pbb!=0 && ht > (rgb - pbb) ) 
		{
			float t = LINE((rgb - pbb), rgb, ht);
			RGB_MIX(o_result, i_grass_col, i_rock_col, t);
		} else
			o_result = i_grass_col;
	}
	else if( ht < srb ) 
	{
		float pbb = i_boundary_blend * (rgb - srb);

		if( pbb!=0 ) 
		{
			if( ht < (rgb + pbb) ) 
			{
				float t = LINE(rgb, (rgb + pbb), ht);
				RGB_MIX(o_result, i_grass_col, i_rock_col, t);
			}
			else if(ht > (srb - pbb)) 
			{
				float t = LINE((srb - pbb), srb, ht);
				RGB_MIX(o_result, i_rock_col, i_snow_col, t);
			} else
				o_result = i_rock_col;
		}
		else 
			o_result = i_rock_col;
	}
	else 
	{
		float pbb = i_boundary_blend * (1.0 - srb);

		if(pbb!=0 && ht < (srb + pbb)) 
		{
			float t = LINE(srb, (srb + pbb), ht);
			RGB_MIX( o_result, i_rock_col, i_snow_col, t );
		} else
			o_result = i_snow_col;
	}
	
	o_result_a = h<0.0 ? 0.0 : h * i_amplitude;
}

/* Old Softimage */
void sib_texture2d_terrain(
	point i_coord;
	SIB_TEXTURE2D_TERRAIN_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture2d_terrain(
			i_coord,
			SIB_TEXTURE2D_TERRAIN_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

#endif
