/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_incidence_sl
#define __sib_incidence_sl

void sib_incidence(
	point i_custom_vector;
	float i_mode, i_exponenet;

	output float o_result;)
{
	extern normal N;
	extern vector I;
	normal Nf = ntransform( "world", ShadingNormal( normalize(N) ) );

	uniform vector k_directions[6] =
	{
		(1, 0, 0), (-1, 0, 0),
		(0, 1, 0), (0, -1, 0),
		(0, 0, 1), (0, 0, -1)
	};

	float dot_mix;
	float mode = mod( i_mode, 8 );
	
	if( mode < 6 )
	{
		dot_mix = k_directions[mode] . Nf;
		dot_mix = (dot_mix + 1) *0.5;
	}
	else if( mode == 6 )
	{
		/* camera vs. surface normal */
		dot_mix = abs( vtransform("world", normalize(-I)).Nf );	
	}
	else
	{
		/* custom vector vs surface normal */
		dot_mix = Nf.vector(i_custom_vector);
		dot_mix =(dot_mix+1)*0.5;
	}

	dot_mix = clamp( dot_mix, 0, 1 );
	o_result = dot_mix > 0 ? abs(pow(dot_mix, i_exponenet)) : 0;	
}

#endif
