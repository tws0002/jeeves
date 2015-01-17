/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __misss_fast_shader_sl
#define __misss_fast_shader_sl

#include "misss_lambert_gamma.sl"

/* Multiplier for sss part to best match with the MR */
#define SSSMULTIPLIER 1.4

color screen_compose(color a, b)
{
	return 1.0 - (1.0 - a) * (1.0 - b);
}

color screen_compose(color a, b, c)
{
	return 1.0 - (1.0 - clamp(a,0,1) ) * (1.0 - clamp(b,0,1)) * (1.0 - clamp(c,0,1));
}

void misss_fast_shader(
	string i_lightmap; // unused
	string i_depthmap; // unused
	string i_bump; // unused
	RGBA_DECLARE( i_diffuse_illum );
	RGBA_DECLARE( i_diffuse_color );
	RGBA_DECLARE( i_specular_illum );
	float i_diffuse_weight;
	RGBA_DECLARE( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;
	RGBA_DECLARE( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius; // unused
	float i_back_sss_depth; // unused
	/* In mr this parameter absolutely dont affect to result */
	uniform float i_scale_conversion;
	bool i_screen_composit;
	bool i_output_sss_only;
	float i_falloff; // unused
	float i_samples ; // unused

	RGBA_DECLARE_OUTPUT(o_result);
	
	/* SSS scale. It is necessary to have separate parameter
	   because in this shader i_scale_conversion don't affect to result
	   unlike other sss shaders */
	uniform float i_scale;)
{
	extern point P;
	extern normal N;
	extern vector I;
	extern normal N_nobump;

	color diffuse = i_diffuse_illum * i_diffuse_color * i_diffuse_weight;
	color specular = i_specular_illum;
	
	normal Nn = normalize(N);
	normal Nf = ShadingNormal( Nn );
	
	uniform string raytype = "unknown";	
	rayinfo( "type", raytype );
	
	if( raytype == "subsurface" )
	{
		float is_backface = Nn . - vector( E ) > 0 ? 1 : 0;
		if ( is_backface != 0 )
		{
			// Back scattering.
			o_result = 2 * i_back_sss_color * i_back_sss_weight * diffuse * SSSMULTIPLIER;
		}
		else
		{
			// Front scattering.
			o_result = i_front_sss_color * i_front_sss_weight * diffuse * SSSMULTIPLIER;
		}
	}
	else
	{
		uniform float scale = i_scale;

		/* bo metter match to mr */
		if(scale > 1)
			scale = 1 + (scale-1)*0.33333;
		
		color subsurf =
			subsurface(P, normalize(N_nobump),
				"absorption", color(0.002, 0.004, 0.007),
				"scattering", color(2.19, 2.62, 3),
				"ior", 1.5,
				"scale", scale,
				"normalize", 1,
				"model", "grosjean", "irradiance", diffuse ) * 
				SSSMULTIPLIER;
		
		if( i_output_sss_only == true )
		{
			o_result = subsurf;
		}
		else
		{
			if( i_screen_composit == true )
				o_result = screen_compose(diffuse, specular, subsurf);
			else
				o_result = diffuse + specular + subsurf;
		}
	}

	o_result_a = 1;
}

/* The same parameters but without i_scale parameter */
void misss_fast_shader(
	string i_lightmap; // unused
	string i_depthmap; // unused
	string i_bump; // unused
	RGBA_DECLARE( i_diffuse_illum );
	RGBA_DECLARE( i_diffuse_color );
	RGBA_DECLARE( i_specular_illum );
	float i_diffuse_weight;
	RGBA_DECLARE( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;
	RGBA_DECLARE( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius; // unused
	float i_back_sss_depth; // unused
	uniform float i_scale_conversion; // unused
	bool i_screen_composit;
	bool i_output_sss_only;
	float i_falloff; // unused
	float i_samples ; // unused

	RGBA_DECLARE_OUTPUT(o_result);)
{
	misss_fast_shader(
		i_lightmap,
		i_depthmap,
		i_bump,
		RGBA_USE( i_diffuse_illum ),
		RGBA_USE( i_diffuse_color ),
		RGBA_USE( i_specular_illum ),
		i_diffuse_weight,
		RGBA_USE( i_front_sss_color ),
		i_front_sss_weight,
		i_front_sss_radius,
		RGBA_USE( i_back_sss_color ),
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,
		i_scale_conversion,
		i_screen_composit,
		i_output_sss_only,
		i_falloff,
		i_samples,

		RGBA_USE(o_result),
		
		1.0);
}

void misss_fast_shader(
	string i_lm;
	float i_lm_FlipX, i_lm_FlipY, i_lm_Xmin, i_lm_Xmax, i_lm_Ymin, i_lm_Ymax, i_lm_exposure, i_lm_gamma,
		i_lm_Hue, i_lm_Saturation, i_lm_Gain, i_lm_Brighness, i_lm_GrayScale, i_lm_normalizedBlurX,
		i_lm_normalizedBlurY, i_lm_Amount, i_lm_BlurAlpha;
	string i_dm;
	float i_dm_FlipX, i_dm_FlipY, i_dm_Xmin, i_dm_Xmax, i_dm_Ymin, i_dm_Ymax, i_dm_exposure, i_dm_gamma,
		i_dm_Hue, i_dm_Saturation, i_dm_Gain, i_dm_Brighness, i_dm_GrayScale, i_dm_normalizedBlurX,
		i_dm_normalizedBlurY, i_dm_Amount, i_dm_BlurAlpha;
	color i_bump; bool i_bump_connected;
	color i_diffuse_illum; bool i_diffuse_illum_connected;
	color i_diffuse_color;
	color i_specular_illum; bool i_specular_illum_connected; 
	float i_diffuse_weight;
	color i_front_sss_color;
	float i_front_sss_weight;
	float i_front_sss_radius;
	color i_back_sss_color;
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;
	uniform float i_scale_conversion;
	bool i_screen_composit;
	bool i_output_sss_only;
	float i_falloff;
	float i_samples;

	RGBA_DECLARE_OUTPUT(o_result); 
	)
{
	RGBA_DECLARE( diffuse_comp );
	if( i_diffuse_illum_connected==true )
	{
		diffuse_comp = i_diffuse_illum;
	}
	else
	{
		misss_lambert_gamma(
			color(0),	// i_ambient
			color(1),	// i_ambience
			color(1),	// i_diffuse
			true,		// i_indirect
			1.0,		// i_diffuse_curve
			0,			// i_flip
			0,			// i_mode
			RGBA_USE(diffuse_comp) );
	}
	
	misss_fast_shader(
		i_lm, // unused
		i_dm, // unused
		"", // unused
		diffuse_comp, 1,
		i_diffuse_color, 1,
		i_specular_illum, 1,
		i_diffuse_weight,
		i_front_sss_color, 1,
		i_front_sss_weight,
		i_front_sss_radius,
		i_back_sss_color, 1,
		i_back_sss_weight,
		i_back_sss_radius, // unused
		i_back_sss_depth, // unused
		i_scale_conversion, // unused
		i_screen_composit,
		i_output_sss_only,
		i_falloff, // unused
		i_samples, // unused

		RGBA_USE(o_result) );
}

// Softimage 2012
void misss_fast_shader(
	string i_lm;
	float i_lm_FlipX, i_lm_FlipY, i_lm_Xmin, i_lm_Xmax, i_lm_Ymin, i_lm_Ymax, i_lm_exposure, i_lm_gamma,
		i_lm_Hue, i_lm_Saturation, i_lm_Gain, i_lm_Brighness, i_lm_GrayScale, i_lm_normalizedBlurX,
		i_lm_normalizedBlurY, i_lm_Amount, i_lm_BlurAlpha;
	string i_dm;
	float i_dm_FlipX, i_dm_FlipY, i_dm_Xmin, i_dm_Xmax, i_dm_Ymin, i_dm_Ymax, i_dm_exposure, i_dm_gamma,
		i_dm_Hue, i_dm_Saturation, i_dm_Gain, i_dm_Brighness, i_dm_GrayScale, i_dm_normalizedBlurX,
		i_dm_normalizedBlurY, i_dm_Amount, i_dm_BlurAlpha;
	color i_bump; bool i_bump_connected;
	color i_diffuse_illum; bool i_diffuse_illum_connected;
	color i_diffuse_color;
	color i_specular_illum; bool i_specular_illum_connected; 
	float i_diffuse_weight;
	color i_front_sss_color;
	float i_front_sss_weight;
	float i_front_sss_radius;
	color i_back_sss_color;
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;
	uniform float i_scale_conversion;
	bool i_screen_composit;
	bool i_output_sss_only;
	float i_falloff;
	float i_samples;
	color i_fallback_shader; bool i_fallback_shader_connected;

	RGBA_DECLARE_OUTPUT(o_result); 
	)
{
	misss_fast_shader(
		i_lm,
		i_lm_FlipX, i_lm_FlipY, i_lm_Xmin, i_lm_Xmax, i_lm_Ymin, i_lm_Ymax, i_lm_exposure, i_lm_gamma,
		i_lm_Hue, i_lm_Saturation, i_lm_Gain, i_lm_Brighness, i_lm_GrayScale, i_lm_normalizedBlurX,
		i_lm_normalizedBlurY, i_lm_Amount, i_lm_BlurAlpha,
		
		i_dm,
		i_dm_FlipX, i_dm_FlipY, i_dm_Xmin, i_dm_Xmax, i_dm_Ymin, i_dm_Ymax, i_dm_exposure, i_dm_gamma,
		i_dm_Hue, i_dm_Saturation, i_dm_Gain, i_dm_Brighness, i_dm_GrayScale, i_dm_normalizedBlurX,
		i_dm_normalizedBlurY, i_dm_Amount, i_dm_BlurAlpha,
		
		i_bump, i_bump_connected,
		i_diffuse_illum, i_diffuse_illum_connected,
		i_diffuse_color,
		i_specular_illum, i_specular_illum_connected,
		i_diffuse_weight,
		i_front_sss_color,
		i_front_sss_weight,
		i_front_sss_radius,
		i_back_sss_color,
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,
		i_scale_conversion,
		i_screen_composit,
		i_output_sss_only,
		i_falloff,
		i_samples,

		RGBA_USE(o_result) );
}
#endif
