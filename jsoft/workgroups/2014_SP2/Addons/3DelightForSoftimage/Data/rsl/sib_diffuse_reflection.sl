#ifndef __sib_diffuse_reflection_sl
#define __sib_diffuse_reflection_sl

#include "xsi_material.h"

void sib_diffuse_reflection(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_reflectivity);
	bool i_alpha;
	float i_reflect_glossy;
	float i_reflect_samples;
	bool i_no_trace;
	float i_max_depth;
	float i_scalerefl;
	bool i_invertrefl;
	bool i_usealpharefl;
	bool i_reflect_inuse;
	
	RGBA_DECLARE_OUTPUT(o_result); )
{
	color reflection_color = 0;
	color reflection_weight = 0;
	
	extern float __reflects;
	
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
		
		reflection_color,
		reflection_weight);
	
	bool i_refract_inuse = false;
	float i_ior = 1;
	float i_trans_glossy = 0;
	
	extern point P;
	extern vector I;
	extern normal N;
	normal Nf = ShadingNormal( normalize(N) );

	color diff=i_input, spec=0, amb=0, irrad=0, incand=0;
	color refl=reflection_color, refr=0;
	XSI_COMBINE_MATERIAL_COMPONENTS (
		o_result,
		diff, 1,
		amb, irrad,
		spec, 0,
		refl, reflection_weight,
		refr, 0,
		incand,
		P, Nf );

	XSI_MATERIAL_SET_OUTPUT( Diffuse, diff );
	XSI_MATERIAL_SET_OUTPUT( Reflection, refl );
}

#endif //__sib_diffuse_reflection_sl
