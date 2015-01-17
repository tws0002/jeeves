/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __texture_lookup_sl
#define __texture_lookup_sl

void mib_texture_lookup(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;

	output color o_result;
	output float o_result_a; )
{
	xsi_textureLookupRGBA(
		XSI_TEXTURE_USE(i_tex), i_coord[0], i_coord[1],
		o_result, o_result_a );
}
#endif
