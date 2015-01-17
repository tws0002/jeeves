/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_wood_sl
#define __sib_texture_wood_sl

#define SIB_TEXTURE_WOOD_PARAMS \
	/* main texture parameters */ \
	RGBA_COLOR( i_filler_col ); \
	RGBA_COLOR( i_vein_col ); \
	float i_vein_spread, i_layer_size, i_randomness, i_age; \
\
	/* Grain parameters */ \
	RGBA_COLOR( i_grain_col ); \
	float i_grain_bias, i_grain_scale, i_grain_density; \
\
	/* Concentric ring location */ \
	float i_center_u, i_center_v; \
\
	/* Use wobbly structure instead of [0..1,0..1,0..1] containment */ \
	float i_wobbly_struct; \
 \
	float i_uamplitude, i_vamplitude, i_ratio, i_iter_l; \
	point i_frequencies; \
	float i_absolute

#define SIB_TEXTURE_WOOD_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_filler_col), RGBA_COLOR_PARAM(i_vein_col), \
	i_vein_spread, i_layer_size, i_randomness, i_age, \
	RGBA_COLOR_PARAM(i_grain_col), i_grain_bias, i_grain_scale, i_grain_density, \
	i_center_u, i_center_v, \
	i_wobbly_struct, i_uamplitude, i_vamplitude, i_ratio, i_iter_l, i_frequencies, \
	i_absolute

#define SIB_TEXTURE_WOOD_PARAMS_LIST_COPYALPHA \
	i_filler_col_a * i_alpha_factor,  i_filler_col_a, \
	i_vein_col_a * i_alpha_factor, i_vein_col_a, \
	i_vein_spread, i_layer_size, i_randomness, i_age, \
	i_grain_col_a * i_alpha_factor, i_grain_col_a, \
	i_grain_bias, i_grain_scale, i_grain_density, \
	i_center_u, i_center_v, \
	i_wobbly_struct, i_uamplitude, i_vamplitude, i_ratio, i_iter_l, i_frequencies, \
	i_absolute

/* Softimage 2013 */
void sib_texture_wood(
	point i_coord;
	SIB_TEXTURE_WOOD_PARAMS;

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a; )
{
	point coord = i_coord;

	if( i_wobbly_struct != 0 )
	{
		if( i_uamplitude!=0 || i_vamplitude!=0 )
		{
			coord += vector( sibu_frac3D2D( i_coord, FRACTAL_3D2D_PARAMS_LIST ));
		}
	}

	point noisebase = point( floor(coord[0]), floor(coord[1]), 0 );

	float _u = coord[0] - noisebase[0];
	float _v = coord[1] - noisebase[1];

	if( i_wobbly_struct==0 )
	{
		if( i_uamplitude!=0 || i_vamplitude!=0 )
		{
			point tmpvec = sibu_frac3D2D( i_coord, FRACTAL_3D2D_PARAMS_LIST );
			_u += tmpvec[0];
			_v += tmpvec[1];
		}
	}


	float dist = HYPOT( _u - i_center_u, _v - i_center_v );

	/* now 'dist' is the distance to the center of the twig. Henceforth,
	 * we apply transformations to turn it into the blend between vein
	 * colour and filler colour.
	 * What we have to do to turn dist into an index into a single ring.
	 * But first,  let's consider the forward transformation.  We take a
	 * scalar describing the distance traveled through successive rings, 
	 * and want to produce a scalar describing radius.  First, to get
	 * random variation to the thickness, a noise function of the scalar is
	 * added.  Then a scaling is applied which translates it into the
	 * distance.
	 * The particular scaling we use is to start at a specific scale 's1'
	 * and at the age of 'age' have grown the scaling _linearly_ to 's2'
	 * which we maintain.  The result of this speculation is a once
	 * differentiable
	 * function ( we put s1=0 and s2 = s):
	 * radius = scalar<age : s/(2*age) * scalar *scalar
	 *			scalar>age : -s*age/2 + s*scalar
	 * i.e. a parabolic/linear function.
	 * Our reverse transformation is, of course,  the reverse of this.
	 */
	
	float scale = max( i_layer_size, 0.001 );
	float tmp = i_age * scale * 0.5;

	if( dist < tmp )
		dist = sqrt( i_age*dist*2.0/scale );
	else
		dist = (dist+tmp)/scale;

	/* apply random factor to ring thickness */
	if( i_randomness!=0 )
	{
		noisebase[2] = dist;
		dist += mi_noise_3d( noisebase ) * i_randomness;
	}
	
	/* now, the 'dist' is the aforementioned scalar index into the rings. */
	
	dist = SLICE(dist);
	dist = i_vein_spread!=0 ? exp(-dist/i_vein_spread) : 1.0;

	RGBA_MIX( o_result, i_filler_col, i_vein_col, dist );
	
	if( i_grain_bias!=0 && i_grain_density!=0 )
	{
		point ns;
		
		if( i_grain_scale!=0 )
			ns = i_coord * point(100,100,2) / i_grain_scale;
		else
			ns = i_coord * point(1000,1000,20);

		/* disturb a parameter to hide any repetiveness in the noise */
		/* not used now, since we have learned that the extremes of
		   the noise function are no longer on the lattice points.*/
		/*ns.x += FLOOR(FL(100.0)*SIN(FLOOR(ns.y+FL(0.5)))); */
		ns[1] += 3 * sin(ns[2]*0.5);

		float bright = sibu_noise_3d_uni( ns );
		float level = 1.0 - i_grain_density;

		if( bright > level )
		{
			/* normalize brightness */
			bright = (bright-level)/(1.0-level);

			if( i_grain_bias != 0.5 )
				bright = pow(bright, log(i_grain_bias)/log(0.5));

			RGBA_MIX(o_result, o_result, i_grain_col, bright );
		}
	}
}

/* Old Softimage */
void sib_texture_wood(
		point i_coord;
		SIB_TEXTURE_WOOD_PARAMS;

		output color o_result;
		output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_wood(
			i_coord,
			SIB_TEXTURE_WOOD_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}
#endif
