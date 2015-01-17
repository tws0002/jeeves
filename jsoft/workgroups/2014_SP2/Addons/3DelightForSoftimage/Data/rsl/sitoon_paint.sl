
#ifndef __sitoon_paint_sl
#define __sitoon_paint_sl

#include "sitoon_utils.h"
#include "sitoon_paint_highlight.sl"

/* what layer */
#define paint_layer_DIFFUSE  1
#define	paint_layer_GLOSSY 2
#define paint_layer_INCIDENT_A 3
#define paint_layer_INCIDENT_B 4

/* precedence */
#define paint_order_UNDER  0
#define paint_order_OVER  1

#define bool float
#define SITOON_COLOR_DECLARE(name) \
	uniform bool i_##name##_enable; \
	RGBA_DECLARE(i_##name##_color); \
	float i_##name##_cover; \
	float i_##name##_softness; \
	uniform float i_##name##_mix_mode; \
	uniform bool i_##name##_use_illuminance

#define SITOON_INCIDENT_DECLARE_NO_DIR(x) \
	uniform bool i_incident_##x##_enable; \
	uniform float i_incident_##x##_order; \
	RGBA_DECLARE(i_incident_##x##_color); \
	float i_incident_##x##_cover; \
	float i_incident_##x##_softness; \
	uniform float i_incident_##x##_invert; \
	uniform float i_incident_##x##_mix_mode; \
	uniform float i_incident_##x##_vec_select; \
	uniform float i_incident_##x##_space_select
	
#define SITOON_INCIDENT_DECLARE(x) \
	SITOON_INCIDENT_DECLARE_NO_DIR(x); \
	point i_incident_##x##_vec

#define SITOON_COLOR_USE(name) \
	i_##name##_enable, \
	RGBA_USE(i_##name##_color), \
	i_##name##_cover, \
	i_##name##_softness, \
	i_##name##_mix_mode, \
	i_##name##_use_illuminance

#define SITOON_INCIDENT_USE_NO_DIR(x) \
	i_incident_##x##_enable, \
	i_incident_##x##_order, \
	RGBA_USE(i_incident_##x##_color), \
	i_incident_##x##_cover, \
	i_incident_##x##_softness, \
	i_incident_##x##_invert, \
	i_incident_##x##_mix_mode, \
	i_incident_##x##_vec_select, \
	i_incident_##x##_space_select

#define SITOON_INCIDENT_USE(x) \
	SITOON_INCIDENT_USE_NO_DIR(x), \
	i_incident_##x##_vec


float sitoon_paint_layer(
	RGBA_DECLARE_OUTPUT(o_result);
	SITOON_COLOR_DECLARE(glossy);
 	SITOON_COLOR_DECLARE(diffuse);
	SITOON_INCIDENT_DECLARE(a);
	SITOON_INCIDENT_DECLARE(b);
	float i_layer )
{
	float factor = 0;

	if( i_layer == paint_layer_DIFFUSE )
	{
		/* composite diffuse highlights (lambert) */
		RGBA_DECLARE( filter );
		color highlight = 0;
		float highlight_a = 0;
		RGBA_ASSIGN( filter, i_diffuse_color );
		if(sitoon_highlight(
			RGBA_USE(filter), 
			i_diffuse_cover, i_diffuse_softness,
			highlight_mode_DIFFUSE, i_diffuse_use_illuminance,
			RGBA_USE(highlight)) != 0 )
		{
			sitoon_color_mix(
				RGBA_USE( o_result ), 
				RGBA_USE( highlight ),
				RGBA_USE( o_result ),
				highlight_a * filter_a,
				i_diffuse_mix_mode );
		}
	}
	else if( i_layer == paint_layer_GLOSSY )
	{
		/* composite glossy highlights (phong) */
		RGBA_DECLARE( filter );
		color highlight = 0;
		float highlight_a = 0;
		RGBA_ASSIGN( filter, i_glossy_color );

		if( sitoon_highlight(
			RGBA_USE(filter),
			i_glossy_cover, i_glossy_softness,
			highlight_mode_GLOSSY, i_glossy_use_illuminance,
			RGBA_USE(highlight)) != 0 )
		{
			sitoon_color_mix(
				RGBA_USE(o_result), 
				RGBA_USE(highlight), 
				RGBA_USE(o_result), 
				highlight_a * filter_a, i_glossy_mix_mode);
		}
	}
	else if( i_layer == paint_layer_INCIDENT_A )
	{
		/* composite incident illumination "a" */
		vector dir = vector( i_incident_a_vec );
		sitoon_which_dir(
			i_incident_a_vec_select, i_incident_a_space_select, dir );

		float factor = sitoon_incidence_vector(
			sqrt(1-i_incident_a_cover),
			i_incident_a_softness, dir, i_incident_a_invert);

		if( factor != 0 )
		{
			sitoon_color_mix(
				RGBA_USE(o_result), 
				RGBA_USE(i_incident_a_color), 
				RGBA_USE(o_result), 
				i_incident_a_color_a * factor,
				i_incident_a_mix_mode );
		}
	}
	else if( i_layer == paint_layer_INCIDENT_B )
	{
		/* composite incident illumination "b" */
		vector dir = vector(i_incident_b_vec);
		sitoon_which_dir(
			i_incident_b_vec_select, i_incident_b_space_select, dir );

		float factor = sitoon_incidence_vector(
			sqrt(1-i_incident_b_cover),
			i_incident_b_softness, dir, i_incident_b_invert);

		if( factor != 0 )
		{
			sitoon_color_mix(
				RGBA_USE(o_result), 
				RGBA_USE(i_incident_b_color), 
				RGBA_USE(o_result), 
				i_incident_b_color_a * factor,
				i_incident_b_mix_mode );
		}
	}
	else
		factor = 0;

	/* 1=altered color, 0 = no change */
	return factor != 0 ? 1 : 0;
}

void sitoon_paint(
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

	RGBA_DECLARE_OUTPUT(o_result); )
{
	RGBA_ASSIGN( o_result, i_surface );

	if( i_ambience_enable != 0 )
	{
		float amount = i_ambience_amount;
		if( i_ambience_ambient_only )
			amount *= sitoon_ambient();
		
		if( amount != 0 )
		{
			sitoon_color_mix(
				RGBA_USE(o_result),
				RGBA_USE(i_ambience),
				RGBA_USE(o_result),
				amount, i_ambience_mix_mode );
		}
	}

	if( i_incident_a_enable!=0 && i_incident_a_order == paint_order_UNDER ) 
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_INCIDENT_A );
	}

	if( i_incident_b_enable!=0 && i_incident_b_order == paint_order_UNDER ) 
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_INCIDENT_B );
	}

	/* Diffuse and glossy */
	if( i_diffuse_enable != 0 )
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_DIFFUSE );
	}
	if( i_glossy_enable != 0 )
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_GLOSSY );
	}

	if( i_incident_a_enable!=0 && i_incident_a_order == paint_order_OVER ) 
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_INCIDENT_A );
	}

	if( i_incident_b_enable!=0 && i_incident_b_order == paint_order_OVER ) 
	{
		sitoon_paint_layer(
			RGBA_USE(o_result),
			SITOON_COLOR_USE(glossy),
			SITOON_COLOR_USE(diffuse),
			SITOON_INCIDENT_USE(a),
			SITOON_INCIDENT_USE(b),
			paint_layer_INCIDENT_B );
	}
}

/* Softimage 2012 */
void sitoon_paint(
	uniform bool i_ambience_enable;
	float i_ambience_amount;
	uniform float i_ambience_mix_mode;
	uniform bool i_ambience_ambient_only;

	RGBA_DECLARE(i_surface);

	SITOON_COLOR_DECLARE(glossy);
 	SITOON_COLOR_DECLARE(diffuse);
	SITOON_INCIDENT_DECLARE(a);
	SITOON_INCIDENT_DECLARE(b);

	RGBA_DECLARE_OUTPUT(o_result); )
{
	sitoon_paint(
		i_ambience_enable,
		color(0, 0, 0), 1,
		i_ambience_amount,
		i_ambience_mix_mode,
		i_ambience_ambient_only,
		RGBA_USE(i_surface),
		SITOON_COLOR_USE(glossy),
		SITOON_COLOR_USE(diffuse),
		SITOON_INCIDENT_USE(a),
		SITOON_INCIDENT_USE(b),
		RGBA_USE(o_result));
}

/*
	This version of sitoon_paint is called when there is
	no layer B in Softimage 2012.
*/
void sitoon_paint(
	uniform bool i_ambience_enable;
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

	RGBA_DECLARE_OUTPUT(o_result); )
{
	uniform float i_incident_b_order = 0;
	uniform float i_incident_b_softness = 0;
	uniform float i_incident_b_cover = 0;	
	uniform float i_incident_b_invert = false;	
	uniform float i_incident_b_mix_mode = 0;	
	uniform float i_incident_b_vec_select = 0;	
	uniform float i_incident_b_space_select = 0;
	
	/* Call Softimage 2012 version */
	sitoon_paint(
		i_ambience_enable,
		i_ambience_amount,
		i_ambience_mix_mode,
		i_ambience_ambient_only,
		RGBA_USE(i_surface),
		SITOON_COLOR_USE(glossy),
		SITOON_COLOR_USE(diffuse),
		SITOON_INCIDENT_USE(a),
		SITOON_INCIDENT_USE(b),
		RGBA_USE(o_result));
}

/*
	This version of sitoon_paint is called when there is
	no layer B.
*/
void sitoon_paint(
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

	RGBA_DECLARE_OUTPUT(o_result); )
{
	uniform float i_incident_b_order = 0;
	uniform float i_incident_b_softness = 0;
	uniform float i_incident_b_cover = 0;	
	uniform float i_incident_b_invert = false;	
	uniform float i_incident_b_mix_mode = 0;	
	uniform float i_incident_b_vec_select = 0;	
	uniform float i_incident_b_space_select = 0;	

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
		RGBA_USE(o_result));
}

void sitoon_paint(
	uniform bool i_ambience_enable;
	float i_ambience_amount;
	uniform float i_ambience_mix_mode;
	uniform bool i_ambience_ambient_only;

	RGBA_DECLARE(i_surface);

	SITOON_COLOR_DECLARE(glossy);
 	SITOON_COLOR_DECLARE(diffuse);
	SITOON_INCIDENT_DECLARE_NO_DIR(a);

	uniform bool i_incident_b_enable;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	sitoon_paint(
		i_ambience_enable,
		color(0, 0, 0), 1,
		i_ambience_amount,
		i_ambience_mix_mode,
		i_ambience_ambient_only,
		RGBA_USE(i_surface),
		SITOON_COLOR_USE(glossy),
		SITOON_COLOR_USE(diffuse),
		SITOON_INCIDENT_USE_NO_DIR(a),
		point(0, 0, 0),
		i_incident_b_enable,
		color(0, 0, 0), 0,
		point(0, 0, 0),
		RGBA_USE(o_result));
}

#endif
