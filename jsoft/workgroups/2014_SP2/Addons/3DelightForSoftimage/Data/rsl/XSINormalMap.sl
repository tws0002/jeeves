/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __XSINormalMap_sl
#define __XSINormalMap_sl

#include "XSINormalMap2.sl"

void XSINormalMap(
	XSI_TEXTURE_DECLARE( i_map );
	point i_uv;
	RGBA_DECLARE( i_tangent );

	output point o_bump_normal; )
{
	XSINormalMap2(XSI_TEXTURE_USE(i_map), i_uv, RGBA_USE(i_tangent), false, o_bump_normal);
}

#endif
