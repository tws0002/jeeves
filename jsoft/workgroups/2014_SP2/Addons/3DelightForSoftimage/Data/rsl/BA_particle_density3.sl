/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __BA_particle_density3_sl
#define __BA_particle_density3_sl

#include "BA_utils.sl"

#define FALLOFF_BY_SIZE_KEEP 0
#define FALLOFF_BY_SIZE_FADE 1

#define FALLOFF_TYPE_LINEAR 0
#define FALLOFF_TYPE_CUBIC 1

#define DENSITY_CHANNEL_ALPHA 0
#define DENSITY_CHANNEL_GREEN 1

void BA_particle_density3(
	output float o_density;
	RGBA_DECLARE_OUTPUT(o_color);
	output float o_age_perc;
	float i_falloff_start;
	float i_elliptical_shape; // unused
	float i_falloff_type;
	float i_falloff_bias;
	bool i_use_input_density_shape;
	bool i_use_particle_color;
	RGBA_DECLARE(i_particle_color);
	bool i_ref_convert; // unused
	bool i_scale_texture_coords; // unused
	bool i_rotate_texture_coords; // unused
	float i_density_texture;
	bool i_use_input_density_texture;
	float i_elliptical; // unused
	float i_metaball_shape;
	float i_density_shape;
	bool i_trans_by_size;
	bool i_pt_size_neighbour; // unused
	bool i_use_bubble;
	float i_motion_blur_samples; // unused
	float pt_adjustsize_mult; // unused
	float i_trans_by_size_min;
	bool i_motion_blur_fake; // unused
	bool i_motion_blur_curved; // unused
	bool i_unique_texture_coords; // unused
	bool i_flow_texture; // unused
	bool i_enable_global_gradient_color;
	float i_motion_blur_length; // unused
	float i_flow_texture_scl; // unused
	float i_roll_min; // unused
	float i_roll_max; // unused
	float i_trans_by_size_type;
	float i_rotation_type; // unused
	float i_flow_mode; // unused
	RGBA_DECLARE(i_flow_texture_col); // unused
	RGBA_DECLARE(i_global_gradient_color);
	point i_rot_point_dir; // unused
	float i_screw_min; // unused
	float i_screw_max; // unused
	float i_rot_cloud_dist; // unused
	bool i_inst_inuse; // unused
	string i_inst_source; // unused
	float i_intensity_global_gradient_color;
	float i_intensity_global_gradient_density;
	bool i_use_particle;
	float i_density_shape_intensity;
	float i_density_texture_intensity;
	float i_limit_density;
	float i_global_gradient_density_channel;
	RGBA_DECLARE(i_global_gradient_density);
	float i_strand_scaledown_max; // unused
	float i_strand_densitydown_max; // unused
	float i_strand_head_density; // unused
	float i_strand_head_size; // unused
	float i_strand_tail_density; // unused
	float i_strand_tail_size; ) // unused
{
	extern uniform string BA_ptcFileName;
	extern point P;

	uniform float maxNeighbors = 1000;

	o_color = 0;
	o_age_perc = 0;
	o_density = 0;

	uniform string category = concat("pointcloud:", BA_ptcFileName);
	point samplePosition = P;
	point neighborPosition = 0;
	float neighborSize = 0;
	color neighborColor = 0;
	float neighborAgePercent = 0;
	float neighborAlpha = 0;
	float neighborVelocity = 0;
	float neighborID = 0;
	float xyz[9] = {0};

	extern point P;
	point P_backup = P;

	float totalAlpha = 0.0;
	float nbNeighbors = 0;
	gather(
		category, samplePosition, vector(0), 0, maxNeighbors,
		"radius", 0.0,
		"point:a", neighborAlpha)
	{
		totalAlpha += neighborAlpha;
		nbNeighbors += 1;
	}

	if(nbNeighbors == 0)
	{
		return;
	}

	float totalFalloff = 0.0;
	color gradientColor = 0.0;
	float gradientDensity = 0.0;
	gather(
		category, samplePosition, vector(0), 0, maxNeighbors,
		"radius", 0.0,
		"point:position", neighborPosition,
		"point:size", neighborSize,
		"point:rgb", neighborColor,
		"point:age_percent", neighborAgePercent,
		"point:a", neighborAlpha,
		"point:velocity", neighborVelocity,
		"point:ID", neighborID,
		"point:xyz", xyz)
	{
		vector localX = vector(xyz[0], xyz[1], xyz[2]);
		vector localY = vector(xyz[3], xyz[4], xyz[5]);
		vector localZ = vector(xyz[6], xyz[7], xyz[8]);
		vector delta = samplePosition - neighborPosition;
		point localPosition = point(delta.localX, delta.localY, delta.localZ) / neighborSize;

		/*
			Transform P so that subsequent calls to transform work well. For
			example, transform("current", "object", P) will return the value of
			localPosition, which is what we want.
		*/
		P = transform("object", "current", localPosition);

		// Allow the particle to override some parameters
		float density_texture = i_density_texture;
		float density_texture_intensity = i_density_texture_intensity;
		float density_shape = i_density_shape;
		float density_shape_intensity = i_density_shape_intensity;
		RGBA_DECLARE_INIT1(particle_color, i_particle_color);
		bool use_particle_color = i_use_particle_color;
		bool use_particle = i_use_particle;
		RGBA_DECLARE_INIT1(global_gradient_color, i_global_gradient_color);
		RGBA_DECLARE_INIT1(global_gradient_density, i_global_gradient_density);
		Particle_Shading(
			/* Inputs */
			totalAlpha,
			neighborSize,
			neighborAgePercent,
			neighborAlpha, // density (alpha)
			neighborAlpha, // density_after_falloff
			neighborVelocity,
			neighborID,
			/* Overridable inputs */
			density_texture, 
			density_texture_intensity, 
			density_shape, 
			density_shape_intensity, 
			RGBA_USE(particle_color), 
			use_particle_color, 
			use_particle,
			RGBA_USE(global_gradient_color),
			RGBA_USE(global_gradient_density));

		if(use_particle)
		{
			RGBA_DECLARE_INIT0(C);
			C = use_particle_color ? particle_color : neighborColor;
			C_a = neighborAlpha;

			if(i_trans_by_size)
			{
				float trans_by_size_min = i_trans_by_size_min/2.0;
				if(neighborSize > trans_by_size_min)
				{
					float scale = neighborSize / trans_by_size_min;
					if(i_trans_by_size_type == FALLOFF_BY_SIZE_FADE)
					{
						scale *= neighborSize;
					}
					C_a /= scale;
				}
			}

			float falloff = 1.0;

			float distanceFromCenter = length(vector(localPosition));
			float falloff_start = i_use_bubble ? i_falloff_start : 0.0;
			if(distanceFromCenter > falloff_start)
			{
				float falloffRatio =
					(distanceFromCenter - falloff_start) / (1.0 - falloff_start);
				falloffRatio *= falloffRatio;

				if(i_falloff_type == FALLOFF_TYPE_LINEAR)
				{
					falloff = 1 - falloffRatio;
				}
				else
				{
					float falloffRatio2 = falloffRatio*falloffRatio;
					falloff = -4/9*falloffRatio2*falloffRatio + 17/9*falloffRatio2 - 22/9*falloffRatio + 1.0;
				}
			}

			if(i_use_bubble)
			{
				falloff = 1 - abs(2*falloff-1);
			}

			falloff = BA_bias(falloff, i_falloff_bias);

			C_a *= falloff;

			if(i_use_input_density_texture)
			{
				C_a *= mix(1.0, density_texture, density_texture_intensity);
			}

			if(i_use_input_density_shape)
			{
				float shape = (1.0-density_shape) * density_shape_intensity;
				C_a = max(C_a - shape * neighborAlpha, 0.0);
				if(falloff > shape)
				{
					falloff -= shape;
				}
			}

			if(neighborAlpha < 0.025)
			{
				totalFalloff += falloff * neighborAlpha * 40;
			}
			else if(neighborAgePercent > 0.9)
			{
				totalFalloff += falloff * (1.05 - neighborAgePercent) / 0.15;
			}
			else
			{
				totalFalloff += falloff;
			}

			if(i_enable_global_gradient_color)
			{
				float global_gradient_density_scalar = 1.0;
				if(i_global_gradient_density_channel == DENSITY_CHANNEL_ALPHA)
				{
					global_gradient_density_scalar = global_gradient_density_a;
				}
				else if(i_global_gradient_density_channel == DENSITY_CHANNEL_GREEN)
				{
					global_gradient_density_scalar = global_gradient_density[1];
				}
				gradientColor += global_gradient_color * C_a;
				gradientDensity += global_gradient_density_scalar * C_a;
			}

			o_color += C * C_a;
			o_age_perc += neighborAgePercent * C_a;
			o_density += C_a;
		}
	}

	P = P_backup;

	if(o_density > 0.0)
	{
		o_color /= o_density;
		o_age_perc /= o_density;

		gradientColor /= o_density;
		gradientDensity /= o_density;

		o_density = max(o_density - i_metaball_shape, 0);

		if(i_enable_global_gradient_color)
		{
			o_color = mix(o_color, gradientColor, i_intensity_global_gradient_color);
			o_density *= mix(1, gradientDensity, i_intensity_global_gradient_density);
		}

		if(totalFalloff > i_limit_density)
		{
			o_density =
				o_density / totalFalloff * i_limit_density +
				o_density * (1.0 - i_limit_density/totalFalloff) * 0.05;
		}
	}
}

void BA_particle_density3(
	float i_falloff_start;
	float i_elliptical_shape;
	float i_falloff_type;
	float i_falloff_bias;
	bool i_use_input_density_shape;
	bool i_use_particle_color;
	RGBA_DECLARE(i_particle_color);
	bool i_ref_convert;
	bool i_scale_texture_coords;
	bool i_rotate_texture_coords;
	float i_density_texture;
	bool i_use_input_density_texture;
	float i_elliptical;
	float i_metaball_shape;
	float i_density_shape;
	bool i_trans_by_size;
	bool i_pt_size_neighbour;
	bool i_use_bubble;
	float i_motion_blur_samples;
	float pt_adjustsize_mult;
	float i_trans_by_size_min;
	bool i_motion_blur_fake;
	bool i_motion_blur_curved;
	bool i_unique_texture_coords;
	bool i_flow_texture;
	bool i_enable_global_gradient_color;
	float i_motion_blur_length;
	float i_flow_texture_scl;
	float i_roll_min;
	float i_roll_max;
	float i_trans_by_size_type;
	float i_rotation_type;
	float i_flow_mode;
	RGBA_DECLARE(i_flow_texture_col);
	RGBA_DECLARE(i_global_gradient_color);
	point i_rot_point_dir;
	float i_screw_min;
	float i_screw_max;
	float i_rot_cloud_dist;
	bool i_inst_inuse;
	string i_inst_source;
	float i_intensity_global_gradient_color;
	float i_intensity_global_gradient_density;
	bool i_use_particle;
	float i_density_shape_intensity;
	float i_density_texture_intensity;
	float i_limit_density;
	float i_global_gradient_density_channel;
	RGBA_DECLARE(i_global_gradient_density);
	float i_strand_scaledown_max;
	float i_strand_densitydown_max;
	float i_strand_head_density;
	float i_strand_head_size;
	float i_strand_tail_density;
	float i_strand_tail_size;
	output float o_density;
	RGBA_DECLARE_OUTPUT(o_color);
	output float o_age_perc; )
{
	BA_particle_density3(
		o_density,
		RGBA_USE(o_color),
		o_age_perc,
		i_falloff_start,
		i_elliptical_shape,
		i_falloff_type,
		i_falloff_bias,
		i_use_input_density_shape,
		i_use_particle_color,
		RGBA_USE(i_particle_color),
		i_ref_convert,
		i_scale_texture_coords,
		i_rotate_texture_coords,
		i_density_texture,
		i_use_input_density_texture,
		i_elliptical,
		i_metaball_shape,
		i_density_shape,
		i_trans_by_size,
		i_pt_size_neighbour,
		i_use_bubble,
		i_motion_blur_samples,
		pt_adjustsize_mult,
		i_trans_by_size_min,
		i_motion_blur_fake,
		i_motion_blur_curved,
		i_unique_texture_coords,
		i_flow_texture,
		i_enable_global_gradient_color,
		i_motion_blur_length,
		i_flow_texture_scl,
		i_roll_min,
		i_roll_max,
		i_trans_by_size_type,
		i_rotation_type,
		i_flow_mode,
		RGBA_USE(i_flow_texture_col),
		RGBA_USE(i_global_gradient_color),
		i_rot_point_dir,
		i_screw_min,
		i_screw_max,
		i_rot_cloud_dist,
		i_inst_inuse,
		i_inst_source,
		i_intensity_global_gradient_color,
		i_intensity_global_gradient_density,
		i_use_particle,
		i_density_shape_intensity,
		i_density_texture_intensity,
		i_limit_density,
		i_global_gradient_density_channel,
		RGBA_USE(i_global_gradient_density),
		i_strand_scaledown_max,
		i_strand_densitydown_max,
		i_strand_head_density,
		i_strand_head_size,
		i_strand_tail_density,
		i_strand_tail_size);
}

#endif
