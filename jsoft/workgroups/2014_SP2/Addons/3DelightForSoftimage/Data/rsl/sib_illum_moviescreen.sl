
#ifndef _sib_illum_moviescreen_h
#define _sib_illum_moviescreen_h

#include "xsi_material.h"

void sib_illum_moviescreen(
	RGBA_COLOR(i_diffuse);
	RGBA_COLOR(i_ambient);
	RGBA_COLOR(i_radiance);

	output color o_res;
	output float o_res_a; )
{
	extern normal N;
	extern point P;

	uniform color ambience = 0.1;
	option( "user:xsi_ambience", ambience );
	o_res = i_ambient*ambience;

	illuminance( P, N, PI/2 )
	{
		o_res += Cl;
	}

	if( i_radiance!=0 )
	{
		o_res += ColorBleeding( i_radiance ) * i_radiance;
	}

	o_res_a = 1;
}

#endif
