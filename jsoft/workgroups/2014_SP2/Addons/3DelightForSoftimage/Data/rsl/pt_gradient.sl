/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_gradient_sl
#define __pt_gradient_sl

#define bool float

#define GRADIENT_INTERPOLATION_EPSILON 0.001
#define GRADIENT_EVALUATION_EPSILON 0.0001

#define GRADIENT_INTERPOLATION_LINEAR 0
#define GRADIENT_INTERPOLATION_CUBIC 1

float pt_gradientWeight(
	float i_evalPoint;
	float i_midPoint;
	float i_interpolation; )
{
	float value = 0.0;

	if(i_interpolation == GRADIENT_INTERPOLATION_LINEAR)
	{
		if(i_evalPoint < i_midPoint)
		{
			value = i_evalPoint / i_midPoint / 2.0;
		}
		else
		{
			value = ((i_evalPoint-i_midPoint) / (1.0-i_midPoint)) / 2.0 + 0.5;
		}
	}
	else if(i_interpolation == GRADIENT_INTERPOLATION_CUBIC)
	{
		if(i_midPoint < GRADIENT_INTERPOLATION_EPSILON)
		{
			value = 1.0;
		}
		else if(i_midPoint > 1.0 - GRADIENT_INTERPOLATION_EPSILON)
		{
			value = 0.0;
		}
		else
		{
			float e2 = i_evalPoint*i_evalPoint;
			float mid2 = i_midPoint * i_midPoint;
			float mid3 = i_midPoint * mid2;
			float x = (1.0 - 2.0 * mid3) / (2.0 * mid2 * (1.0 - i_midPoint));
			value = clamp(e2 * ((1.0 - x) * i_evalPoint + x), 0.0, 1.0);
		}
	}

	return value;
}

void pt_gradientUpdateClosestMarkers(
	float i_evalPoint;
	RGBA_DECLARE(i_markerColor);
	float i_markerPosRGB;
	float i_markerPosA;
	float i_markerMidRGB;
	float i_markerMidA;
	RGBA_DECLARE_OUTPUT(o_lowColor);
	output float o_lowPosRGB;
	output float o_lowPosA;
	output float o_lowMidRGB;
	output float o_lowMidA;
	RGBA_DECLARE_OUTPUT(o_highColor);
	output float o_highPosRGB;
	output float o_highPosA;
	output float o_highMidRGB;
	output float o_highMidA; )
{
	/* Ignore invalid marker positions */
	if(0.0 <= i_markerPosRGB && i_markerPosRGB <= 1.0)
	{
		/* Process the RGB channels */
		if(i_evalPoint < i_markerPosRGB)
		{
			/* Update the upper bound */
			if(i_markerPosRGB < o_highPosRGB)
			{
				o_highColor = i_markerColor;
				o_highPosRGB = i_markerPosRGB;
				o_highMidRGB = i_markerMidRGB;
			}
		}
		else
		{
			/* Update the lower bound */
			if(i_markerPosRGB > o_lowPosRGB)
			{
				o_lowColor = i_markerColor;
				o_lowPosRGB = i_markerPosRGB;
				o_lowMidRGB = i_markerMidRGB;
			}
		}
	}

	/* Ignore invalid marker positions */
	if(0.0 <= i_markerPosA && i_markerPosA <= 1.0)
	{
		/* Process the alpha channel */
		if(i_evalPoint < i_markerPosA)
		{
			/* Update the upper bound */
			if(i_markerPosA < o_highPosA)
			{
				o_highColor_a = i_markerColor_a;
				o_highPosA = i_markerPosA;
				o_highMidA = i_markerMidA;
			}
		}
		else
		{
			/* Update the lower bound */
			if(i_markerPosA > o_lowPosA)
			{
				o_lowColor_a = i_markerColor_a;
				o_lowPosA = i_markerPosA;
				o_lowMidA = i_markerMidA;
			}
		}
	}
}

void pt_gradient(
	float i_evalPoint;
	float i_evalMin;
	float i_evalMax;
	float i_interpolation;
	RGBA_DECLARE(i_Color00);
	float i_posRGB00;
	float i_posAlpha00;
	float i_midRGB00;
	float i_midAlpha00;
	RGBA_DECLARE(i_Color01);
	float i_posRGB01;
	float i_posAlpha01;
	float i_midRGB01;
	float i_midAlpha01;
	RGBA_DECLARE(i_Color02);
	float i_posRGB02;
	float i_posAlpha02;
	float i_midRGB02;
	float i_midAlpha02;
	RGBA_DECLARE(i_Color03);
	float i_posRGB03;
	float i_posAlpha03;
	float i_midRGB03;
	float i_midAlpha03;
	RGBA_DECLARE(i_Color04);
	float i_posRGB04;
	float i_posAlpha04;
	float i_midRGB04;
	float i_midAlpha04;
	RGBA_DECLARE(i_Color05);
	float i_posRGB05;
	float i_posAlpha05;
	float i_midRGB05;
	float i_midAlpha05;
	RGBA_DECLARE(i_Color06);
	float i_posRGB06;
	float i_posAlpha06;
	float i_midRGB06;
	float i_midAlpha06;
	RGBA_DECLARE(i_Color07);
	float i_posRGB07;
	float i_posAlpha07;
	float i_midRGB07;
	float i_midAlpha07;
	RGBA_DECLARE(i_Color08);
	float i_posRGB08;
	float i_posAlpha08;
	float i_midRGB08;
	float i_midAlpha08;
	RGBA_DECLARE(i_Color09);
	float i_posRGB09;
	float i_posAlpha09;
	float i_midRGB09;
	float i_midAlpha09;
	RGBA_DECLARE(i_Color10);
	float i_posRGB10;
	float i_posAlpha10;
	float i_midRGB10;
	float i_midAlpha10;
	RGBA_DECLARE(i_Color11);
	float i_posRGB11;
	float i_posAlpha11;
	float i_midRGB11;
	float i_midAlpha11;
	RGBA_DECLARE(i_Color12);
	float i_posRGB12;
	float i_posAlpha12;
	float i_midRGB12;
	float i_midAlpha12;
	RGBA_DECLARE(i_Color13);
	float i_posRGB13;
	float i_posAlpha13;
	float i_midRGB13;
	float i_midAlpha13;
	RGBA_DECLARE(i_Color14);
	float i_posRGB14;
	float i_posAlpha14;
	float i_midRGB14;
	float i_midAlpha14;
	RGBA_DECLARE(i_Color15);
	float i_posRGB15;
	float i_posAlpha15;
	float i_midRGB15;
	float i_midAlpha15;

	output color o_result;
	output float o_result_a; )
{
	float evalLength = i_evalMax - i_evalMin;
	if(abs(evalLength) < GRADIENT_EVALUATION_EPSILON)
	{
		evalLength = GRADIENT_EVALUATION_EPSILON;
	}

	float pos =
		clamp(
			(i_evalPoint - i_evalMin) / evalLength,
			min(i_evalMin, i_evalMax),
			max(i_evalMin, i_evalMax));

	RGBA_DECLARE(lowColor);
	float lowPosRGB = -1.0;
	float lowPosA = -1.0;
	float lowMidRGB;
	float lowMidA;
	RGBA_DECLARE(highColor);
	float highPosRGB = 2.0;
	float highPosA = 2.0;
	float highMidRGB;
	float highMidA;

	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color00), i_posRGB00, i_posAlpha00, i_midRGB00, i_midAlpha00,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color01), i_posRGB01, i_posAlpha01, i_midRGB01, i_midAlpha01,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color02), i_posRGB02, i_posAlpha02, i_midRGB02, i_midAlpha02,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color03), i_posRGB03, i_posAlpha03, i_midRGB03, i_midAlpha03,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color04), i_posRGB04, i_posAlpha04, i_midRGB04, i_midAlpha04,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color05), i_posRGB05, i_posAlpha05, i_midRGB05, i_midAlpha05,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color06), i_posRGB06, i_posAlpha06, i_midRGB06, i_midAlpha06,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color07), i_posRGB07, i_posAlpha07, i_midRGB07, i_midAlpha07,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color08), i_posRGB08, i_posAlpha08, i_midRGB08, i_midAlpha08,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color09), i_posRGB09, i_posAlpha09, i_midRGB09, i_midAlpha09,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color10), i_posRGB10, i_posAlpha10, i_midRGB10, i_midAlpha10,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color11), i_posRGB11, i_posAlpha11, i_midRGB11, i_midAlpha11,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color12), i_posRGB12, i_posAlpha12, i_midRGB12, i_midAlpha12,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color13), i_posRGB13, i_posAlpha13, i_midRGB13, i_midAlpha13,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color14), i_posRGB14, i_posAlpha14, i_midRGB14, i_midAlpha14,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
	pt_gradientUpdateClosestMarkers(
		pos,
		RGBA_USE(i_Color15), i_posRGB15, i_posAlpha15, i_midRGB15, i_midAlpha15,
		RGBA_USE(lowColor), lowPosRGB, lowPosA, lowMidRGB, lowMidA,
		RGBA_USE(highColor), highPosRGB, highPosA, highMidRGB, highMidA);
		
	/* Interpolate the RGB values */
	if(lowPosRGB < 0.0 || lowPosRGB == highPosRGB)
	{
		o_result = highColor;
	}
	else if(highPosRGB > 1.0)
	{
		o_result = lowColor;
	}
	else
	{
		float weight = pt_gradientWeight(pos, lowMidRGB, i_interpolation);
		o_result = mix(lowColor, highColor, weight);
	}

	/* Interpolate the alpha value */
	if(lowPosA < 0.0 || lowPosA == highPosA)
	{
		o_result_a = highColor_a;
	}
	else if(highPosA > 1.0)
	{
		o_result_a = lowColor_a;
	}
	else
	{
		pos -= lowPosA;
		pos /= (highPosA-lowPosA);
		float weight = pt_gradientWeight(pos, lowMidA, i_interpolation);
		o_result_a = mix(lowColor_a, highColor_a, weight);
	}
}

#undef GRADIENT_INTERPOLATION_LINEAR
#undef GRADIENT_INTERPOLATION_CUBIC

#endif
