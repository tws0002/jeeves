/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_illum_lambert_sl
#define __sib_illum_lambert_sl

void sib_illum_lambert(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_ambience);

	point i_bump;

	RGBA_DECLARE(i_radiance);
	float i_radiance_filter;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	color diff, amb;
	normal Nf;
	SetLambertChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		i_bump,
		diff,
		amb,
		Nf);

	/* this combines amb and diff */
	extern point P;
	XSI_COMBINE_COMPONENTS_NO_SPEC(o_result, diff, amb, P, Nf);

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
}

void sib_illum_lambert(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);

	point i_bump;

	RGBA_DECLARE(i_radiance);
	float i_radiance_filter;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	sib_illum_lambert(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		color(0, 0, 0), 0,
		i_bump,
		RGBA_USE(i_radiance),
		i_radiance_filter,
		RGBA_USE(o_result));
}

#endif
