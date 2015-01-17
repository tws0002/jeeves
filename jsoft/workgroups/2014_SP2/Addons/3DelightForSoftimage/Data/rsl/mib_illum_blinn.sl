#ifndef __mib_illum_blinn_sl
#define __mib_illum_blinn_sl

#include "simple_blinn.sl"

void mib_illum_blinn(
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_diffuse );
	RGBA_DECLARE( i_specular );
	float i_roughness;
	float i_ior;
	float i_mode;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	simple_blinn(
		RGBA_USE( i_ambience ),
		RGBA_USE( i_ambient ),
		RGBA_USE( i_diffuse ),
		RGBA_USE( i_specular ),
		
		i_roughness,
		i_ior,

		1, 1,

		RGBA_USE( o_result ) );
}

#endif /* __mib_illum_blinn_sl */
