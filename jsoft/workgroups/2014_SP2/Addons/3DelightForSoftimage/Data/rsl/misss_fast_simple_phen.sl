/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __misss_fast_simple_phen_sl
#define __misss_fast_simple_phen_sl

#include "misss_fast_skin_phen.sl"

void misss_fast_simple_phen(
	/* NOTE: lightmap parameters are unused. */
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;

	string i_displace, i_environment; /* unused */

	point i_bump; /* unused */

	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_overall_color );
	RGBA_DECLARE( i_diffuse_color );
	float i_diffuse_weight;

	/* front color. */
	RGBA_DECLARE( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;

	/* back color */
	RGBA_DECLARE( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;

	/* specular */
	RGBA_DECLARE( i_specular );
	float i_exponent;

	/* unused parameters block */
	float i_lightmap_gamma;
	RGBA_DECLARE( i_radiance );

	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	bool i_screen_composit;

	RGBA_DECLARE_OUTPUT( o_result ); )
{
	extern normal N;
	extern vector I;
	
	// todo: remove this line when the i_normal_camera input is put back.
	normal i_normal_camera = N;

	uniform string raytype = "";
	rayinfo("type", raytype);

	if( raytype == "subsurface" )
	{
		float is_backface = N . - vector( E ) > 0 ? 1 : 0;

		// Subsurface scattering.
		color result_amb =
			i_ambient != 0 ? xsi_ambience() * i_ambient : i_ambient;

		color colorbleeding = 0;
		if(i_radiance != 0)
		{
			/* Compute weight of ColorBleeding */
			color weight = i_radiance;
			if ( is_backface != 0 )
			{
				// Back scattering.
				weight *= 1.5 * i_back_sss_color * i_back_sss_weight;
			}
			else
			{
				// Front scattering.
				weight *= 2.0 * i_front_sss_color * i_front_sss_weight;
			}

			colorbleeding = i_radiance * ColorBleeding( weight );
		}
		
		color d = diffuse(normalize(N)) + colorbleeding;

		if ( is_backface != 0 )
		{
			// Back scattering.
			o_result = 0.14 * result_amb * i_diffuse_weight;
			o_result += 1.5 * i_back_sss_color * i_back_sss_weight * d;
			o_result *= i_overall_color;
		}
		else
		{
			// Front scattering.
			o_result = 0.14 * result_amb * i_diffuse_weight;
			o_result += 2.0 * i_front_sss_color * i_front_sss_weight * d;
			o_result *= i_overall_color;
		}
	}
	else
	{
		// Diffuse component.
		RGBA_DECLARE( diffuse );
		misss_lambert_gamma(
			RGBA_USE(i_ambient),
			RGBA_USE(i_diffuse_color),  // i_ambience
			RGBA_USE(i_diffuse_color),  // i_diffuse
			i_radiance,                 // i_indirect
			1.0,                        // i_diffuse_curve
			false,                      // i_flip
			i_normal_camera,
			0, // i_mode
			i_lightmap,
			RGBA_USE(diffuse) );

		// Specular component.
		RGBA_DECLARE( specular );
		misss_skin_specular(
			1.0,                        // i_overall_weight
			5.0,                        // i_edge_factor
			RGBA_USE(i_specular),
			1.0,                        // i_primary_weight
			1.0,                        // i_primary_edge_weight
			i_exponent,                 // i_primary_shinyness
			color(0.9, 0.95, 1.0),1,    // i_secondary_spec_color
			0.2,                        // i_secondary_weight
			0.0,                        // i_secondary_edge_weight
			33.0,                       // i_secondary_shinyness
			0.0,                        // i_reflect_weight
			0.0,                        // i_reflect_edge_weight
			2.0,                        // i_reflect_shinyness
			false,                      // i_reflect_environment_only
			i_normal_camera,
			0,
			i_lightmap,
			RGBA_USE(specular) );
			
		misss_fast_shader(
			i_lightmap,
			"",                     // i_depthmap
			"",                     // i_bump
			RGBA_USE(diffuse),      // i_diffuse_illum
			RGBA_USE(i_overall_color),  // i_diffuse_color
			RGBA_USE(specular),     // i_specular_illum
			i_diffuse_weight,
			RGBA_USE(i_front_sss_color),
			i_front_sss_weight,
			i_front_sss_radius,
			RGBA_USE(i_back_sss_color),
			i_back_sss_weight,
			i_back_sss_radius,
			i_back_sss_depth,
			i_scale_conversion,
			i_screen_composit,
			false,                  // i_output_sss_only
			i_falloff,
			i_samples,
			RGBA_USE(o_result),
			i_scale_conversion );
	}
}

void misss_fast_simple_phen(
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;
	string i_displace, i_environment;
	point i_bump;
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_overall_color);
	RGBA_DECLARE(i_diffuse_color);
	float i_diffuse_weight;
	RGBA_DECLARE(i_front_sss_color);
	float i_front_sss_weight;
	float i_front_sss_radius;
	RGBA_DECLARE(i_back_sss_color);
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;
	RGBA_DECLARE(i_specular);
	float i_exponent;
	float i_lightmap_gamma;
	RGBA_DECLARE(i_radiance);
	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	bool i_screen_composit;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	misss_fast_simple_phen(
		i_lightmap,
		i_lightmap_size,
		i_samples,
		i_displace, i_environment,
		i_bump,
		RGBA_USE(i_ambient),
		color(0, 0, 0), 0,
		RGBA_USE(i_overall_color),
		RGBA_USE(i_diffuse_color),
		i_diffuse_weight,
		RGBA_USE(i_front_sss_color),
		i_front_sss_weight,
		i_front_sss_radius,
		RGBA_USE(i_back_sss_color),
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,
		RGBA_USE(i_specular),
		i_exponent,
		i_lightmap_gamma,
		RGBA_USE(i_radiance),
		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,
		RGBA_USE(o_result));
}

/* Version for "Fast Simple (misss)" node of Softiamge 2011. */

void misss_fast_simple_phen(
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;
	color i_displace; bool i_displace_connected;
	color i_environment; bool i_environment_connected;
	point i_bump;
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_overall_color);
	RGBA_DECLARE(i_diffuse_color);
	float i_diffuse_weight;
	RGBA_DECLARE(i_front_sss_color);
	float i_front_sss_weight;
	float i_front_sss_radius;
	RGBA_DECLARE(i_back_sss_color);
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;
	RGBA_DECLARE(i_specular);
	float i_exponent;
	float i_lightmap_gamma;
	RGBA_DECLARE(i_radiance);
	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	bool i_screen_composit;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	misss_fast_simple_phen(
		i_lightmap,
		i_lightmap_size,
		i_samples,
		"", "",
		i_bump,
		RGBA_USE(i_ambient),
		color(0, 0, 0), 0,
		RGBA_USE(i_overall_color),
		RGBA_USE(i_diffuse_color),
		i_diffuse_weight,
		RGBA_USE(i_front_sss_color),
		i_front_sss_weight,
		i_front_sss_radius,
		RGBA_USE(i_back_sss_color),
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,
		RGBA_USE(i_specular),
		i_exponent,
		i_lightmap_gamma,
		RGBA_USE(i_radiance),
		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,
		RGBA_USE(o_result));
}

/* Version for "misss_fast_simple_phen" Material Phenomena node of Softiamge 2011. */

void misss_fast_simple_phen(
	/* NOTE: lightmap and depthmap parameters are unused. */
	string i_lm;
	float i_lm_FlipX, i_lm_FlipY, i_lm_Xmin, i_lm_Xmax, i_lm_Ymin, i_lm_Ymax, i_lm_exposure, i_lm_gamma,
		i_lm_Hue, i_lm_Saturation, i_lm_Gain, i_lm_Brighness, i_lm_GrayScale, i_lm_normalizedBlurX,
		i_lm_normalizedBlurY, i_lm_Amount, i_lm_BlurAlpha;
	string i_dm;
	float i_dm_FlipX, i_dm_FlipY, i_dm_Xmin, i_dm_Xmax, i_dm_Ymin, i_dm_Ymax, i_dm_exposure, i_dm_gamma,
		i_dm_Hue, i_dm_Saturation, i_dm_Gain, i_dm_Brighness, i_dm_GrayScale, i_dm_normalizedBlurX,
		i_dm_normalizedBlurY, i_dm_Amount, i_dm_BlurAlpha;
		
	string  i_lightmap_group;
	float i_lightmap_size;
	float i_samples;
	
	/* unused */
	color i_bump; uniform bool i_bump_connected;

	RGBA_COLOR( i_ambient );
	color i_overall_color;
	color i_diffuse_color;
	float i_diffuse_weight;

	color i_front_sss_color;
	float i_front_sss_weight;
	float i_front_sss_radius;

	color i_back_sss_color;
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;
	
	color i_specular;
	float i_exponent;
	float i_lightmap_gamma;
	
	bool i_indirect;

	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	bool i_screen_composit;
	
	float i_mode;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	misss_fast_simple_phen(
		"", /* lightmap */
		0, /* lightmap_size */
		1, /* samples */

		"", "", /* displace, environment */

		point(0), /* bump */
		
		RGBA_USE(i_ambient),
		color(0), 0, /* ambience */
		i_overall_color, 1,
		i_diffuse_color, 1,
		i_diffuse_weight,
		
		i_front_sss_color, 1,
		i_front_sss_weight,
		i_front_sss_radius,
		
		i_back_sss_color, 1,
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,
		
		i_specular, 1,
		i_exponent,
		i_lightmap_gamma,
		
		color(1), 1, /* radiance */
		
		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,
		
		RGBA_USE(o_result));
}

#endif
