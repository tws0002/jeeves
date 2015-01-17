/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __material_ward_sl
#define __material_ward_sl

void material_ward(
	RGBA_DECLARE( i_image );
	float i_surfderiv_mode;
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_diffuse );
	RGBA_COLOR( i_glossy );
	float i_shiny_u, i_shiny_v;	

	XSI_MATERIAL_COMMON_PARAMS_SPECULAR_NO_BUMP;

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

	color diff, spec, amb;
	normal Nf;

	SetWardChannels(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_glossy),
		i_shiny_u, i_shiny_v,
		i_surfderiv_mode,
		diff,
		spec,
		amb,
		Nf);

	color color_bleeding = i_radiance;
	if( i_radiance_filter == true )
		color_bleeding *= i_diffuse;

	extern point P;
	XSI_COMBINE_MATERIAL_COMPONENTS(
		o_result,
		diff, i_diffuse_inuse,
		amb, color_bleeding,
		spec, i_specular_inuse,
		reflect_color, reflect_weight, 
		refract_color, real_transparency, 
		incand_color, 
		P, 
		Nf);

	amb += incand_color;

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Specular, spec );
	XSI_MATERIAL_SET_OUTPUT( Ambient, amb );
	XSI_MATERIAL_SET_OUTPUT( Reflection, reflect_color );
	XSI_MATERIAL_SET_OUTPUT( Refraction, refract_color );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, color_bleeding );
}

#endif
