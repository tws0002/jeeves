/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_material_h
#define __xsi_material_h

#define XSI_ENV_RAY_REFLECTION 1
#define XSI_ENV_RAY_BACKGROUND 2
#define XSI_ENV_RAY_FOREGROUND 3

#define XSI_MATERIAL_SET_OUTPUT( name, var ) \
	extern varying color name; \
	name = var;
	
#define XSI_MATERIAL_ADD_OUTPUT( name, var ) \
	extern varying color name; \
	name += var;

#define XSI_MATERIAL_COMMON_PARAMS_SPECULAR \
	RGBA_DECLARE( i_transparency ); \
	float i_trans_glossy; \
	float i_transparent_samples; \
\
	RGBA_DECLARE( i_reflectivity ); \
	float i_reflect_glossy; \
	uniform float i_reflect_samples; \
\
	float i_ior; \
	float i_translucency; \
\
	RGBA_DECLARE( i_incandescence ); \
	float i_inc_inten; \
\
	point i_bump; \
\
	float i_no_trace; \
	float i_diffuse_inuse, i_specular_inuse, i_reflect_inuse, i_refract_inuse, \
		i_incand_inuse, i_translucent_inuse; \
\
	RGBA_DECLARE( i_radiance ); \
	float i_radiance_filter; \
	float i_scaletrans, i_inverttrans, i_usealphatrans; \
	float i_scalerefl, i_invertrefl, i_usealpharefl

#define XSI_MATERIAL_COMMON_PARAMS_SPECULAR_USE \
	RGBA_USE(i_transparency), \
	i_trans_glossy, \
	i_transparent_samples, \
\
	RGBA_USE(i_reflectivity), \
	i_reflect_glossy, \
	i_reflect_samples, \
\
	i_ior, \
	i_translucency, \
\
	RGBA_USE(i_incandescence), \
	i_inc_inten, \
\
	i_bump, \
\
	i_no_trace, \
	i_diffuse_inuse, i_specular_inuse, i_reflect_inuse, i_refract_inuse, \
		i_incand_inuse, i_translucent_inuse, \
\
	RGBA_USE(i_radiance), \
	i_radiance_filter, \
	i_scaletrans, i_inverttrans, i_usealphatrans, \
	i_scalerefl, i_invertrefl, i_usealpharefl


#define XSI_MATERIAL_COMMON_PARAMS_SPECULAR_NO_BUMP \
	RGBA_DECLARE( i_transparency ); \
	float i_trans_glossy; \
	float i_transparent_samples; \
\
	RGBA_DECLARE( i_reflectivity ); \
	float i_reflect_glossy; \
	uniform float i_reflect_samples; \
\
	float i_ior; \
	float i_translucency; \
\
	RGBA_DECLARE( i_incandescence ); \
	float i_inc_inten; \
\
	float i_no_trace; \
	float i_diffuse_inuse, i_specular_inuse, i_reflect_inuse, i_refract_inuse, \
		i_incand_inuse, i_translucent_inuse; \
\
	RGBA_DECLARE( i_radiance ); \
	float i_radiance_filter; \
	float i_scaletrans, i_inverttrans, i_usealphatrans; \
	float i_scalerefl, i_invertrefl, i_usealpharefl

#define XSI_MATERIAL_COMMON_PARAMS_SPECULAR_NO_BUMP_USE \
	RGBA_USE(i_transparency), \
	i_trans_glossy, \
	i_transparent_samples, \
\
	RGBA_USE(i_reflectivity), \
	i_reflect_glossy, \
	i_reflect_samples, \
\
	i_ior, \
	i_translucency, \
\
	RGBA_USE(i_incandescence), \
	i_inc_inten, \
\
	i_no_trace, \
	i_diffuse_inuse, i_specular_inuse, i_reflect_inuse, i_refract_inuse, \
		i_incand_inuse, i_translucent_inuse, \
\
	RGBA_USE(i_radiance), \
	i_radiance_filter, \
	i_scaletrans, i_inverttrans, i_usealphatrans, \
	i_scalerefl, i_invertrefl, i_usealpharefl


#define XSI_MATERIAL_COMMON_PARAMS_DIFFUSE \
	RGBA_DECLARE( i_transparency ); \
	float i_trans_glossy; \
	float i_transparent_samples; \
 \
	RGBA_DECLARE( i_reflectivity ); \
	float i_reflect_glossy; \
	uniform float i_reflect_samples; \
 \
	float i_ior; \
	float i_translucency; \
 \
	RGBA_DECLARE( i_incandescence ); \
	float i_inc_inten; \
 \
	point i_bump; \
\
	float i_no_trace; \
	float i_diffuse_inuse, i_reflect_inuse, i_refract_inuse, i_incand_inuse, \
		i_translucent_inuse; \
 \
	RGBA_DECLARE( i_radiance ); \
	float i_radiance_filter; \
	float i_scaletrans, i_inverttrans, i_usealphatrans; \
	float i_scalerefl, i_invertrefl, i_usealpharefl

#define XSI_TEXTURE_COMMON_PARAMS \
	point i_coord; \
	point i_repeats; \
	float i_alt_x, i_alt_y, i_alt_z; \
	point i_min, i_max; \
	point i_step; \
	float i_factor; \
	float i_torus_u, i_torus_v; \
	float i_alpha, i_bump_inuse; \
	uniform float i_alpha_output; \
	float i_alpha_factor

#define XSI_TEXTURE_COMMON_PARAMS_LIST \
	i_coord, \
	i_repeats, \
	i_alt_x, i_alt_y, i_alt_z, \
	i_min, i_max, \
	i_step, \
	i_factor, \
	i_torus_u, i_torus_v, \
	i_alpha, i_bump_inuse, \
	i_alpha_output, \
	i_alpha_factor

#define XSI_TEXTURE_COMMON_PARAMS_WITH_TRANSFORM \
	point i_coord; \
	uniform matrix i_transform; \
	point i_repeats; \
	float i_alt_x, i_alt_y, i_alt_z; \
	point i_min, i_max; \
	point i_step; \
	float i_factor; \
	float i_torus_u, i_torus_v; \
	float i_alpha, i_bump_inuse; \
	uniform float i_alpha_output; \
	float i_alpha_factor

#define XSI_TEXTURE_DO_BUMP\
	if( i_bump_inuse )\
	{\
		point dummy = 0;\
		mib_bump_map(\
			dummy, dummy,\
			coord,\
			i_step,\
			i_factor,\
			i_torus_u, i_torus_v, \
			i_alpha,\
			RGBA_COLOR_PARAM(o_result),\
			0 /* clamp */,\
			dummy );\
	}

/*
	Compute the color that is supposed to be reflected using
	ray tracing.
*/
void xsi_reflect(
	RGBA_DECLARE( i_reflectivity );
	float i_reflect_glossy;
	float i_reflect_samples;
	
	float i_no_trace;
	
	float i_reflect_inuse;
	
	float i_scalerefl;
	float i_invertrefl;
	float i_usealpharefl;
	
	float __reflects;
	output color o_color;
	output color o_weight;)
{
	if( i_reflect_inuse != 0 && __reflects != 0 )
	{
		o_weight = i_usealpharefl ? color(i_reflectivity_a) : i_reflectivity;
		if(i_invertrefl)
			o_weight = 1 - o_weight;
		o_weight *= i_scalerefl;

		float samples = max(i_reflect_samples, 4);

		if(o_weight != 0)
		{
			extern normal N;
			extern vector I;
			extern point P;

			normal Nf = faceforward( normalize(N), I );
			vector R = reflect(I, Nf);

			uniform string envmap = "";
			option( "user:_3delight_reflection_envmap", envmap );

			float samplecone = clamp(i_reflect_glossy, 0, 1)/PI;

			/* TODO: Standard distribution of standard materials should be
			 * cosine */
			if( i_no_trace == 0 )
			{
				o_color = trace(P, R,
						"samples", samples,
						"samplecone", samplecone,
						"environmentmap", envmap,
						"environmentspace", "world",
						"weight", o_weight,
						"subset", "-xsi_InvisibleToReflectionRays");
			}
			else
			{
				if( envmap != "" )
				{
					/* Trace environment only. Temporary solution: use
					 * trace() with "subset" "__tmp__shit__" */
					o_color = trace(P, R,
							"samples", samples,
							"samplecone", samplecone,
							"environmentmap", envmap,
							"environmentspace", "world",
							"weight", o_weight,
							"subset", "__tmp__shit__");
				}
			}

		}
		o_color *= o_weight;
	}
}

/*
	Compute the color that is supposed to be refracted using
	ray tracing.

	NOTES
	- If the IOR is 1, we do not use any ray-tracing and let the
	  XSI_COMBINE routine to correctly alter the Oi using the 
	  "real_transparency" computed below.
	
	OUTPUTS
	o_color : the refracted color if IOR != 1
	o_real_transparency
	        : transparency modulated by the refraction flags: invert,
	          use alpha, scale.
*/
void xsi_refract(
	RGBA_DECLARE( i_transparency );
	float i_trans_glossy;
	float i_transparent_samples;
	
	float i_ior;
	
	float i_refract_inuse;
	float i_scaletrans;
	float i_inverttrans;
	float i_usealphatrans;
	
	float __refracts;
	float __transparent;
	
	output color o_color;
	output color o_real_transparency;)
{
	extern float __transparent;
	extern float __refracts;
	if( i_refract_inuse!=0 && (__transparent != 0 || __refracts != 0) )
	{
		extern color Oi;
		
		o_real_transparency =
			i_usealphatrans ? color(i_transparency_a) : i_transparency;
		if( i_inverttrans != 0 )
		{
			o_real_transparency = 1 - o_real_transparency;
		}
		
		o_real_transparency *= i_scaletrans;

		if( (i_ior==1.0 && i_trans_glossy==0) ||
			(__refracts == 0.0 /* shadow maps act as if ior==1*/) )
		{
			/* Do nothing here. The XSI_COMBINE_ macro is responsible of
			   correctly altering Oi. */
		}
		else if( o_real_transparency != 0 && __refracts != 0 )
		{
			extern normal N;
			extern vector I;
			extern point P;
			
			float eta = (I.N<0.0) ? 1.0 / i_ior  : i_ior;
			normal Nf = faceforward( normalize(N), I );
			vector nI = normalize(I);
			vector refr_dir = refract(nI, Nf, eta);
			string subset;
			if(refr_dir == 0)
			{
				refr_dir = reflect(nI, Nf);
				subset = "-xsi_InvisibleToReflectionRays";
			}
			else
			{
				subset = "-xsi_InvisibleToRefractionRays";
			}

			uniform string envmap = "";
			option( "user:_3delight_reflection_envmap", envmap );

			float samples = max(4, i_transparent_samples);

			if( i_trans_glossy == 0)
			{
				/* No sample cone */
				o_color = trace(
					P, refr_dir,
					"samples", samples,
					"environmentmap", envmap,
					"environmentspace", "world",
					"weight", o_real_transparency,
					"subset", subset);
			}
			else
			{
				/* Simulate behaviour of microfacets. If ior = 1, then light
				 * doesn't change direction when refracts and samplecone is 0.
				 * increasing ior makes samplecone bigger. */
				float samplecone = clamp(abs(log(eta)) * i_trans_glossy, 0, 1);

				/* TODO: Standard distribution of standard materials is cosine
				 */
				o_color = trace(
					P, refr_dir,
					"samplecone", samplecone,
					"samples", samples,
					"environmentmap", envmap,
					"environmentspace", "world",
					"weight", o_real_transparency,
					"subset", subset);
			}
		}
	}
}

#define XSI_INCANDESCENCE(o_color) \
	if( i_incand_inuse != 0 && \
		i_inc_inten != 0 && \
		1 == islightcategory( "incandescence" ) ) \
	{ \
		o_color = i_incandescence * i_inc_inten; \
	} \
	else \
	{ \
		o_color = 0; \
	}

#define XSI_COMBINE_COMPONENTS_SPEC(out, diff, amb, irrad, spec, P, Nf) \
{ \
	extern uniform float __is_subsurface_ray; \
	extern uniform float __subsurface_strength; \
	extern normal N_nobump; \
	\
	/* Get Color Bleeding */ \
	if( irrad != 0 ) \
	{ \
		irrad *= ColorBleeding( irrad ); \
	} \
	\
	if( __subsurface_strength != 0 ) \
	{ \
		if( __is_subsurface_ray == 1 ) \
			out = diff + amb + irrad; \
		else \
		{ \
			diff = mix( \
					diff, \
					subsurface( \
						P, normalize( N_nobump ), \
						"model", "grosjean", \
						"irradiance", diff), \
					__subsurface_strength ); \
			out = diff + amb + irrad + spec; \
		} \
	} \
	else \
		out = diff + amb + irrad + spec; \
 \
	out##_a = 1; \
}

#define XSI_COMBINE_COMPONENTS_NO_SPEC(out, diff, amb, P, Nf) \
{ \
	extern uniform float __is_subsurface_ray; \
	extern uniform float __subsurface_strength; \
	extern normal N_nobump; \
	if( __subsurface_strength != 0 ) \
	{ \
		if( __is_subsurface_ray == 1 ) \
			out = diff + amb; \
		else \
		{ \
			diff = mix( \
					diff, \
					subsurface( \
						P, normalize( N_nobump ), \
						"model", "grosjean", \
						"irradiance", diff), \
					__subsurface_strength ); \
			out = diff + amb; \
		} \
	} \
	else \
		out = diff + amb; \
 \
	out##_a = 1; \
}

#define XSI_COMBINE_MATERIAL_COMPONENTS(out, diff, diff_on, amb, irrad, spec, spec_on, refl, refl_weight, refr, real_transparency, incand, P, Nf) \
	{ \
		extern uniform float __is_subsurface_ray; \
		extern uniform float __subsurface_strength; \
		extern color Oi; \
		extern normal N_nobump; \
		\
		uniform bool Oi_refraction = false, sss = false; \
		\
		/* Mental ray tries to "conserve energy": the refraction is toned  \
		   down proportionally to the luminance of the reflection. \
		   FIXME: What this means is that our shader compiler is NOT able to \
		   to do a good optimization for opacity rays since Oi and relfections \
		   are now bound! */ \
		float refl_luminance = luminance( refl ); \
		color scaled_transparency = real_transparency * \
			(1 - min(refl_luminance, 1)); \
		\
		color diff_scale = 1 - refl_weight; \
		\
		color Oi_multiplier = Oi; \
		if( i_refract_inuse != 0 ) \
		{ \
			/* Perform the transparency here if ior == 1 */ \
			if( (i_ior==1.0 && i_trans_glossy==0)  || \
				(__refracts == 0.0 /* shadow maps act as if ior==1*/) ) \
			{ \
				Oi_refraction = true; \
				Oi *= 1-scaled_transparency*diff_scale; \
				Oi_multiplier *= 1-scaled_transparency; \
			} \
		} \
		\
		if( __subsurface_strength != 0 ) \
		{ \
			if( __is_subsurface_ray == 1 ) \
			{ \
				sss = true; \
				diff = diff * diff_on; \
				amb = amb * diff_on; \
				irrad = irrad * diff_on; \
			} \
			else \
			{ \
				diff = mix( \
						diff*diff_on, \
						subsurface( \
							P, normalize( N_nobump ), \
							"model", "grosjean", \
							"irradiance", diff*diff_on), \
						__subsurface_strength ); \
				diff *= diff_scale; \
				amb = amb * diff_on * diff_scale; \
				irrad = irrad * diff_on * diff_scale; \
			} \
		} \
		else \
		{ \
			diff = diff * diff_on * diff_scale; \
			amb = amb * diff_on * diff_scale; \
			irrad = irrad * diff_on * diff_scale; \
		} \
		\
		if( sss == false ) \
		{ \
			if( i_refract_inuse!=0 && Oi_refraction == false ) \
			{ \
				diff *= 1-scaled_transparency; \
				amb *= 1-scaled_transparency; \
				irrad *= 1-scaled_transparency; \
				incand *= 1-scaled_transparency; \
				refr = refr * diff_scale * scaled_transparency; \
			} \
			else \
			{ \
				refr = 0; \
			} \
			\
			spec = spec * spec_on; \
		} \
		else \
		{ \
			/* Off reflection/refraction/specular if we are in sss \
			 * computation mode */ \
			spec = 0; \
			refl = 0; \
			refr = 0; \
		} \
		\
		diff *= Oi_multiplier; \
		amb *= Oi_multiplier; \
		irrad *= Oi_multiplier; \
		incand *= Oi_multiplier; \
		refr *= Oi_multiplier; \
		\
		/* Get Color Bleeding */ \
		if( irrad != 0 ) \
		{ \
			irrad *= ColorBleeding( irrad ); \
		} \
		\
		out = diff + amb + irrad + spec + refl + refr + incand; \
		out##_a = 1; \
	}

color ColorBleeding( color i_weight )
{
	uniform float xsi_gi_caster = 1;
	attribute( "user:__xsi_gi_caster", xsi_gi_caster );
	if (xsi_gi_caster == 0)
	{
		return 0;
	}

	uniform float cb_algo = 0;
	option( "user:xsi_cb_algorithm", cb_algo );

	if( cb_algo == 0 )
	{
		return 0;
	}

	extern normal N;
	extern vector I;
	extern point P;

	normal Nf = ShadingNormal( normalize(N) );

	color result = 0;
	uniform float falloff = 0;
	uniform float falloffmode = -1;
	uniform float maxdist = 0;
	attribute( "user:xsi_falloff_type", falloffmode );
	attribute( "user:xsi_maxdist", maxdist );
	if( falloffmode != -1 )
	{
		attribute( "user:xsi_falloff_exponent", falloff );
	}

	uniform string envmap = "";
	option( "user:_3delight_envmap", envmap );

	if( cb_algo == 2.0 )
	{
		/* Point-based */

		uniform string bake_file = "";
		uniform float maxsolidangle = 0.01;

		option( "user:bake_file", bake_file );
		option( "user:xsi_ptc_maxsolidangle", maxsolidangle );
		
		uniform float pointcloud_bias;
		if( attribute("user:xsi_pointcloud_bias", pointcloud_bias) == 0 )
		{
			pointcloud_bias = 0.01;
		}

		result = indirectdiffuse(
			P, Nf, 0,
			"pointbased", 1,
			"clamp", 1, 
			"filename", bake_file,
			"coordsystem", "world",
			"coneangle", PI * 0.5,
			"sortbleeding", 1,
			"hitsides", "both",
			"maxsolidangle", maxsolidangle,
			"environmentmap", envmap,
			"environmentspace", "world",
			"bias", pointcloud_bias,
			"maxdist", maxdist,
			"falloffmode", falloffmode, "falloff", falloff);
	}
	else
	{
		/* ray-traced, samples are specified using the "irradiance"
		   "shadingrate" attribute. */

		uniform string hitmode = "shader";
		attribute( "user:diffuse_hitmode", hitmode );

		float samples = 64;
		attribute( "irradiance:nsamples", samples );

		result = trace(
				P, Nf,
				"type", "diffuse",
				"bsdf", "cosine",
				"hitmode", hitmode,
				"maxdist", maxdist,
				"samples", samples,
				"weight", i_weight,
				"environmentmap", envmap,
				"environmentspace", "world");
	}

	return result;
}

/* PointBasedReflection

   Emulates reflection using Point-Based indirectdiffuse. Works only if
   Point-Based Color Bleeding is enabled. */

bool PointBasedReflection(
	vector i_R;
	float i_ConeAngle;
	color o_result;)
{
	extern point P;
	
	uniform float cb_algo = 0;
	option( "user:xsi_cb_algorithm", cb_algo );
	
	/* It works only if Color Bleeding Algorithm is Point-Based */
	if( cb_algo == 2.0 )
	{
		uniform string bake_file = "";
		uniform string envmap = "";
		uniform float maxsolidangle = 0.01;
		
		/* We get all necessary options from Global Illumination
		   at the moment. In future all these parameters should be
		   reflection only. */
		option( "user:bake_file", bake_file );
		option( "user:_3delight_reflection_envmap", envmap );
		option( "user:xsi_ptc_maxsolidangle", maxsolidangle );
		
		uniform float pointcloud_bias;
		if( attribute("user:xsi_pointcloud_bias", pointcloud_bias) == 0 )
		{
			pointcloud_bias = 0.01;
		}
		
		uniform float falloff = 0;
		uniform float falloffmode = -1;
		uniform float maxdist = 0;
		attribute( "user:xsi_falloff_type", falloffmode );
		attribute( "user:xsi_maxdist", maxdist );
		if( falloffmode != -1 )
		{
			attribute( "user:xsi_falloff_exponent", falloff );
		}
		
		o_result = indirectdiffuse(
			P, i_R, 0,
			"pointbased", 1,
			"clamp", 1, 
			"filename", bake_file,
			"coordsystem", "world",
			"coneangle", i_ConeAngle,
			"sortbleeding", 1,
			"maxsolidangle", maxsolidangle,
			"environmentmap", envmap,
			"bias", pointcloud_bias,
			"maxdist", maxdist,
			"falloffmode", falloffmode, "falloff", falloff);
		
		return true;
	}
	
	return false;
}

#endif
