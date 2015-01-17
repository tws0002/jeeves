/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __XSINormalMap3_sl
#define __XSINormalMap3_sl

#define bool float

#include "mib_texture_remap.sl"

void XSINormalMap3(
	XSI_TEXTURE_DECLARE(i_map);
	point i_uv;
	RGBA_DECLARE(i_tangent);
	bool i_unbiasTangent;
	point i_repeats;
	bool i_alt_x;
	bool i_alt_y;
	bool i_alt_z;
	point i_min;
	point i_max;
	bool i_unbiasNormalMap;
	output point o_bump_normal; )
{
	extern vector I;
	extern normal N;

	point coord;
	matrix i_transform = 1;
	uniform float i_torus_x = 0, i_torus_y = 0, i_torus_z = 0;
	uniform point i_offset = 0;
	mib_texture_remap(
		i_uv,
		MIB_TEXTURE_REMAP_PARAMS_LIST,
		coord);

	color col = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_map), coord[0], coord[1]);

	/* We cheat here and trick the shader compiler to think
	   that i_tangent is in "object" space, otherwise we 
	   get a handful of warnings about space misuse */
	vector tangent = vector "object" (0,0,0);
	tangent[0] = i_tangent[0];
	tangent[1] = i_tangent[1];
	tangent[2] = i_tangent[2];

	uniform float tScale = i_unbiasTangent ? 1.0 : 2.0;
	uniform float tOffset = i_unbiasTangent ? 0.0 : 0.5;
	uniform float nScale = i_unbiasNormalMap ? 1.0 : 2.0;
	uniform float nOffset = i_unbiasNormalMap ? 0.0 : 0.5;

	tangent = tScale * (tangent - tOffset);
	normal bump_normal = normal( nScale * point(col-nOffset) );
	float direction = tScale * (i_tangent_a - tOffset);

	/* tangents are in object space, transform to world */
	tangent = vtransform( "object", "world", tangent );
	normal Nfw = normalize(ntransform("current", "world", ShadingNormal( N )));

	vector binormal = normalize( Nfw^tangent ) * direction;

	tangent = normalize(tangent) * direction;

	matrix basis = (
		tangent[0], tangent[1], tangent[2], 0,
		binormal[0], binormal[1], binormal[2], 0,
		Nfw[0], Nfw[1], Nfw[2], 0,
		0, 0, 0, 1 );

	/* Here, we are transforming a normal vector using vtransform.  It's wrong,
		but it works! */
	bump_normal = vtransform(basis, vector(bump_normal));

	o_bump_normal = point( normalize(bump_normal) ); 
}

#endif
