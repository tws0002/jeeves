/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_state_scalar_sl
#define __sib_state_scalar_sl

void sib_state_scalar(
	float i_mode;
	output float o_result )
{		
	extern point P;
	extern vector I;
	extern normal N;
	extern float time, u, v;

	/* In case 'i_mode' is unknown */
	o_result = 0;

	if( i_mode == 0 )
		o_result = xcomp( transform("raster", P) );
	else if( i_mode == 1 )
	{
		uniform float format[3] = {512, 512, 1};
		option( "Format", format );
		float y = ycomp( transform("raster", P) );
		o_result = format[1] - y - 1;
	}
	else if( i_mode == 2 )
		o_result = time;
	else if( i_mode == 3 )
		o_result = 1; /* not supported. Can be implemented using message passing */
	else if( i_mode == 4 )
		o_result = 1; /* see above */
	else if( i_mode == 5 )
	{
		normal Nf = ShadingNormal( normalize(N) );
		o_result = Nf.normalize(-I); 
	}
	else if( i_mode == 6 )
		o_result = length( I );
	else if( i_mode == 7 )
		o_result = u;
	else if( i_mode == 8 )
		o_result = v;
	else if( i_mode == 9 )
	{
		/* we would need a special primvar attached to hair primitives in order
		   to support this. */
		o_result = 1;
	}
}
#endif
