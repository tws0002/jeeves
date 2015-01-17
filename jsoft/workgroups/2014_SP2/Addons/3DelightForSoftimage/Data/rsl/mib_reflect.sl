/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_reflect_sl
#define __mib_reflect_sl

void mib_reflect(
	RGBA_COLOR( i_input );
	RGBA_COLOR( i_reflect );
	float i_notrace;
	
	output color o_result;
	output float o_result_a; )
{
	extern normal N;
	extern vector I;
	extern point P;

	normal Nf = ShadingNormal( normalize(N) );
	vector R = reflect( I, Nf );

	o_result = trace( P, normalize(R) );	

	if( i_reflect != color(1,1,1) ) 
		o_result = o_result * i_reflect + (1-i_reflect) * i_input;

	o_result_a = 1;
}
#endif
