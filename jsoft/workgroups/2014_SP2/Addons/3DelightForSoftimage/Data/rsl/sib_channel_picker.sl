/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_channel_picker_sl
#define __sib_channel_picker_sl

#define CSPACE_RGBA	1
#define CSPACE_HLSA	2
#define CSPACE_HSVA	3

#define CHANNEL_RGBA_R		1
#define CHANNEL_RGBA_G		2
#define CHANNEL_RGBA_B		3
#define CHANNEL_RGBA_A		4
#define CHANNEL_AVERAGE_RGB	5
#define CHANNEL_AVERAGE_RGBA 6
#define CHANNEL_MAX_RGB		7
#define CHANNEL_MIN_RGB		8
#define CHANNEL_MAX_RGBA	9
#define CHANNEL_MIN_RGBA	10

#define CHANNEL_HLSA_H		1
#define CHANNEL_HLSA_L		2
#define CHANNEL_HLSA_S		3
#define CHANNEL_HLSA_A		4

#define CHANNEL_HSVA_H		1
#define CHANNEL_HSVA_S		2
#define CHANNEL_HSVA_V		3
#define CHANNEL_HSVA_A		4

void sib_channel_picker(
	RGBA_COLOR(i_input);
	float i_colspace;

	float i_channel_rgba, i_channel_hlsa, i_channel_hsva;
	float i_invert, i_premultiply;

	output float o_result; )
{
	o_result = 0;
	float premultiply = i_premultiply;

	if( i_colspace == CSPACE_RGBA )
	{
		float i_channel = i_channel_rgba;

		if (i_channel == CHANNEL_RGBA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			if( i_channel == CHANNEL_RGBA_R )
				o_result = comp(i_input, 0); 
			else if( i_channel == CHANNEL_RGBA_G )	
				o_result = comp(i_input, 1);
			else if( i_channel == CHANNEL_RGBA_B )	
				o_result = comp(i_input, 2);
			else if( i_channel == CHANNEL_AVERAGE_RGB )
				o_result = ( comp(i_input,0) + comp(i_input,1) + comp(i_input,2) ) / 3;
			else if( i_channel == CHANNEL_AVERAGE_RGBA )
				o_result =  ( comp(i_input,0) + comp(i_input,1) + comp(i_input,2) + i_input_a ) / 4;
			else if( i_channel == CHANNEL_MAX_RGB )
				o_result = max( comp(i_input,0), comp(i_input,1), comp(i_input,2) );
			else if( i_channel == CHANNEL_MIN_RGB )
				o_result = min( comp(i_input,0), comp(i_input,1), comp(i_input,2) );
			else if( i_channel ==  CHANNEL_MAX_RGBA )
				o_result = max( comp(i_input,0), comp(i_input,1), comp(i_input,2), i_input_a );
			else if( i_channel == CHANNEL_MIN_RGBA )
				o_result = min( comp(i_input,0), comp(i_input,1), comp(i_input,2), i_input_a );
		}
	}
	else if( i_colspace == CSPACE_HLSA )
	{
		float i_channel = i_channel_hlsa;

		if( i_channel == CHANNEL_HLSA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			color l_hls = ctransform( "hsl", i_input );
			if( i_channel == CHANNEL_HLSA_H )
				o_result = comp(l_hls, 0);
			else if( i_channel == CHANNEL_HLSA_L )	
				o_result = comp(l_hls,2);
			else if( i_channel == CHANNEL_HLSA_S )	
				o_result = comp(l_hls,1);
		} 
	}
	else if( i_colspace == CSPACE_HSVA )
	{
		float i_channel = i_channel_hsva;

		if( i_channel == CHANNEL_HSVA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			color l_hsv = ctransform( "hsv", i_input );
			if( i_channel == CHANNEL_HSVA_H )
				o_result = comp(l_hsv, 0);
			else if( i_channel == CHANNEL_HSVA_S )	
				o_result = comp(l_hsv,1);
			else if( i_channel == CHANNEL_HSVA_V )	
				o_result = comp(l_hsv,2);
		}
	}

	if( i_invert != 0 )
		o_result = 1 - o_result;

	if( premultiply != 0 ) 
		o_result = o_result * i_input_a;
} 

void sib_channel_picker(
	RGBA_COLOR(i_input);
	float i_colspace;
	float i_channel;
	float i_invert, i_premultiply;

	output float o_result; )
{
	o_result = 0;
	float premultiply = i_premultiply;

	if( i_colspace == CSPACE_RGBA )
	{
		if (i_channel == CHANNEL_RGBA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			if( i_channel == CHANNEL_RGBA_R )
				o_result = comp(i_input, 0); 
			else if( i_channel == CHANNEL_RGBA_G )	
				o_result = comp(i_input, 1);
			else if( i_channel == CHANNEL_RGBA_B )	
				o_result = comp(i_input, 2);
			else if( i_channel == CHANNEL_AVERAGE_RGB )
				o_result = ( comp(i_input,0) + comp(i_input,1) + comp(i_input,2) ) / 3;
			else if( i_channel == CHANNEL_AVERAGE_RGBA )
				o_result =  ( comp(i_input,0) + comp(i_input,1) + comp(i_input,2) + i_input_a ) / 4;
			else if( i_channel == CHANNEL_MAX_RGB )
				o_result = max( comp(i_input,0), comp(i_input,1), comp(i_input,2) );
			else if( i_channel == CHANNEL_MIN_RGB )
				o_result = min( comp(i_input,0), comp(i_input,1), comp(i_input,2) );
			else if( i_channel ==  CHANNEL_MAX_RGBA )
				o_result = max( comp(i_input,0), comp(i_input,1), comp(i_input,2), i_input_a );
			else if( i_channel == CHANNEL_MIN_RGBA )
				o_result = min( comp(i_input,0), comp(i_input,1), comp(i_input,2), i_input_a );
		}
	}
	else if( i_colspace == CSPACE_HLSA )
	{
		if( i_channel == CHANNEL_HLSA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			color l_hls = ctransform( "hsl", i_input );
			if( i_channel == CHANNEL_HLSA_H )
				o_result = comp(l_hls, 0);
			else if( i_channel == CHANNEL_HLSA_L )	
				o_result = comp(l_hls,2);
			else if( i_channel == CHANNEL_HLSA_S )	
				o_result = comp(l_hls,1);
		} 
	}
	else if( i_colspace == CSPACE_HSVA )
	{
		if( i_channel == CHANNEL_HSVA_A) 
		{
			o_result = i_input_a;
			premultiply = 0;
		}
		else
		{
			color l_hsv = ctransform( "hsv", i_input );
			if( i_channel == CHANNEL_HSVA_H )
				o_result = comp(l_hsv, 0);
			else if( i_channel == CHANNEL_HSVA_S )	
				o_result = comp(l_hsv,1);
			else if( i_channel == CHANNEL_HSVA_V )	
				o_result = comp(l_hsv,2);
		}
	}

	if( i_invert != 0 )
		o_result = 1 - o_result;

	if( premultiply != 0 ) 
		o_result = o_result * i_input_a;
} 
#endif
