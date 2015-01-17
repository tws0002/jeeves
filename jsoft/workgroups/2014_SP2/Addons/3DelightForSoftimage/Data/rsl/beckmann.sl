/*
	Copyright (c) 2010 DNA Research
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __beckmann_sl
#define __beckmann_sl

void beckmann(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);
	RGBA_DECLARE(i_ambience);

	float i_shiny;
	point i_bump;
	
	RGBA_DECLARE(i_radiance); 
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	color diff, spec, amb;
	normal Nf;
	SetBeckmannChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		i_shiny,
		i_bump,
		diff,
		spec,
		amb,
		Nf);

	color color_bleeding = i_diffuse * i_radiance;

	/* this combines amb, diff and spec */
	extern point P;
	XSI_COMBINE_COMPONENTS_SPEC(
			o_result, diff, amb, color_bleeding, spec, P, Nf);

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Specular, spec );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, color_bleeding );
}

void beckmann(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);
	RGBA_DECLARE(i_ambience);

	float i_shiny;
	point i_bump;
	
	RGBA_DECLARE(i_radiance); 

	float i_radiance_filter;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	color diff, spec, amb;
	normal Nf;
	SetBeckmannChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		i_shiny,
		i_bump,
		diff,
		spec,
		amb,
		Nf);

	color color_bleeding = i_diffuse * i_radiance;

	/* this combines amb, diff and spec */
	extern point P;
	XSI_COMBINE_COMPONENTS_SPEC(
			o_result, diff, amb, color_bleeding, spec, P, Nf);

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Specular, spec );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, color_bleeding );
}

#endif