/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_shape_sl
#define __pt_shape_sl

#define bool float
#define enum float

#define FALLOFF_NONE 0
#define FALLOFF_LINEAR 1
#define FALLOFF_SQUARE 2
#define FALLOFF_SQUARE_ROOT 3
#define FALLOFF_USER_DEFINED 4
#define FALLOFF_SMOOTH 5
#define FALLOFF_GAUSS 6

#define FALLOFF_EPSILON 0.001

#define SHAPE_NONE 0
#define SHAPE_STEP 1
#define SHAPE_SINE 2
#define SHAPE_STAR 3
#define SHAPE_BEAM 4
#define SHAPE_SYMMETRY 5
#define SHAPE_NOISE 6
#define SHAPE_TURBULENCE 7
#define SHAPE_FRACTAL 8

#define SHAPE_EPSILON 0.0001

float pt_shapeFalloffFromType(
	enum i_falloffType;
	float i_fromMin;
	float i_fromMax;
	float i_exponent;
	float i_gaussRate; )
{
	float falloff = 1.0;
	if(i_falloffType == FALLOFF_LINEAR)
	{
		falloff = i_fromMin;
	}
	else if(i_falloffType == FALLOFF_SQUARE)
	{
		falloff = 1.0 - i_fromMax*i_fromMax;
	}
	else if(i_falloffType == FALLOFF_SQUARE_ROOT)
	{
		/*
			Strangely, this falloff type appears as "Cubic" in the user
			interface, but it's really a square root.
		*/
		falloff = sqrt(i_fromMin);
	}
	else if(i_falloffType == FALLOFF_USER_DEFINED)
	{
		float exponent = i_exponent;
		if(exponent < FALLOFF_EPSILON)
		{
			exponent = FALLOFF_EPSILON;
		}
		falloff = 1.0 - pow(i_fromMax, exponent);
	}
	else if(i_falloffType == FALLOFF_SMOOTH)
	{
		float fromMin2 = i_fromMin*i_fromMin;
		falloff = 3.0 * fromMin2 - 2.0 * fromMin2*i_fromMin;
	}
	else if(i_falloffType == FALLOFF_GAUSS)
	{
		if(i_gaussRate < FALLOFF_EPSILON)
		{
			falloff = i_fromMin;
		}
		else
		{
			falloff =
				(1.0 - exp(-4.0 * i_gaussRate * i_fromMin)) /
				(1.0 - exp(-4.0 * i_gaussRate));
		}
	}
	return falloff;
}

float pt_shapeFalloff(
	enum i_falloffType;
	float i_falloffX;
	float i_falloffY;
	float i_falloffStart;
	float i_falloffEnd;
	float i_exponent;
	float i_gaussRate; )
{
	extern varying float u;
	extern varying float v;

	float falloff = 1.0;
	if(i_falloffType != FALLOFF_NONE)
	{
		float x = 2.0 * (u - i_falloffX);
		float y = 2.0 * (v - i_falloffY);
		float fromCenter = sqrt(x*x + y*y);

		float falloffLength = i_falloffEnd - i_falloffStart;

		float inside = 1.0 -
			filterstep(
				min(i_falloffStart, i_falloffEnd),
				fromCenter,
				"filter",
				"box");
		float outside =
			filterstep(
				max(i_falloffStart, i_falloffEnd),
				fromCenter,
				"filter",
				"box");
		float slope = max(0.0, 1.0 - inside - outside);

		if(slope > 0.0)
		{
			if(abs(falloffLength) < FALLOFF_EPSILON)
			{
				falloffLength = sign(falloffLength) * FALLOFF_EPSILON;
			}

			float fromMax =
				clamp((fromCenter - i_falloffStart) / falloffLength, 0.0, 1.0);
			float fromMin = 1.0 - fromMax;
			falloff =
				pt_shapeFalloffFromType(
					i_falloffType,
					fromMin,
					fromMax,
					i_exponent,
					i_gaussRate);
			falloff = clamp(falloff, 0.0, 1.0) * slope;
		}
		else
		{
			falloff = 0.0;
		}

		if(falloffLength >= 0)
		{
			falloff += inside;
		}
		else
		{
			falloff += outside;
		}
	}
	
	return falloff;
}

float pt_shapeTurbulence(
	point i_samplePos;
	float i_scale;
	float i_lowFreq;
	float i_highFreq; )
{
	float lowFreq = abs(i_lowFreq);
	float highFreq = abs(i_highFreq);
	if(lowFreq > highFreq)
	{
		float f = highFreq;
		highFreq = lowFreq;
		lowFreq = f;
	}
	if(lowFreq == 0.0)
	{
		lowFreq = i_highFreq / 4.0;
	}

	point samplePos = i_samplePos * i_scale * lowFreq;

	float tScale = 0.0;
	float t = 0.0;
	float f;
	for(f = lowFreq; f < highFreq; f *= 2.0)
	{
		t += mi_noise_3d(2.0*samplePos) / f;
		tScale += 1.0 / f;
		samplePos *= 2.0;
	}
	
	return t / tScale;
}

float pt_shapeFractal(
	point i_samplePos;
	float i_weight;
	float i_granular;
	float i_octaves; )
{
	float granular = max(0.0, i_granular);
	float wm = 1.0 / pow(granular, i_weight);

	point samplePos = i_samplePos;
	float tScale = 1.0;
	float t = mi_noise_3d(2.0*samplePos);
	float w = wm;
	float i;
	for(i = 1; i < i_octaves; i += 1)
	{
		samplePos *= granular;
		t += w * mi_noise_3d(2.0*samplePos);
		tScale += w;
		w *= wm;
	}	

	return t / tScale;
}
				
float pt_shapeIntensity(
	enum i_shapeType;
	float i_shapeX;
	float i_shapeY;
	float i_stepWidth;
	float i_sineScale;
	float i_starBranches;
	float i_beamWidth;
	float i_symmetryWidth;
	float i_noiseTime;
	float i_noiseScale;
	float i_turbulenceTime;
	float i_turbulenceScale;
	float i_turbulenceLowFreq;
	float i_turbulenceHighFreq;
	float i_fractalTime;
	float i_fractalScale;
	float i_fractalWeight;
	float i_fractalGranular;
	float i_fractalOctaves; )
{
	extern varying float u;
	extern varying float v;

	float x = 2.0 * (u - i_shapeX);
	float y = 2.0 * (v - i_shapeY);

	float intensity = 1.0;
	if(i_shapeType == SHAPE_STEP)
	{
		if(i_stepWidth < 0.0 || i_stepWidth > 1.0)
		{
			intensity = 0.0;
		}
		else
		{
			float fromCenter = sqrt(x*x + y*y);
			float inside =
				1.0 - filterstep(i_stepWidth, fromCenter, "filter", "box");
			float outside = filterstep(1.0, fromCenter, "filter", "box");
			float slope = max(0.0, 1.0 - inside - outside);
			intensity = inside;
			if(slope > 0.0)
			{
				intensity +=
					slope * i_stepWidth / (i_stepWidth - 1.0) * (1.0 - 1.0/fromCenter);
			}
		}
	}
	else if(i_shapeType == SHAPE_SINE)
	{
		float fromCenter = sqrt(x*x + y*y);
		float inside = 1.0 - filterstep(1.0, fromCenter);
		float s = sin(0.5 * PI * i_sineScale * (1.0 - fromCenter));
		float positive = filterstep(0.0, s);
		intensity = inside * positive * s;
	}
	else if(i_shapeType == SHAPE_STAR)
	{
		float fromCenter = sqrt(x*x + y*y);
		float inside = 1.0 - filterstep(0.0, fromCenter);
		float outside = filterstep(1.0, fromCenter);
		float slope = max(0.0, 1.0 - inside - outside);
		intensity = inside;
		if(slope > 0.0)
		{
			intensity += slope * 0.5 * (cos(i_starBranches * atan(y, x)) + 1.0);
		}
	}
	else if(i_shapeType == SHAPE_BEAM)
	{
		if(i_beamWidth < 0.0 || i_beamWidth > 1.0)
		{
			intensity = 0.0;
		}
		else
		{
			float fromCenter = abs(x);
			float inside =
				1.0 - filterstep(i_beamWidth, fromCenter, "filter", "box");
			float outside =
				filterstep(1.0, fromCenter, "filter", "box");
			float slope = max(0.0, 1.0 - inside - outside);
			intensity = inside;
			if(slope > 0.0)
			{
				intensity +=
					slope * i_beamWidth / (i_beamWidth - 1.0) * (1.0 - 1.0/fromCenter);
			}
		}
	}
	else if(i_shapeType == SHAPE_SYMMETRY)
	{
		if(i_symmetryWidth < SHAPE_EPSILON)
		{
			intensity = 0.0;
		}
		else
		{
			float fromCenter = max(abs(x), abs(y));
			float inside = 1.0 - filterstep(0.0, fromCenter);
			float outside =
				filterstep(i_symmetryWidth, fromCenter, "filter", "box");
			float slope = max(0.0, 1.0 - inside - outside);
			intensity = inside;
			if(slope > 0.0)
			{
				intensity +=
					slope * (1.0 - fromCenter / i_symmetryWidth / sqrt(2.0));
			}
		}
	}
	else if(i_shapeType == SHAPE_NOISE)
	{
		intensity = mi_noise_3d(2.0 * i_noiseScale * point(x, y, i_noiseTime));
	}
	else if(i_shapeType == SHAPE_TURBULENCE)
	{
		intensity =
			pt_shapeTurbulence(
				point(x, y, i_turbulenceTime),
				i_turbulenceScale,
				i_turbulenceLowFreq,
				i_turbulenceHighFreq);
	}
	else if(i_shapeType == SHAPE_FRACTAL)
	{
		intensity =
			pt_shapeFractal(
				i_fractalScale * point(x, y, i_fractalTime),
				i_fractalWeight,
				i_fractalGranular,
				i_fractalOctaves);
	}
	
	return intensity;
}

void pt_shape(
	RGBA_DECLARE(i_input);
	enum i_falloffType;
	float i_falloffX;
	float i_falloffY;
	bool i_falloffRGB;
	bool i_falloffAlpha;
	bool i_falloffRGBInvert;
	bool i_falloffAlphaInvert;
	float i_falloffStart;
	float i_falloffEnd;
	float i_exponent;
	float i_gaussRate;
	enum i_shapeType;
	float i_shapeX;
	float i_shapeY;
	bool i_shapeRGB;
	bool i_shapeAlpha;
	bool i_shapeRGBInvert;
	bool i_shapeAlphaInvert;
	float i_stepWidth;
	float i_sineScale;
	float i_starBranches;
	float i_beamWidth;
	float i_symmetryWidth;
	float i_noiseTime;
	float i_noiseScale;
	float i_turbulenceTime;
	float i_turbulenceScale;
	float i_turbulenceLowFreq;
	float i_turbulenceHighFreq;
	float i_fractalTime;
	float i_fractalScale;
	float i_fractalWeight;
	float i_fractalGranular;
	float i_fractalOctaves;

	output color o_result;
	output float o_result_a; )
{
	float falloff = 1.0;
	if(i_falloffRGB == true || i_falloffAlpha == true)
	{
		falloff = 
			pt_shapeFalloff(
				i_falloffType,
				i_falloffX,
				i_falloffY,
				i_falloffStart,
				i_falloffEnd,
				i_exponent,
				i_gaussRate);
	}

	float intensity = 1.0;
	if(i_shapeRGB == true || i_shapeAlpha == true)
	{
		intensity =
			pt_shapeIntensity(
				i_shapeType,
				i_shapeX,
				i_shapeY,
				i_stepWidth,
				i_sineScale,
				i_starBranches,
				i_beamWidth,
				i_symmetryWidth,
				i_noiseTime,
				i_noiseScale,
				i_turbulenceTime,
				i_turbulenceScale,
				i_turbulenceLowFreq,
				i_turbulenceHighFreq,
				i_fractalTime,
				i_fractalScale,
				i_fractalWeight,
				i_fractalGranular,
				i_fractalOctaves);
	}

	RGBA_ASSIGN(o_result, i_input);

	if(i_falloffRGB == true)
	{
		if(i_falloffRGBInvert == true)
		{
			o_result *= (1.0 - falloff);
		}
		else
		{
			o_result *= falloff;
		}
	}

	if(i_falloffAlpha == true)
	{
		if(i_falloffAlphaInvert == true)
		{
			o_result_a *= (1.0 - falloff);
		}
		else
		{
			o_result_a *= falloff;
		}
	}

	if(i_shapeRGB == true)
	{
		if(i_shapeRGBInvert == true)
		{
			o_result *= (1.0 - intensity);
		}
		else
		{
			o_result *= intensity;
		}
	}

	if(i_shapeAlpha == true)
	{
		if(i_shapeAlphaInvert == true)
		{
			o_result_a *= (1.0 - intensity);
		}
		else
		{
			o_result_a *= intensity;
		}
	}
}

#undef FALLOFF_NONE
#undef FALLOFF_LINEAR
#undef FALLOFF_SQUARE
#undef FALLOFF_SQUARE_ROOT
#undef FALLOFF_USER_DEFINED
#undef FALLOFF_SMOOTH
#undef FALLOFF_GAUSS

#undef FALLOFF_EPSILON

#undef SHAPE_NONE
#undef SHAPE_STEP
#undef SHAPE_SINE
#undef SHAPE_STAR
#undef SHAPE_BEAM
#undef SHAPE_SYMMETRY
#undef SHAPE_NOISE
#undef SHAPE_TURBULENCE
#undef SHAPE_FRACTAL

#undef SHAPE_EPSILON

#endif
