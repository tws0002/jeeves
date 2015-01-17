/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_gradient_sl
#define __sib_color_gradient_sl

#define LINEARINTERPOL 0
#define CUBICINTERPOL 1
#define SCALAR_INPUT 0
#define VECTOR_INPUT 1
#define VECTOR_INPUT_X 2
#define VECTOR_INPUT_Y 3
#define VECTOR_INPUT_Z 4
#define VERTICAL_GRADIENT 0
#define HORIZONTAL_GRADIENT 1
#define WAVE_GRADIENT 2
#define RAINBOW_GRADIENT 3
#define DIAGDOWN_GRADIENT 4
#define DIAGUP_GRADIENT 5

#define GRAD_COLOR_DECLARE( c ) \
	RGBA_DECLARE( i_##c ); \
	float i_pos_##c, i_mid_##c

#define GRAD_COLOR_USE( c ) \
	RGBA_USE( i_##c ), i_pos_##c, i_mid_##c

#define GRAD_ALPHA_DECLARE( c ) \
	float i_##c; \
	float i_pos_##c, i_mid_##c

#define GRAD_ALPHA_USE( c ) \
	i_##c, i_pos_##c, i_mid_##c

/*
	We actually sort from element 1 to ndata inclusive. Elements 0 and
	> ndata are not relevent here
*/
void SortColors( 
	output float knots[10];
	RGBA_ARRAY_DECLARE_OUTPUT(colors);
	float ndata; )
{
	/* We go with a Shell sort. Damn, who have thought I would be 
	   sorting in SL. */

	float increment;
	for( increment = floor(ndata/2); increment > 0;
		increment = (increment == 2 ? 1 : round(increment / 2.2)))
	{
		float i;
		for( i=increment; i<ndata; i+=1 )
		{
			float j;
			for(
				j = i;
				j >= increment && knots[j - increment + 1] > knots[j + 1];
				j-=increment)
			{
				float temp = knots[j + 1];
				knots[j + 1] = knots[j - increment + 1];
				knots[j - increment + 1] = temp;

				RGBA_DECLARE(temp_color);
				RGBA_ASSIGN_FROM_ARRAY(temp_color, colors, j + 1);
				RGBA_ARRAY_ASSIGN_FROM_ARRAY(colors, j + 1, colors, j - increment + 1);
				RGBA_ARRAY_ASSIGN_VALUE1(colors, j - increment + 1, temp_color);
			}
		}
	}
}

void SortAlphas( 
	output float knots[10];
	output float alphas[10]; 
	float ndata; )
{
	float increment;
	for( increment = floor(ndata/2); increment > 0;
		increment = (increment == 2 ? 1 : round(increment / 2.2)))
	{
		float i;
		for( i=increment; i<ndata; i+=1 )
		{
			float j;
			for(
				j = i;
				j >= increment && knots[j - increment + 1] > knots[j + 1];
				j-=increment)
			{
				float temp = knots[j + 1];
				knots[j + 1] = knots[j - increment + 1];
				knots[j - increment + 1] = temp;

				temp = alphas[j + 1];
				alphas[j + 1] = alphas[j - increment + 1];
				alphas[j - increment + 1] = temp;
			}
		}
	}
}

#define SIB_COLOR_GRADIENT_PARAMS_DECLARE \
	float i_gradient_type; \
	float i_inverse, i_clip, i_enable_alpha_gradient; \
	float i_gradient_min, i_gradient_max; \
	float i_rgba_interpolation; \
\
	GRAD_COLOR_DECLARE( color1 ); \
	GRAD_COLOR_DECLARE( color2 ); \
	GRAD_COLOR_DECLARE( color3 ); \
	GRAD_COLOR_DECLARE( color4 ); \
	GRAD_COLOR_DECLARE( color5 ); \
	GRAD_COLOR_DECLARE( color6 ); \
	GRAD_COLOR_DECLARE( color7 ); \
	GRAD_COLOR_DECLARE( color8 ); \
\
	float i_alpha_interpolation; \
\
	GRAD_ALPHA_DECLARE( alpha1 ); \
	GRAD_ALPHA_DECLARE( alpha2 ); \
	GRAD_ALPHA_DECLARE( alpha3 ); \
	GRAD_ALPHA_DECLARE( alpha4 ); \
	GRAD_ALPHA_DECLARE( alpha5 ); \
	GRAD_ALPHA_DECLARE( alpha6 ); \
	GRAD_ALPHA_DECLARE( alpha7 ); \
	GRAD_ALPHA_DECLARE( alpha8 )
 
#define SIB_COLOR_GRADIENT_PARAMS_USE \
	i_gradient_type, \
	i_inverse, i_clip, i_enable_alpha_gradient, \
	i_gradient_min, i_gradient_max, \
	i_rgba_interpolation, \
\
	GRAD_COLOR_USE( color1 ), \
	GRAD_COLOR_USE( color2 ), \
	GRAD_COLOR_USE( color3 ), \
	GRAD_COLOR_USE( color4 ), \
	GRAD_COLOR_USE( color5 ), \
	GRAD_COLOR_USE( color6 ), \
	GRAD_COLOR_USE( color7 ), \
	GRAD_COLOR_USE( color8 ), \
\
	i_alpha_interpolation, \
\
	GRAD_ALPHA_USE( alpha1 ), \
	GRAD_ALPHA_USE( alpha2 ), \
	GRAD_ALPHA_USE( alpha3 ), \
	GRAD_ALPHA_USE( alpha4 ), \
	GRAD_ALPHA_USE( alpha5 ), \
	GRAD_ALPHA_USE( alpha6 ), \
	GRAD_ALPHA_USE( alpha7 ), \
	GRAD_ALPHA_USE( alpha8 )

void sib_color_gradient(
	float i_input;
	point i_coord;
	float i_input_type;

	SIB_COLOR_GRADIENT_PARAMS_DECLARE;

	RGBA_DECLARE_OUTPUT(o_result); )
{
	float input;

	o_result_a = 1;

	if( i_input_type == SCALAR_INPUT )
		input = i_input;
	else if( i_input_type == VECTOR_INPUT_X )
		input = i_coord[0];
	else if( i_input_type == VECTOR_INPUT_Y )
		input = i_coord[1];
	else if( i_input_type == VECTOR_INPUT_Z )
		input = i_coord[2];
	else if( i_input_type == VECTOR_INPUT )
	{
		if( i_gradient_type == VERTICAL_GRADIENT )
			input = i_coord[1];
		else if( i_gradient_type == HORIZONTAL_GRADIENT )
			input = i_coord[0];	
		else if( i_gradient_type == WAVE_GRADIENT )
			input = sqrt(sqr(0.5-i_coord[0]) + sqr(0.5-i_coord[1])) / (1/sqrt(2));
		else if( i_gradient_type == RAINBOW_GRADIENT )
		{
			float DeltaX = .5 - i_coord[0];
			float DeltaY = .5 - i_coord[1];
			float Denominator = sqrt(sqr(DeltaX) + sqr(DeltaY));
			if( Denominator == 0 || abs(Denominator)<miSCALAR_EPSILON )
				input = 1;
			else
				input = acos( DeltaY / Denominator) / PI;
		}
		else if( i_gradient_type == DIAGDOWN_GRADIENT )
			input = 0.5 * (i_coord[0] + i_coord[1] );
		else if( i_gradient_type == DIAGUP_GRADIENT )
			input = 0.5 * (i_coord[0] - i_coord[1] + 1 );
	}

	/* Remap "input" from the provided [min..max] range to the [0..1] range*/
	float delta_oldrange = i_gradient_max - i_gradient_min;
	if( abs(delta_oldrange) < miSCALAR_EPSILON )
		delta_oldrange = miSCALAR_EPSILON;

	input = (1.0 * (( input - i_gradient_min ) / delta_oldrange));

	if( input > 1.0 )
		input = 1.0;
	else if( input < 0.0 )
		input = 0.0;
	if( i_inverse )
		input = 1 - input;

	/* The f0nky stuff starts here (read the garbage starts here): count
	   the total number of colors. First put everything into arrays */

	float knots[ 8 ] = {
		i_pos_color1, i_pos_color2, i_pos_color3, i_pos_color4,
		i_pos_color5, i_pos_color6, i_pos_color7, i_pos_color8 };
	float packed_knots[10] = {0,...};

	color colors[ 8 ] = {
		i_color1, i_color2, i_color3, i_color4,
		i_color5, i_color6, i_color7, i_color8 };
	float colors_a[ 8 ] = {
		i_color1_a, i_color2_a, i_color3_a, i_color4_a,
		i_color5_a, i_color6_a, i_color7_a, i_color8_a };
	RGBA_ARRAY_DECLARE_SIZED(packed_colors, 10);

	float n, ndata=0;
	float sorted = true;
	for( n=0; n<8; n+=1 )
	{
		if( knots[n] != -1 )
		{
			packed_knots[ndata+1] = knots[n];
			RGBA_ARRAY_ASSIGN_FROM_ARRAY(packed_colors, ndata+1, colors, n);
			if( ndata>0 && packed_knots[ndata+1] < packed_knots[ndata] )
				sorted = false;
			ndata += 1;
		}
	}

	if( sorted == false )
	{
		/* Jesus, we have to sort those damn colors!!! */
		SortColors( packed_knots, RGBA_USE(packed_colors), ndata );
	}
	
	/* build a valid first/last knot */
	packed_knots[0] = 0.0;
	packed_knots[ndata+1] = 1.0;

	/* build the first/last color */
	RGBA_ARRAY_ASSIGN_FROM_ARRAY(packed_colors, 0, packed_colors, 1);
	RGBA_ARRAY_ASSIGN_FROM_ARRAY(packed_colors, ndata+1, packed_colors, ndata);

	/* clamp input to min/max knot value */
	float colorInput = input;
	if( i_clip == false )
		colorInput = clamp( colorInput, packed_knots[1], packed_knots[ndata] );

	/* use "input" to lookup in the gradient curve */
	colorInput = spline( "solvelinear", colorInput, packed_knots );
	if( i_rgba_interpolation == LINEARINTERPOL )
	{
		o_result = spline( "linear", colorInput, packed_colors );
		o_result_a = spline( "linear", colorInput, packed_colors_a );
	}
	else
	{
		o_result = spline( "catrom", colorInput, packed_colors );
		o_result_a = spline( "catrom", colorInput, packed_colors_a );
	}

	/* In clamp mode, perform an anti-aliased check against gradient
	   boundaries */
	if( i_clip==true )
	{
		float clip = 1-filterstep( packed_knots[1], input );
		RGBA_SMULT(o_result, 1-clip);
		clip = filterstep( packed_knots[ndata], input );
		RGBA_SMULT(o_result, 1-clip);
	}

	if( i_enable_alpha_gradient==true )
	{
		/* Do exactly the same thing for alpha ramp */
		float knots[ 8 ] = {
			i_pos_alpha1, i_pos_alpha2, i_pos_alpha3, i_pos_alpha4,
			i_pos_alpha5, i_pos_alpha6, i_pos_alpha7, i_pos_alpha8 };

		float alphas[ 8 ] = {
			i_alpha1, i_alpha2, i_alpha3, i_alpha4,
			i_alpha5, i_alpha6, i_alpha7, i_alpha8 };
		float packed_alphas[10];

		ndata = 0;
		sorted = true;
		for( n=0; n<8; n+=1 )
		{
			if( knots[n] != -1 )
			{
				packed_knots[ndata+1] = knots[n];
				packed_alphas[ndata+1] = alphas[n];
				if( ndata>0 && packed_knots[ndata+1] < packed_knots[ndata] )
					sorted = false;
				ndata += 1;
			}
		}

		if( sorted == false )
			SortAlphas( packed_knots, packed_alphas, ndata );

		/* build a valid first/last knot */
		packed_knots[0] = packed_knots[1];
		packed_knots[ndata+1] = packed_knots[ndata];

		/* build the first/last color */
		packed_alphas[0] = packed_alphas[1];
		packed_alphas[ndata+1] = packed_alphas[ndata];

		/* clamp input to min/max knot value */
		float alphaInput = clamp( input, packed_knots[1], packed_knots[ndata] );

		alphaInput = spline( "solvelinear", alphaInput, packed_knots );
		if( i_alpha_interpolation == LINEARINTERPOL )
		{
			o_result_a = spline( "linear", alphaInput, packed_alphas );
		}
		else
		{
			o_result_a = spline( "catrom", alphaInput, packed_alphas );
		}
	}
}
#endif
