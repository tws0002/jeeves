/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_scalar_math_curve_sl
#define __sib_scalar_math_curve_sl

void sib_scalar_math_curve(
	float i_input;
	FCURVE_DECLARE(i_curve);
	output float o_result)
{
	float nbKeys = FCURVE_NB_KEYS(i_curve);
	float k0 = 0;
	while(k0 < nbKeys-1 && FCURVE_VALUE_X(i_curve, k0+1) < i_input)
	{
		k0 += 1;
	}

	if(FCURVE_VALUE_X(i_curve, 0) > i_input)
	{
		o_result = FCURVE_PRE_VALUE_Y(i_curve, 0);
	}
	else if(k0 == nbKeys-1)
	{
		o_result = FCURVE_POST_VALUE_Y(i_curve, k0);
	}
	else
	{
		float interpolation = FCURVE_INTERPOLATION(i_curve, k0);
		if(interpolation == FCURVE_INTERPOLATION_CONSTANT)
		{
			o_result = FCURVE_POST_VALUE_Y(i_curve, k0);
		}
		else
		{
			float k1 = k0+1;
			float x0 = FCURVE_VALUE_X(i_curve, k0);
			float y0 = FCURVE_POST_VALUE_Y(i_curve, k0);
			float x1 = FCURVE_VALUE_X(i_curve, k1);
			float y1 = FCURVE_PRE_VALUE_Y(i_curve, k1);
			float xRange = x1 - x0;
			float yRange = y1 - y0;
			float normalizedInput = (i_input - x0) / xRange;
			if(interpolation == FCURVE_INTERPOLATION_LINEAR)
			{
				o_result = normalizedInput * yRange + y0;
			}
			else
			{
				float tx0 = FCURVE_POST_TANGENT_X(i_curve, k0) / xRange;
				float ty0 = FCURVE_POST_TANGENT_Y(i_curve, k0);
				float tx1 = FCURVE_PRE_TANGENT_X(i_curve, k1) / xRange;
				float ty1 = FCURVE_PRE_TANGENT_Y(i_curve, k1);

				float t = spline("solvebezier", normalizedInput, 0, tx0, 1-tx1, 1);
//				float t = spline("solvehermite", normalizedInput, 0, tx0, 1, tx1);
				o_result = spline("bezier", t, y0, y0+ty0, y1-ty1, y1);
//				o_result = spline("hermite", t, y0, ty0, y1, ty1);
			}
		}
	}
}

#endif
