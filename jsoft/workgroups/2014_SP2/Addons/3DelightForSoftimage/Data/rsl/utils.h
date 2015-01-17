/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Developers. 2013                              */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

/*
	Copyright (c) 2006 soho vfx inc.
	Copyright (c) 2006 The 3Delight Team.
*/

#ifndef _utils_h
#define _utils_h

#define EPSILON 1e-6

/* Compute the CIE luminance (Rec. 709) of a given color. */
float CIEluminance(color c)
{
	return
		comp(c, 0) * 0.212671 +
		comp(c, 1) * 0.715160 +
		comp(c, 2) * 0.072169;
}

/* Compute the square of a given value. */
float sq(float x)
{
	return x * x;
}

/* Compute absolute value of a given color */
color cabs( color i_color )
{
	return color(
		abs(comp(i_color, 0)), abs(comp(i_color,1)), abs(comp(i_color,2)) );
}

/* Taken from ARMAN and improved. */
float filteredpulsetrain (float edge, period, x, dx)
{
	/* First, normalize so period == 1 and our domain of interest is > 0 */
	float w = dx/period;
	float x0 = x/period - w/2;
	float x1 = x0+w;
	float nedge = edge / period;

	/* Definite integral of normalized pulsetrain from 0 to t */
	float integral (float t) { 
		extern float nedge;
		return ((1-nedge)*floor(t) + max(0,t-floor(t)-nedge));
	}

	float result;
	if( x0 == x1 )
	{
		/* Trap the unfiltered case so it doesn't return 0 (when dx << x). */
		result = (x0 - floor(x0) < nedge) ? 0 : 1;
	}
	else
	{
		result = (integral(x1) - integral(x0)) / w;

		/*
		   The above integral is subject to its own aliasing as we go beyond
		   where the pattern should be extinct. We try to avoid that by
		   switching to a constant value.
		   */
		float extinct = smoothstep( 0.4, 0.5, w );
		result = result + extinct * (1 - nedge - result);
	}

	return result;
}

/* Perlin's bias function */
float bias(float b, x)
{
	return pow(x, log(b)/LOG05);
}

#endif
