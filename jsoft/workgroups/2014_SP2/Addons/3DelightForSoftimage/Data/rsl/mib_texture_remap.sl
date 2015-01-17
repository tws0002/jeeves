/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_texture_remap_sl
#define __mib_texture_remap_sl

#define MIB_TEXTURE_REMAP_PARAMS \
	uniform matrix i_transform; \
	point i_repeats; \
	float i_alt_x, i_alt_y, i_alt_z; \
	float i_torus_x, i_torus_y, i_torus_z; \
	point i_min, i_max; \
	point i_offset

#define MIB_TEXTURE_REMAP_PARAMS_LIST \
	i_transform, i_repeats, i_alt_x, i_alt_y, i_alt_z, i_torus_x, i_torus_y, i_torus_z, i_min, i_max, i_offset

void mib_texture_remap(
	point i_input; 
	MIB_TEXTURE_REMAP_PARAMS;
	output point o_result )
{
	if(UNDEFINED_UV(i_input[0]) || UNDEFINED_UV(i_input[1]) || UNDEFINED_UV(i_input[2]))
	{
		o_result = point(UNDEFINED_UV_VALUE, UNDEFINED_UV_VALUE, UNDEFINED_UV_VALUE);
		return;
	}

	point tex = i_input;

	if( comp(i_transform,3, 3)!=0 )
		tex = transform(i_transform, tex);

	float x = xcomp(tex);
	float y = ycomp(tex);
	float z = zcomp(tex);

	/* repeat/alt*/
	if( xcomp(i_repeats)!=0 && x>= 0 && x < 1) 
	{
		x *= xcomp(i_repeats);
		if ( i_alt_x != 0)
		{
			float i = floor(x);
			if( mod(i, 2) == 0 )
				x = 2*i + 1 - x;
		}
		x = SLICE(x);
	}

	if( ycomp(i_repeats)!=0 && y>= 0 && y < 1) 
	{
		y *= ycomp(i_repeats);
		if( i_alt_y != 0)
		{
			float i = floor(y);
			if( mod(i, 2) == 0 )
				y = 2*i + 1 - y;
		}
		y = SLICE(y);
	}

	if( zcomp(i_repeats)!=0 && z>= 0 && z < 1) 
	{
		z *= zcomp(i_repeats);
		if ( i_alt_z != 0)
		{
			float i = floor(z);
			if( mod(i, 2) == 0 )
				z = 2*i + 1 - z;
		}
		z = SLICE(z);
	}

	/* crop */
	o_result = point(x, y, z) * (i_max-i_min) + i_min;
	o_result += vector(i_offset);
}
#endif
