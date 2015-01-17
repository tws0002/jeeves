#ifndef __sib_diffuse_refraction_phen_sl
#define __sib_diffuse_refraction_phen_sl

#include "xsi_material.h"

void sib_diffuse_refraction_phen(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_transparency);
	bool i_alpha;
	float i_trans_glossy;
	float i_transparent_samples;
	float i_ior;
	float i_max_depth;
	float i_scaletrans;
	bool i_inverttrans;
	bool i_usealphatrans;
	bool i_refract_inuse;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	color refraction_color = 0;
	color refraction_weight = 0;
	
	extern float __refracts;
	extern float __transparent;
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
		refraction_color,
		refraction_weight);


	extern point P;
	extern vector I;
	extern normal N;
	normal Nf = faceforward( normalize(N), I );

	color diff=i_input, spec=0, amb=0, irrad=0, incand=0;
	color refl=0, refr=refraction_color;
	XSI_COMBINE_MATERIAL_COMPONENTS (
		o_result,
		diff, 1,
		amb, irrad,
		spec, 0,
		refl, 0,
		refr, refraction_weight,
		incand,
		P, Nf );

	XSI_MATERIAL_SET_OUTPUT( Diffuse, i_input );
	XSI_MATERIAL_SET_OUTPUT( Refraction, refraction_color );	
}

#endif //__sib_diffuse_refraction_phen_sl
