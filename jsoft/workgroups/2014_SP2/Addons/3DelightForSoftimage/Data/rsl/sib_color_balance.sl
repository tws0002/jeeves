/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_balance_sl
#define __sib_color_balance_sl

float weird_formula_1( float i_value )
{
	return( (2/3) * (1 - sqr(i_value-0.5)) );
}

float weird_formula_2( float i_value )
{
	return( 1.075 - 1.0 / ( i_value * 16.0 + 1.0 ) );
}

float balance_channel(
	float in_value, in_shadow, in_midtone, in_highlight )
{
	float result = in_value;

	if( in_shadow > 0.0 )
		result += in_shadow * weird_formula_1( result );
	else
		result += in_shadow * weird_formula_2( 1.0 - result );

	result = clamp( result, 0.0, 1.0 );

	result += in_midtone * weird_formula_1( result );
	result = clamp( result, 0.0, 1.0 );

	if( in_highlight > 0.0 )
		result += in_highlight * weird_formula_2( result );
	else
		result += in_highlight * weird_formula_1( result );

	result = clamp( result, 0.0, 1.0 );

	return result;
}


void sib_color_balance(
	RGBA_COLOR( i_color );
	float i_shadows_red, i_shadows_green, i_shadows_blue;
	float i_midtones_red, i_midtones_green, i_midtones_blue;
	float i_highlights_red, i_highlights_green, i_highlights_blue;
	float i_preserve_luminosity; 
	
	output color o_result;
	output float o_result_a;)
{
	float R = balance_channel( 
		comp(i_color, 0), 
		i_shadows_red / 255.0,
		i_midtones_red / 255.0,
		i_highlights_red / 255.0);

	float G = balance_channel( 
		comp(i_color, 1), 
		i_shadows_green / 255.0,
		i_midtones_green / 255.0,
		i_highlights_green / 255.0);
	
	float B = balance_channel( 
		comp(i_color, 2), 
		i_shadows_blue / 255.0,
		i_midtones_blue / 255.0,
		i_highlights_blue / 255.0);

	o_result = color( R, G, B );
	o_result_a = i_color_a;

	if( i_preserve_luminosity != 0 )
	{
		// Get the luminosity of the original input color
		// and substitute that in place of the balanced
		// luminosity.
		color hls = ctransform( "hls", o_result );

		float _max = max( max( comp(i_color,0), comp(i_color,1) ), comp(i_color,2) );
		float _min = min( min( comp(i_color,0), comp(i_color,1) ), comp(i_color,2) );

		setcomp( hls, 1, (_max + _min) * 0.5 );

		o_result = ctransform( "rgb", "hls", hls );
	}
}
#endif

