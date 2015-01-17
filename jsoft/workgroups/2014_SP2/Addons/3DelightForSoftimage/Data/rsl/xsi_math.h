/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_math_h
#define __xsi_math_h

#define MATHBASIC_ADD 0
#define MATHBASIC_SUB 1
#define MATHBASIC_MUL 2
#define MATHBASIC_DIV 3
#define MATHBASIC_MIN 4
#define MATHBASIC_MAX 5

#define MATHEXPO_POW 0
#define MATHEXPO_LOG	1
#define MATHEXPO_BIAS	2
#define MATHEXPO_GAIN	3

#define MATHLOGIC_E		0
#define MATHLOGIC_L		1
#define MATHLOGIC_G		2
#define MATHLOGIC_LE	3
#define MATHLOGIC_GE	4

#define MATHUNARY_ABS 0
#define MATHUNARY_NEG 1
#define MATHUNARY_INV 2

#define SCALAR_MATH_OPER(m,a,b)	scalarMathOp(m, a, b)

float scalarMathOp( float m, a, b )
{
	float result;

	if( m == 3 )
		result = a;
	else if( m == 0 )
		result = a + b;
	else if( m == 1 )
		result = a - b;
	else
		result = a * b;

	return result;
}

float doscalarmathbasic(float input1, input2, op)
{
	float result = input1;

	if( op == MATHBASIC_ADD )	
		result = input1 + input2;
	else if( op == MATHBASIC_SUB )
		result = input1 - input2;
	else if( op == MATHBASIC_MUL )
		result = input1 * input2;
	else if( op == MATHBASIC_DIV ) 
	{
		if( abs(input2) < miSCALAR_EPSILON ) 
			result = input2>=0 ? miHUGE_SCALAR : -miHUGE_SCALAR;
		else 
			result = input1/input2;
	}
	else if( op == MATHBASIC_MIN ) 
		result = (input1 > input2) ? input2 : input1;
	else if( op == MATHBASIC_MAX ) 
		result = (input1 > input2) ? input1 : input2;

	return result;
}

float doscalarmathunary( float input, op; )
{
	float result = input;

	if( op == MATHUNARY_ABS )
		result = abs( input );
	else if( op == MATHUNARY_NEG )
		result = -input;
	else if( op == MATHUNARY_INV )
		result = 1-input;

	return result;
}

float doscalarmathexponent( float i_input, i_factor, op; )
{
	float result;

	if( op == MATHEXPO_POW )
	{ 
		float input = clamp( i_input, 0.0, 1.0 );
		float factor = clamp( i_factor, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );

		/* No zero exponent and only allow negative inputs for non-fractional
		   exponents. */
		if( factor == 0.0 || ( input < 0.0 && factor != floor(factor)) )
			result = 0.0;
		else
			result = pow(input, factor);
	}
	else if( op == MATHEXPO_LOG )
	{ 
		if( i_factor>=0 && i_input>=0 && i_factor!=1 )
		{
			float num, denom;
			if (i_factor < miSCALAR_EPSILON) 
				denom = miHUGE_SCALAR;
			else
				denom = log(i_factor);

			if (i_input < miSCALAR_EPSILON)
				num = miHUGE_SCALAR;
			else
				num = log(i_input);

			result = num/denom;
		}
	}
	else if( op == MATHEXPO_BIAS )
	{
		float input = clamp( i_input, 0.0, 1.0 );
		float factor = clamp( i_factor, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );
		result = BIAS(factor, input);
	}
	else if( op == MATHEXPO_GAIN )
	{
		float input = clamp( i_input, 0.0, 1.0 );
		float factor = clamp( i_factor, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );
		result = GAIN(factor, input);
	}
	else
		result = i_input;

	return result;
}


float doscalarmathlogic(float input1, input2, op; )
{
	float result;

	if( op == MATHLOGIC_E )
		result = (input1 == input2) ? 1 : 0;
	else if( op == MATHLOGIC_L )
		result = (input1 < input2) ? 1 : 0;
	else if( op == MATHLOGIC_G )
		result = (input1 > input2) ? 1 : 0;
	else if( op == MATHLOGIC_LE )
		result = (input1 <= input2) ? 1 : 0;
	else if( op == MATHLOGIC_GE )
		result = (input1 >= input2) ? 1 : 0;
	else 
		/* Invalid operator */
		result = input1;

	return result;
}
#endif
