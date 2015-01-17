/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texproj_lookup_sl
#define __sib_texproj_lookup_sl

#include "mib_texture_remap.sl"

void sib_texproj_lookup(
	point i_coord;
	
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;
	point i_min, i_max;
	float i_torus_x, i_torus_y;

	output point o_result )
{
	uniform matrix i_transform = 1;
	uniform float i_torus_z = 0;
	uniform point i_offset = 0;

	mib_texture_remap(
		i_coord,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		o_result );
}

#endif
