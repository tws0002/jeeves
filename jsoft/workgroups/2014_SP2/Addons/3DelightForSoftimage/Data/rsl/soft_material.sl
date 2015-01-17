/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __soft_material_sl
#define __soft_material_sl

void soft_material(
	float i_mode;
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_diffuse );
	RGBA_COLOR( i_specular );
	RGBA_COLOR( i_ambience );
	float i_shiny;
	float i_transp;
	float i_reflect;
	float i_ior;
	float i_sblur;
	float i_sblurdecay;
	float i_notrace;
	uniform string unknown;
	
	output color o_result;
	output float o_result_a; )
{
	extern normal N;
	extern vector I;
	extern color Oi;

	o_result_a = 1;
	
	color opacity = 1-i_transp;

	normal Nf = ShadingNormal( normalize(N) );

	if( i_mode == 1 ) /* lambert */
	{
		o_result = diffuse( Nf ) * i_diffuse;
		o_result_a = i_diffuse_a;
	}
	else if( i_mode == 2 ) /* phong */
	{
		o_result = diffuse( Nf ) * i_diffuse;
		o_result += i_specular * specularstd( Nf, normalize(-I), 1/i_shiny );
		o_result += i_ambient * i_ambience;
	}
	else if( i_mode == 3 ) /* blinn */
	{
		o_result = diffuse( Nf ) * i_diffuse;
		o_result += blinn_specular( Nf, -normalize(I), i_ior, 0.1 );
		o_result += i_ambient * i_ambience;
	}	
	else
	{
		o_result = i_ambient * i_ambience;
	}
	
	o_result *= opacity;
	Oi = opacity;
}

void soft_material(
	float i_mode;
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_diffuse );
	RGBA_COLOR( i_specular );
	RGBA_COLOR( i_ambience );
	float i_shiny;
	float i_transp;
	float i_reflect;
	float i_ior;
	float i_sblur;
	float i_sblurdecay;
	float i_notrace;
	output color o_result;
	output float o_result_a; )
{
	soft_material(
		i_mode,
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		RGBA_USE(i_ambience),
		i_shiny,
		i_transp,
		i_reflect,
		i_ior,
		i_sblur,
		i_sblurdecay,
		i_notrace,
		"",
		RGBA_USE(o_result));
}

#endif
