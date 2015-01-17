/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __XSINormalMap2_sl
#define __XSINormalMap2_sl

#include "XSINormalMap3.sl"

void XSINormalMap2(
	XSI_TEXTURE_DECLARE(i_map);
	point i_uv;
	RGBA_DECLARE(i_tangent);
	bool i_unbiasTangent;

	output point o_bump_normal; )
{
	XSINormalMap3(
		XSI_TEXTURE_USE(i_map), 
		i_uv, 
		RGBA_USE(i_tangent), 
		i_unbiasTangent, 
		point(0, 0, 0), 
		false, 
		false, 
		false, 
		point(0, 0, 0),
		point(1, 1, 1),
		i_unbiasTangent,
		o_bump_normal);
}

/* Softimage 2013 SP1 */
void XSINormalMap2(
		XSI_TEXTURE_DECLARE(i_map);
		point i_uv;
		RGBA_DECLARE(i_tangent);
		bool i_unbiasTangent;
		bool i_unbiasNormalMap;

		output point o_bump_normal; )
{
	XSINormalMap3(
		XSI_TEXTURE_USE(i_map), 
		i_uv, 
		RGBA_USE(i_tangent), 
		i_unbiasTangent, 
		point(0, 0, 0), 
		false, 
		false, 
		false, 
		point(0, 0, 0),
		point(1, 1, 1),
		i_unbiasNormalMap,
		o_bump_normal);
}

#endif
