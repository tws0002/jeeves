#ifndef __mib_illum_lambert_h
#define __mib_illum_lambert_h

void mib_illum_lambert(
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_diffuse );
	float i_mode;
	RGBA_DECLARE_OUTPUT( o_result ); )
{
	color diff, amb;
	normal Nf;
	SetLambertChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		0,
		diff,
		amb,
		Nf);

	/* this combines amb and diff */
	extern point P;
	XSI_COMBINE_COMPONENTS_NO_SPEC(o_result, diff, amb, P, Nf);

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
}

#endif /* __mib_illum_lambert_h */
