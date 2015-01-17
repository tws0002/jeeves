/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_flagstone_sl
#define __sib_texture_flagstone_sl

/* Softimage 2013 */
void sib_texture_flagstone(
	point i_coord;
	float i_mortar_width;

	float i_noise_type;
	float i_seed;
	XSI_TEXTURE_DECLARE(i_permfiledat);

	output float o_mortar;
	output float o_stone_color )
{
	float f1, f2;
	point p1, p2;
	float feature_hash;

	voronoi_f1f2_3d( i_coord*1.5, 1, i_seed,
		feature_hash, f1, p1, f2, p2 );

	float dist = f2-f1;
	o_stone_color = feature_hash;
	o_mortar = 1 - filterstep( i_mortar_width, dist);
}

/* Old Softimage */
void sib_texture_flagstone(
	point i_coord;
	float i_mortar_width;
	output float o_mortar;
	output float o_stone_color )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_flagstone(
			i_coord,
			i_mortar_width,

			i_noise_type,
			i_seed,

			XSI_TEXTURE_USE(buffer),

			o_mortar,
			o_stone_color );
}

#endif
