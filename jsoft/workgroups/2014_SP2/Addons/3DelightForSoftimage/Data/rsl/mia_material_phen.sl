/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __mia_material_phen_sl
#define __mia_material_phen_sl

#include "mia_material.sl"

/*
	Architectural of Softimage 2011 SP1
*/
void mia_material_phen(

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
	float				i_fg_quality;
	float				i_fg_quality_w;

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
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
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;
	
	float				i_refl_base;
	RGBA_COLOR(			i_refl_base_color );
	float				i_refl_base_gloss;
	float				i_refl_base_gloss_samples;
	point				i_refl_base_bump;

	RGBA_DECLARE_OUTPUT(o_result); )
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

		i_bump, 0.0,				/* bump and alpha */
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,
		
		false,						/* i_multiple_output */
		
		i_refl_base,
		RGBA_USE(i_refl_base_color),
		i_refl_base_gloss,
		i_refl_base_gloss_samples,
		i_refl_base_bump,
		
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
	Architectural of Softimage 2011
*/
void mia_material_phen(

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
	float				i_fg_quality;
	float				i_fg_quality_w;

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
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
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;

	RGBA_DECLARE_OUTPUT(o_result); )
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

		i_bump, i_bump_connected,
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,
		
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
	Architectural and mia_Material of Softimage 2010 and XSI 7
*/
void mia_material_phen(

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
	float				i_fg_quality;
	float				i_fg_quality_w;

	/* Ambient occlusion. */
	bool				i_ao_on;
	float				i_ao_samples;
	float				i_ao_distance;
	RGBA_COLOR(			i_ao_dark );
	RGBA_COLOR(			i_ao_ambient );
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

	string				i_bump_unknown;
	bool				i_no_diffuse_bump;
	float				i_bump_mode;
	point				i_overall_bump;
	point				i_standard_bump;

	RGBA_DECLARE_OUTPUT(o_result); )
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

#endif  // __mia_material_phen_sl
