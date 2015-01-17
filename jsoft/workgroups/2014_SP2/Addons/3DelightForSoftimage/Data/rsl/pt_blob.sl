/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_blob_sl
#define __pt_blob_sl

#include "pt_shade.sl"

#define bool float
#define enum float

#define BLEND_MAXIMUM 0
#define BLEND_WEIGHTED 1
#define BLEND_AVERAGE 2

#define TEXTURE_COORD_SPHERICAL 0
#define TEXTURE_COORD_CYLINDRICAL 1
#define TEXTURE_COORD_LOLLIPOP 2
#define TEXTURE_COORD_PARTICLE_LOCAL 3
#define TEXTURE_COORD_CLOUD_LOCAL 4
#define TEXTURE_COORD_WORLD 5

#define COLOR_BURN_MAX 0.999

void pt_blob(
	RGBA_DECLARE(i_color);			/* used */
	point i_bump;					/* unused */
	float i_blending;				/* unused */
	enum i_blendType;				/* unused */
	enum i_textureCoord;			/* unused */
	bool i_useRotation;				/* unused */
	bool i_sumTextures;				/* unused */
	bool i_blurActive;				/* unused */
	float i_blurWidth;				/* unused */
	float i_blurExponent;			/* unused */
	bool i_shading;					/* used */
	float i_selfShadow;				/* unused */
	enum i_ambientType;				/* used */
	RGBA_DECLARE(i_ambience);		/* used */
	RGBA_DECLARE(i_ambient);		/* used */
	float i_ambientPercentage;		/* used */
	enum i_specularType;			/* used */
	RGBA_DECLARE(i_specular);		/* used */
	float i_specularPercentage;		/* used */
	float i_shiny;					/* used */
	enum i_irradianceType;			/* used */
	RGBA_DECLARE(i_irradiance);		/* used */
	float i_irradiancePercentage;	/* used */
	enum i_radianceType;			/* used */
	RGBA_DECLARE(i_radiance);		/* used */
	float i_radiancePercentage;		/* used */
	float i_colorBurn;				/* used */
	float i_scaling;				/* unused */

	output color o_result;
	output float o_result_a; )
{
	extern varying normal N;
	extern varying vector I;
	extern varying color Oi;

	N = ShadingNormal( normalize(N) );

	pt_shade(
		RGBA_USE(i_color),
		i_shading,
		i_ambientType,
		RGBA_USE(i_ambience),
		RGBA_USE(i_ambient),
		i_ambientPercentage,
		i_specularType,
		RGBA_USE(i_specular),
		i_specularPercentage,
		i_shiny,
		i_irradianceType,
		RGBA_USE(i_irradiance),
		i_irradiancePercentage,
		i_radianceType,
		RGBA_USE(i_radiance),
		i_radiancePercentage,
		o_result,
		o_result_a);
		
	float burnFactor = 1.0 - clamp(i_colorBurn, 0, COLOR_BURN_MAX);
	o_result *= o_result_a;
	Oi = o_result_a * burnFactor;
}

#undef BLEND_TYPE_MAXIMUM
#undef BLEND_TYPE_WEIGHTED
#undef BLEND_TYPE_AVERAGING

#undef TEXTURE_COORD_SPHERICAL
#undef TEXTURE_COORD_CYLINDRICAL
#undef TEXTURE_COORD_LOLLIPOP
#undef TEXTURE_COORD_PARTICLE_LOCAL
#undef TEXTURE_COORD_CLOUD_LOCAL
#undef TEXTURE_COORD_WORLD

#undef COLOR_BURN_MAX

#endif
