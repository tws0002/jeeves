/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __rh_renderer_sl
#define __rh_renderer_sl

float RangeInterpolate(
	float color_a, color_b;
	float pos;
	float range_center, range_crossover )
{
	float res;

	float range_start = range_center - range_crossover*0.5;
	float range_end = range_center + range_crossover*0.5;
	
	if( range_start < 0 )
		range_start = 0;
	else if( range_end > 1 )
		range_end = 1;

	if( pos <= range_start )
		res = color_a;
	else if( pos >= range_end )
		res = color_b;
	else
	{
		float t  = (pos-range_start)/(range_end-range_start);
//		float t  = smoothstep(range_start, range_end, pos);
		res = mix( color_a, color_b, t );
	}

	return res;
}

color RangeInterpolate(
	color color_a, color_b;
	float pos;
	float range_center, range_crossover )
{
	color res;

	float range_start = range_center - range_crossover*0.5;
	float range_end = range_center + range_crossover*0.5;
	
	if( range_start < 0 )
		range_start = 0;
	else if( range_end > 1 )
		range_end = 1;

	if( pos <= range_start )
		res = color_a;
	else if( pos >= range_end )
		res = color_b;
	else
	{
		float t  = (pos-range_start)/(range_end-range_start);
//		float t  = smoothstep(range_start, range_end, pos);
		res = mix( color_a, color_b, t );
	}
	return res;
}

void rh_renderer(
	float i_self_shadow;

	/* bsp parameters are unused */
	float i_bsp_depth, i_bsp_max_leaf, i_bsp_max_tree, i_bsp_max_memory;

	RGBA_DECLARE( i_material );
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_diffuse_root );
	RGBA_DECLARE( i_diffuse_tip_A );
	RGBA_DECLARE( i_diffuse_tip_B );
	
	float i_tip_balance,
		i_diffuse_crossover_center,
		i_diffuse_crossover_range,
		i_diffuse_variation;
	
	float i_specular_in_use;
	RGBA_DECLARE( i_specular );
	float i_specular_decay;
	
	RGBA_DECLARE( i_irradiance );
	
	float i_transparency_in_use,
		i_transparency_root,
		i_transparency_tip,
		i_transparency_crossover_center,
		i_transparency_crossover_range;

	float i_diffuse_model;
	float i_normal_blend;

	float i_flat_shade_root, i_flat_shade_tip;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern float v;
	extern vector I;
	extern normal N;
	extern point P;
	extern vector dPdv;
	extern normal __root_normal;
	extern float __hair_id;

	o_result_a = 1;

	normal Nf = ShadingNormal( normalize(N) );

	/* Get the tip color by checking the A/B balance */
	color tip_color;
	if( i_tip_balance==0 )
		tip_color = i_diffuse_tip_A;
	else if( i_tip_balance==1 )
		tip_color = i_diffuse_tip_B;
	else
		tip_color = __hair_id > i_tip_balance ?
			i_diffuse_tip_A : i_diffuse_tip_B;

	color curr_color = RangeInterpolate(
		i_diffuse_root, tip_color, v,
		i_diffuse_crossover_center,
		i_diffuse_crossover_range  );

	/* Compute the vector we will use for lighting */
	vector T = normalize(dPdv);
	vector V = normalize(-I);

	color Cspec=0, Cdiff=0, Camb=0;
	illuminance( P )
	{
		vector Ln = normalize(L);
		vector H;

		float nonspecular = 0, nondiffuse = 0;
		lightsource( "__nonspecular", nonspecular );
		lightsource( "__nondiffuse", nondiffuse );
#if 0
// This gives really strange results...
		/* Get the lighting normal depending on the render
		   mode (surface normal or Kajyia-Key hack).
		   NOTE: we check the length of normal since when the "strand
		   multiplier" is active we have bad normals because of a bug
		   in XSI and we set these to 0. */
		if( i_diffuse_model == 0 && length(__root_normal) > 0)
			H = __root_normal;
		else
#endif
		{
			H = normalize(Ln - T * T.Ln);
		}
	
		/* Blend with curve normal if needed. */	
		if( i_normal_blend > 0 )
			H = normalize( mix(H, Nf, i_normal_blend) );

		float CosA = Ln.H;
		if( CosA > 0.0 && nondiffuse!=1 )
			Cdiff += Cl * CosA * (1-nondiffuse);

		if( i_specular_in_use!=0 && i_specular!=0 && nonspecular!=1 )
		{
			H = normalize((Ln+V) * 0.5);
			CosA = 1 - (T.H)*(T.H);
			if( CosA > 0.0 )
				Cspec += Cl * pow(CosA, i_specular_decay) * 
					(1-nonspecular);
		}
	}

	if( i_diffuse_variation != 0 )
	{
		color rnd_color = ctransform( "hsv", curr_color );
		rnd_color[0] = __hair_id;
		rnd_color = ctransform( "hsv", "rgb", rnd_color );
		curr_color = mix(curr_color, rnd_color, i_diffuse_variation/10);
	}

	Cdiff *= curr_color;
	Cspec *= i_specular;
	Camb = i_ambient*xsi_ambience();

	if( i_transparency_in_use != 0 )
	{
		o_result_a = 1-RangeInterpolate( 
			i_transparency_root, i_transparency_tip, v,
			i_transparency_crossover_center,
			i_transparency_crossover_range );
	}

	/* Compute color bleeding */
	color Cirr = curr_color * i_irradiance;
	if( Cirr != 0 )
		Cirr *= ColorBleeding( Cirr * o_result_a );

	Cdiff *= o_result_a;
	Cspec *= o_result_a;
	Camb *= o_result_a;
	Cirr *= o_result_a;

	o_result = Cdiff + Cspec + Camb + Cirr;

	XSI_MATERIAL_SET_OUTPUT( Diffuse, Cdiff );
	XSI_MATERIAL_SET_OUTPUT( Specular, Cspec );
	XSI_MATERIAL_SET_OUTPUT( Ambient, Camb );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, Cirr );

	extern color Oi;
	Oi *= o_result_a;
}

void rh_renderer(
	float i_self_shadow;

	float i_bsp_depth, i_bsp_max_leaf, i_bsp_max_tree, i_bsp_max_memory;

	RGBA_DECLARE(i_material);
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse_root);
	RGBA_DECLARE(i_diffuse_tip_A);
	RGBA_DECLARE(i_diffuse_tip_B);

	float i_tip_balance,
		i_diffuse_crossover_center,
		i_diffuse_crossover_range,
		i_diffuse_variation;

	float i_specular_in_use;
	RGBA_DECLARE( i_specular );
	float i_specular_decay;
	
	RGBA_DECLARE( i_irradiance );

	float i_transparency_in_use,
		i_transparency_root,
		i_transparency_tip,
		i_transparency_crossover_center,
		i_transparency_crossover_range;

	float i_diffuse_model;
	float i_normal_blend;

	float i_flat_shade_root, i_flat_shade_tip;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	rh_renderer(
		i_self_shadow,
		i_bsp_depth, i_bsp_max_leaf, i_bsp_max_tree, i_bsp_max_memory,
		RGBA_USE(i_material),
		color(0, 0, 0), 0,
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse_root),
		RGBA_USE(i_diffuse_tip_A),
		RGBA_USE(i_diffuse_tip_B),
		i_tip_balance,
		i_diffuse_crossover_center,
		i_diffuse_crossover_range,
		i_diffuse_variation,
		i_specular_in_use,
		RGBA_USE(i_specular),
		i_specular_decay,
		RGBA_USE(i_irradiance),
		i_transparency_in_use,
		i_transparency_root,
		i_transparency_tip,
		i_transparency_crossover_center,
		i_transparency_crossover_range,
		i_diffuse_model,
		i_normal_blend,
		i_flat_shade_root, i_flat_shade_tip,
		RGBA_USE(o_result));
}

#endif
