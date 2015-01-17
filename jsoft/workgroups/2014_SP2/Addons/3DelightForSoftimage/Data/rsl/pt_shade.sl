/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_shade_sl
#define __pt_shade_sl

#define bool float
#define enum float

#define AMBIENT_NONE 0
#define AMBIENT_USE_COLOR 1
#define AMBIENT_USE_PERCENTAGE 2

#define SPECULAR_NONE 0
#define SPECULAR_USE_COLOR 1
#define SPECULAR_USE_PERCENTAGE 2

#define IRRADIANCE_NONE 0
#define IRRADIANCE_USE_COLOR 1
#define IRRADIANCE_USE_PERCENTAGE 2

#define RADIANCE_NONE 0
#define RADIANCE_USE_COLOR 1
#define RADIANCE_USE_PERCENTAGE 2

void pt_shade(
	RGBA_DECLARE(i_color);			/* used, wrong shading model */
	bool i_shading;					/* used */
	enum i_ambientType;				/* used */
	RGBA_DECLARE(i_ambience);		/* used */
	RGBA_DECLARE(i_ambient);		/* used */
	float i_ambientPercentage;		/* used */
	enum i_specularType;			/* used */
	RGBA_DECLARE(i_specular);		/* used, wrong shading model */
	float i_specularPercentage;		/* used */
	float i_shiny;					/* used, wrong shading model */
	enum i_irradianceType;			/* used */
	RGBA_DECLARE(i_irradiance);		/* unused */
	float i_irradiancePercentage;	/* used */
	enum i_radianceType;			/* used */
	RGBA_DECLARE(i_radiance);		/* unused */
	float i_radiancePercentage;		/* used */

	output color o_result;
	output float o_result_a; )
{
	extern varying normal N;
	extern varying vector I;
	extern varying point E;

	RGBA_DECLARE_INIT4(ambience, 0, 0, 0, 0);
	RGBA_DECLARE_INIT4(ambient, 0, 0, 0, 0);
	RGBA_DECLARE_INIT4(specular, 0, 0, 0, 0);
	float shiny = 0;
	if(i_shading == true)
	{
		RGBA_ASSIGN(ambience, i_ambience);
		
		if(i_ambientType == AMBIENT_USE_COLOR)
		{
			RGBA_ASSIGN(ambient, i_ambient);
		}
		else if(i_ambientType == AMBIENT_USE_PERCENTAGE)
		{
			RGBA_ASSIGN(ambient, i_color);
			ambient *= i_ambientPercentage * 0.01;
		}

		if(i_specularType == SPECULAR_USE_COLOR)
		{
			RGBA_ASSIGN(specular, i_specular);
		}
		else if(i_specularType == SPECULAR_USE_PERCENTAGE)
		{
			RGBA_ASSIGN(specular, i_color);
			specular *= i_specularPercentage * 0.01;
		}

		shiny = i_shiny;
	}

#if 0
	RGBA_DECLARE_INIT4(irradiance, 0, 0, 0, 0);
	if(i_irradianceType == IRRADIANCE_USE_COLOR)
	{
		RGBA_ASSIGN(irradiance, i_irradiance);
	}
	else if(i_irradianceType == IRRADIANCE_USE_PERCENTAGE)
	{
		RGBA_ASSIGN(irradiance, i_color);
		irradiance *= i_irradiancePercentage * 0.01;
	}

	RGBA_DECLARE_INIT4(radiance, 0, 0, 0, 0);
	if(i_radianceType == RADIANCE_USE_COLOR)
	{
		RGBA_ASSIGN(radiance, i_radiance);
	}
	else if(i_radianceType == RADIANCE_USE_PERCENTAGE)
	{
		RGBA_ASSIGN(radiance, i_color);
		radiance *= i_radiancePercentage * 0.01;
	}
#endif

	if(i_shading == true)
	{
		o_result = i_color * diffuse(N) + specular * specular(N, normalize(-I), 1.0/shiny) + ambience * ambient;
	}
	else
	{
		o_result = i_color;
	}
	o_result_a = i_color_a;
}

#undef AMBIENT_NONE
#undef AMBIENT_USE_COLOR
#undef AMBIENT_USE_PERCENTAGE

#undef SPECULAR_NONE
#undef SPECULAR_USE_COLOR
#undef SPECULAR_USE_PERCENTAGE

#undef IRRADIANCE_NONE
#undef IRRADIANCE_USE_COLOR
#undef IRRADIANCE_USE_PERCENTAGE

#undef RADIANCE_NONE
#undef RADIANCE_USE_COLOR
#undef RADIANCE_USE_PERCENTAGE

#endif
