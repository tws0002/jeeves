/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __material_constant_sl
#define __material_constant_sl

void material_constant(
	RGBA_DECLARE( i_color );
	RGBA_DECLARE( i_transparency );
	float i_trans_glossy;
	uniform float i_transparent_samples;
	
	RGBA_DECLARE( i_reflectivity );
	float i_reflect_glossy;
	uniform float i_reflect_samples;

	float i_ior;
	
	RGBA_DECLARE( i_incandescence );
	float i_inc_inten;

	float i_no_trace;
	float i_reflect_inuse, i_refract_inuse, i_incand_inuse;

	RGBA_DECLARE( i_radiance );
	float i_scaletrans, i_inverttrans, i_usealphatrans;
	float i_scalerefl, i_invertrefl, i_usealpharefl;
	
	RGBA_DECLARE_OUTPUT(o_result); )	
{
	color reflect_color = 0, reflect_weight = 0, refract_color = 0, incand_color = 0;
	color real_transparency = 0;
	
	extern float __reflects;
	extern float __refracts;
	extern float __transparent;
	
	xsi_reflect(
		RGBA_USE(i_reflectivity),
		i_reflect_glossy,
		i_reflect_samples,
		
		i_no_trace,
		
		i_reflect_inuse,
		
		i_scalerefl,
		i_invertrefl,
		i_usealpharefl,
		
		__reflects,
		
		reflect_color,
		reflect_weight);
	xsi_refract(
		RGBA_USE(i_transparency),
		i_trans_glossy,
		i_transparent_samples,
		
		i_ior,
		
		i_refract_inuse,
		i_scaletrans,
		i_inverttrans,
		i_usealphatrans,
		
		__refracts,
		__transparent,
		refract_color,
		real_transparency);
	XSI_INCANDESCENCE(incand_color);

	extern point P;
	extern normal N;
	extern vector I;

	color color_bleeding = i_radiance;

	normal Nf = ShadingNormal( normalize(N) );

	color diff=i_color, spec=0, amb=0;

	XSI_COMBINE_MATERIAL_COMPONENTS(
		o_result,
		diff, true,
		amb, color_bleeding,
		spec, 0,
		reflect_color, reflect_weight, 
		refract_color, real_transparency, 
		incand_color, 
		P, 
		Nf);

	amb += incand_color;

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
	XSI_MATERIAL_SET_OUTPUT( Reflection, reflect_color );
	XSI_MATERIAL_SET_OUTPUT( Refraction, refract_color );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, color_bleeding );
}

#endif
