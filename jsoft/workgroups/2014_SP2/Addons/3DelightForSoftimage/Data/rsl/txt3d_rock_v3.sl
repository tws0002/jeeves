/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt3d_rock_v3_sl
#define __txt3d_rock_v3_sl

#include "sib_texture_rock.sl"
#include "mib_bump_map.sl"
#include "mib_texture_remap.sl"

/*
	This is the more elaborate version of sib_texture2d_grid shader.
*/
/* Softimage 2013 */
void txt3d_rock_v3(
	RGBA_COLOR( i_color1 );
	RGBA_COLOR( i_color2 );

	float i_grain_size, i_diffusion, i_mix_ratio;
	XSI_TEXTURE_COMMON_PARAMS;	

	float i_noise_type;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a; )
{
	point coord;
	uniform float i_torus_x=0, i_torus_y=0, i_torus_z=0;
	uniform point i_offset = 0;
	uniform matrix i_transform = 1;
	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord );

	float rock;
	sib_texture_rock( coord,
		i_grain_size, i_diffusion, i_mix_ratio,
		i_noise_type,
		XSI_TEXTURE_USE(i_permfiledat),
		XSI_TEXTURE_USE(i_valfiledat),
		rock );

	if( i_alpha_output == true )
	{
		o_result = mix( i_color1_a, i_color2_a, rock ) * i_alpha_factor;
	}
	else
	{
		RGBA_MIX( o_result, i_color1, i_color2, rock );
	}

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt3d_rock_v3(
	RGBA_COLOR( i_color1 );
	RGBA_COLOR( i_color2 );

	float i_grain_size, i_diffusion, i_mix_ratio;
	XSI_TEXTURE_COMMON_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	txt3d_rock_v3(
			RGBA_USE( i_color1 ),
			RGBA_USE( i_color2 ),

			i_grain_size, i_diffusion, i_mix_ratio,
			XSI_TEXTURE_COMMON_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

#endif