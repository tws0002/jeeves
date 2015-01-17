/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_color_interpolate_sl
#define __mib_color_interpolate_sl

#include "xsi_color.h"

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1, i_weight2, i_weight3, i_weight4, i_weight5, i_weight6;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	if( i_num < 1 )
	{
		o_result = 0;
		o_result_a = 0;
	}
	else if( i_num == 1 )
	{
		RGBA_ASSIGN( o_result, i_color_0 );
	}
	else
	{
		uniform float num = i_num;
		if (num > 8)
			num = 8;

		color colors[8] = {
			i_color_0, i_color_1, i_color_2, i_color_3,
			i_color_4, i_color_5, i_color_6, i_color_7 };

		float colors_a[8] = {
			i_color_0_a, i_color_1_a, i_color_2_a, i_color_3_a,
			i_color_4_a, i_color_5_a, i_color_6_a, i_color_7_a };

		float weights[6] = {
			i_weight1, i_weight2, i_weight3, i_weight4,
			i_weight5, i_weight6 };

		if( i_input <= 0 )
		{ 
			RGBA_ASSIGN( o_result, i_color_0 );
		}
		else if( i_input >= 1 )
		{
			o_result = colors[num-1];
			o_result_a = colors_a[num-1];
		}
		else
		{
			float prev = 0;
			float next = 1;
			float i;

			for( i=0; i<num-2; i+=1 )
			{
				next = weights[i];

				if( i_input <= next )
					break;

				prev = next;
				next = 1;
			}

			float w = (i_input - prev) / (next - prev);
			float w_1 = 1.0 - w;

			if( i_input == 0 )
			{
				o_result = colors[i];
				o_result_a = colors_a[i];
			}
			else if( i_input == 1 )
			{
				o_result = colors[i+1];
				o_result_a = colors_a[i+1];
			}
			else
			{
				color pcol = colors[i];
				color ncol = colors[i+1];

				o_result[0] = w_1 * pcol[0] + w * ncol[0];
				o_result[1] = w_1 * pcol[1] + w * ncol[1];
				o_result[2] = w_1 * pcol[2] + w * ncol[2];
				o_result_a = w_1 * colors_a[i] + w * colors_a[i+1];
			}
		}
	}
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1, i_weight2, i_weight3, i_weight4, i_weight5;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	mib_color_interpolate(
		i_input, i_num,
		i_weight1, i_weight2, i_weight3, i_weight4, i_weight5, 0,
		RGBA_COLOR_PARAM(i_color_0),
		RGBA_COLOR_PARAM(i_color_1),
		RGBA_COLOR_PARAM(i_color_2),
		RGBA_COLOR_PARAM(i_color_3),
		RGBA_COLOR_PARAM(i_color_4),
		RGBA_COLOR_PARAM(i_color_5),
		RGBA_COLOR_PARAM(i_color_6),
		RGBA_COLOR_PARAM(i_color_7),
		o_result, o_result_a );
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1, i_weight2, i_weight3, i_weight4;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	mib_color_interpolate(
		i_input, i_num,
		i_weight1, i_weight2, i_weight3, i_weight4, 0, 0,
		RGBA_COLOR_PARAM(i_color_0),
		RGBA_COLOR_PARAM(i_color_1),
		RGBA_COLOR_PARAM(i_color_2),
		RGBA_COLOR_PARAM(i_color_3),
		RGBA_COLOR_PARAM(i_color_4),
		RGBA_COLOR_PARAM(i_color_5),
		RGBA_COLOR_PARAM(i_color_6),
		RGBA_COLOR_PARAM(i_color_7),
		o_result, o_result_a );
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1, i_weight2, i_weight3;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	mib_color_interpolate(
		i_input, i_num,
		i_weight1, i_weight2, i_weight3, 0, 0, 0,
		RGBA_COLOR_PARAM(i_color_0),
		RGBA_COLOR_PARAM(i_color_1),
		RGBA_COLOR_PARAM(i_color_2),
		RGBA_COLOR_PARAM(i_color_3),
		RGBA_COLOR_PARAM(i_color_4),
		RGBA_COLOR_PARAM(i_color_5),
		RGBA_COLOR_PARAM(i_color_6),
		RGBA_COLOR_PARAM(i_color_7),
		o_result, o_result_a );
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1, i_weight2;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	mib_color_interpolate(
		i_input, i_num,
		i_weight1, i_weight2, 0, 0, 0, 0,
		RGBA_COLOR_PARAM(i_color_0),
		RGBA_COLOR_PARAM(i_color_1),
		RGBA_COLOR_PARAM(i_color_2),
		RGBA_COLOR_PARAM(i_color_3),
		RGBA_COLOR_PARAM(i_color_4),
		RGBA_COLOR_PARAM(i_color_5),
		RGBA_COLOR_PARAM(i_color_6),
		RGBA_COLOR_PARAM(i_color_7),
		o_result, o_result_a );
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	float i_weight1;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	mib_color_interpolate(
		i_input, i_num,
		i_weight1, 0, 0, 0, 0, 0,
		RGBA_COLOR_PARAM(i_color_0),
		RGBA_COLOR_PARAM(i_color_1),
		RGBA_COLOR_PARAM(i_color_2),
		RGBA_COLOR_PARAM(i_color_3),
		RGBA_COLOR_PARAM(i_color_4),
		RGBA_COLOR_PARAM(i_color_5),
		RGBA_COLOR_PARAM(i_color_6),
		RGBA_COLOR_PARAM(i_color_7),
		o_result, o_result_a );
}

void mib_color_interpolate(
	float i_input;
	float i_num;
	RGBA_COLOR(i_color_0);
	RGBA_COLOR(i_color_1);
	RGBA_COLOR(i_color_2);
	RGBA_COLOR(i_color_3);
	RGBA_COLOR(i_color_4);
	RGBA_COLOR(i_color_5);
	RGBA_COLOR(i_color_6);
	RGBA_COLOR(i_color_7);

	output color o_result;
	output float o_result_a; )
{
	RGBA_MIX( o_result, i_color_0, i_color_1, i_input );
}


#endif
