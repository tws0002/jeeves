/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_illum_phong_sl
#define __sib_illum_phong_sl

#include "simple_phong.sl"

void sib_illum_phong(
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_diffuse );
	RGBA_DECLARE( i_specular );
	RGBA_DECLARE( i_ambience );
	float i_shinyness;
	point i_bump;
	RGBA_DECLARE( i_radiance );
	float i_radiance_filter;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	simple_phong(
		i_ambient, i_diffuse, i_specular, i_ambience, 
		i_shinyness, i_bump, i_radiance, i_radiance );
}

void sib_illum_phong(
	RGBA_DECLARE( i_ambient );
	RGBA_DECLARE( i_diffuse );
	RGBA_DECLARE( i_specular );
	float i_shinyness;
	point i_bump;
	RGBA_DECLARE( i_radiance );
	float i_radiance_filter;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	sib_illum_phong(
		RGBA_USE(i_ambient),
		RGBA_USE(i_diffuse),
		RGBA_USE(i_specular),
		color(0, 0, 0), 0,
		i_shinyness,
		i_bump,
		RGBA_USE(i_radiance),
		i_radiance_filter,
		RGBA_USE(o_result));
}