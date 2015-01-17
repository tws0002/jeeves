/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_bump_map_sl
#define __mib_bump_map_sl

#define MIB_BUMP_MAP_PARAMS \
	point i_step; \
	float i_factor; \
	float i_torus_u, i_torus_v; \
	float i_alpha; \
	RGBA_COLOR( i_tex ); \
	float i_clamp

/* NOTE: we ignore bump basis and compute our own */		
void mib_bump_map(
	point i_u, i_v;
	point i_coord;
	MIB_BUMP_MAP_PARAMS;
	
	output point o_result; )
{
	extern float du, dv;
	extern vector I, dPdu, dPdv;
	extern normal N;

	float value = i_alpha == 1.0 ? i_tex_a : COLOR_LUMA( i_tex ); 

	/* The part about dPdu/dPdv ensures that the bump's scale does
	   not depend on the underlying parametrization of the
	   patch (the use of Du and Dv below introduce that) and that it happens
	   in object space.  */

	float u_spacing = sign(du) * max( abs(du), i_step[0] );
	float v_spacing = sign(dv) * max( abs(dv), i_step[1] );
	float uscale = du / (u_spacing * length(vtransform("object", dPdu)) );
	float vscale = dv / (v_spacing * length(vtransform("object", dPdv)) );

	vector gu = vector(1, 0, -Du(value*i_factor*.007) * uscale);
	vector gv = vector(0, 1, -Dv(value*i_factor*.007) * vscale);
	normal n = gu ^ gv;	

	vector basisx = normalize((N ^ dPdu) ^ N);
	vector basisy = normalize((N ^ dPdv) ^ N);

	N = normal( xcomp(n)*basisx + ycomp(n)*basisy + zcomp(n) * normalize(N) );
	o_result = point( normalize( ntransform("world", N)) );
}

/* Softimage 2013 SP1 */
void mib_bump_map(
	point i_u, i_v;
	point i_coord;

	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	XSI_TEXTURE_DECLARE( i_map );
	float i_clamp;

	output point o_result; )
{
	RGBA_COLOR( tex );

	xsi_textureLookupRGBA(
			XSI_TEXTURE_USE( i_map ),
			i_coord[0],
			i_coord[1],
			RGBA_USE( tex ) );

	mib_bump_map(
			i_u, i_v,
			i_coord,

			i_step,
			i_factor,
			i_torus_u, i_torus_v,
			i_alpha,

			RGBA_USE( tex ),

			i_clamp,

			o_result );
}

#endif
