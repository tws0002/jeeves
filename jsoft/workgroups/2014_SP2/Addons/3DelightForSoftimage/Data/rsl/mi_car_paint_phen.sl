#ifndef __mi_car_paint_phen_h
#define __mi_car_paint_phen_h

#include "mi_metallic_paint.sl"
#include "mi_bump_flakes.sl"

#define cpow(c, n) color(pow(c[0],n),pow(c[1],n),pow(c[2],n))

color TraceWithEnvironment(
	point i_P;
	vector i_direction;
	float i_angle, i_samples;
   	uniform float i_maxdist;
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
				"maxdist", i_maxdist,
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
				"maxdist", i_maxdist,
				"samples", i_samples,
				"environmentmap", envmap,
				"environmentspace", "world",
				"weight", i_weight,
				"subset", "__tmp__shit__");
	}

	return reflection;
}

void mi_car_paint_phen(
	RGBA_COLOR(i_ambient);
	RGBA_COLOR( i_base_color );
	RGBA_COLOR( i_edge_color );
	float i_edge_color_bias;
	RGBA_COLOR( i_lit_color );
	float i_lit_color_bias;
	float i_diffuse_weight;
	float i_diffuse_bias;
	float i_irradiance_weight;

	RGBA_COLOR( i_spec );
	float i_spec_weight;
	float i_spec_exp;
	RGBA_COLOR( i_spec_sec );
	float i_spec_sec_weight;
	float i_spec_sec_exp;
	uniform bool i_spec_glazing;

	RGBA_COLOR( i_flake_color );
	float i_flake_weight;
	float i_flake_reflect;
	float i_flake_exp;
	float i_flake_density;
	float i_flake_decay;
	float i_flake_strength;
	float i_flake_scale;

	RGBA_COLOR( i_reflection_color );
	float i_edge_factor;
	float i_reflection_edge_weight;
	float i_reflection_base_weight;
	uniform float i_samples;
	uniform float i_glossy_spread;
	uniform float i_max_distance;
	uniform bool i_single_env_sample;

	RGBA_COLOR( i_dirt_color );
	float i_dirt_weight;

	float i_global_weight;

	output color o_result;
	output float o_result_a; )
{
	color my_contrast(color a; float b)
	{
		color buf = a-0.5;
		buf *= b;
		buf += 0.5;
		return clamp(buf, color(0.0), color(1.0));
	}

	extern vector I;
	extern point P;
	extern normal N;
	vector In = normalize(I);
	vector V = -In;
	normal Nn = normalize(N);
	normal Ns = ShadingNormal( Nn );

	RGBA_DECLARE( metallic_comp );

	mi_metallic_paint(
		RGBA_USE(i_ambient),
		RGBA_USE(i_base_color),
		RGBA_USE(i_edge_color),
		i_edge_color_bias,
		RGBA_USE(i_lit_color),
		i_lit_color_bias,
		i_diffuse_weight,
		i_diffuse_bias,
		1.0,
		RGBA_USE(i_spec),
		i_spec_weight,
		i_spec_exp,
		RGBA_USE(i_spec_sec),
		i_spec_sec_weight,
		i_spec_sec_exp,
		i_spec_glazing,
		color 0, 0, /* flake color */
		0.0,
		0.0,
		0.0,
		0.0,
		1.0,
		color 0, 0, /* flake bump */
		"a",
		RGBA_USE(metallic_comp) );

	// But this shader have not anisotropy, there is ability to make it faster
	vector R = reflect(I, Nn);
	float base_edge_mix = pow(-(Nn.In), 1/i_edge_factor);
	base_edge_mix = mix(i_reflection_edge_weight, i_reflection_base_weight, base_edge_mix);
	color reflection_comp = 0;

	if( base_edge_mix != 0 )
	{
		reflection_comp =
			base_edge_mix *
			TraceWithEnvironment(
				P, R,
				i_glossy_spread,
				i_samples,
				i_max_distance,
				0,
				base_edge_mix);
	}

	color cFlakes;
	normal nFlakes;
	float decay = length(I);

	if(i_flake_decay > 0)
	{
		decay = 1 - decay/i_flake_decay;
		decay = clamp(decay, 0, 1);
		decay = pow(decay, 0.75);
	}
	else
		decay = 1;

	mi_bump_flakes_with_normal(
		i_flake_density, i_flake_strength, i_flake_scale,
		nFlakes, cFlakes );

	cFlakes = my_contrast(cFlakes, 1.5);
	color flake_spec_comp = cFlakes * i_flake_color	* phong(nFlakes, V, i_flake_exp/5) *
		i_flake_weight * decay;
	color flake_refl_comp = cFlakes * i_flake_color * i_flake_weight * i_flake_reflect * decay;
	if(flake_refl_comp != color(0.0))
		flake_refl_comp *= trace(P, reflect(In, nFlakes));

	XSI_MATERIAL_ADD_OUTPUT( Reflection, flake_refl_comp + reflection_comp);
	XSI_MATERIAL_ADD_OUTPUT( Specular, flake_spec_comp );

	color dirt = diffuse(Ns) * 0.9 * i_dirt_color + 0.1;

	o_result = metallic_comp + flake_spec_comp + flake_refl_comp + reflection_comp;
	o_result *= i_global_weight;
	o_result = mix(o_result, dirt, i_dirt_weight);
}

void mi_car_paint_phen(
	color i_ambient;
	color i_base_color;
	color i_edge_color;
	float i_edge_color_bias;
	color i_lit_color;
	float i_lit_color_bias;
	float i_diffuse_weight;
	float i_diffuse_bias;
	
	color i_flake_color;
	float i_flake_weight;
	float i_flake_reflect;
	float i_flake_exp;
	float i_flake_density;
	float i_flake_decay;
	float i_flake_strength;
	float i_flake_scale;

	color i_spec;
	float i_spec_weight;
	float i_spec_exp;
	color i_spec_sec;
	float i_spec_sec_weight;
	float i_spec_sec_exp;
	uniform bool i_spec_glazing;

	color i_reflection_color;
	float i_edge_factor;
	float i_reflection_edge_weight;
	float i_reflection_base_weight;
	uniform float i_samples;
	uniform float i_glossy_spread;
	uniform float i_max_distance;
	uniform bool i_single_env_sample;

	color i_dirt_color;
	float i_dirt_weight;

	float i_irradiance_weight;
	float i_global_weight;
	float i_mode;

	output color o_result;
	output float o_result_a; )
{
	mi_car_paint_phen(
		i_ambient, 1,
		i_base_color, 1,
		i_edge_color, 1,
		i_edge_color_bias,
		i_lit_color, 1,
		i_lit_color_bias,
		i_diffuse_weight,
		i_diffuse_bias,
		i_irradiance_weight,

		i_spec, 1,
		i_spec_weight,
		i_spec_exp,
		i_spec_sec, 1,
		i_spec_sec_weight,
		i_spec_sec_exp,
		i_spec_glazing,

		i_flake_color, 1,
		i_flake_weight,
		i_flake_reflect,
		i_flake_exp,
		i_flake_density,
		i_flake_decay,
		i_flake_strength,
		i_flake_scale,

		i_reflection_color, 1,
		i_edge_factor,
		i_reflection_edge_weight,
		i_reflection_base_weight,
		i_samples,
		i_glossy_spread,
		i_max_distance,
		i_single_env_sample,

		i_dirt_color, 1,
		i_dirt_weight,

		i_global_weight,

		RGBA_USE( o_result ) );
}

#undef cpow

#endif
