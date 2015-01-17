/*
	Copyright (c) 2009 TAARNA Studios International.
	Copyright (c) 2011 DNA Research.
*/

#ifndef __mia_material_sl
#define __mia_material_sl

#include "XSIAmbientOcclusion.sl"

// Compute the square of a given value.
float sq(float x)
{
	return x * x;
}

// Compute the roughness corresponding to a given glossiness value.
float roughness(float gloss)
{
	return pow(2.0, 8.0 * gloss);
}

// Compute sampling parameters.
float compute_sampling_angle( float glossiness; )
{
	if( glossiness >= 1.0 )
		return 0.0;
	else
	    return (1.0 - pow(clamp(glossiness, 0.0, 1.0), 0.1)) * PI / 2.0;
}

color xsi_trace_with_environment(
	point i_P;
	vector i_I, i_N;
	float i_ior;
	float i_glossiness, i_samples;
   	uniform float i_single_env_sample;
	uniform float i_is_refration_flag;
	uniform bool i_falloff_on;
	float i_falloff_dist;
	uniform bool i_falloff_color_on;
	color i_falloff_color;
	color i_weight; )
{
	color reflection = 0;

	bool solid_env_color_flag =
		(i_falloff_on==true && i_falloff_color_on==true) ? true : false; 
	uniform float maxdist = ( i_falloff_on == 0 ) ? 0 : i_falloff_dist;
	
	uniform string envmap = "";
	if( solid_env_color_flag == 0)
	{
		option( "user:_3delight_reflection_envmap", envmap );

		/* 3dfmax environment map */
		if( envmap == "" )
		{
			option( "user:__3dfmax_envmap", envmap );
		}
	}

	vector trace_dir;
	if( i_is_refration_flag != 0 )
	{
		/* Get the refraction direction */
		trace_dir = refract( i_I, i_N, i_ior);
		if( length( trace_dir ) < 1e-4 )
		{
			/* There is no refraction. It means an angle of incidence
			 * less than Brewster's angle, and the light is perfectly
			 * reflected. */
			trace_dir = reflect( i_I, i_N );
		}
	}
	else
	{
		/* Get the reflection direction */
		trace_dir = reflect( i_I, i_N );
	}

	if( i_glossiness >= 1 )
	{
		color T;
		float hitdist;
		reflection =
			trace( i_P, trace_dir, hitdist,
					"samples", i_samples,
					"transmission", T,
					"maxdist", maxdist,
					"environmentmap", envmap,
					"environmentspace", "world",
					"weight", i_weight,
					"subset", "-xsi_InvisibleToReflectionRays");

		if( i_falloff_on==true )
		{
			/* quadratic falloff. */
			T = 1-pow( 1-clamp(hitdist/maxdist,0,1), 2)*(1-T);

			if( T[0]>0 || T[1]>0 || T[2]>0 )
			{
				color env_color = 0;
				if( solid_env_color_flag != 0 )
				{
					env_color = i_falloff_color;
				}
				else if( envmap != "" )
				{
					env_color =
						environment (envmap, vtransform("world", trace_dir));
				}

				reflection = mix( reflection, env_color, T );
			}
		}
	}
	else
	{
		vector W_o;
		vector __N;
		if( i_is_refration_flag != 0 )
		{
			/* Refraction */
			/* There is no blinn distribution for refraction
			 * in standard trace() */
			W_o = reflect(-trace_dir, -i_N);
			__N = -i_N;
		}
		else
		{
			/* Reflection */
			W_o = -i_I;
			__N = i_N;
		}

		float roughness = 1-pow(i_glossiness, 1/5.5);

		color T;
		float hitdist;
		reflection =
			trace( i_P, __N, hitdist,
					"distribution", "blinn",
					"wo", W_o,
					"roughness", roughness,
					"samples", i_samples,
					"transmission", T,
					"maxdist", maxdist,
					"environmentmap", envmap,
					"environmentspace", "world",
					"weight", i_weight,
					"subset", "-xsi_InvisibleToReflectionRays");

		if( i_falloff_on==true )
		{
			/* quadratic falloff. */
			T = 1-pow( 1-clamp(hitdist/maxdist,0,1), 2)*(1-T);

			if( T[0]>0 || T[1]>0 || T[2]>0 )
			{
				color env_color = 0;
				if( solid_env_color_flag != 0 )
				{
					env_color = i_falloff_color;
				}
				else if( envmap != "" )
				{
					if(i_single_env_sample == 1)
					{
						env_color =
							environment(
									envmap,
									vtransform("world", trace_dir));
					}
					else
					{
						/* Trace environment only. Temporary solution: use
						 * trace() with "subset" "__tmp__shit__" */
						env_color =
							trace( i_P, __N, hitdist,
									"distribution", "blinn",
									"wo", W_o,
									"roughness", roughness,
									"samples", i_samples,
									"weight", i_weight,
									"environmentmap", envmap,
									"environmentspace", "world",
									"subset", "__tmp__shit__");
					}
				}
				reflection = mix( reflection, env_color, T );
			}
		}
	}

	return reflection;
}

/*
	Compute reflection component.
*/
color mia_material_reflection(
	vector In;
	normal Nf;
	vector V;
	float refl_gloss;
	float refl_gloss_samples;
	uniform bool i_single_env_sample;
	uniform bool i_falloff_on;
	float i_falloff_dist;
	uniform bool i_falloff_color_on;
	color i_falloff_color;
	color i_weight; )
{
	extern point P;
	extern float __reflects;

	if( __reflects == 0 )
	{
		return color 0;
	}

	// Compute the sampling parameters.
	float sample_angle = compute_sampling_angle( refl_gloss );
	float sample_count = (refl_gloss == 0) ?
		min(4, refl_gloss_samples) : refl_gloss_samples;

	// Compute reflected direction.
	vector refl_dir = reflect(In, Nf);

	return xsi_trace_with_environment(
			P, In, Nf, 0.0,
			refl_gloss,
			sample_count,
			i_single_env_sample,
			0,
			i_falloff_on,
			i_falloff_dist,
			i_falloff_color_on,
			i_falloff_color,
			i_weight );
}


/*
	Compute refraction component.
*/
color mia_material_refraction(
	normal Nn;
	vector In;
	normal Nf;
	vector V;
	float refr_ior;
	float refr_gloss;
	float refr_gloss_samples;
	uniform bool i_single_env_sample;
	uniform bool i_falloff_on;
	float i_falloff_dist;
	uniform bool i_falloff_color_on;
	color i_falloff_color;
	color i_weight; )
{
	extern point P;
	extern float __refracts;

	if( __refracts == 0 )
	{
		return 0;
	}

	// Compute the sampling parameters.
	float sample_angle = compute_sampling_angle( refr_gloss );
	float sample_count = (refr_gloss == 0) ?
		min(4, refr_gloss_samples) : refr_gloss_samples;

	// Compute refracted direction.
	float eta = (In . Nn < 0.0) ? 1.0 / refr_ior : refr_ior;
	vector refr_dir = refract(In, Nf, eta);

	return xsi_trace_with_environment(
			P, In, Nf, eta,
			refr_gloss,
			sample_count,
			i_single_env_sample,
			1,
			i_falloff_on,
			i_falloff_dist,
			i_falloff_color_on,
			i_falloff_color,
			i_weight );
}

/*
	Compute specular highlights.

	NOTES
	- We use the ward anysotropic model. But we sum 3 highlights with decreasing
	roughness and increasing contribution.
*/
color mia_material_specular_highlights(
	normal	i_Nf;
	vector	i_V;
	float	i_refl_roughness_u, i_refl_roughness_v;
	vector	i_dPdu, i_dPdv)
{
	extern color Cl;
	extern point P;

	vector xdir = normalize( i_dPdu );
	vector ydir = normalize( i_dPdv );

	xdir = normalize(i_Nf^xdir^i_Nf);
	ydir = normalize(i_Nf^ydir^i_Nf);
	
	color highlights = 0;

	/* We have three specular highlights of diminushing roughness but increasing
	   brightness */
	uniform float component_coefs[3] = {0.5, 1.0, 1.5}; 

	illuminance( "specular", P, i_Nf, PI * 0.5 )
	{
		float nonspecular = 0;
		lightsource ("__nonspecular", nonspecular);

		if (nonspecular < 1) 
		{

			vector Ln = normalize(L);

			float dot_ln = Ln . i_Nf;
			float dot_vn = i_V . i_Nf;

			if( dot_vn*dot_ln>0.0 )
			{
				vector Hn = normalize(i_V + Ln);
				float dot_hn2 = min(sq(Hn . i_Nf), 1.0);

				if( dot_hn2>0.0 )
				{
					/* precompute this to get it out of the loop below */
					float k1_devider = 1 / (sqrt(dot_vn * dot_ln) * 4.0 * PI);  
					float smooth_step_ln = smoothstep( 0, 0.25, dot_ln );

					uniform float i=0;
					uniform float roughness_coef = 1;

					for( i=0; i<3; i+=1.0 )
					{
						// Compute the highlight due to this light source.
						float k1 =
							(i_refl_roughness_u * 
							 	i_refl_roughness_v *
								roughness_coef *
								roughness_coef ) *
							k1_devider;
						float k2 =
							sq(Hn.xdir * i_refl_roughness_u * roughness_coef) +
							sq(Hn.ydir * i_refl_roughness_v * roughness_coef);
						color c =
							k1 * exp(-k2 / dot_hn2)
							* dot_ln
							* smooth_step_ln;

						// Accumulate highlights.
						highlights +=
							Cl * c * component_coefs[i] * (1-nonspecular);

						roughness_coef *= 0.5;
					}
				}
			}
		}
	}

	return highlights;
}

/*
	Rotates x and y around z
*/
void mia_material_rotate_axis(
	float i_amount;
	output vector io_x;
	output vector io_y;
	vector i_z)
{
	matrix localVMatrix = matrix(
		io_x[0], io_x[1], io_x[2], 0.0,
		io_y[0], io_y[1], io_y[2], 0.0,
		i_z[0], i_z[1], i_z[2], 0.0,
		0.0, 0.0, 0.0, 1.0 );

	float amount = i_amount * 2 * PI;

	vector x = vector(cos(amount), sin(amount), 0);
	vector y = vector(cos(amount - PI/2), sin(amount - PI/2), 0);

	io_x = vector(
			comp(localVMatrix,0,0)*x[0] + comp(localVMatrix,1,0)*x[1] + comp(localVMatrix,2,0)*x[2],
			comp(localVMatrix,0,1)*x[0] + comp(localVMatrix,1,1)*x[1] + comp(localVMatrix,2,1)*x[2],
			comp(localVMatrix,0,2)*x[0] + comp(localVMatrix,1,2)*x[1] + comp(localVMatrix,2,2)*x[2]);
	io_y = vector(
			comp(localVMatrix,0,0)*y[0] + comp(localVMatrix,1,0)*y[1] + comp(localVMatrix,2,0)*y[2],
			comp(localVMatrix,0,1)*y[0] + comp(localVMatrix,1,1)*y[1] + comp(localVMatrix,2,1)*y[2],
			comp(localVMatrix,0,2)*y[0] + comp(localVMatrix,1,2)*y[1] + comp(localVMatrix,2,2)*y[2]);
}

/*
	Common function for all mia_material shaders
*/
void mia_material_common(

	/* Diffuse reflection parameters. */
	float				i_diffuse;
	RGBA_COLOR(			i_diffuse_color );
	float				i_diffuse_roughness;

	/* Reflection parameters. */
	float				i_reflectivity;
	RGBA_COLOR(			i_refl_color );
	float				i_refl_gloss;
	float				i_refl_gloss_samples;
	bool				i_refl_interpolate;
	bool				i_refl_hl_only;
	bool				i_refl_is_metal;

	/* Transparency/refraction parameters. */
	float				i_tranparency;
	RGBA_COLOR(			i_refr_color );
	float				i_refr_gloss;
	float				i_refr_ior;
	float				i_refr_gloss_samples; 
	bool				i_refr_interpolate;
	bool				i_refr_translucency;
	RGBA_COLOR(			i_refr_trans_color );
	float				i_refr_trans_weight;
	float				i_anisotropy;
	float				i_anisotropy_rotation;
	point				i_anisotropy_channel;

	/* BRDF parameters. */
	bool				i_brdf_fresnel;
	float				i_brdf_0_degree_refl;
	float				i_brdf_90_degree_refl;
	float				i_brdf_curve;
	bool				i_brdf_conserve_energy;

	/* Interpolation parameters. Not used. */
	float				i_intr_grid_density;
	float				i_intr_refl_samples;
	bool				i_intr_refl_ddist_on;
	float				i_intr_refl_ddist;
	float				i_intr_refr_samples;

	/* Reflection */
	bool				i_single_env_sample;
	bool				i_refl_falloff_on;
	float				i_refl_falloff_dist;
	bool				i_refl_falloff_color_on;
	RGBA_COLOR(			i_refl_falloff_color );
	float				i_refl_depth;
	float				i_refl_cutoff;

	/* Refraction */
	bool				i_refr_falloff_on;
	float				i_refr_falloff_dist;
	bool				i_refr_falloff_color_on;
	RGBA_COLOR(			i_refr_falloff_color );
	float				i_refr_depth;
	float				i_refr_cutoff;

	float				i_indirect_multiplier;
	float				i_fg_quality;				/* ignore */
	float				i_fg_quality_w;				/* ignore */

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
	float				i_ao_do_details;			/* ignore */

	/* Additional flags */
	bool				i_thin_walled;
	/* can be done through message passing */
	bool				i_no_visible_area_hl;		/* ignore */
	bool				i_skip_inside_refl;
	bool				i_do_refractive_caustics;	/* ignore */
	bool				i_backface_cull;			/* ignore */
	bool				i_propagate_alpha;

	float				i_hl_vs_refl_balance;
	float				i_cutout_opacity;
	RGBA_COLOR(			i_additional_color );

	RGBA_COLOR(			i_bump_shader);
	bool				i_no_diffuse_bump; 
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;
	
	bool				i_multiple_output;
	
	float				i_refl_base;
	RGBA_COLOR(			i_refl_base_color );
	float				i_refl_base_gloss;
	float				i_refl_base_gloss_samples;
	point				i_refl_base_bump;

	/* Output parameters */
	RGBA_DECLARE_OUTPUT(o_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_raw);
	RGBA_DECLARE_OUTPUT(o_diffuse_level);
	RGBA_DECLARE_OUTPUT(o_spec_result);
	RGBA_DECLARE_OUTPUT(o_spec_raw);
	RGBA_DECLARE_OUTPUT(o_spec_level);
	RGBA_DECLARE_OUTPUT(o_refl_result);
	RGBA_DECLARE_OUTPUT(o_refl_raw);
	RGBA_DECLARE_OUTPUT(o_refl_level);
	RGBA_DECLARE_OUTPUT(o_refr_result);
	RGBA_DECLARE_OUTPUT(o_refr_raw);
	RGBA_DECLARE_OUTPUT(o_refr_level);
	RGBA_DECLARE_OUTPUT(o_tran_result);
	RGBA_DECLARE_OUTPUT(o_tran_raw);
	RGBA_DECLARE_OUTPUT(o_tran_level);
	RGBA_DECLARE_OUTPUT(o_indirect_result);
	RGBA_DECLARE_OUTPUT(o_indirect_raw);
	RGBA_DECLARE_OUTPUT(o_indirect_post_ao);
	RGBA_DECLARE_OUTPUT(o_ao_raw);
	RGBA_DECLARE_OUTPUT(o_add_result);
	RGBA_DECLARE_OUTPUT(o_opacity_result);
	RGBA_DECLARE_OUTPUT(o_opacity_raw);
	output float o_opacity;)
{
	extern vector I;
	extern vector L;
	extern normal N;
	extern color Oi;
	extern point P;
	extern vector dPdu, dPdv;

	extern uniform float __is_shadow_ray;

	/* visibility to reflecions and refractions. */
	extern uniform float __refracts, __reflects;

	/* visiblity and strength of subsurface computations */
	extern uniform float __is_subsurface_ray;
	extern uniform float __subsurface_strength;

	extern normal N_nobump;

	normal Nn = normalize(N);
	vector In = normalize(I);
	normal Nf = ShadingNormal(Nn);
	vector V = -In;

	uniform string rtype;
	uniform float rdepth;

	color refl_color = i_refl_color;
	color refl_base_color = i_refl_base_color;
	color refr_color = i_refr_color;
	uniform bool ao_on = i_ao_on;

	if( __refracts == 0 || __is_subsurface_ray == 1 )
	{
		/* Disable further refraction */
		refr_color = 0;
	}

	if( __reflects == 0 || __is_subsurface_ray == 1  )
	{
		/* Disable reflections and ao */
		refl_color = 0;
		refl_base_color = 0;
		ao_on = false;
	}

	if (i_cutout_opacity <= 0)
	{
		/* Automatic continuation. */
		o_result = 0.0; o_result_a = 0.0;
		o_diffuse_result = 0.0; o_diffuse_result_a = 0.0;
		o_diffuse_raw = 0.0; o_diffuse_raw_a = 0.0;
		o_diffuse_level = 0.0; o_diffuse_level_a = 0.0;
		o_spec_result = 0.0; o_spec_result_a = 0.0;
		o_spec_raw = 0.0; o_spec_raw_a = 0.0;
		o_spec_level = 0.0; o_spec_level_a = 0.0;
		o_refl_result = 0.0; o_refl_result_a = 0.0;
		o_refl_raw = 0.0; o_refl_raw_a = 0.0;
		o_refl_level = 0.0; o_refl_level_a = 0.0;
		o_refr_result = 0.0; o_refr_result_a = 0.0;
		o_refr_raw = 0.0; o_refr_raw_a = 0.0;
		o_refr_level = 0.0; o_refr_level_a = 0.0;
		o_tran_result = 0.0; o_tran_result_a = 0.0;
		o_tran_raw = 0.0; o_tran_raw_a = 0.0;
		o_tran_level = 0.0; o_tran_level_a = 0.0;
		o_indirect_result = 0.0; o_indirect_result_a = 0.0;
		o_indirect_raw = 0.0; o_indirect_raw_a = 0.0;
		o_indirect_post_ao = 0.0; o_indirect_post_ao_a = 0.0;
		o_ao_raw = 0.0; o_ao_raw_a = 0.0;
		o_add_result = 0.0; o_add_result_a = 0.0;
		o_opacity_result = 0.0; o_opacity_result_a = 0.0;
		o_opacity_raw = 0.0; o_opacity_raw_a = 0.0;
		o_opacity = 0.0;
		Oi = 0.0;
	}
	else
	{
		uniform float xsi_cb_algorithm = 0;
		option( "user:xsi_cb_algorithm", xsi_cb_algorithm );
		
		float diffuse_scale = i_diffuse;
		float reflectivity_scale = i_reflectivity;
		float transparency_scale = i_tranparency;

		/* Compute the reflection curve. */
		if (i_brdf_fresnel == true)
		{
			/* Automatic mode. */
			float eta = (In . Nn < 0.0) ? 1.0 / i_refr_ior : i_refr_ior;
			float kr, kt;
			fresnel( In, Nf, eta, kr, kt );
			reflectivity_scale *= kr;
		}
		else
		{
			/* Manual mode. */
			reflectivity_scale *=
				mix(
					i_brdf_0_degree_refl,
					i_brdf_90_degree_refl,
					pow(1-abs(V . Nf), i_brdf_curve));
		}

		/* Compute component weights. */
		
		float refl_base = SATURATE(i_refl_base);
		float refl_base_inv = 1.0 - refl_base;

		RGBA_COLOR(scaled_refl_color);
		scaled_refl_color =
			refl_color * reflectivity_scale * refl_base_inv;
		scaled_refl_color_a = luminance(scaled_refl_color);
		
		RGBA_COLOR(scaled_refl_base_color);
		scaled_refl_base_color =
			refl_base_color * reflectivity_scale * refl_base;
		scaled_refl_base_color_a = luminance(scaled_refl_base_color);
		
		if (i_refl_is_metal == true)
		{
			diffuse_scale *=
				1.0 -
				luminance(refl_color) * reflectivity_scale * refl_base_inv;
			diffuse_scale *=
				1.0 -
				luminance(refl_base_color) * reflectivity_scale * refl_base;
			diffuse_scale = max(diffuse_scale, 0.0);
			
			scaled_refl_color *= i_diffuse_color;
			scaled_refl_base_color *= i_diffuse_color;
		}
		o_refl_level = scaled_refl_color;

		RGBA_COLOR(scaled_refr_color);
		scaled_refr_color = refr_color;
		scaled_refr_color_a = luminance(scaled_refr_color);

		if (i_brdf_conserve_energy == true)
		{
			if (i_refl_hl_only == false)
			{
				diffuse_scale *=
					1.0 - min(scaled_refr_color_a * i_tranparency, 1.0);
				diffuse_scale *= 1.0 - min(scaled_refl_color_a, 1.0);
				diffuse_scale *= 1.0 - min(scaled_refl_base_color_a, 1.0);
				transparency_scale *= 1.0 - min(scaled_refl_color_a, 1.0);
				transparency_scale *= 1.0 - min(scaled_refl_base_color_a, 1.0);
			}
		}
		
		if (i_refl_hl_only == true && xsi_cb_algorithm != 2)
		{
			/* If Highlight Only is active, MR emulates soft reflections,
			   so no actual reflection rays are traced, which saves rendering
			   time. The next code is result of hard reverse engineering. */
			diffuse_scale += luminance(scaled_refl_color);
			diffuse_scale += luminance(scaled_refl_base_color);
		}

		o_refr_level = transparency_scale;
		scaled_refr_color *= transparency_scale;

		RGBA_COLOR(scaled_diffuse_color);
		scaled_diffuse_color = i_diffuse_color * diffuse_scale;
		
		if (i_refl_hl_only == true && xsi_cb_algorithm == 2)
		{
			/* If Highlight Only is active, MR emulates soft reflections,
			   so no actual reflection rays are traced, which saves rendering
			   time. The next code is result of hard reverse engineering. */
			scaled_diffuse_color *= 1-luminance(scaled_refl_color);
			scaled_diffuse_color *= 1-luminance(scaled_refl_base_color);
		}

		/* Ambient occlusion. */
		color ambient_occlusion = 0;

		/* NOTE: no AO for shadow rays. */
		o_ao_raw = 0.0;
		o_indirect_post_ao = 1.0;
		if (ao_on == true)
		{
			XSIAmbientOcclusion(
				i_ao_samples,
				1,1,	/* ambient */
				0,1,	/* dark */
				1.0,	/* i_spread */
				i_ao_distance,
				false,	/* i_reflective */
				0,		/* output_mode */				
				false	/* occlusion_in_alpha */,
				o_ao_raw, o_ao_raw_a );

			ambient_occlusion = mix(i_ao_ambient, i_ao_dark, 1-o_ao_raw );
			o_indirect_post_ao = o_ao_raw;
		}

		/* Diffuse component. */
		o_diffuse_raw = LocIllumOrenNayar(Nf, V, i_diffuse_roughness);
		color diffuse_component =
			scaled_diffuse_color
			* (ambient_occlusion + o_diffuse_raw);

		o_diffuse_level = scaled_diffuse_color;
		o_diffuse_result = o_diffuse_level * o_diffuse_raw;

		/* Reflected component. */
		color reflection_raw = 0;
		color reflection_base_raw = 0;
		if(i_refl_hl_only==false)
		{
			if( scaled_refl_color != 0 )
			{
				reflection_raw = mia_material_reflection(
					In, Nf, V,
					i_refl_gloss, i_refl_gloss_samples,
					i_single_env_sample, i_refl_falloff_on, i_refl_falloff_dist,
					i_refl_falloff_color_on, i_refl_falloff_color,
					scaled_refl_color * i_cutout_opacity );
			}
			if( scaled_refl_base_color != 0 )
			{
				reflection_base_raw = mia_material_reflection(
					In, Nf, V,
					i_refl_base_gloss, i_refl_base_gloss_samples,
					i_single_env_sample, i_refl_falloff_on, i_refl_falloff_dist,
					i_refl_falloff_color_on, i_refl_falloff_color,
					scaled_refl_base_color * i_cutout_opacity );
			}
		}
		else
		{
			/* If Highlight Only is active, MR emulates soft reflections by
			   final gathering (if it's active). We can emulate reflections by
			   point-based indirectdiffuse (if point-based color bleeding is
			   active) */
			vector refl_dir = reflect(In, Nf);
			PointBasedReflection(refl_dir, PI/2, reflection_raw);
			reflection_base_raw = reflection_raw;
		}
		
		color reflected_component =
			scaled_refl_color * reflection_raw +
			scaled_refl_base_color * reflection_base_raw;
			
		o_refl_raw =
			reflection_raw * refl_base_inv + reflection_base_raw * refl_base;

		/* Compute reflection roughness values. */
		float refl_roughness_u = roughness(i_refl_gloss);
		float refl_roughness_v = refl_roughness_u * i_anisotropy;
		
		if (refl_roughness_u >= 80.0)
			refl_roughness_u = 80.0 + sqrt(refl_roughness_u - 80.0);
		if (refl_roughness_v >= 80.0)
			refl_roughness_v = 80.0 + sqrt(refl_roughness_v - 80.0);
		
		float refl_base_roughness_u = roughness(i_refl_base_gloss);
		float refl_base_roughness_v = refl_base_roughness_u * i_anisotropy;

		if (refl_base_roughness_u >= 80.0)
			refl_base_roughness_u = 80.0 + sqrt(refl_base_roughness_u - 80.0);
		if (refl_base_roughness_v >= 80.0)
			refl_base_roughness_v = 80.0 + sqrt(refl_base_roughness_v - 80.0);

		/* Compute specular highlights. In "metal mode" the higlight color is
		   inherited from the diffuse color. */

		color highlights_component = 0;
		color hcolor = i_hl_vs_refl_balance * scaled_refl_color;
		
		color spec_raw = 0;
		color spec_base_raw = 0;
		if( __is_shadow_ray == 0 && __is_subsurface_ray == 0 )
		{
			vector act_dPdu = dPdu;
			vector act_dPdv = dPdv;

			if( refl_base_roughness_u != refl_base_roughness_v )
			{
				/* Tangents for anisotropic highlights */
				float act_u = i_anisotropy_channel[0];
				float act_v = i_anisotropy_channel[1];

				act_dPdu = normalize( Du(act_u) * Du(P) + Dv(act_u) * Dv(P) );
				act_dPdv = normalize( Du(act_v) * Du(P) + Dv(act_v) * Dv(P) );

				vector act_Nrml = normalize( act_dPdu*act_dPdv );

				mia_material_rotate_axis(
						i_anisotropy_rotation,
						act_dPdu, act_dPdv, act_Nrml);
			}

			spec_raw =
				mia_material_specular_highlights(
					Nf, V,
					refl_roughness_u, refl_roughness_v,
					act_dPdu, act_dPdv );
			spec_base_raw =
				mia_material_specular_highlights(
					Nf, V,
					refl_base_roughness_u, refl_base_roughness_v,
					act_dPdu, act_dPdv );
		}
		
		highlights_component = 
			i_hl_vs_refl_balance * scaled_refl_color * spec_raw +
			i_hl_vs_refl_balance * scaled_refl_base_color * spec_base_raw;
		
		o_spec_raw = spec_raw;
		o_spec_result = highlights_component;
		o_spec_level = i_hl_vs_refl_balance * scaled_refl_color;

		/* Refracted component. */
		color refracted_component = 0;
		if( scaled_refr_color != 0 )
		{
			o_refr_raw =
				mia_material_refraction(
					Nn, In, Nf, V,
					i_thin_walled == true ? 1.0 : i_refr_ior,
					i_refr_gloss,
					i_refr_gloss_samples,
					i_single_env_sample,
					i_refr_falloff_on, i_refr_falloff_dist,
					i_refr_falloff_color_on, i_refr_falloff_color,
					scaled_refr_color * i_cutout_opacity );

			refracted_component =  scaled_refr_color * o_refr_raw;
		}

		o_indirect_result = i_indirect_multiplier * scaled_diffuse_color;
		o_indirect_raw = 0;

		if( o_indirect_result != 0 )
		{
			o_indirect_raw = ColorBleeding(
					luminance(o_indirect_result * i_cutout_opacity) );
			o_indirect_result *= o_indirect_raw;
		}
		o_indirect_post_ao *= o_indirect_result;

		color diff = diffuse_component + i_additional_color;

		color aov_diffuse = diffuse_component * i_cutout_opacity;
		color aov_specular = highlights_component * i_cutout_opacity;
		color aov_ambient = i_additional_color * i_cutout_opacity;
		color aov_reflection = reflected_component * i_cutout_opacity;
		color aov_refraction = refracted_component * i_cutout_opacity;
		color aov_irradiance = o_indirect_result * i_cutout_opacity;

		if( __subsurface_strength != 0 )
		{
			if( __is_subsurface_ray == 1 )
			{
				aov_specular = 0;
				aov_reflection = 0;
				aov_refraction = 0;
				aov_irradiance = 0;
			}
			else
			{
				color sss_comp =
					subsurface(
							P, normalize(N_nobump),
							"normalize", 1,
							"model", "grosjean",
							"irradiance", aov_diffuse) * i_cutout_opacity;
				aov_diffuse = mix(aov_diffuse, sss_comp, __subsurface_strength);
				aov_ambient = mix(aov_ambient, sss_comp, __subsurface_strength);
			}
		}

		o_refl_result = reflected_component;
		o_refr_result = refracted_component;
		o_add_result = i_additional_color;

		o_result =
			aov_diffuse +
			aov_specular +
			aov_ambient +
			aov_reflection +
			aov_refraction +
			aov_irradiance;

		XSI_MATERIAL_SET_OUTPUT( Diffuse, aov_diffuse );
		XSI_MATERIAL_SET_OUTPUT( Specular, aov_specular );
		XSI_MATERIAL_SET_OUTPUT( Ambient, aov_ambient );
		XSI_MATERIAL_SET_OUTPUT( Reflection, aov_reflection );
		XSI_MATERIAL_SET_OUTPUT( Refraction, aov_refraction );
		XSI_MATERIAL_SET_OUTPUT( Irradiance, aov_irradiance );

		if (i_propagate_alpha)
			o_result_a = i_diffuse_color_a;
		else
			o_result_a = 1.0;

		/* Scale results by cutout opacity. */
		o_opacity_result = o_result;
		o_opacity = i_cutout_opacity;

		Oi *= i_cutout_opacity;

		if( __is_shadow_ray == 1 )
		{
			/* Transparency for shadow rays */
			Oi *= (1-transparency_scale);
		}
	}
}

/*
	Architectural Multi-out of Softimage 2011
*/
void mia_material(
	/* Diffuse reflection parameters. */
	float				i_diffuse;
	RGBA_COLOR(			i_diffuse_color );
	float				i_diffuse_roughness;

	/* Reflection parameters. */
	float				i_reflectivity;
	RGBA_COLOR(			i_refl_color );
	float				i_refl_gloss;
	float				i_refl_gloss_samples;
	bool				i_refl_interpolate;
	bool				i_refl_hl_only;
	bool				i_refl_is_metal;

	/* Transparency/refraction parameters. */
	float				i_tranparency;
	RGBA_COLOR(			i_refr_color );
	float				i_refr_gloss;
	float				i_refr_ior;
	float				i_refr_gloss_samples; 
	bool				i_refr_interpolate;
	bool				i_refr_translucency;
	RGBA_COLOR(			i_refr_trans_color );
	float				i_refr_trans_weight;
	float				i_anisotropy;
	float				i_anisotropy_rotation;
	point				i_anisotropy_channel;

	/* BRDF parameters. */
	bool				i_brdf_fresnel;
	float				i_brdf_0_degree_refl;
	float				i_brdf_90_degree_refl;
	float				i_brdf_curve;
	bool				i_brdf_conserve_energy;

	/* Interpolation parameters. Not used. */
	float				i_intr_grid_density;
	float				i_intr_refl_samples;
	bool				i_intr_refl_ddist_on;
	float				i_intr_refl_ddist;
	float				i_intr_refr_samples;

	/* Reflection */
	bool				i_single_env_sample;
	bool				i_refl_falloff_on;
	float				i_refl_falloff_dist;
	bool				i_refl_falloff_color_on;
	RGBA_COLOR(			i_refl_falloff_color );
	float				i_refl_depth;
	float				i_refl_cutoff;

	/* Refraction */
	bool				i_refr_falloff_on;
	float				i_refr_falloff_dist;
	bool				i_refr_falloff_color_on;
	RGBA_COLOR(			i_refr_falloff_color );
	float				i_refr_depth;
	float				i_refr_cutoff;

	float				i_indirect_multiplier;
	float				i_fg_quality;				/* ignore */
	float				i_fg_quality_w;				/* ignore */

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
	float				i_ao_do_details;			/* ignore */

	/* Additional flags */
	bool				i_thin_walled;
	/* can be done through message passing */
	bool				i_no_visible_area_hl;		/* ignore */
	bool				i_skip_inside_refl;
	bool				i_do_refractive_caustics;	/* ignore */
	bool				i_backface_cull;			/* ignore */
	bool				i_propagate_alpha;

	float				i_hl_vs_refl_balance;
	float				i_cutout_opacity;
	RGBA_COLOR(			i_additional_color );

	RGBA_COLOR(			i_bump_shader);
	bool				i_no_diffuse_bump; 
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;

	bool				i_multiple_output;

	/* Output parameters */
	RGBA_DECLARE_OUTPUT(o_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_raw);
	RGBA_DECLARE_OUTPUT(o_diffuse_level);
	RGBA_DECLARE_OUTPUT(o_spec_result);
	RGBA_DECLARE_OUTPUT(o_spec_raw);
	RGBA_DECLARE_OUTPUT(o_spec_level);
	RGBA_DECLARE_OUTPUT(o_refl_result);
	RGBA_DECLARE_OUTPUT(o_refl_raw);
	RGBA_DECLARE_OUTPUT(o_refl_level);
	RGBA_DECLARE_OUTPUT(o_refr_result);
	RGBA_DECLARE_OUTPUT(o_refr_raw);
	RGBA_DECLARE_OUTPUT(o_refr_level);
	RGBA_DECLARE_OUTPUT(o_tran_result);
	RGBA_DECLARE_OUTPUT(o_tran_raw);
	RGBA_DECLARE_OUTPUT(o_tran_level);
	RGBA_DECLARE_OUTPUT(o_indirect_result);
	RGBA_DECLARE_OUTPUT(o_indirect_raw);
	RGBA_DECLARE_OUTPUT(o_indirect_post_ao);
	RGBA_DECLARE_OUTPUT(o_ao_raw);
	RGBA_DECLARE_OUTPUT(o_add_result);
	RGBA_DECLARE_OUTPUT(o_opacity_result);
	RGBA_DECLARE_OUTPUT(o_opacity_raw);
	output float o_opacity;)
{
	mia_material_common(
		i_diffuse,
		RGBA_USE(i_diffuse_color),
		i_diffuse_roughness,

		i_reflectivity,
		RGBA_USE(i_refl_color),
		i_refl_gloss,
		i_refl_gloss_samples,
		i_refl_interpolate,
		i_refl_hl_only,
		i_refl_is_metal,

		i_tranparency,
		RGBA_USE(i_refr_color),
		i_refr_gloss,
		i_refr_ior,
		i_refr_gloss_samples,
		i_refr_interpolate,
		i_refr_translucency,
		RGBA_USE(i_refr_trans_color),
		i_refr_trans_weight,
		i_anisotropy,
		i_anisotropy_rotation,
		i_anisotropy_channel,

		i_brdf_fresnel,
		i_brdf_0_degree_refl,
		i_brdf_90_degree_refl,
		i_brdf_curve,
		i_brdf_conserve_energy,

		i_intr_grid_density,
		i_intr_refl_samples,
		i_intr_refl_ddist_on,
		i_intr_refl_ddist,
		i_intr_refr_samples,

		i_single_env_sample,
		i_refl_falloff_on,
		i_refl_falloff_dist,
		i_refl_falloff_color_on,
		RGBA_USE(i_refl_falloff_color),
		i_refl_depth,
		i_refl_cutoff,

		i_refr_falloff_on,
		i_refr_falloff_dist,
		i_refr_falloff_color_on,
		RGBA_USE(i_refr_falloff_color),
		i_refr_depth,
		i_refr_cutoff,

		i_indirect_multiplier,
		i_fg_quality,
		i_fg_quality_w,

		i_ao_on,
		i_ao_samples,
		i_ao_distance,
		RGBA_USE(i_ao_dark),
		RGBA_USE(i_ao_ambient),
		i_ao_do_details,

		i_thin_walled,
		i_no_visible_area_hl,
		i_skip_inside_refl,
		i_do_refractive_caustics,
		i_backface_cull,
		i_propagate_alpha,

		i_hl_vs_refl_balance,
		i_cutout_opacity,
		RGBA_USE(i_additional_color),

		RGBA_USE(i_bump_shader),
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,

		i_multiple_output,
		
		0.0,
		color(0.0),0.0,
		1.0,
		8,
		point(0.0),

		RGBA_USE(o_result),
		RGBA_USE(o_diffuse_result),
		RGBA_USE(o_diffuse_raw),
		RGBA_USE(o_diffuse_level),
		RGBA_USE(o_spec_result),
		RGBA_USE(o_spec_raw),
		RGBA_USE(o_spec_level),
		RGBA_USE(o_refl_result),
		RGBA_USE(o_refl_raw),
		RGBA_USE(o_refl_level),
		RGBA_USE(o_refr_result),
		RGBA_USE(o_refr_raw),
		RGBA_USE(o_refr_level),
		RGBA_USE(o_tran_result),
		RGBA_USE(o_tran_raw),
		RGBA_USE(o_tran_level),
		RGBA_USE(o_indirect_result),
		RGBA_USE(o_indirect_raw),
		RGBA_USE(o_indirect_post_ao),
		RGBA_USE(o_ao_raw),
		RGBA_USE(o_add_result),
		RGBA_USE(o_opacity_result),
		RGBA_USE(o_opacity_raw),
		o_opacity);
}

/*
	Architectural Multi-out of Softimage 2011 SP1
*/
void mia_material(

	/* Diffuse reflection parameters. */
	float				i_diffuse;
	RGBA_COLOR(			i_diffuse_color );
	float				i_diffuse_roughness;

	/* Reflection parameters. */
	float				i_reflectivity;
	RGBA_COLOR(			i_refl_color );
	float				i_refl_gloss;
	float				i_refl_gloss_samples;
	bool				i_refl_interpolate;
	bool				i_refl_hl_only;
	bool				i_refl_is_metal;

	/* Transparency/refraction parameters. */
	float				i_tranparency;
	RGBA_COLOR(			i_refr_color );
	float				i_refr_gloss;
	float				i_refr_ior;
	float				i_refr_gloss_samples; 
	bool				i_refr_interpolate;
	bool				i_refr_translucency;
	RGBA_COLOR(			i_refr_trans_color );
	float				i_refr_trans_weight;
	float				i_anisotropy;
	float				i_anisotropy_rotation;
	point				i_anisotropy_channel;

	/* BRDF parameters. */
	bool				i_brdf_fresnel;
	float				i_brdf_0_degree_refl;
	float				i_brdf_90_degree_refl;
	float				i_brdf_curve;
	bool				i_brdf_conserve_energy;

	/* Interpolation parameters. Not used. */
	float				i_intr_grid_density;
	float				i_intr_refl_samples;
	bool				i_intr_refl_ddist_on;
	float				i_intr_refl_ddist;
	float				i_intr_refr_samples;

	/* Reflection */
	bool				i_single_env_sample;
	bool				i_refl_falloff_on;
	float				i_refl_falloff_dist;
	bool				i_refl_falloff_color_on;
	RGBA_COLOR(			i_refl_falloff_color );
	float				i_refl_depth;
	float				i_refl_cutoff;

	/* Refraction */
	bool				i_refr_falloff_on;
	float				i_refr_falloff_dist;
	bool				i_refr_falloff_color_on;
	RGBA_COLOR(			i_refr_falloff_color );
	float				i_refr_depth;
	float				i_refr_cutoff;

	float				i_indirect_multiplier;
	float				i_fg_quality;				/* ignore */
	float				i_fg_quality_w;				/* ignore */

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
	float				i_ao_do_details;			/* ignore */

	/* Additional flags */
	bool				i_thin_walled;
	/* can be done through message passing */
	bool				i_no_visible_area_hl;		/* ignore */
	bool				i_skip_inside_refl;
	bool				i_do_refractive_caustics;	/* ignore */
	bool				i_backface_cull;			/* ignore */
	bool				i_propagate_alpha;

	float				i_hl_vs_refl_balance;
	float				i_cutout_opacity;
	RGBA_COLOR(			i_additional_color );

	color				i_bump_shader; bool i_bump_shader_connected;
	bool				i_no_diffuse_bump; 
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;
	
	bool				i_multiple_output;
	
	float				i_refl_base;
	RGBA_COLOR(			i_refl_base_color );
	float				i_refl_base_gloss;
	float				i_refl_base_gloss_samples;
	point				i_refl_base_bump;
	
	/* Output parameters */
	RGBA_DECLARE_OUTPUT(o_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_raw);
	RGBA_DECLARE_OUTPUT(o_diffuse_level);
	RGBA_DECLARE_OUTPUT(o_spec_result);
	RGBA_DECLARE_OUTPUT(o_spec_raw);
	RGBA_DECLARE_OUTPUT(o_spec_level);
	RGBA_DECLARE_OUTPUT(o_refl_result);
	RGBA_DECLARE_OUTPUT(o_refl_raw);
	RGBA_DECLARE_OUTPUT(o_refl_level);
	RGBA_DECLARE_OUTPUT(o_refr_result);
	RGBA_DECLARE_OUTPUT(o_refr_raw);
	RGBA_DECLARE_OUTPUT(o_refr_level);
	RGBA_DECLARE_OUTPUT(o_tran_result);
	RGBA_DECLARE_OUTPUT(o_tran_raw);
	RGBA_DECLARE_OUTPUT(o_tran_level);
	RGBA_DECLARE_OUTPUT(o_indirect_result);
	RGBA_DECLARE_OUTPUT(o_indirect_raw);
	RGBA_DECLARE_OUTPUT(o_indirect_post_ao);
	RGBA_DECLARE_OUTPUT(o_ao_raw);
	RGBA_DECLARE_OUTPUT(o_add_result);
	RGBA_DECLARE_OUTPUT(o_opacity_result);
	RGBA_DECLARE_OUTPUT(o_opacity_raw);
	output float o_opacity;)
{
	mia_material_common(
		i_diffuse,
		RGBA_USE(i_diffuse_color),
		i_diffuse_roughness,

		i_reflectivity,
		RGBA_USE(i_refl_color),
		i_refl_gloss,
		i_refl_gloss_samples,
		i_refl_interpolate,
		i_refl_hl_only,
		i_refl_is_metal,

		i_tranparency,
		RGBA_USE(i_refr_color),
		i_refr_gloss,
		i_refr_ior,
		i_refr_gloss_samples,
		i_refr_interpolate,
		i_refr_translucency,
		RGBA_USE(i_refr_trans_color),
		i_refr_trans_weight,
		i_anisotropy,
		i_anisotropy_rotation,
		i_anisotropy_channel,

		i_brdf_fresnel,
		i_brdf_0_degree_refl,
		i_brdf_90_degree_refl,
		i_brdf_curve,
		i_brdf_conserve_energy,

		i_intr_grid_density,
		i_intr_refl_samples,
		i_intr_refl_ddist_on,
		i_intr_refl_ddist,
		i_intr_refr_samples,

		i_single_env_sample,
		i_refl_falloff_on,
		i_refl_falloff_dist,
		i_refl_falloff_color_on,
		RGBA_USE(i_refl_falloff_color),
		i_refl_depth,
		i_refl_cutoff,

		i_refr_falloff_on,
		i_refr_falloff_dist,
		i_refr_falloff_color_on,
		RGBA_USE(i_refr_falloff_color),
		i_refr_depth,
		i_refr_cutoff,

		i_indirect_multiplier,
		i_fg_quality,
		i_fg_quality_w,

		i_ao_on,
		i_ao_samples,
		i_ao_distance,
		RGBA_USE(i_ao_dark),
		RGBA_USE(i_ao_ambient),
		i_ao_do_details,

		i_thin_walled,
		i_no_visible_area_hl,
		i_skip_inside_refl,
		i_do_refractive_caustics,
		i_backface_cull,
		i_propagate_alpha,

		i_hl_vs_refl_balance,
		i_cutout_opacity,
		RGBA_USE(i_additional_color),

		i_bump_shader, 0,
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,
		
		i_multiple_output,
		
		i_refl_base,
		RGBA_USE(i_refl_base_color),
		i_refl_base_gloss,
		i_refl_base_gloss_samples,
		i_refl_base_bump,
		
		RGBA_USE(o_result),
		RGBA_USE(o_diffuse_result),
		RGBA_USE(o_diffuse_raw),
		RGBA_USE(o_diffuse_level),
		RGBA_USE(o_spec_result),
		RGBA_USE(o_spec_raw),
		RGBA_USE(o_spec_level),
		RGBA_USE(o_refl_result),
		RGBA_USE(o_refl_raw),
		RGBA_USE(o_refl_level),
		RGBA_USE(o_refr_result),
		RGBA_USE(o_refr_raw),
		RGBA_USE(o_refr_level),
		RGBA_USE(o_tran_result),
		RGBA_USE(o_tran_raw),
		RGBA_USE(o_tran_level),
		RGBA_USE(o_indirect_result),
		RGBA_USE(o_indirect_raw),
		RGBA_USE(o_indirect_post_ao),
		RGBA_USE(o_ao_raw),
		RGBA_USE(o_add_result),
		RGBA_USE(o_opacity_result),
		RGBA_USE(o_opacity_raw),
		o_opacity);
}

/*
	mia_material of Softimage 2011
*/
void mia_material(

	/* Diffuse reflection parameters. */
	float				i_diffuse;
	color				i_diffuse_color;
	float				i_diffuse_roughness;

	/* Reflection parameters. */
	float				i_reflectivity;
	color				i_refl_color;
	float				i_refl_gloss;
	float				i_refl_gloss_samples;
	bool				i_refl_interpolate;
	bool				i_refl_hl_only;
	bool				i_refl_is_metal;

	/* Transparency/refraction parameters. */
	float				i_tranparency;
	color				i_refr_color;
	float				i_refr_gloss;
	float				i_refr_ior;
	float				i_refr_gloss_samples; 
	bool				i_refr_interpolate;
	bool				i_refr_translucency;
	color				i_refr_trans_color;
	float				i_refr_trans_weight;
	float				i_anisotropy;
	float				i_anisotropy_rotation;
	point				i_anisotropy_channel;

	/* BRDF parameters. */
	bool				i_brdf_fresnel;
	float				i_brdf_0_degree_refl;
	float				i_brdf_90_degree_refl;
	float				i_brdf_curve;
	bool				i_brdf_conserve_energy;

	/* Interpolation parameters. Not used. */
	float				i_intr_grid_density;
	float				i_intr_refl_samples;
	bool				i_intr_refl_ddist_on;
	float				i_intr_refl_ddist;
	float				i_intr_refr_samples;

	/* Reflection */
	bool				i_single_env_sample;
	bool				i_refl_falloff_on;
	float				i_refl_falloff_dist;
	bool				i_refl_falloff_color_on;
	color				i_refl_falloff_color;
	float				i_refl_depth;
	float				i_refl_cutoff;

	/* Refraction */
	bool				i_refr_falloff_on;
	float				i_refr_falloff_dist;
	bool				i_refr_falloff_color_on;
	color				i_refr_falloff_color;
	float				i_refr_depth;
	float				i_refr_cutoff;

	float				i_indirect_multiplier;
	float				i_fg_quality;
	float				i_fg_quality_w;

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	color				i_ao_dark;
	color				i_ao_ambient;
	float				i_ao_do_details;

	/* Additional flags */
	bool				i_thin_walled;
	bool				i_no_visible_area_hl;
	bool				i_skip_inside_refl;
	bool				i_do_refractive_caustics;
	bool				i_backface_cull;
	bool				i_propagate_alpha;

	float				i_hl_vs_refl_balance;
	float				i_cutout_opacity;
	RGBA_COLOR(			i_additional_color );

	color				i_bump; bool i_bump_connected;
	bool				i_no_diffuse_bump;
	float				i_mode;

	RGBA_DECLARE(		o_result); )
{
	RGBA_DECLARE(dummy_diffuse_result);
	RGBA_DECLARE(dummy_diffuse_raw);
	RGBA_DECLARE(dummy_diffuse_level);
	RGBA_DECLARE(dummy_spec_result);
	RGBA_DECLARE(dummy_spec_raw);
	RGBA_DECLARE(dummy_spec_level);
	RGBA_DECLARE(dummy_refl_result);
	RGBA_DECLARE(dummy_refl_raw);
	RGBA_DECLARE(dummy_refl_level);
	RGBA_DECLARE(dummy_refr_result);
	RGBA_DECLARE(dummy_refr_raw);
	RGBA_DECLARE(dummy_refr_level);
	RGBA_DECLARE(dummy_tran_result);
	RGBA_DECLARE(dummy_tran_raw);
	RGBA_DECLARE(dummy_tran_level);
	RGBA_DECLARE(dummy_indirect_result);
	RGBA_DECLARE(dummy_indirect_raw);
	RGBA_DECLARE(dummy_indirect_post_ao);
	RGBA_DECLARE(dummy_ao_raw);
	RGBA_DECLARE(dummy_add_result);
	RGBA_DECLARE(dummy_opacity_result);
	RGBA_DECLARE(dummy_opacity_raw);
	float dummy_opacity;

	mia_material(
		i_diffuse,
		i_diffuse_color, 1,
		i_diffuse_roughness,

		i_reflectivity,
		i_refl_color, 1,
		i_refl_gloss,
		i_refl_gloss_samples,
		i_refl_interpolate,
		i_refl_hl_only,
		i_refl_is_metal,

		i_tranparency,
		i_refr_color, 1,
		i_refr_gloss,
		i_refr_ior,
		i_refr_gloss_samples,
		i_refr_interpolate,
		i_refr_translucency,
		i_refr_trans_color, 1,
		i_refr_trans_weight,
		i_anisotropy,
		i_anisotropy_rotation,
		i_anisotropy_channel,

		i_brdf_fresnel,
		i_brdf_0_degree_refl,
		i_brdf_90_degree_refl,
		i_brdf_curve,
		i_brdf_conserve_energy,

		i_intr_grid_density,
		i_intr_refl_samples,
		i_intr_refl_ddist_on,
		i_intr_refl_ddist,
		i_intr_refr_samples,

		i_single_env_sample,
		i_refl_falloff_on,
		i_refl_falloff_dist,
		i_refl_falloff_color_on,
		i_refl_falloff_color, 1,
		i_refl_depth,
		i_refl_cutoff,

		i_refr_falloff_on,
		i_refr_falloff_dist,
		i_refr_falloff_color_on,
		i_refr_falloff_color, 1,
		i_refr_depth,
		i_refr_cutoff,

		i_indirect_multiplier,
		i_fg_quality,
		i_fg_quality_w,

		i_ao_on,
		i_ao_samples,
		i_ao_distance,
		i_ao_dark, 1,
		i_ao_ambient, 1,
		i_ao_do_details,

		i_thin_walled,
		i_no_visible_area_hl,
		i_skip_inside_refl,
		i_do_refractive_caustics,
		i_backface_cull,
		i_propagate_alpha,

		i_hl_vs_refl_balance,
		i_cutout_opacity,
		i_additional_color, 1,

		color(0), 0,				/* i_bump_shader */
		i_no_diffuse_bump,
		0,							/* i_bump_mode */
		0,							/* i_overall_bump */
		0,							/* i_standard_bump */
		
		false,						/* i_multiple_output */
		
		RGBA_USE(o_result),
		RGBA_USE(dummy_diffuse_result),
		RGBA_USE(dummy_diffuse_raw),
		RGBA_USE(dummy_diffuse_level),
		RGBA_USE(dummy_spec_result),
		RGBA_USE(dummy_spec_raw),
		RGBA_USE(dummy_spec_level),
		RGBA_USE(dummy_refl_result),
		RGBA_USE(dummy_refl_raw),
		RGBA_USE(dummy_refl_level),
		RGBA_USE(dummy_refr_result),
		RGBA_USE(dummy_refr_raw),
		RGBA_USE(dummy_refr_level),
		RGBA_USE(dummy_tran_result),
		RGBA_USE(dummy_tran_raw),
		RGBA_USE(dummy_tran_level),
		RGBA_USE(dummy_indirect_result),
		RGBA_USE(dummy_indirect_raw),
		RGBA_USE(dummy_indirect_post_ao),
		RGBA_USE(dummy_ao_raw),
		RGBA_USE(dummy_add_result),
		RGBA_USE(dummy_opacity_result),
		RGBA_USE(dummy_opacity_raw),
		dummy_opacity);
}

/*
	mia_Material_MultiOutput of Softimage 2010
*/
void mia_material(

	/* Output parameters */
	RGBA_DECLARE_OUTPUT(o_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_result);
	RGBA_DECLARE_OUTPUT(o_diffuse_raw);
	RGBA_DECLARE_OUTPUT(o_diffuse_level);
	RGBA_DECLARE_OUTPUT(o_spec_result);
	RGBA_DECLARE_OUTPUT(o_spec_raw);
	RGBA_DECLARE_OUTPUT(o_spec_level);
	RGBA_DECLARE_OUTPUT(o_refl_result);
	RGBA_DECLARE_OUTPUT(o_refl_raw);
	RGBA_DECLARE_OUTPUT(o_refl_level);
	RGBA_DECLARE_OUTPUT(o_refr_result);
	RGBA_DECLARE_OUTPUT(o_refr_raw);
	RGBA_DECLARE_OUTPUT(o_refr_level);
	RGBA_DECLARE_OUTPUT(o_tran_result);
	RGBA_DECLARE_OUTPUT(o_tran_raw);
	RGBA_DECLARE_OUTPUT(o_tran_level);
	RGBA_DECLARE_OUTPUT(o_indirect_result);
	RGBA_DECLARE_OUTPUT(o_indirect_raw);
	RGBA_DECLARE_OUTPUT(o_indirect_post_ao);
	RGBA_DECLARE_OUTPUT(o_ao_raw);
	RGBA_DECLARE_OUTPUT(o_add_result);
	RGBA_DECLARE_OUTPUT(o_opacity_result);
	RGBA_DECLARE_OUTPUT(o_opacity_raw);
	output float o_opacity;

	/* Diffuse reflection parameters. */
	float				i_diffuse;
	RGBA_COLOR(			i_diffuse_color );
	float				i_diffuse_roughness;

	/* Reflection parameters. */
	float				i_reflectivity;
	RGBA_COLOR(			i_refl_color );
	float				i_refl_gloss;
	float				i_refl_gloss_samples;
	bool				i_refl_interpolate;
	bool				i_refl_hl_only;
	bool				i_refl_is_metal;

	/* Transparency/refraction parameters. */
	float				i_tranparency;
	RGBA_COLOR(			i_refr_color );
	float				i_refr_gloss;
	float				i_refr_ior;
	float				i_refr_gloss_samples; 
	bool				i_refr_interpolate;
	bool				i_refr_translucency;
	RGBA_COLOR(			i_refr_trans_color );
	float				i_refr_trans_weight;
	float				i_anisotropy;
	float				i_anisotropy_rotation;
	point				i_anisotropy_channel;

	/* BRDF parameters. */
	bool				i_brdf_fresnel;
	float				i_brdf_0_degree_refl;
	float				i_brdf_90_degree_refl;
	float				i_brdf_curve;
	bool				i_brdf_conserve_energy;

	/* Interpolation parameters. Not used. */
	float				i_intr_grid_density;
	float				i_intr_refl_samples;
	bool				i_intr_refl_ddist_on;
	float				i_intr_refl_ddist;
	float				i_intr_refr_samples;

	/* Reflection */
	bool				i_single_env_sample;
	bool				i_refl_falloff_on;
	float				i_refl_falloff_dist;
	bool				i_refl_falloff_color_on;
	RGBA_COLOR(			i_refl_falloff_color );
	float				i_refl_depth;
	float				i_refl_cutoff;

	/* Refraction */
	bool				i_refr_falloff_on;
	float				i_refr_falloff_dist;
	bool				i_refr_falloff_color_on;
	RGBA_COLOR(			i_refr_falloff_color );
	float				i_refr_depth;
	float				i_refr_cutoff;

	float				i_indirect_multiplier;
	float				i_fg_quality;				/* ignore */
	float				i_fg_quality_w;				/* ignore */

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
	float				i_ao_do_details;			/* ignore */

	/* Additional flags */
	bool				i_thin_walled;
	/* can be done through message passing */
	bool				i_no_visible_area_hl;		/* ignore */
	bool				i_skip_inside_refl;
	bool				i_do_refractive_caustics;	/* ignore */
	bool				i_backface_cull;			/* ignore */
	bool				i_propagate_alpha;

	float				i_hl_vs_refl_balance;
	float				i_cutout_opacity;
	RGBA_COLOR(			i_additional_color );

	string				i_bump_unknown;
	bool				i_no_diffuse_bump; 
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;
	
	bool				i_multiple_output;)
{
	mia_material(
		i_diffuse,
		RGBA_USE(i_diffuse_color),
		i_diffuse_roughness,

		i_reflectivity,
		RGBA_USE(i_refl_color),
		i_refl_gloss,
		i_refl_gloss_samples,
		i_refl_interpolate,
		i_refl_hl_only,
		i_refl_is_metal,

		i_tranparency,
		RGBA_USE(i_refr_color),
		i_refr_gloss,
		i_refr_ior,
		i_refr_gloss_samples,
		i_refr_interpolate,
		i_refr_translucency,
		RGBA_USE(i_refr_trans_color),
		i_refr_trans_weight,
		i_anisotropy,
		i_anisotropy_rotation,
		i_anisotropy_channel,

		i_brdf_fresnel,
		i_brdf_0_degree_refl,
		i_brdf_90_degree_refl,
		i_brdf_curve,
		i_brdf_conserve_energy,

		i_intr_grid_density,
		i_intr_refl_samples,
		i_intr_refl_ddist_on,
		i_intr_refl_ddist,
		i_intr_refr_samples,

		i_single_env_sample,
		i_refl_falloff_on,
		i_refl_falloff_dist,
		i_refl_falloff_color_on,
		RGBA_USE(i_refl_falloff_color),
		i_refl_depth,
		i_refl_cutoff,

		i_refr_falloff_on,
		i_refr_falloff_dist,
		i_refr_falloff_color_on,
		RGBA_USE(i_refr_falloff_color),
		i_refr_depth,
		i_refr_cutoff,

		i_indirect_multiplier,
		i_fg_quality,
		i_fg_quality_w,

		i_ao_on,
		i_ao_samples,
		i_ao_distance,
		RGBA_USE(i_ao_dark),
		RGBA_USE(i_ao_ambient),
		i_ao_do_details,

		i_thin_walled,
		i_no_visible_area_hl,
		i_skip_inside_refl,
		i_do_refractive_caustics,
		i_backface_cull,
		i_propagate_alpha,

		i_hl_vs_refl_balance,
		i_cutout_opacity,
		RGBA_USE(i_additional_color),

		color(0), 0,
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,
		
		i_multiple_output,
		
		RGBA_USE(o_result),
		RGBA_USE(o_diffuse_result),
		RGBA_USE(o_diffuse_raw),
		RGBA_USE(o_diffuse_level),
		RGBA_USE(o_spec_result),
		RGBA_USE(o_spec_raw),
		RGBA_USE(o_spec_level),
		RGBA_USE(o_refl_result),
		RGBA_USE(o_refl_raw),
		RGBA_USE(o_refl_level),
		RGBA_USE(o_refr_result),
		RGBA_USE(o_refr_raw),
		RGBA_USE(o_refr_level),
		RGBA_USE(o_tran_result),
		RGBA_USE(o_tran_raw),
		RGBA_USE(o_tran_level),
		RGBA_USE(o_indirect_result),
		RGBA_USE(o_indirect_raw),
		RGBA_USE(o_indirect_post_ao),
		RGBA_USE(o_ao_raw),
		RGBA_USE(o_add_result),
		RGBA_USE(o_opacity_result),
		RGBA_USE(o_opacity_raw),
		o_opacity);
}

#endif  // __mia_material_sl
