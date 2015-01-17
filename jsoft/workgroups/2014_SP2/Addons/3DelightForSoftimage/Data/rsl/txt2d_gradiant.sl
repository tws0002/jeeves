/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __txt2d_gradiant_sl
#define __txt2d_gradiant_sl

#include "mib_texture_remap.sl"
#include "mib_color_interpolate.sl"
#include "sib_gradiant.sl"

#define TXT2D_GRADIANT_COLORS \
	RGBA_COLOR( i_color_0 ); \
	RGBA_COLOR( i_color_1 ); \
	RGBA_COLOR( i_color_2 ); \
	RGBA_COLOR( i_color_3 ); \
	RGBA_COLOR( i_color_4 ); \
	RGBA_COLOR( i_color_5 ); \
	RGBA_COLOR( i_color_6 ); \
	RGBA_COLOR( i_color_7 )

#define TXT2D_GRADIANT_COLORS_LIST \
	RGBA_COLOR_PARAM(i_color_0), \
	RGBA_COLOR_PARAM(i_color_1), \
	RGBA_COLOR_PARAM(i_color_2), \
	RGBA_COLOR_PARAM(i_color_3), \
	RGBA_COLOR_PARAM(i_color_4), \
	RGBA_COLOR_PARAM(i_color_5), \
	RGBA_COLOR_PARAM(i_color_6), \
	RGBA_COLOR_PARAM(i_color_7)

#define TXT2D_GRADIANT_OTHER_PARAMS \
	float i_mode, i_x_offset, i_y_offset, i_spread_pitch, i_spread_compact; \
	point i_coord; \
	uniform matrix i_transform; \
	point i_repeats; \
	float i_alt_x, i_alt_y, i_alt_z; \
	point i_min, i_max

#define TXT2D_GRADIANT_PARAMS \
	TXT2D_GRADIANT_COLORS; \
	TXT2D_GRADIANT_OTHER_PARAMS

#define TXT2D_GRADIANT_COMMON_CODE \
	point coord; \
\
	/* TODO: what to do with these? */ \
	uniform float i_torus_x = 0; \
	uniform float i_torus_y = 0; \
	uniform float i_torus_z = 0; \
	uniform point i_offset = 0; \
 \
	mib_texture_remap( \
		i_coord, \
		MIB_TEXTURE_REMAP_PARAMS_LIST, \
		coord ); \
\
	float gradiant; \
	sib_gradiant( coord, i_mode, i_x_offset, i_y_offset, gradiant ); \
	gradiant = BIAS( i_spread_compact, gradiant ); \
	gradiant = GAIN( i_spread_pitch, gradiant );	

void txt2d_gradiant(
	float i_num;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}


void txt2d_gradiant(
	float i_num;
	float i_weight_1;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}

void txt2d_gradiant(
	float i_num;
	float i_weight_1, i_weight_2;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1, i_weight_2,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}

void txt2d_gradiant(
	float i_num;
	float i_weight_1, i_weight_2, i_weight_3;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1, i_weight_2, i_weight_3,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}

void txt2d_gradiant(
	float i_num;
	float i_weight_1, i_weight_2, i_weight_3, i_weight_4;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1, i_weight_2, i_weight_3, i_weight_4,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}

void txt2d_gradiant(
	float i_num;
	float i_weight_1, i_weight_2, i_weight_3, i_weight_4, i_weight_5;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1, i_weight_2, i_weight_3, i_weight_4, i_weight_5,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}


void txt2d_gradiant(
	float i_num;
	float i_weight_1, i_weight_2, i_weight_3, i_weight_4, i_weight_5, i_weight_6;
	TXT2D_GRADIANT_PARAMS; 

	output color o_result;
	output float o_result_a; )
{
	TXT2D_GRADIANT_COMMON_CODE

	mib_color_interpolate( 
		gradiant,
		i_num, i_weight_1, i_weight_2, i_weight_3, i_weight_4, i_weight_5, i_weight_6,
		TXT2D_GRADIANT_COLORS_LIST,
		o_result, o_result_a );
}

#endif
