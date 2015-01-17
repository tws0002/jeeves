#ifndef __mi_metallic_paint_h
#define __mi_metallic_paint_h

#include "xsi_illum.h"

#define cpow(c, n) ( color(pow(comp(c,0),n),pow(comp(c,1),n),pow(comp(c,2),n)) )

void mi_metallic_paint(
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_base_color );
	RGBA_COLOR( i_edge_color );
	float i_edge_color_bias;
	RGBA_COLOR( i_lit_color );
	float i_lit_color_bias;
	float i_diffuse_weight;
	float i_diffuse_bias;
	float i_iradiance_weight;

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
	float i_flake_decay;

	float i_global_weight;
							
	RGBA_COLOR( i_flake_bump );
	uniform string i_flake_bump_str;
	
	output color o_outColor;
	output float o_outColor_a;
)
{
	color getMetallicDiffuse(
		vector i_Nf; vector i_In;
		color i_base;
		color i_lit; float i_lit_bias;
		float i_bias;
		uniform float keyLightsOnly; 
		uniform float unshadowed;)
	{
		extern point P;
		
		color C = 0;
		
		illuminance( P, i_Nf, PI/2 )
		{
			float isKeyLight = 1;
		
			if( keyLightsOnly != 0 )
			{
				lightsource( "iskeylight", isKeyLight );
			}
			
			if( isKeyLight != 0 )
			{
				float nondiffuse = 0;
				lightsource( "__nondiffuse", nondiffuse );
			
				if( nondiffuse < 1 )
				{
					vector Ln = normalize(L);
					float diffuse_mult = Ln.i_Nf;
					float lit_mult = pow(diffuse_mult, i_lit_bias) * 0.5;
					
					color Cd = i_base;
					Cd = mix(Cd, i_lit, lit_mult);
					
					diffuse_mult = pow(diffuse_mult, i_bias);
					
					varying color cur_cl;
					GET_CL(cur_cl);
					
					C += cur_cl * Cd * diffuse_mult * (1-nondiffuse);
				}
			}
		}
		return C;
	}
	
	color csmoothstep(float min, max; color value)
	{
		color buf = color(
			smoothstep(min, max, comp(value, 0)),
			smoothstep(min, max, comp(value, 1)),
			smoothstep(min, max, comp(value, 2)) );
		
		return buf;
	}
	
	color my_contrast(color a; float b)
	{
		color buf = a-0.5;
		buf *= b;
		buf += 0.5;
		return clamp(buf, color(0.0), color(1.0));
	}
	
	extern point P;
	extern normal N;	
	extern vector I;
	
	normal Nn = normalize(N);
	normal Nf = ShadingNormal(Nn);
	vector In = normalize(I);
	vector V = -In;
	
	float edge_mult = (1-pow(Nf.V, i_edge_color_bias));
	color diffuse_color = mix(i_base_color, i_edge_color, edge_mult);
	
	color diffuse_component = getMetallicDiffuse(
		Nf, In,
		diffuse_color,
		i_lit_color, i_lit_color_bias,
		i_diffuse_bias,
		0, 0);
		
	color ambient_component = i_ambient*diffuse_color;
	
	color spec_weight = i_spec * i_spec_weight;
	color spec_sec_weight = i_spec_sec * i_spec_sec_weight;
	color flake_weight = i_flake_color * i_flake_weight * 0.5;
	
	color spec_raw = 0;
	color spec_sec_raw = 0;
	color flake_raw = 0;
	
	if (spec_weight != 0)
	{
		if(i_spec_glazing == true)
		{
			spec_raw = getGaussianG(In, Nf, sqrt(0.5/i_spec_exp), 0, 0);
		}
		else
		{
			spec_raw = getGaussian(In, Nf, sqrt(2/i_spec_exp), 0, 0);
		}
	}
	
	if (spec_sec_weight != 0)
	{
		spec_sec_raw = getGaussian(In, Nf, sqrt(2/i_spec_sec_exp), 0, 0);
	}
	
	color flake_mult = color(0.5);
	if(i_flake_bump_str != "")
		flake_mult = my_contrast(i_flake_bump, 1.5);
	
	vector flake_nrml = Nf;
	
	float decay = length(I);
	if(i_flake_decay > 0)
	{
		decay = 1 - decay/i_flake_decay;
		decay = clamp(decay, 0, 1);
		decay = pow(decay, 0.75);
	} else
		decay = 1;
	
	flake_weight *= flake_mult * decay;
	
	if (flake_weight != 0)
	{
		flake_raw = getGaussian(In, Nf, sqrt(2/i_flake_exp), 0, 0);
	}
	
	color specular_component = 
		spec_weight*spec_raw +
		spec_sec_weight*spec_sec_raw +
		flake_weight*flake_raw;
		
	color irradiance_component = diffuse_color * i_iradiance_weight;
	
	float refl_dist;
	color refl_trs;
	
	color reflection_weight = 
		flake_mult * i_flake_color * flake_weight * decay * i_flake_reflect;
	color reflection_raw = 0;
	if(reflection_weight != color(0.0))
		reflection_raw =
			trace(P, reflect(In, flake_nrml), refl_dist, "transmission", refl_trs);
	color reflection_component = reflection_raw * reflection_weight;
	
	extern point P;
	XSI_COMBINE_COMPONENTS_SPEC(
		o_outColor,
		diffuse_component,
		ambient_component,
		irradiance_component,
		specular_component + reflection_component,
		P, Nf);
	
	XSI_MATERIAL_SET_OUTPUT( Specular, specular_component );
	XSI_MATERIAL_SET_OUTPUT( Diffuse, diffuse_component );
	XSI_MATERIAL_SET_OUTPUT( Ambient, ambient_component );
	XSI_MATERIAL_SET_OUTPUT( Reflection, reflection_component );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, irradiance_component );
}

void mi_metallic_paint(
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_base_color );
	color i_edge_color;
	float i_edge_color_bias;
	color i_lit_color;
	float i_lit_color_bias;
	float i_diffuse_weight;
	float i_diffuse_bias;
	float i_iradiance_weight;

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
	float i_flake_decay;

	color i_flake_bump; bool i_flake_bump_connected;
	
	float i_global_weight;
							
	float i_mode;
	
	output color o_outColor;
	output float o_outColor_a;
)
{
	mi_metallic_paint(
		RGBA_USE( i_ambient ),
		RGBA_USE( i_base_color ),
		i_edge_color, 1,
		i_edge_color_bias,
		i_lit_color, 1,
		i_lit_color_bias,
		i_diffuse_weight,
		i_diffuse_bias,
		i_iradiance_weight,

		RGBA_USE( i_spec ),
		i_spec_weight,
		i_spec_exp,
		RGBA_USE( i_spec_sec ),
		i_spec_sec_weight,
		i_spec_sec_exp,
		i_spec_glazing,
		
		RGBA_USE( i_flake_color ),
		i_flake_weight,
		i_flake_reflect,
		i_flake_exp,
		i_flake_decay,

		i_global_weight,
		
		i_flake_bump, 1,
		i_flake_bump_connected==true?"a":"",
		
		RGBA_USE( o_outColor ) );
}

#undef cpow

#endif /* __mi_metallic_paint_h */
