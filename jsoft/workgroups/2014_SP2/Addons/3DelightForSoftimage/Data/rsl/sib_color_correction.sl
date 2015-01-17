/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_correction_sl
#define __sib_color_correction_sl

void sib_color_correction(
	RGBA_COLOR( i_color );
	float i_gamma, i_contrast, i_hue, i_saturation, i_level;

	output color o_result;
	output float o_result_a; )
{
	o_result = i_color;

	float gamma = clamp( i_gamma, 0.001, 20.0 );
	float contrast = 1.0 - i_contrast;

	/* perform gamma correction */
	o_result = sibu_gamma( o_result, gamma );
	
	/* adjust the contrast */
	contrast = clamp( contrast, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );

	o_result = color(
			GAIN( contrast, comp(o_result,0) ),
			GAIN( contrast, comp(o_result,1) ),
			GAIN( contrast, comp(o_result,2) ) );
	
	/*convert the color into HLS space*/
	color hsl = ctransform( "hsl", o_result );

	/* perform the hue shift */
	float H = comp(hsl, 0) * 360;
	H += i_hue;
	if (H<0.0)
		H += 360.0;
	else if (H>360.0)
		H -= 360.0;
	setcomp( hsl, 0, H/360 );

	/* add the saturation */
	float S = comp(hsl, 1);
	S += i_saturation;
	S = clamp( S, 0, 1.0 );
	setcomp( hsl, 1, S );

	/* add the level */
	float L = comp(hsl, 2);
	L += i_level;
	L = clamp( L, 0, 1.0 );
	setcomp( hsl, 2, L );

	/* convert the color back into rgb */
	o_result = ctransform( "hsl", "rgb", hsl );
	o_result_a = i_color_a;
}
#endif

