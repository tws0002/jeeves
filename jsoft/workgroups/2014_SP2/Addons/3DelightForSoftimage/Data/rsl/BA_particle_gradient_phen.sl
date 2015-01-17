/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __BA_particle_gradient_phen_sl
#define __BA_particle_gradient_phen_sl

#include "BA_particle_gradientcontrol.sl"
#include "sib_color_gradient.sl"

#define bool float
#define false 0

void BA_particle_gradient_phen(
	uniform float i_start1;
	uniform float i_end1;
	float i_intensity1;
	uniform float i_start2;
	uniform float i_end2;
	float i_intensity2;
	uniform bool i_enable3;
	float i_input3;
	uniform float i_start3;
	uniform float i_end3;
	float i_intensity3;
	uniform bool i_enable4;
	float i_input4;
	uniform float i_start4;
	uniform float i_end4;
	float i_intensity4;
	uniform bool i_enable5;
	float i_input5;
	uniform float i_start5;
	uniform float i_end5;
	float i_intensity5;
	uniform bool i_enable6;
	float i_input6;
	uniform float i_start6;
	uniform float i_end6;
	float i_intensity6;
	bool i_invert;
	float i_rgba_interpolation;
	RGBA_DECLARE(i_color1);
	float i_pos_color1;
	float i_mid_color1;
	RGBA_DECLARE(i_color2);
	float i_pos_color2;
	float i_mid_color2;
	RGBA_DECLARE(i_color3);
	float i_pos_color3;
	float i_mid_color3;
	RGBA_DECLARE(i_color4);
	float i_pos_color4;
	float i_mid_color4;
	RGBA_DECLARE(i_color5);
	float i_pos_color5;
	float i_mid_color5;
	RGBA_DECLARE(i_color6);
	float i_pos_color6;
	float i_mid_color6;
	RGBA_DECLARE(i_color7);
	float i_pos_color7;
	float i_mid_color7;
	RGBA_DECLARE(i_color8);
	float i_pos_color8;
	float i_mid_color8;
	uniform bool i_adjust1;
	uniform bool i_adjust2;
	uniform bool i_adjust3;
	uniform bool i_adjust4;
	uniform bool i_adjust5;
	uniform bool i_adjust6;
	RGBA_DECLARE_OUTPUT(o_output); )
{
	float control;
	BA_particle_gradientcontrol(
		i_start1, i_end1, i_intensity1,
		i_start2, i_end2, i_intensity2,
		i_enable3, i_input3, i_start3, i_end3, i_intensity3,
		i_enable4, i_input4, i_start4, i_end4, i_intensity4,
		i_enable5, i_input5, i_start5, i_end5, i_intensity5,
		i_enable6, i_input6, i_start6, i_end6, i_intensity6,
		i_adjust1, i_adjust2, i_adjust3, i_adjust4, i_adjust5, i_adjust6,
		control);

	/* TODO : split sib_color_gradient */

	float i_alpha_interpolation = LINEARINTERPOL;
	float i_gradient_type = VERTICAL_GRADIENT;
	float i_inverse = i_invert;
	float i_clip = false;
	float i_enable_alpha_gradient = false;
	float i_gradient_min = 0.0;
	float i_gradient_max = 1.0;
	GRAD_ALPHA_DECLARE(alpha1);
	GRAD_ALPHA_DECLARE(alpha2);
	GRAD_ALPHA_DECLARE(alpha3);
	GRAD_ALPHA_DECLARE(alpha4);
	GRAD_ALPHA_DECLARE(alpha5);
	GRAD_ALPHA_DECLARE(alpha6);
	GRAD_ALPHA_DECLARE(alpha7);
	GRAD_ALPHA_DECLARE(alpha8);
	sib_color_gradient(
		control,
		point(0),
		SCALAR_INPUT,
		SIB_COLOR_GRADIENT_PARAMS_USE,
		RGBA_USE(o_output));
}

#endif
