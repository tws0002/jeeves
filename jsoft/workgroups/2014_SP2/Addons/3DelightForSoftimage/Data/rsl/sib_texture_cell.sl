/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture_cell_sl
#define __sib_texture_cell_sl

/*
 * Generates an organic cell-like texture.
 * The texture is comprised of two color inputs.
 * 
 * PARAMETERS:
 * i_noise_type: the algorithm for the pattern: 
 * - Legacy produces the same pattern as in versions prior to Softimage 2013
 * - Default produces the same pattern as shown in High Quality display mode
 */

/* Softimage 2013 */
void sib_texture_cell(
	point i_coord;
	float i_noise_type;
	float i_seed;
	XSI_TEXTURE_DECLARE(i_tex);

	output float o_result;
	output float o_index )
{
	o_index = 0; /* FIXME */

	float f1;
	point p1;

	voronoi_f1_3d( i_coord, 1, i_seed, f1, p1 );
	o_result = f1;
}

/* Old Softimage */
void sib_texture_cell(
	point i_coord;
	output float o_result;
	output float o_index )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture_cell(
			i_coord,
			i_noise_type,
			0,
			XSI_TEXTURE_USE(buffer),
			o_result,
			o_index );
}

#endif
