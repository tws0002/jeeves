/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sitoon_host_sl
#define __sitoon_host_sl

#define bool float

#define SITOON_HOST_DECLARE \
	uniform bool i_bypass; \
	bool i_backcull; \
	float i_modify_spread; \
	float i_modify_detect_n_delta; \
	bool i_override_enable; \
	RGBA_DECLARE(i_override_color); \
	float i_override_mix_mode; \
	float i_detect_transparency_threshold; \
	uniform bool i_exterior; \
	uniform bool i_interior; \
	float i_blend_group; \
	string i_blend_objects; \
	float i_blend_z_delta; \
	float i_unblend_group; \
	bool i_refract_enable; \
	float i_refract_mode; \
	RGBA_DECLARE(i_refract_filter); \
	float i_refract_index; \
	bool i_refract_pri_enable; \
	float i_refract_pri_rgb; \
	float i_refract_pri_mode; \
	float i_refract_pri_alpha; \
	float i_refract_sec_enable; \
	float i_refract_sec_rgb; \
	float i_refract_sec_mode; \
	float i_refract_sec_alpha; \
	bool i_reflect_enable; \
	float i_reflect_mode; \
	RGBA_DECLARE(i_reflect_filter); \
	bool i_reflect_pri_enable; \
	float i_reflect_pri_rgb; \
	float i_reflect_pri_mode; \
	float i_reflect_pri_alpha; \
	bool i_reflect_sec_enable; \
	float i_reflect_sec_rgb; \
	float i_reflect_sec_mode; \
	float i_reflect_sec_alpha

#define SITOON_HOST_USE \
	i_bypass, \
	i_backcull, \
	i_modify_spread, \
	i_modify_detect_n_delta, \
	i_override_enable, \
	RGBA_USE(i_override_color), \
	i_override_mix_mode, \
	i_detect_transparency_threshold, \
	i_exterior, \
	i_interior, \
	i_blend_group, \
	i_blend_objects, \
	i_blend_z_delta, \
	i_unblend_group, \
	i_refract_enable, \
	i_refract_mode, \
	RGBA_USE(i_refract_filter), \
	i_refract_index, \
	i_refract_pri_enable, \
	i_refract_pri_rgb, \
	i_refract_pri_mode, \
	i_refract_pri_alpha, \
	i_refract_sec_enable, \
	i_refract_sec_rgb, \
	i_refract_sec_mode, \
	i_refract_sec_alpha, \
	i_reflect_enable, \
	i_reflect_mode, \
	RGBA_USE(i_reflect_filter), \
	i_reflect_pri_enable, \
	i_reflect_pri_rgb, \
	i_reflect_pri_mode, \
	i_reflect_pri_alpha, \
	i_reflect_sec_enable, \
	i_reflect_sec_rgb, \
	i_reflect_sec_mode, \
	i_reflect_sec_alpha


void sitoon_host(
	RGBA_DECLARE(i_surface);
	SITOON_HOST_DECLARE;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern varying normal N;
	extern varying point P;
	extern uniform color ObjectLabels;
	extern uniform float __faceID;
	extern varying normal __toonhost_N;
	extern varying float __toonhost_z;
	extern uniform color __toonhost_ObjectLabels;
	extern uniform float __toonhost_faceID;
	extern varying float __edgewidthscale;
	extern varying color __edgecolor;
	
	uniform bool enable = 1-i_bypass;

	__toonhost_N = N;
	__toonhost_z = zcomp(transform("camera", P));
	__toonhost_ObjectLabels = ObjectLabels;
	__toonhost_faceID = enable * i_interior * __faceID;

	if(enable * (i_exterior + i_interior))
	{
		__edgewidthscale = max(0.0001, __edgewidthscale * i_modify_spread);
		if(i_override_enable)
		{
			__edgecolor = i_override_color;
		}
	}
	else
	{
		__edgewidthscale = 0.0001;
		__edgecolor = color(0, 0, 0);
	}
	
	RGBA_ASSIGN(o_result, i_surface);
}

void sitoon_host(
	RGBA_DECLARE(i_surface);
	uniform bool i_bypass;
	bool i_backcull;
	float i_modify_spread;
	float i_modify_detect_n_delta;
	bool i_override_enable;
	RGBA_DECLARE(i_override_color);
	float i_override_mix_mode;
	float i_detect_transparency_threshold;
	uniform bool i_exterior;
	uniform bool i_interior;
	float i_blend_group;
	float i_blend_z_delta;
	float i_unblend_group;
	bool i_refract_enable;
	float i_refract_mode;
	RGBA_DECLARE(i_refract_filter);
	float i_refract_index;
	bool i_refract_pri_enable;
	float i_refract_pri_rgb;
	float i_refract_pri_mode;
	float i_refract_pri_alpha;
	float i_refract_sec_enable;
	float i_refract_sec_rgb;
	float i_refract_sec_mode;
	float i_refract_sec_alpha;
	bool i_reflect_enable;
	float i_reflect_mode;
	RGBA_DECLARE(i_reflect_filter);
	bool i_reflect_pri_enable;
	float i_reflect_pri_rgb;
	float i_reflect_pri_mode;
	float i_reflect_pri_alpha;
	bool i_reflect_sec_enable;
	float i_reflect_sec_rgb;
	float i_reflect_sec_mode;
	float i_reflect_sec_alpha;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	string i_blend_objects;
	sitoon_host(
		RGBA_USE(i_surface),
		SITOON_HOST_USE,
		RGBA_USE(o_result));
}

#endif
