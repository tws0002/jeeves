/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_hsl_adjust_sl
#define __sib_color_hsl_adjust_sl

#define mode_MASTER 0 
#define mode_RED 1
#define mode_YELLOW 2
#define mode_GREEN 3
#define mode_CYAN 4
#define mode_BLUE 5
#define mode_MAGENTA 6

void sib_color_hls_adjust(
	RGBA_COLOR(i_color);
	uniform float i_master_h,
		i_master_l, i_master_s,
		i_red_h, i_red_l, i_red_s,
		i_green_h, i_green_l, i_green_s,
		i_blue_h, i_blue_l, i_blue_s,
		i_cyan_h, i_cyan_l, i_cyan_s,
		i_yellow_h, i_yellow_l, i_yellow_s,
		i_magenta_h, i_magenta_l, i_magenta_s;
	output color o_result;
	output float o_result_a; )
{
	color hsl = ctransform( "hsl", i_color );
	hsl[0] *= 360;

	/* Choose the slice as a +/- 30° around the color axis in question */
	float huesel = floor( ( mod( hsl[0] + 30.0, 360.0 ) / 60.0 ) ) + 1;

	float hue_master = i_master_h;
	float lightness_master = i_master_l / 100.0;
	float saturation_master = i_master_s / 100.0;

	float hue, lightness, saturation;

	if( huesel == mode_MASTER )
	{
		hue = i_master_h;
		lightness = i_master_l / 100.0;
		saturation = i_master_s / 100.0;
	}
	else if( huesel == mode_RED )
	{
		hue = i_red_h;
		lightness = i_red_l / 100.0;
		saturation = i_red_s / 100.0;
	}
	else if( huesel == mode_GREEN )
	{
		hue = i_green_h;
		lightness = i_green_l / 100.0;
		saturation = i_green_s / 100.0;
	}
	else if( huesel == mode_BLUE )
	{
		hue = i_blue_h;
		lightness = i_blue_l / 100.0;
		saturation = i_blue_s / 100.0;
	}
	else if( huesel == mode_CYAN )
	{
		hue = i_cyan_h;
		lightness = i_cyan_l / 100.0;
		saturation = i_cyan_s / 100.0;
	}
	else if( huesel == mode_YELLOW )
	{
		hue = i_yellow_h;
		lightness = i_yellow_l / 100.0;
		saturation = i_yellow_s / 100.0;
	}
	else if( huesel == mode_MAGENTA )
	{
		hue = i_magenta_h;
		lightness = i_magenta_l / 100.0;
		saturation = i_magenta_s / 100.0;
	}
	else
	{
		hue = hue_master;
		lightness = lightness_master;
		saturation = saturation_master;
	}

	/* Adjust the hue and wrap around if values go outside of boundaries */
	hsl[0] += hue_master + hue;
	hsl[0] /= 360.0;
	hsl[0] = SLICE( hsl[0] );

	float val = ( lightness_master + lightness ) * 0.5;
	if( val < 0 )
		hsl[2] *= ( 1.0 + val );
	else
		hsl[2] += ( ( 1.0 - hsl[2] ) * val );

	hsl[1] *= (1.0 + saturation_master + saturation);

	o_result = ctransform( "hsl", "rgb", hsl );
	o_result_a = i_color_a;
}
#endif
