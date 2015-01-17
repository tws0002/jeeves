/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __simple_cooktorr_sl
#define __simple_cooktorr_sl

void simple_cooktorr(
	RGBA_DECLARE(i_ambience);
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);

	float i_roughness;
	RGBA_DECLARE( i_ior_tuple );

	RGBA_DECLARE(i_radiance);

	RGBA_DECLARE_OUTPUT(o_result); )
{
	color diff, spec, amb;
	normal Nf;
	SetCookTorranceChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		i_roughness,
		RGBA_USE(i_ior_tuple),
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

void simple_cooktorr(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);

	float i_roughness;
	RGBA_DECLARE( i_ior_tuple );

	RGBA_DECLARE(i_radiance);

	RGBA_DECLARE_OUTPUT(o_result); )
{
	color diff, spec, amb;
	normal Nf;
	SetCookTorranceChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		i_roughness,
		RGBA_USE(i_ior_tuple),
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
