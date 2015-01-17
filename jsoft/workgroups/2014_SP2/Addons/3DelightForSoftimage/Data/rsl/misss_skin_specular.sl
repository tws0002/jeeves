/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __misss_skin_specular_sl
#define __misss_skin_specular_sl

#include "xsi_constants.h"
#include "xsi_color.h"

#define SPECULARMULTIPLIER ( smoothstep(-0.1, 0.3, max(Ln . Nn, 0.0)) )

color misss_specular_trace_with_environment(
	point i_P;
	vector i_direction;
	float i_angle, i_samples;
	uniform float i_env_only;
	color i_weight; )
{
	RGBA_COLOR( env_color );
	color reflection = 0;
	
	uniform string envmap = "";
	option( "user:_3delight_reflection_envmap", envmap );

	float samplecone = clamp(i_angle, 0, 1);

	if( i_env_only == 0 )
	{
		reflection = trace( i_P, i_direction,
				"samplecone", samplecone,
				"samples", i_samples,
				"environmentmap", envmap,
				"environmentspace", "world",
				"weight", i_weight,
				"subset", "-xsi_InvisibleToReflectionRays");
	}
	else if( envmap != "" )
	{
		/* Trace environment only. Temporary solution: use
		 * trace() with "subset" "__tmp__shit__" */
		reflection = trace( i_P, i_direction,
				"samplecone", samplecone,
				"samples", i_samples,
				"environmentmap", envmap,
				"environmentspace", "world",
				"weight", i_weight,
				"subset", "__tmp__shit__");
	}

	return reflection;
}

color pow(color c; float exponent)
{
	return
		color( pow(c[0], exponent), pow(c[1], exponent), pow(c[2], exponent));
}

color misss_phong(
	normal  Nn;
	vector  V;
	float   shinyness)
{
	extern point P;

	vector R = reflect(-V, Nn);
	color C = 0.0;

	illuminance( "specular", P, Nn, PI )
	{
		float nonspec = 0;
		lightsource ("__nonspecular", nonspec);
		if (nonspec < 1)
		{
			vector Ln = normalize(L);
			C +=
				Cl *
				pow(max(R . Ln, 0.0), shinyness) *
				SPECULARMULTIPLIER *
				(1-nonspec);
		}
	}

	return C;
}

color misss_skin_specular_edge(
	normal  Nn;
	vector  V;
	float   edge_factor;
	float   shinyness)
{
	extern point P;

	float e = 1.0 + 0.5 * edge_factor + 0.1 * shinyness;
	vector R = reflect(-V, Nn);
	color C = 0.0;

	illuminance( "specular", P, Nn, PI )
	{
		float nonspec = 0;
		lightsource ("__nonspecular", nonspec);
		if (nonspec < 1)
		{
			vector Ln = normalize(L);
			C +=
				Cl *
				pow(max(R . Ln, 0.0), shinyness) *
				SPECULARMULTIPLIER *
				pow(1.0 - max(V . Nn, 0.0), e) *
				(1-nonspec);
		}
	}

	return C;
}

void misss_skin_specular(
	float   i_overall_weight;
	float   i_edge_factor;
	RGBA_DECLARE(i_primary_spec_color);
	float   i_primary_weight;
	float   i_primary_edge_weight;
	float   i_primary_shinyness;
	RGBA_DECLARE(i_secondary_spec_color);
	float   i_secondary_weight;
	float   i_secondary_edge_weight;
	float   i_secondary_shinyness;
	float   i_reflect_weight;
	float   i_reflect_edge_weight;
	float   i_reflect_shinyness;
	uniform bool i_reflect_environment_only;
	normal  i_normal_camera;
	float   i_mode; // unused
	string  i_lights; // unused

	output color o_result;
	output float o_result_a; )
{
	extern vector I;
	extern point P;

	normal Nn = normalize(i_normal_camera);
	normal Nf = ShadingNormal( Nn );
	vector V = normalize(-I);

	float Eps = 1.0e-4;
	float primary_shinyness = max(i_primary_shinyness, Eps);
	float secondary_shinyness = max(i_secondary_shinyness, Eps);

	color primary_spec =
		i_primary_weight
		* i_primary_spec_color
		* misss_phong(Nn, V, primary_shinyness);
	primary_spec +=
		i_primary_edge_weight
		* i_primary_spec_color
		* misss_skin_specular_edge(
				Nn, V,
				i_edge_factor,
				primary_shinyness);

	color secondary_spec =
		i_secondary_weight
		* i_secondary_spec_color
		* misss_phong(Nn, V, secondary_shinyness);
	secondary_spec +=
		i_secondary_edge_weight
		* i_secondary_spec_color
		* misss_skin_specular_edge(
				Nn, V,
				i_edge_factor,
				secondary_shinyness);

	vector reflection_dir = reflect(I, Nn);

	float angle = i_reflect_shinyness == 0.0
		? 0.0
		: 1.0 / (1.0 + i_reflect_shinyness);

	/* Mental ray traces only a couple of samples per ray. We try to increase
	   the total number of samples with greater sample cones. We keep ray count
	   in the [4 .. 32] range if shinyness != 0, 1 otherwise. */
	uniform float samples;
	if( angle == 0 )
		samples = 1;
	else if( angle <= 0.01 )
		samples = 4;
	else if( angle >= 0.3 )
		samples = 32;
	else
	{
		samples = (angle - 0.01) / (0.3 - 0.01);
		samples *= 32;
		if( samples < 4 )
			samples = 4;
	}

	color transmission = 1.0;
	color reflection_color = 0.0;
	color reflection_weight =
		i_reflect_weight +
		i_reflect_edge_weight * misss_skin_specular_edge(
				Nn, V,
				i_edge_factor,
				i_reflect_shinyness);

	if( reflection_weight != 0 )
	{
		reflection_color = misss_specular_trace_with_environment(
			P, reflection_dir, angle,
			samples, /* samples */
			i_reflect_environment_only, /* env only */
			reflection_weight );
	}

	color reflection = reflection_weight * reflection_color;

	o_result = primary_spec + secondary_spec + reflection;
	o_result *= i_overall_weight;
	o_result_a = 1.0;
	
	XSI_MATERIAL_SET_OUTPUT( Specular, o_result );
}

/* The 18 parameters version. */
void misss_skin_specular(
	float   i_overall_weight;
	float   i_edge_factor;
	RGBA_DECLARE(i_primary_spec_color);
	float   i_primary_weight;
	float   i_primary_edge_weight;
	float   i_primary_shinyness;
	RGBA_DECLARE(i_secondary_spec_color);
	float   i_secondary_weight;
	float   i_secondary_edge_weight;
	float   i_secondary_shinyness;
	float   i_reflect_weight;
	float   i_reflect_edge_weight;
	float   i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	output color o_result;
	output float o_result_a; )
{
	extern normal N;

	misss_skin_specular(
		i_overall_weight, i_edge_factor,
		RGBA_USE(i_primary_spec_color),
		i_primary_weight, i_primary_edge_weight, i_primary_shinyness,
		RGBA_USE(i_secondary_spec_color),
		i_secondary_weight, i_secondary_edge_weight, i_secondary_shinyness,
		i_reflect_weight, i_reflect_edge_weight, i_reflect_shinyness,
		i_reflect_environment_only,
		N,
		0, /* mode: unused */
		"", /* lights: unused */
		RGBA_USE(o_result) );
}

void misss_skin_specular(
	float	i_overall_weight;
	float	i_edge_factor;
	color	i_primary_spec_color;
	float	i_primary_weight;
	float	i_primary_edge_weight;
	float	i_primary_shinyness;
	color	i_secondary_spec_color;
	float	i_secondary_weight;
	float	i_secondary_edge_weight;
	float	i_secondary_shinyness;
	float	i_reflect_weight;
	float	i_reflect_edge_weight;
	float	i_reflect_shinyness;
	uniform bool i_reflect_environment_only;

	float	i_mode;

	RGBA_DECLARE_OUTPUT ( o_result ); )
{
	extern normal N;

	misss_skin_specular(
		i_overall_weight, i_edge_factor,
		i_primary_spec_color, 1,
		i_primary_weight, i_primary_edge_weight, i_primary_shinyness,
		i_secondary_spec_color, 1,
		i_secondary_weight, i_secondary_edge_weight, i_secondary_shinyness,
		i_reflect_weight, i_reflect_edge_weight, i_reflect_shinyness,
		i_reflect_environment_only,
		N,
		0, /* mode: unused */
		"", /* lights: unused */
		RGBA_USE(o_result) );
}

#endif  // !__misss_impl
