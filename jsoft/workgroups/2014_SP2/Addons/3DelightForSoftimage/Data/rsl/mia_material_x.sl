/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __mia_material_x_sl
#define __mia_material_x_sl

#include "mia_material.sl"

/*
	mia_material_x of Softimage 2011
*/
void mia_material_x(

	// Diffuse reflection parameters.
	float		i_diffuse_weight;
	color		i_diffuse;
	float		i_diffuse_roughness;

	// Reflection parameters.
	float		i_reflectivity;
	color		i_refl_color;
	float		i_refl_gloss;
	float		i_refl_gloss_samples;
	bool		i_refl_interpolate;
	bool		i_refl_hl_only;
	bool		i_refl_is_metal;

	// Transparency/refraction parameters.
	float		i_tranparency;
	color		i_refr_color;
	float		i_refr_gloss;
	float		i_refr_ior;
	float		i_refr_gloss_samples; 
	bool		i_refr_interpolate;
	bool		i_refr_translucency;
	color		i_refr_trans_color;
	float		i_refr_trans_weight;
	float		i_anisotropy;
	float		i_anisotropy_rotation;
	float		i_anisotropy_channel;

	// BRDF parameters.
	bool		i_brdf_fresnel;
	float		i_brdf_0_degree_refl;
	float		i_brdf_90_degree_refl;
	float		i_brdf_curve;
	bool		i_brdf_conserve_energy;

	// Interpolation parameters. Not used.
	float		i_intr_grid_density;
	float		i_intr_refl_samples;
	bool		i_intr_refl_ddist_on;
	float		i_intr_refl_ddist;
	float		i_intr_refr_samples;

	// Reflection
	bool		i_single_env_sample;
	bool		i_refl_falloff_on;
	float		i_refl_falloff_dist;
	bool		i_refl_falloff_color_on;
	color		i_refl_falloff_color;
	float		i_refl_depth;
	float		i_refl_cutoff;

	// Refraction
	bool		i_refr_falloff_on;
	float		i_refr_falloff_dist;
	bool		i_refr_falloff_color_on;
	color		i_refr_falloff_color;
	float		i_refr_depth;
	float		i_refr_cutoff;

	float		i_indirect_multiplier;
	float		i_fg_quality;
	float		i_fg_quality_w;

	// Ambient occlusion.
	bool		i_ao_on;
	float		i_ao_samples;
	float		i_ao_distance;
	color		i_ao_dark;
	color		i_ao_ambient;
	float		i_ao_do_details;                // ignore

	// Additional flags
	bool		i_thin_walled;
	bool		i_no_visible_area_hl;           // ignore but easily done through message passing
	bool		i_skip_inside_refl;
	bool		i_do_refractive_caustics;       // ignore
	bool		i_backface_cull;                // ignore
	bool		i_propagate_alpha;

	float		i_hl_vs_refl_balance;
	float		i_cutout_opacity;
	RGBA_COLOR( i_additional_color );

	color		i_bump; bool i_bump_connected;
	bool		i_no_diffuse_bump;
	float		i_mode;
	float		i_bump_mode;
	point		i_overall_bump;
	point		i_standard_bump;

	bool		i_multiple_outputs;

	float		i_refl_base;
	color		i_refl_base_color;
	float		i_refl_base_gloss;
	float		i_refl_base_gloss_samples;
	point		i_refl_base_bump;


	RGBA_DECLARE(o_result); 
	RGBA_DECLARE(o_diffuse_result);
	RGBA_DECLARE(o_diffuse_raw);
	RGBA_DECLARE(o_diffuse_level);
	RGBA_DECLARE(o_spec_result);
	RGBA_DECLARE(o_spec_raw);
	RGBA_DECLARE(o_spec_level);
	RGBA_DECLARE(o_refl_result);
	RGBA_DECLARE(o_refl_raw);
	RGBA_DECLARE(o_refl_level);
	RGBA_DECLARE(o_refr_result);
	RGBA_DECLARE(o_refr_raw);
	RGBA_DECLARE(o_refr_level);
	RGBA_DECLARE(o_tran_result);
	RGBA_DECLARE(o_tran_raw);
	RGBA_DECLARE(o_tran_level);
	RGBA_DECLARE(o_indirect_result);
	RGBA_DECLARE(o_indirect_raw);
	RGBA_DECLARE(o_indirect_post_ao);
	RGBA_DECLARE(o_ao_raw);
	RGBA_DECLARE(o_add_result);
	RGBA_DECLARE(o_opacity_result);
	RGBA_DECLARE(o_opacity_raw);
	float o_opacity; )
{
	mia_material(
		i_diffuse_weight,
		i_diffuse, 1,
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

		i_bump, i_bump_connected,
		i_no_diffuse_bump,
		i_bump_mode,
		i_overall_bump,
		i_standard_bump,
		
		i_multiple_outputs,
		
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


#endif /* __mia_material_x_sl */
