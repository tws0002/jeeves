/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __miss_fast_skin_phen_sl
#define __miss_fast_skin_phen_sl

//
// Fast skin shader for 3Delight.
// Authors: the /*jupiter jazz*/ group and DNA Research
//
// Supported inputs:
//
//   i_lightmap............................N/A
//   i_samples.............................N/A
//   i_ambient.............................yes
//   i_overall_color.......................yes
//   i_diffuse_color.......................yes
//   i_diffuse_weight......................yes
//   i_front_sss_color.....................yes
//   i_front_sss_weight....................yes
//   i_front_sss_radius....................RiAttribute
//   i_mid_sss_color.......................yes
//   i_mid_sss_weight......................yes
//   i_mid_sss_radius......................RiAttribute
//   i_back_sss_color......................yes
//   i_back_sss_weight.....................yes
//   i_back_sss_radius.....................RiAttribute
//   i_back_sss_depth......................RiAttribute
//   i_overall_weight......................yes
//   i_edge_factor.........................yes
//   i_primary_spec_color..................yes
//   i_primary_weight......................yes
//   i_primary_edge_weight.................yes
//   i_primary_shinyness...................yes
//   i_secondary_spec_color................yes
//   i_secondary_weight....................yes
//   i_secondary_edge_weight...............yes
//   i_secondary_shinyness.................yes
//   i_reflect_weight......................yes
//   i_reflect_edge_weight.................yes
//   i_reflect_shinyness...................yes
//   i_reflect_environment_only............yes
//   i_scale_conversion....................yes
//   i_falloff.............................RiAttribute
//   i_screen_composit.....................yes
//   i_normal_camera.......................yes
//   i_mode................................N/A
//   i_lights..............................N/A

// Notes:
//
//   The attributes (RiAttribute) controlling the subsurface scattering should
//   be set in function of the values of i_front_sss_radius, i_back_sss_radius,
//   i_back_sss_depth and i_falloff (but probably not all these parameters can
//   be supported by the scattering model implemented in 3Delight core).
//
//   For instance, the i_front_sss_radius and i_back_sss_radius (maybe the
//   average of these two parameters) would be mapped to the mean free path
//   attribute of 3Delight.
//
//   The front and back scattering AOVs are not supported (they are always set
//   to black). The reason is that there is no way to separate front scattering
//   and back scattering from the output of the subsurface() shadeop.
//

#include "misss_fast_shader.sl"
#include "misss_lambert_gamma.sl"
#include "misss_skin_specular.sl"

void misss_fast_skin_phen(

	/* NOTE: lightmap parameters are unused. */
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;

	string i_displace, i_environment; /* unused */

	point i_bump; /* unused */

	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_ambience );
	RGBA_COLOR( i_overall_color );
	RGBA_COLOR( i_diffuse_color );
	float i_diffuse_weight;

	/* epiderm color. */
	RGBA_COLOR( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;

	/* subdermal color */
	RGBA_COLOR( i_mid_sss_color );
	float i_mid_sss_weight;
	float i_mid_sss_radius;

	/* back color */
	RGBA_COLOR( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;

	float i_overall_weight;
	float i_edge_factor;

	RGBA_COLOR( i_primary_spec_color );
	float i_primary_weight;
	float i_primary_edge_weight;
	float i_primary_shinyness;

	RGBA_COLOR( i_secondary_spec_color );
	float i_secondary_weight;
	float i_secondary_edge_weight;
	float i_secondary_shinyness;

	float i_reflect_weight;
	float i_reflect_edge_weight;
	float i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	/* unused parameters block */
	float i_lightmap_gamma;
	RGBA_DECLARE( i_radiance );
	RGBA_DECLARE( i_lightmap_diffuse );

	float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	uniform bool i_screen_composit;

	output color o_result;
	output float o_result_a; )
{
	// todo: remove this line when the i_normal_camera input is put back.
	extern normal N;
	normal i_normal_camera = N;

	uniform string raytype = "unknown";
	rayinfo("type", raytype);

	if( raytype == "subsurface" )
	{
		// Subsurface scattering.
		color result_amb =
			i_ambient != 0 ? xsi_ambience() * i_ambient : i_ambient;

		extern normal N;
		extern vector I;

		float is_backface = N . - vector( E ) > 0 ? 1 : 0;
		
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
				weight *=
					( 0.5 * i_front_sss_color * i_front_sss_weight +
					  0.75 * i_mid_sss_color * i_mid_sss_weight );
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
			o_result += 0.5 * i_front_sss_color * i_front_sss_weight * d;
			o_result += 0.75 * i_mid_sss_color * i_mid_sss_weight * d;
			o_result *= i_overall_color;
		}
	}
	else
	{
		// Diffuse component.		
		RGBA_DECLARE( diffuse ); diffuse_a = 0;
		misss_lambert_gamma(
			RGBA_USE(i_ambient),
			RGBA_USE(i_diffuse_color), // i_ambience
			RGBA_USE(i_diffuse_color), // i_diffuse
			i_radiance, // i_indirect
			1.0, // diffuse_curve
			false,	  // i_flip
			i_normal_camera,
			0, // i_mode
			"", // i_lights
			RGBA_USE(diffuse) );

		// Specular component.
		RGBA_DECLARE( specular );
		misss_skin_specular(
			i_overall_weight,
			i_edge_factor,
			RGBA_USE(i_primary_spec_color),
			i_primary_weight,
			i_primary_edge_weight,
			i_primary_shinyness,
			RGBA_USE(i_secondary_spec_color),
			i_secondary_weight,
			i_secondary_edge_weight,
			i_secondary_shinyness,
			i_reflect_weight,
			i_reflect_edge_weight,
			i_reflect_shinyness,
			i_reflect_environment_only,
			i_normal_camera,
			0, // i_mode,
			"", // i_lights
			RGBA_USE(specular) );
			
		// Surface shading.
		RGBA_DECLARE( shallow_scatter );
		misss_fast_shader(
			i_lightmap,
			"", // i_depthmap
			"", // i_bump
			RGBA_USE(diffuse), // i_diffuse_illum
			color 1.0, 1.0, // i_diffuse_color
			color 0.0, 1.0, // i_specular_illum
			i_diffuse_weight,
			RGBA_USE(i_mid_sss_color),
			i_mid_sss_weight,
			i_mid_sss_radius,
			0.0, 1.0, // i_back_sss_color
			0.0, // i_back_sss_weight
			0.0, // i_back_sss_radius
			0.0, // i_back_sss_depth
			i_scale_conversion,
			i_screen_composit,
			false, // i_output_sss_only
			i_falloff,
			i_samples,
			RGBA_USE(shallow_scatter),
			i_scale_conversion );

		misss_fast_shader(
			i_lightmap,	 // i_lightmap
			"",		 // i_depthmap
			"",		 // i_bump
			RGBA_USE(shallow_scatter),// i_diffuse_illum
			RGBA_USE(i_overall_color), // i_diffuse_color
			RGBA_USE(specular), // i_specular_illum
			1.0, // i_diffuse_weight
			RGBA_USE(i_front_sss_color), // i_front_sss_color
			i_front_sss_weight, // i_front_sss_weight
			i_front_sss_radius, // i_front_sss_radius
			RGBA_USE(i_back_sss_color),
			i_back_sss_weight,
			i_back_sss_radius,
			i_back_sss_depth,
			i_scale_conversion,
			i_screen_composit,
			false,	 // i_output_sss_only
			i_falloff,
			i_samples,
			RGBA_USE(o_result),
			i_scale_conversion );
	}

	o_result_a = 1.0;
}

/* Version for Softiamge 2011 without ambience. */

void misss_fast_skin_phen(
	/* NOTE: lightmap parameters are unused. */
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;

	string i_displace, i_environment; /* unused */

	point i_bump; /* unused */

	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_overall_color );
	RGBA_COLOR( i_diffuse_color );
	float i_diffuse_weight;

	/* epiderm color. */
	RGBA_COLOR( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;

	/* subdermal color */
	RGBA_COLOR( i_mid_sss_color );
	float i_mid_sss_weight;
	float i_mid_sss_radius;

	/* back color */
	RGBA_COLOR( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;

	float i_overall_weight;
	float i_edge_factor;

	RGBA_COLOR( i_primary_spec_color );
	float i_primary_weight;
	float i_primary_edge_weight;
	float i_primary_shinyness;

	RGBA_COLOR( i_secondary_spec_color );
	float i_secondary_weight;
	float i_secondary_edge_weight;
	float i_secondary_shinyness;

	float i_reflect_weight;
	float i_reflect_edge_weight;
	float i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	/* unused parameters block */
	float i_lightmap_gamma;
	RGBA_DECLARE( i_radiance );
	RGBA_DECLARE( i_lightmap_diffuse );

	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	uniform bool i_screen_composit;

	output color o_result;
	output float o_result_a; )
{
	misss_fast_skin_phen(
		i_lightmap,
		i_lightmap_size,
		i_samples,

		i_displace, i_environment,

		i_bump,

		RGBA_USE( i_ambient ),
		0, 0, /* ambience */
		RGBA_USE( i_overall_color ),
		RGBA_USE( i_diffuse_color ),
		i_diffuse_weight,

		/* epiderm color. */
		RGBA_USE( i_front_sss_color ),
		i_front_sss_weight,
		i_front_sss_radius,

		/* subdermal color */
		RGBA_USE( i_mid_sss_color ),
		i_mid_sss_weight,
		i_mid_sss_radius,

		/* back color */
		RGBA_USE( i_back_sss_color ),
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,

		i_overall_weight,
		i_edge_factor,

		RGBA_USE( i_primary_spec_color ),
		i_primary_weight,
		i_primary_edge_weight,
		i_primary_shinyness,

		RGBA_USE( i_secondary_spec_color ),
		i_secondary_weight,
		i_secondary_edge_weight,
		i_secondary_shinyness,

		i_reflect_weight,
		i_reflect_edge_weight,
		i_reflect_shinyness,
		i_reflect_environment_only,

		i_lightmap_gamma,
		RGBA_USE( i_radiance ),
		RGBA_USE( i_lightmap_diffuse ),

		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,

		o_result, o_result_a );
}

/* Version for "Fast Skin (misss)" node of Softiamge 2011. */

void misss_fast_skin_phen(
	/* NOTE: lightmap parameters are unused. */
	string  i_lightmap;
	float i_lightmap_size;
	float i_samples;

	/* unused */
	color i_displace; bool i_displace_connected;
	color i_environment; bool i_environment_connected;

	point i_bump; /* unused */

	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_overall_color );
	RGBA_COLOR( i_diffuse_color );
	float i_diffuse_weight;

	/* epiderm color. */
	RGBA_COLOR( i_front_sss_color );
	float i_front_sss_weight;
	float i_front_sss_radius;

	/* subdermal color */
	RGBA_COLOR( i_mid_sss_color );
	float i_mid_sss_weight;
	float i_mid_sss_radius;

	/* back color */
	RGBA_COLOR( i_back_sss_color );
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;

	float i_overall_weight;
	float i_edge_factor;

	RGBA_COLOR( i_primary_spec_color );
	float i_primary_weight;
	float i_primary_edge_weight;
	float i_primary_shinyness;

	RGBA_COLOR( i_secondary_spec_color );
	float i_secondary_weight;
	float i_secondary_edge_weight;
	float i_secondary_shinyness;

	float i_reflect_weight;
	float i_reflect_edge_weight;
	float i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	/* unused parameters block */
	float i_lightmap_gamma;
	RGBA_DECLARE( i_radiance );
	RGBA_DECLARE( i_lightmap_diffuse );

	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	uniform bool i_screen_composit;

	output color o_result;
	output float o_result_a; )
{
	misss_fast_skin_phen(
		i_lightmap,
		i_lightmap_size,
		i_samples,

		"", "",

		i_bump,

		RGBA_USE( i_ambient ),
		0, 0, /* ambience */
		RGBA_USE( i_overall_color ),
		RGBA_USE( i_diffuse_color ),
		i_diffuse_weight,

		/* epiderm color. */
		RGBA_USE( i_front_sss_color ),
		i_front_sss_weight,
		i_front_sss_radius,

		/* subdermal color */
		RGBA_USE( i_mid_sss_color ),
		i_mid_sss_weight,
		i_mid_sss_radius,

		/* back color */
		RGBA_USE( i_back_sss_color ),
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,

		i_overall_weight,
		i_edge_factor,

		RGBA_USE( i_primary_spec_color ),
		i_primary_weight,
		i_primary_edge_weight,
		i_primary_shinyness,

		RGBA_USE( i_secondary_spec_color ),
		i_secondary_weight,
		i_secondary_edge_weight,
		i_secondary_shinyness,

		i_reflect_weight,
		i_reflect_edge_weight,
		i_reflect_shinyness,
		i_reflect_environment_only,

		i_lightmap_gamma,
		RGBA_USE( i_radiance ),
		RGBA_USE( i_lightmap_diffuse ),

		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,

		o_result, o_result_a );
}

/* Version for "misss_fast_skin_phen" Material Phenomena node of Softiamge 2011. */

void misss_fast_skin_phen(
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

	color i_mid_sss_color;
	float i_mid_sss_weight;
	float i_mid_sss_radius;

	color i_back_sss_color;
	float i_back_sss_weight;
	float i_back_sss_radius;
	float i_back_sss_depth;

	float i_overall_weight;
	float i_edge_factor;

	color i_primary_spec_color;
	float i_primary_weight;
	float i_primary_edge_weight;
	float i_primary_shinyness;

	color i_secondary_spec_color;
	float i_secondary_weight;
	float i_secondary_edge_weight;
	float i_secondary_shinyness;

	float i_reflect_weight;
	float i_reflect_edge_weight;
	float i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	/* unused parameters block */
	color i_environment; uniform bool i_environment_connected;
	
	float i_lightmap_gamma;
	uniform bool i_indirect;

	uniform float i_scale_conversion;
	float i_scatter_bias;
	float i_falloff;
	uniform bool i_screen_composit;

	uniform float i_mode;
	
	output color o_result;
	output float o_result_a; )
{
	misss_fast_skin_phen(
		"", /* lightmap */
		0, /* lightmap_size */
		1, /* samples */

		"", "", /* displace, environment */

		point(0), /* bump */

		RGBA_USE( i_ambient ),
		0, 0, /* ambience */
		i_overall_color, 1,
		i_diffuse_color, 1,
		i_diffuse_weight,

		/* epiderm color. */
		i_front_sss_color, 1,
		i_front_sss_weight,
		i_front_sss_radius,

		/* subdermal color */
		i_mid_sss_color, 1,
		i_mid_sss_weight,
		i_mid_sss_radius,

		/* back color */
		i_back_sss_color, 1,
		i_back_sss_weight,
		i_back_sss_radius,
		i_back_sss_depth,

		i_overall_weight,
		i_edge_factor,

		i_primary_spec_color, 1,
		i_primary_weight,
		i_primary_edge_weight,
		i_primary_shinyness,

		i_secondary_spec_color, 1,
		i_secondary_weight,
		i_secondary_edge_weight,
		i_secondary_shinyness,

		i_reflect_weight,
		i_reflect_edge_weight,
		i_reflect_shinyness,
		i_reflect_environment_only,

		i_lightmap_gamma,
		color(1), 1, /* radiance */
		color(1), 1, /* lightmap_diffuse */

		i_scale_conversion,
		i_scatter_bias,
		i_falloff,
		i_screen_composit,

		o_result, o_result_a );
}
#endif
