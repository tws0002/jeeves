#ifndef __mib_illum_phong_sl
#define __mib_illum_phong_sl

#include "simple_phong.sl"

void mib_illum_phong(
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_ambience );
	RGBA_DECLARE( i_diffuse );
	RGBA_DECLARE( i_specular );
	float i_shinyness;
	float i_mode;
	RGBA_DECLARE_OUTPUT(o_result); )
{
	simple_phong(
		RGBA_USE( i_ambient ),
		RGBA_USE( i_diffuse ),
		RGBA_USE( i_specular ),
		RGBA_USE( i_ambience ),

		i_shinyness,
		0,

		1, 1,

		RGBA_USE( o_result ) );
}

#endif /* __mib_illum_phong_sl */

