/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_zbump_sl
#define __sib_zbump_sl

void sib_zbump(
	point i_bump;
	float i_in_use;

	RGBA_COLOR( i_input );
	float i_scale, i_spacing;

	output point o_result; )
{
	extern float du, dv;
	extern vector I, dPdu, dPdv;
	extern normal N;

	if( i_in_use == 0 )
	{
		o_result = point( ntransform( "world", normalize(N)) );		
	}
	else
	{
		float value = COLOR_LUMA( i_input ); 

		/* The part about dPdu/dPdv ensures that the
		   bump's scale does not depend on the underlying parametrization of the
		   patch (the use of Du and Dv below introduce that) and that it happens
		   in object space.  */

		float u_spacing = sign(du) * max( abs(du), i_spacing );
		float v_spacing = sign(dv) * max( abs(dv), i_spacing );

		float uscale = du / (u_spacing * length(vtransform("object", dPdu)) );
		float vscale = dv / (v_spacing * length(vtransform("object", dPdv)) );

		vector gu = vector(1, 0, Du(value*i_scale) * uscale);
		vector gv = vector(0, 1, Dv(value*i_scale) * vscale);
		normal n = gu ^ gv;	

		vector basisx = normalize((N ^ dPdu) ^ N);
		vector basisy = normalize((N ^ dPdv) ^ N);

		N = normal( xcomp(n)*basisx + ycomp(n)*basisy + zcomp(n) * normalize(N) );
		o_result = point( normalize( ntransform("world", N)) );
	}
}
#endif
