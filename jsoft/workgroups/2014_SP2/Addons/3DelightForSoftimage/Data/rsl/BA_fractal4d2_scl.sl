/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __BA_fractal4d2_scl_sl
#define __BA_fractal4d2_scl_sl

#include "BA_utils.sl"

#define PRESCALE_BIG 0
#define PRESCALE_DEFAULT 1
#define PRESCALE_SMALL 2

#define ANIM_NONE 0
#define ANIM_CONSTANT 1
#define ANIM_USER 2

#define NOISE_TYPE_PERLIN 1
#define NOISE_TYPE_FRACTAL_SUM 2
#define NOISE_TYPE_TURBULENCE 3

#define DISTORT_MAGIC_1 3.33
#define DISTORT_MAGIC_2 4.44

float BA_noise3Dor4D(
	point i_xyz;
	float i_w;
	bool i_4D)
{
	return i_4D != false ? noise(i_xyz, i_w) : noise(i_xyz);
}

point BA_distort(
	float i_distort;
	float i_distort_scale;
	point i_xyz;
	float i_w;
	bool i_4D)
{
	if(i_distort == 0.0)
	{
		return i_xyz;
	}

	point p1 = i_xyz;
	point p2 = (p1 + 0.5) * i_distort_scale;
	p1[0] += i_distort * BA_noise3Dor4D(p2, i_w, i_4D);
	p2 += vector(DISTORT_MAGIC_1);
	p1[1] += i_distort * BA_noise3Dor4D(p2, i_w, i_4D);
	p2 += vector(DISTORT_MAGIC_2);
	p1[2] += i_distort * BA_noise3Dor4D(p2, i_w, i_4D);
	return BA_noise3Dor4D(p1, i_w, i_4D);
// FIXME :	return i_4D ? noise(p1, i_w) : noise(p1);
}

float BA_noise(
	point i_xyz;
	float i_w;
	bool i_4D;
	float i_noise_type;
	float i_recursion;
	float i_lvl_scale;
	float i_lvl_gain;
	float i_distort;
	float i_distort_scale)
{
	float levels =
		i_noise_type != NOISE_TYPE_FRACTAL_SUM && 
		i_noise_type != NOISE_TYPE_TURBULENCE
		? 1 : i_recursion;
	
	point xyz = i_xyz;
	float w = i_w;
	float frequence = 1.0;
	float t = 0.0;
	while(levels >= 1)
	{
		point p = BA_distort(i_distort, i_distort_scale, xyz, w, i_4D);
		float n = BA_noise3Dor4D(p, w, i_4D) * 2.0 - 1.0;
		if(i_noise_type == NOISE_TYPE_TURBULENCE)
		{
			n = abs(n);
		}
		t += n / frequence;
		xyz *= i_lvl_scale;
		w *= i_lvl_scale;
		frequence *= i_lvl_gain;
		levels -= 1;
	}
	
	if(i_noise_type != NOISE_TYPE_TURBULENCE)
	{
		t = (t+1.0)/2.0;
	}
	return t;
}

void BA_fractal4d2_scl(
	float i_color1;
	float i_color2;
	float i_grad_min;
	float i_grad_bias;
	float i_grad_max;
	float i_noise_type;
	float i_recursion;
	float i_lvl_gain;
	float i_time;
	float i_lvl_scale;
	bool i_external_coord;
	point i_ext_coord;
	point i_coord;
	point i_coord_scale;
	float i_distort;
	float i_distort_scale;
	float i_coord_prescale;
	bool i_color_invert;
	float i_time_anim_type;
	float i_time_constant;
	float i_coord_scale_global;
	output float o_result)
{
	point coord_scale = i_coord_scale;
	if(i_coord_prescale == PRESCALE_BIG)
	{
		coord_scale /= 50.0;
	}
	else if(i_coord_prescale == PRESCALE_SMALL)
	{
		coord_scale *= 50.0;
	}
	
	coord_scale *= i_coord_scale_global * 0.1;
	
	bool useTime = i_time_anim_type == ANIM_NONE ? false : true;
	float time = i_time;
	if(i_time_anim_type == ANIM_CONSTANT)
	{
		uniform float frameNumber;
		if(option("Ri:FrameBegin", frameNumber))
		{
			time = i_time_constant * frameNumber * 0.01;
		}
	}

	point coord;
	if(i_external_coord == false)
	{
		coord = i_coord;
	}
	else if(i_ext_coord[0] != point(0))
	{
		coord = i_ext_coord;
	}
	else
	{
		coord = transform("object", P);
	}
	
	coord *= coord_scale;
	
	float a = 
		BA_noise(
			coord, 
			time, 
			useTime, 
			i_noise_type, 
			i_recursion, 
			i_lvl_scale, 
			i_lvl_gain, 
			i_distort, 
			i_distort_scale);
	
	if(i_grad_min != i_grad_max)
	{
		a = (a-i_grad_min) / (i_grad_max-i_grad_min);
	}
	a = BA_bias(a, i_grad_bias);

	float c1 = i_color_invert ? i_color2 : i_color1;
	float c2 = i_color_invert ? i_color1 : i_color2;
	o_result = a >= 1.0 ? c2 : a <= 0.0 ? c1 : mix(c1, c2, a);
}

#endif
