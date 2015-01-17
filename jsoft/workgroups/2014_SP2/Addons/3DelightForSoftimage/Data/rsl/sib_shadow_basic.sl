/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_shadow_basic_sl
#define __sib_shadow_basic_sl

void sib_shadow_basic(
	float i_mode;
	RGBA_COLOR( i_diffuse );
	RGBA_COLOR( i_transparency );
	float i_scaletrans;
	float i_inverttrans;
	float i_usealphatrans;
	float i_transpenabled;
	
	output color o_result;
	output float o_result_a; )	
{
	uniform string raytype;
	rayinfo( "type", raytype);

	o_result = 0;
	o_result_a = 0;	

	if( raytype != "transmission" )
	{
		/* should not use this in non shadow mode */
		o_result = 1;
		o_result_a = 0;
	}
	else if ( i_transpenabled == 1 )
	{
		RGBA_COLOR( transparency );
		RGBA_ASSIGN( transparency, i_transparency );

		if( i_usealphatrans != 0 )
			transparency = transparency_a;

		if ( i_inverttrans == 1 )
			transparency = 1 - transparency;

		transparency *= i_scaletrans;

		if( !BLACK(transparency) )
		{
			o_result = 1;

			uniform float c;
			for( c=0; c<3; c += 1 )
			{	
				float t = comp(transparency, c);
				if( t<0.5 ) 
					setcomp( o_result, c, 2 * t * comp(i_diffuse, c) );
				else 
				{
					float f = 2 * (t - 0.5);
					float omf = 1 - f;
					setcomp( o_result, c, f + omf*comp(i_diffuse, c) );
				}
			}
		}
	}
}
#endif
