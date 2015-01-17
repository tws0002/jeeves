/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_billboard_sl
#define __pt_billboard_sl

#include "pt_shade.sl"

#define bool float
#define enum float

#define NORMAL_PLANAR 0
#define NORMAL_SPHERICAL 1

#define DIRECTION_FACE_CAMERA 0
#define DIRECTION_FACE_CAMERA_LIGHTS 1
#define DIRECTION_FACE_INCOMING_RAY 2
#define DIRECTION_USE_ROTATION 3

#define TEXTURE_COORD_PLANAR 0
#define TEXTURE_COORD_PARTICLE_LOCAL 1
#define TEXTURE_COORD_CLOUD_LOCAL 2
#define TEXTURE_COORD_WORLD 3

#define SHAPE_SQUARE 0
#define SHAPE_RECTANGULAR 1
#define SHAPE_CIRCULAR 2

#define COLOR_BURN_MAX 0.999

void pt_billboard(
	RGBA_DECLARE(i_color);			/* used */
	enum i_normalType;				/* used */
	float i_selfShadow;				/* unused */
	point i_bump;					/* unused */
	enum i_direction;				/* geo */
	enum i_textureCoord;			/* unused */
	enum i_shape;					/* used */
	bool i_followVelocity;			/* geo */
	bool i_shading;					/* used */
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

	output color o_result;
	output float o_result_a; )
{
	extern varying float u;
	extern varying float v;
	extern varying normal N;
	extern varying vector dPdu;
	extern varying vector dPdv;
	extern varying color Oi;
	extern uniform string type;

	float coverage = 1;
	float centeredU = u - 0.5;
	float centeredV = v - 0.5;
	float distance2 = centeredU*centeredU + centeredV*centeredV;
	if(i_shape == SHAPE_CIRCULAR && type != "particle")
	{
		float d = sqrt(distance2);
		coverage = 1 - filterstep(0.5, d);
	}

	if(coverage > 0)
	{
		N = normalize(N);
		if(i_normalType == NORMAL_SPHERICAL && type != "particle")
		{
			float radius2 = 0.5;
			if(i_shape == SHAPE_CIRCULAR)
			{
				radius2 = 0.25;
			}
			float centeredW = sqrt(max(0, radius2 - distance2));
			vector Uaxis = normalize(dPdu);
			vector Vaxis = normalize(dPdv);
			vector newN = centeredU*Uaxis + centeredV*Vaxis + centeredW*N;
			N = normal(normalize(newN));
		}

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
	}

	float burnFactor = 1.0 - clamp(i_colorBurn, 0, COLOR_BURN_MAX);
	o_result_a *= coverage;
	o_result *= o_result_a;
	Oi = o_result_a * burnFactor;
}

#undef NORMAL_TYPE_PLANAR
#undef NORMAL_TYPE_SPHERICAL

#undef DIRECTION_FACE_CAMERA
#undef DIRECTION_FACE_CAMERA_LIGHTS
#undef DIRECTION_FACE_INCOMING_RAY
#undef DIRECTION_USE_ROTATION

#undef TEXTURE_COORD_PLANAR
#undef TEXTURE_COORD_PARTICLE_LOCAL
#undef TEXTURE_COORD_CLOUD_LOCAL
#undef TEXTURE_COORD_WORLD

#undef SHAPE_SQUARE
#undef SHAPE_RECTANGULAR
#undef SHAPE_CIRCULAR

#undef COLOR_BURN_MAX

#endif
