/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __txt3d_fractal_v3_sl
#define __txt3d_fractal_v3_sl

#include "sib_texture_fractal.sl"
#include "mib_texture_remap.sl"
#include "mib_bump_map.sl"

/*
	This is the more elaborate version of sib_texture_fractal shader.
*/
/* Softimage 2013 */
void txt3d_fractal_v3(
	RGBA_COLOR( i_color1 );
	RGBA_COLOR( i_color2 );

	SIB_TEXTURE_FRACTAL_PARAMS;
	XSI_TEXTURE_COMMON_PARAMS;

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

	float fractal;
	sib_texture_fractal( coord,
		SIB_TEXTURE_FRACTAL_PARAMS_LIST,
		fractal );

	RGBA_MIX( o_result, i_color1, i_color2, fractal );

	XSI_TEXTURE_DO_BUMP
}

/* Old Softimage */
void txt3d_fractal_v3(
	RGBA_COLOR( i_color1 );
	RGBA_COLOR( i_color2 );

	SIB_TEXTURE_FRACTAL_PARAMS;
	XSI_TEXTURE_COMMON_PARAMS;

	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	txt3d_fractal_v3(
			RGBA_USE( i_color1 ),
			RGBA_USE( i_color2 ),

			SIB_TEXTURE_FRACTAL_PARAMS_LIST,
			XSI_TEXTURE_COMMON_PARAMS_LIST,

			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

#endif
