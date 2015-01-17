#ifndef __material_strauss_sl
#define __material_strauss_sl

void material_strauss(
	RGBA_DECLARE( i_diffuse );
	float i_smoothness;
	float i_metalness;
	
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_transparency );
	float i_trans_glossy;
	float i_transparent_samples;
	RGBA_DECLARE( i_reflectivity );
	float i_reflect_glossy;
	float i_reflect_samples;
	float i_ior;
	float i_translucency;
	RGBA_DECLARE( i_incandescence );
	float i_inc_inten;
	point i_bump;
	float i_no_trace;
	float i_diffuse_inuse;
	float i_specular_inuse;
	float i_reflect_inuse;
	float i_refract_inuse;
	float i_incand_inuse;
	float i_translucent_inuse;
	RGBA_DECLARE( i_radiance );
	float i_radiance_filter;
	float i_scaletrans;
	float i_inverttrans;
	float i_usealphatrans;
	float i_scalerefl;
	float i_invertrefl;
	float i_usealpharefl;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern point P;
	
	normal Nf;
	
	color ambient, diffuse, specular;
	
	SetStraussChannels(
		RGBA_USE(i_diffuse),
		i_smoothness,
		i_metalness,
		RGBA_USE(i_ambience),
		i_bump,
		diffuse,
		specular,
		ambient,
		Nf);
	
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
	
	color color_bleeding = i_radiance;
	if( i_radiance_filter == true )
		color_bleeding *= i_diffuse;
	
	XSI_COMBINE_MATERIAL_COMPONENTS(
		o_result,
		diffuse, i_diffuse_inuse,
		ambient, color_bleeding,
		specular, i_specular_inuse,
		reflect_color, reflect_weight, 
		refract_color, real_transparency, 
		incand_color, 
		P, 
		Nf);

	ambient += incand_color;

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diffuse );
	XSI_MATERIAL_SET_OUTPUT( Specular, specular );
	XSI_MATERIAL_SET_OUTPUT( Ambient, ambient );
	XSI_MATERIAL_SET_OUTPUT( Reflection, reflect_color );
	XSI_MATERIAL_SET_OUTPUT( Refraction, refract_color );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, color_bleeding );
}

void material_strauss(
	RGBA_DECLARE( i_diffuse );
	float i_smoothness;
	float i_metalness;

	RGBA_DECLARE( i_transparency );
	float i_trans_glossy;
	float i_transparent_samples;
	RGBA_DECLARE( i_reflectivity );
	float i_reflect_glossy;
	float i_reflect_samples;
	float i_ior;
	float i_translucency;
	RGBA_DECLARE( i_incandescence );
	float i_inc_inten;
	point i_bump;
	float i_no_trace;
	float i_diffuse_inuse;
	float i_specular_inuse;
	float i_reflect_inuse;
	float i_refract_inuse;
	float i_incand_inuse;
	float i_translucent_inuse;
	RGBA_DECLARE( i_radiance );
	float i_radiance_filter;
	float i_scaletrans;
	float i_inverttrans;
	float i_usealphatrans;
	float i_scalerefl;
	float i_invertrefl;
	float i_usealpharefl;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	material_strauss(
		RGBA_USE(i_diffuse),
		i_smoothness,
		i_metalness,
		color(0, 0, 0), 0,
		RGBA_USE(i_transparency),
		i_trans_glossy,
		i_transparent_samples,
		RGBA_USE(i_reflectivity),
		i_reflect_glossy,
		i_reflect_samples,
		i_ior,
		i_translucency,
		RGBA_USE(i_incandescence),
		i_inc_inten,
		i_bump,
		i_no_trace,
		i_diffuse_inuse,
		i_specular_inuse,
		i_reflect_inuse,
		i_refract_inuse,
		i_incand_inuse,
		i_translucent_inuse,
		RGBA_USE(i_radiance),
		i_radiance_filter,
		i_scaletrans,
		i_inverttrans,
		i_usealphatrans,
		i_scalerefl,
		i_invertrefl,
		i_usealpharefl,
		RGBA_USE(o_result));
}

#endif
