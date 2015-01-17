/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __BA_volume_cloud_sl
#define __BA_volume_cloud_sl

#define bool float
#define false 0
#define true 1

#define INTERPOLATION_NONE 0
#define INTERPOLATION_LINEAR 1
#define INTERPOLATION_CUBIC 2
#define INTERPOLATION_TRACE 3

void ComposeVolume(
	RGBA_DECLARE(i_color);
	output color io_color;
	output color io_opacity; )
{
	io_color = i_color + (1 - i_color_a) * io_color;
	io_opacity = color(i_color_a) + (1 - i_color_a) * io_opacity;
}

void BA_volume_cloud(
	RGBA_DECLARE(i_diffuse); // OK
	float i_density; // OK
	RGBA_DECLARE(i_ambience); // OK
	float i_MinSizeX; // OK
	float i_MaxSizeX; // OK
	float i_MinSizeY; // OK
	float i_MaxSizeY; // OK
	float i_MinSizeZ; // OK
	float i_MaxSizeZ; // OK
	float i_TilesX; // OK
	float i_TilesY; // OK
	float i_TilesZ; // OK
	float i_ParticleDensity; // OK
	float i_ParticleDensity_shadow; // OK
	float i_ParticleDensity_scatter;
	float i_shading_strength;
	float i_scatter_samplerate;
	RGBA_DECLARE(i_IntensitySunlight);
	RGBA_DECLARE(i_IntensityScatter);
	float i_free_MarchSizeRay;
	float i_free_MarchSizeShadow;
	float i_m_freeH;
	bool i_light_list_shadows;
	bool i_p_showcelldetail;
	bool i_half_boxtiles;
	float i_free_Grid_MultiSampling;
	float i_UseTexture_Min;
	float i_Switch_to_Grid_MarchAlpha;
	float i_ShadowSaturation;
	bool i_Enable_Illumination; // OK
	bool i_Enable_Scatter;
	float i_Shading_model;
	bool i_Use_normal;
	float i_Shadows_interior;
	float i_free_Shadows_exterior;
	bool i_Scatter_flat_shading;
	float i_shading_flat_mix;
	bool i_AutoBoundingBox; // unusable (should be considered when processing scene geometry)
	float i_TileSize; // OK
	float i_free_TileSizeY;
	float i_free_TileSizeZ;
	bool i_UseTileSize; // OK
	float i_Scatter_supress;
	bool i_OnlyMainLightNormal;
	bool i_p_fast_cell_shadows;
	RGBA_DECLARE(i_shadow_col_adjust);
	float i_UseTexture_Max;
	RGBA_DECLARE(i_fg_receive_color);
	bool i_FG_trans_fix;
	RGBA_DECLARE(i_absorption_color);
	bool i_absorption_inuse;
	bool i_absorption_inuse_shadows;
	float i_ParticleDensity_absorption;
	string i_main_light_dir;
	string i_lights;
	bool i_enable_specular;
	bool i_fg_receive;
	bool i_distort_enable;
	float i_contrast_ammount;
	float i_contrast_center;
	float i_free_normal_analyse_dist;
	float i_FreeA;
	float i_cell_interpolation; // OK
	float i_memory_limit; // unused
	RGBA_DECLARE(i_specular_color);
	RGBA_DECLARE(i_fg_cast_color);
	RGBA_DECLARE(i_distort_color);
	point free13;
	point free14;
	float i_spec_rim;
	float i_spec_decay;
	float i_max_motion;
	float i_free_FG_precalc;
	bool i_fg_use_input_normal;
	bool i_shadows_normal;
	bool i_preview_mode; // OK
	bool i_p_illum;
	bool i_p_spec;
	bool i_p_scatter;
	bool i_p_shading;
	float i_p_free_MarchSizeRay;
	float i_free_p_MarchSizeShadow;
	float i_free_p_MarchSizeFG;
	float i_free_p_MarchSizeFGprecalc;
	bool i_p_free_large_march;
	float i_march_threshold;
	float i_p_slice_density;
	float i_fg_back_side;
	float i_fg_col_intensity;
	float i_fg_illum_intensity;
	float i_fg_stored_points_intensity;
	float i_Grid_MultiSampling_light;
	float i_Grid_MultiSampling_FG;
	float i_march_subdivision;
	float i_p_slices_mode;
	float i_p_no_slices;
	float i_fb_distance; // unused
	float i_fb_illum; // unused
	float i_fb_spec; // unused
	float i_fb_scatter; // unused
	float i_fb_ambience; // unused
	float i_fb_fg; // unused
	float i_p_table_reduction;
	bool i_p_render_table;
	bool i_fg_cast;
	float i_distort_intensity;
	float i_distort_input_range;
	bool i_free_p_distort_view;
	bool i_fg_double_sided;
	float i_fb_motion; // unused
	float i_p_slices_input;
	bool i_simple_mode;
	float i_s_detail;
	float i_s_density;
	bool i_p_slice_trans_edge;
	float i_mblur_samples;
	float i_free_p_cell_interpolation;
	float i_fb_AO; // unused
	float i_fb_ambient2; // unused
	float i_fb_normal; // unused
	string fb_s_distance;
	string fb_s_illum;
	string fb_s_spec;
	string fb_s_scatter;
	string fb_s_ambience;
	string fb_s_fg;
	string fb_s_motion;
	string fb_s_AO;
	string fb_s_ambient2;
	string fb_s_normal;
	bool i_fb_enable_distance; // unusable (always false)
	bool i_fb_enable_illum; // unusable (always false)
	bool i_fb_enable_spec; // unusable (always false)
	bool i_fb_enable_scatter; // unusable (always false)
	bool i_fb_enable_ambience; // unusable (always false)
	bool i_fb_enable_fg; // unusable (always false)
	bool i_fb_enable_motion; // unusable (always false)
	bool i_fb_enable_AO; // unusable (always false)
	bool i_fb_enable_ambient2; // unusable (always false)
	bool i_fb_enable_normal; // unusable (always false)
	RGBA_DECLARE(i_AO_color);
	RGBA_DECLARE(i_ambient2);
	RGBA_DECLARE(i_fb_col_FreeC);
	bool i_fb_new_xsi_buffernames; // unused (ignored)
	bool i_fb_fbonly_illum; // unused (ignored)
	bool i_fb_fbonly_spec; // unused (ignored)
	bool i_fb_fbonly_scatter; // unused (ignored)
	bool i_fb_fbonly_ambience; // unused (ignored)
	bool i_fb_fbonly_fg; // unused (ignored)
	bool i_fb_fbonly_motion; // unused (ignored)
	bool i_fb_fbonly_AO; // unused (ignored)
	bool i_fbFreeB;
	bool i_fb_FreeC;
	float i_fb_distance_min;
	float i_fb_distance_max;
	bool i_AO_enable;
	float i_AO_intensity;
	float i_AO_maxdistance;
	float i_free_AO_bias;
	float i_ScatterDistance;
	bool i_preview_renderregion; // OK
	bool i_manual_BBox;
	bool i_BBox_camera_coord;
	bool i_p_AO;
	float i_ambience_intensity; // OK
	float i_diffuse_intensity; // OK
	float i_ParticleDensity_globalscale; // OK
	bool i_restrict_lights;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern vector I;
	extern point P;
	extern color Oi;

	o_result = o_result_a = 0;

	uniform string objectName;
	attribute("identifier:name", objectName);

	uniform string volumeSampler = concat(shadername(), "_sampler");
	uniform string lightSampler = "ice_volume_light";

	uniform float nbAttributes = 0;
	uniform vector cellSize = 0;
	if(VolumeTracer_GetParameters(
		objectName, 
		"nbattributes", nbAttributes, 
		"cellsize", cellSize) < 0)
	{
		uniform string volumeSampler = concat(shadername(), "_sampler");
		uniform string ptcFile;
		attribute("user:BA_ptcFileName", ptcFile);
		uniform vector bbox_size;
		attribute("user:bbox_size", bbox_size);
		uniform point bbox_center;
		attribute("user:bbox_center", bbox_center);
		uniform vector nbCells = 
			i_UseTileSize
			? bbox_size / vector(i_TileSize)
			: clamp(
				vector(i_TilesX, i_TilesY, i_TilesZ), 
				bbox_size/max(vector(i_MaxSizeX, i_MaxSizeY, i_MaxSizeZ), vector(0.0001)), 
				bbox_size/max(vector(i_MinSizeX, i_MinSizeY, i_MinSizeZ), vector(0.0001)));
		nbCells = vector(round(nbCells[0]), round(nbCells[1]), round(nbCells[2]));

		/* Add extra cells around the volume to ensure that its perimeter has zero density. */
		uniform vector newNbCells = nbCells + vector(2, 2, 2);
		bbox_size =
			vector(
				bbox_size[0] * newNbCells[0] / nbCells[0],
				bbox_size[1] * newNbCells[1] / nbCells[1],
				bbox_size[2] * newNbCells[2] / nbCells[2]);
		nbCells = newNbCells;

		uniform string pointCloudParam = concat(volumeSampler, ":BA_ptcFileName");
		if(i_Enable_Illumination == false)
		{
			nbAttributes = 
				VolumeTracer_InitGrid(
					objectName, 
					"grid:center", bbox_center, 
					"grid:size", bbox_size, 
					"grid:nbcells", nbCells, 
					"grid:shader", volumeSampler, 
					pointCloudParam, ptcFile);
		}
		else
		{
			nbAttributes = 
				VolumeTracer_InitGrid(
					objectName, 
					"grid:center", bbox_center, 
					"grid:size", bbox_size, 
					"grid:nbcells", nbCells, 
					"grid:shader", volumeSampler, 
					"grid:shader", lightSampler, 
					pointCloudParam, ptcFile);
		}

		cellSize = bbox_size / nbCells;
	}

	if(nbAttributes <= 0)
	{
		return;
	}

	uniform string rayType = "";
	uniform string shadowMap = "";
	rayinfo("type", rayType);
	option("user:__xsi_rendering_shadowmap", shadowMap);
	uniform bool shadowRay = (rayType == "transmission" || shadowMap != "") ? true : false;

	uniform string densityShader[1] = { volumeSampler };
	uniform string lightShader[1] = { lightSampler };

	uniform float illuminance_index = nbAttributes-3;

	float globalscale = i_ParticleDensity_globalscale / 100.0;
	float ParticleDensity = i_ParticleDensity * globalscale;
	float ParticleDensity_shadow = i_ParticleDensity_shadow * globalscale;
	float ParticleDensity_scatter = i_ParticleDensity_scatter * globalscale; // unused
	float ParticleDensity_absorption = i_ParticleDensity_absorption * globalscale; // unused

	float rayLength = length(I);
	float stepLength = min(cellSize[0], cellSize[1], cellSize[2]);
	float interpolationLevel = 
		i_preview_mode != false && i_preview_renderregion != false 
		? INTERPOLATION_NONE
		: i_cell_interpolation;

	uniform string interpolations[4] = { "nearest", "linear", "cubic", "exact" };
	uniform string interpolation = 
		interpolations[clamp(interpolationLevel, 0, arraylength(interpolations)-1)];

	point start = P-I;
	point end = P;
	float rayID =
		VolumeTracer_InitRay(
			objectName, 
			transform("object", start), 
			transform("object", end), 
			stepLength, 
			interpolation);

	RGBA_DECLARE_INIT0(vol_color);
	float previous_progress = 0.0;
	float progress = 0.0;
	float attributes[];
	resize(attributes, nbAttributes);
	while(vol_color_a < 1.0 && progress < 1.0)
	{
		extern uniform float BA_volume_cloud_density_index;
		extern uniform float BA_volume_cloud_diffuse_index;
		extern uniform float BA_volume_cloud_diffuse_intensity_index;
		extern uniform float BA_volume_cloud_ambience_index;
		extern uniform float BA_volume_cloud_ambience_intensity_index;

		if(BA_volume_cloud_density_index >= 0)
		{
			attributes[BA_volume_cloud_density_index] = 0.0;
		}

		float step;
		previous_progress = progress;
		progress = VolumeTracer_StepRay(rayID, step);
		VolumeTracer_EvaluateStep(rayID, attributes, densityShader);

		float density =
			BA_volume_cloud_density_index >= 0
			? attributes[BA_volume_cloud_density_index]
			: i_density;

		if(shadowRay)
		{
			float opacity = 1 - exp(- density * step * ParticleDensity_shadow);
			vol_color_a += opacity * (1-vol_color_a);
			vol_color = vol_color_a;
		}
		else
		{
			float opacity = 1 - exp(- density * step * ParticleDensity);

			if(opacity > 0.0)
			{
				color diffuse = color(0);
				if(i_Enable_Illumination != false)
				{
					float diffuseIntensity =
						BA_volume_cloud_diffuse_intensity_index >= 0
						? attributes[BA_volume_cloud_diffuse_intensity_index]
						: i_diffuse_intensity;
					diffuse = 
						BA_volume_cloud_diffuse_index >= 0
						? color(
							attributes[BA_volume_cloud_diffuse_index], 
							attributes[BA_volume_cloud_diffuse_index+1], 
							attributes[BA_volume_cloud_diffuse_index+2])
						: i_diffuse;
					diffuse *= diffuseIntensity;

					if(diffuse != color(0.0))
					{
						VolumeTracer_EvaluateStep(rayID, attributes, lightShader);

						color light =
							color(
								attributes[illuminance_index],
								attributes[illuminance_index+1],
								attributes[illuminance_index+2]);

						diffuse *= light;
					}
				}

				color ambience = 
					BA_volume_cloud_ambience_index >= 0
					? color(
						attributes[BA_volume_cloud_ambience_index], 
						attributes[BA_volume_cloud_ambience_index+1], 
						attributes[BA_volume_cloud_ambience_index+2])
					: i_ambience;
				float ambienceIntensity = 
					BA_volume_cloud_ambience_intensity_index >= 0
					? attributes[BA_volume_cloud_ambience_intensity_index]
					: i_ambience_intensity;
				ambience *= ambienceIntensity;

				color illumination = diffuse + ambience;
				vol_color += illumination * opacity * (1-vol_color_a);
				vol_color_a += opacity * (1-vol_color_a);

				outputvolumefragment(
						previous_progress,
						progress,
						"color", illumination * opacity,
						"opacity", opacity );
			}
		}
	}

	ComposeVolume(RGBA_USE(vol_color), o_result, Oi);
}

#endif
