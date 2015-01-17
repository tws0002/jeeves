/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_illum_shadowmaterial_sl
#define __sib_illum_shadowmaterial_sl

void sib_illum_shadowmaterial(
	float i_min, i_max;
	uniform bool i_rgb, i_shadowvisible;

	output color o_result;
	output float o_result_a; )
{
	extern vector I;
	extern point P;
	extern normal N;

	uniform float __ReceivesShadows = 1;
	attribute("user:__xsi_ReceivesShadows", __ReceivesShadows);

	if( __ReceivesShadows != 0  )
	{
		float shadow_illum = 0;
		float counter = 0;

		if( i_shadowvisible == 0 )
		{
			illuminance( P, N, PI/2 ) 
			{
				color shadow_only=-1;
				lightsource( "o_shadow", shadow_only );

				if( shadow_only != -1 )
				{
					counter += 1;
					shadow_illum += COLOR_LUMA(shadow_only);
				}
			}
		}
		else
		{
			illuminance( P )
			{
				if( L.N > 0 )
				{
					color shadow_only=-1;
					lightsource( "o_shadow", shadow_only );

					if( shadow_only != -1 )
					{
						counter += 1;
						shadow_illum += COLOR_LUMA(shadow_only);
					}
				}
				else
				{
					/* Self-shadows */
					uniform float __CastShadows = 1;
					attribute("user:__xsi_CastShadows", __CastShadows);
					/* There is no self-shadow if object is not shadow caster */
					if(__CastShadows == 1)
					{
						counter += 1;
						uniform float umbra = 1; lightsource( "umbra", umbra );
						shadow_illum += 1-umbra;
					}
				}
			}
		}

		o_result_a = shadow_illum / counter;

		if( o_result_a < i_min )
			o_result_a = 0;
		if( o_result_a > i_max )
			o_result_a = 1; 

		if(i_rgb ==  1)
			o_result = o_result_a;
		else
			o_result = 0;
	}
	else
	{
		o_result = 0;
		o_result_a = 0;
	}
}
#endif
