/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sitoon_paint_and_host_sl
#define __sitoon_paint_and_host_sl

#include "sitoon_paint.sl"
#include "sitoon_host.sl"

void sitoon_paint_and_host(
	uniform bool i_ambience_enable;
	RGBA_DECLARE(i_ambience);
	float i_ambience_amount;
	uniform float i_ambience_mix_mode;
	uniform bool i_ambience_ambient_only;

	RGBA_DECLARE(i_surface);

	SITOON_COLOR_DECLARE(glossy);
 	SITOON_COLOR_DECLARE(diffuse);
	SITOON_INCIDENT_DECLARE(a);
	SITOON_INCIDENT_DECLARE(b);

	SITOON_HOST_DECLARE;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_DECLARE(paint);
	sitoon_paint(
		i_ambience_enable,
		RGBA_USE(i_ambience),
		i_ambience_amount,
		i_ambience_mix_mode,
		i_ambience_ambient_only,
		RGBA_USE(i_surface),
		SITOON_COLOR_USE(glossy),
		SITOON_COLOR_USE(diffuse),
		SITOON_INCIDENT_USE(a),
		SITOON_INCIDENT_USE(b),
		RGBA_USE(paint));
	sitoon_host(
		RGBA_USE(paint),
		SITOON_HOST_USE,
		RGBA_USE(o_result));
}

/*
	This version of sitoon_paint_and_host is called when there is
	no layer B.
*/
void sitoon_paint_and_host(
	uniform bool i_ambience_enable;
	RGBA_DECLARE(i_ambience);
	float i_ambience_amount;
	uniform float i_ambience_mix_mode;
	uniform bool i_ambience_ambient_only;

	RGBA_DECLARE(i_surface);

	SITOON_COLOR_DECLARE(glossy);
 	SITOON_COLOR_DECLARE(diffuse);
	SITOON_INCIDENT_DECLARE(a);
	
	uniform bool i_incident_b_enable;
	RGBA_DECLARE(i_incident_b_color);
	point i_incident_b_vec;
	
	SITOON_HOST_DECLARE;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_DECLARE(paint);
	sitoon_paint(
		i_ambience_enable,
		RGBA_USE(i_ambience),
		i_ambience_amount,
		i_ambience_mix_mode,
		i_ambience_ambient_only,
		RGBA_USE(i_surface),
		SITOON_COLOR_USE(glossy),
		SITOON_COLOR_USE(diffuse),
		SITOON_INCIDENT_USE(a),
		i_incident_b_enable,
		RGBA_USE(i_incident_b_color),
		i_incident_b_vec,
		RGBA_USE(paint));
	sitoon_host(
		RGBA_USE(paint),
		SITOON_HOST_USE,
		RGBA_USE(o_result));
}

/* Softimage 2013 */
void sitoon_paint_and_host(
		uniform bool i_ambience_enable;
		float i_ambience_amount;
		uniform float i_ambience_mix_mode;
		uniform bool i_ambience_ambient_only;

		RGBA_DECLARE(i_surface);

		SITOON_COLOR_DECLARE(glossy);
		SITOON_COLOR_DECLARE(diffuse);
		SITOON_INCIDENT_DECLARE(a);
		SITOON_INCIDENT_DECLARE(b);

		// SITOON_HOST_DECLARE
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
		// string i_blend_objects;
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
	string i_blend_objects = "";

	sitoon_paint_and_host(
			i_ambience_enable,
			color(1.0), 1.0,
			i_ambience_amount,
			i_ambience_mix_mode,
			i_ambience_ambient_only,

			RGBA_USE(i_surface),

			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),

			SITOON_HOST_USE,

			RGBA_USE(o_result) );
}


#endif
