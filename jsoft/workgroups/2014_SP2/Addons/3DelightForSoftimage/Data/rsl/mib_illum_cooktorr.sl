#ifndef __mib_illum_cooktorr_sl
#define __mib_illum_cooktorr_sl

#include "simple_cooktorr.sl"

void mib_illum_cooktorr(
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_diffuse );
	RGBA_DECLARE( i_specular );
	float i_roughness;
	RGBA_DECLARE( i_ior );
	float i_mode;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	simple_cooktorr(
		RGBA_USE( i_ambience ),
		RGBA_USE( i_ambient ),
		RGBA_USE( i_diffuse ),
		RGBA_USE( i_specular ),
		
		i_roughness,
		RGBA_USE( i_ior ),

		1, 1,

		RGBA_USE( o_result ) );
}

#endif /* __mib_illum_cooktorr_sl */

