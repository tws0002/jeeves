/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_color_h
#define __xsi_color_h

/* The famous colour intensity macro */
#define RGB_INT(col) \
        (0.299*(comp(col,0)) + 0.587*(comp(col,1)) + 0.114*(comp(col,2)))
#define _SCL(r,s1,e1,s2,e2)		((((r)-(s1)/(e1-s1))*(e2-s2))+s2)


// Compute the CIE luminance (Rec. 709) of a given color.
float luminance(color c)
{
	return
	      comp(c, 0) * 0.212671
	    + comp(c, 1) * 0.715160
	    + comp(c, 2) * 0.072169;
}

/*********************************  colour macros  ***************************************/
/* Macros to help with XSI/MI's RGBA color type */
#define RGBA_DECLARE(c) color c; float c##_a
#define RGBA_DECLARE_INIT4(c, r, g, b, a) color c = color(r, g, b); float c##_a = a
#define RGBA_DECLARE_INIT2(c, rgb, a) color c = rgb; float c##_a = a
#define RGBA_DECLARE_INIT1(c, rgba) color c = rgba; float c##_a = rgba##_a
#define RGBA_DECLARE_INIT0(c) color c = 0; float c##_a = 0
#define RGBA_DECLARE_INITA(c, array) color c = color( array[0], array[1], array[2] ); float c##_a = array[3]
#define RGBA_DECLARE_OUTPUT(c) output color c; output float c##_a
#define RGBA_USE(c) c, c##_a

#define RGBA_ARRAY_DECLARE_SIZED(c, s) color c[s]; float c##_a[s]
#define RGBA_ARRAY_DECLARE(c) color c[]; float c##_a[]
#define RGBA_ARRAY_DECLARE_OUTPUT(c) output color c[]; output float c##_a[]
#define RGBA_ARRAY_USE(c, i) c[i], c##_a[i]

#define RGBA_ARRAY_ASSIGN(dst, i, src) dst##[##i##] = src; dst##_a[##i##] = src##_a
#define RGBA_ARRAY_ASSIGN_FROM_ARRAY(dst, i, src, j) dst##[##i##] = src##[##j##]; dst##_a[##i##] = src##_a##[##j##]
#define RGBA_ARRAY_ASSIGN_VALUE2(dst, i, rgb, a) dst##[##i##] = rgb; dst##_a[##i##] = a
#define RGBA_ARRAY_ASSIGN_VALUE1(dst, i, rgba) dst##[##i##] = rgba; dst##_a[##i##] = rgba##_a

#define RGBA_COLOR(c) RGBA_DECLARE( c )
#define RGBA_COLOR_PARAM(c) RGBA_USE(c)
#define RGBA_ASSIGN(dst, src) dst = src; dst##_a = src##_a;
#define RGBA_ASSIGN_FROM_ARRAY(dst, src, i) dst = src##[##i##]; dst##_a = src##_a[##i##];
#define RGBA_ASSIGN_VALUE4(dst, r, g, b, a) dst = color(r, g, b); dst##_a = a;
#define RGBA_ASSIGN_VALUE2(dst, rgb, a) dst = rgb; dst##_a = a;
#define RGBA_ASSIGN_VALUEA(dst, array) \
	dst = color(array[0], array[1], array[2]); dst##_a = array[3];

#define RGBA_ABS( c ) \
	setcomp( c, 0, abs(comp(c, 0)) ); \
	setcomp( c, 1, abs(comp(c, 1)) ); \
	setcomp( c, 2, abs(comp(c, 2)) ); \
	c##_a = abs( c##_a );

#define BLACK(c) \
	( comp(c,0)<1e-6 && comp(c,1)<1e-6 && comp(c,2)<1e-6 )

/* define colour operations */
#define RGB_SMULT(A, S) \
	A *= (S);

#define RGBA_SMULT(A, S) \
	A *= (S); \
	A##_a *= (S);

#define RGB_MULT(A, B, C) \
	A = (B) * (C);

/* NOTE: the following macro cannot work on expressions! */
#define RGBA_MULT(A, B, C) \
	A = B * C; \
	A##_a = B##_a * C##_a;

#define RGB_ADD(A, B, C) \
	A = B + C;

#define RGBA_ADD(A, B, C) \
	A = B + C; \
	A##_a = B##_a + C##_a;

/* Mix macro: T = 0 [ A = B ] | T = 1 [ A = C ] */
#define RGB_MIX(A, B, C, T) \
	A = mix( B, C, T );

#define RGBA_MIX(A, B, C, T) \
	A = mix( B, C, T ); \
	A##_a = mix( B##_a, C##_a, T );

/* Contrast macro: T = 1 [ A = B ] | T = -1 [ A = C ] | T = 0 [ A = avg(B,C) ] */
#define RGB_CONTRAST(A, B, C, T) \
	A = (B) * (0.5+0.5*(T)) + (C) *(0.5-0.5*(T));

#define RGBA_CONTRAST(A, B, C, T) \
	A = (B) * (0.5+0.5*(T)) + (C) *(0.5-0.5*(T)); \
	A##_a = (B##_a) * (0.5+0.5*(T)) + (C##_a) *(0.5-0.5*(T));

#define COLOR_LUMA(c) ((comp(c,0)+comp(c,1)+comp(c,2))/3.0)

#define RGB_SET_OUTPUT( aov, A ) \
	if( isoutput( #aov ) ) \
	{ \
		outputchannel(#aov, ( A )); \
	}

#define RGBA_SET_OUTPUT( aov, A, B ) \
	RGB_SET_OUTPUT( aov, color( A ) ); \
	RGB_SET_OUTPUT( aov##_a, B );

#define RGBA_ACT_AND_SET_OUTPUT( aov, A, B ) \
	if( isoutput( #aov ) ) \
	{ \
		color C = 0; \
		A; \
		outputchannel(#aov, ( C )); \
	} \
	RGB_SET_OUTPUT( aov##_a, B );

void
mixincolor(
	output color io_result;
	output float io_result_a;

	RGBA_COLOR( i_new );
	float i_mode;
	RGBA_COLOR( i_weight );
	float i_alpha /* boolean */ )
{
	RGBA_COLOR( weight );
	weight = i_alpha!=0 ? i_weight * i_new_a : i_weight;
	weight_a = i_weight_a;

	if( i_mode == 0 )
	{
		/*BLEND*/
		io_result = io_result * (color(1)-i_new*weight) + i_new*weight;
		io_result_a = io_result_a * (1-i_new_a*weight_a) + i_new_a*weight_a;
	}
	else if( i_mode == 1 )		/*MIX*/
	{
		io_result = io_result * (color(1)-weight) + i_new*weight;
		io_result_a = io_result_a * (1-weight_a) + i_new_a*weight_a;
	}
	else if( i_mode == 2 )		/*ADD*/
	{
		io_result = io_result + i_new*weight;
		io_result_a = io_result_a + i_new_a*weight_a;
	}
	else if( i_mode == 3 )		/*BOUNDED ADD*/
	{
		io_result += i_new * weight;
		io_result_a += i_new_a * weight_a;
		io_result = clamp( io_result, 0, 1 );
		io_result_a = clamp( io_result_a, 0, 1 );
	}
	else if( i_mode == 4 )		/*MULTIPLY*/
	{
		io_result *= i_new * weight;
		io_result_a *= i_new_a * weight_a;
	}
	else if( i_mode == 5 )		/*BOUNDED MULTIPLY*/
	{
		io_result *= i_new * weight;
		io_result_a *= i_new_a * weight_a;
		io_result = clamp( io_result, 0, 1 );
		io_result_a = clamp( io_result_a, 0, 1 );
	}
	else if( i_mode == 6 )		/*INTENSITY MIX*/
	{
		float temp = RGB_INT(i_new);
		RGBA_SMULT(weight,temp);

		io_result = io_result*(1.0-weight)+i_new*weight;
		io_result_a = io_result_a*(1.0-weight_a)+i_new_a*weight_a;
	}
	else if( i_mode == 7 )		/*DARKER*/
	{
		io_result = min(io_result,i_new*weight);
		io_result_a = min(io_result_a,i_new_a*weight_a);
	}
	else if( i_mode ==  8 )		/*LIGHTER*/
	{
		io_result = max(io_result,i_new*weight);
		io_result_a = max(io_result_a,i_new_a*weight_a);
	}
	else if( i_mode == 9 )		/*DIFFERENCE*/
	{
		io_result = io_result - i_new*weight;
		io_result_a = io_result_a - i_new_a*weight_a;
		RGBA_ABS( io_result );
	}
	else if( i_mode == 10 )	/*HARD LIGHT*/
	{
		RGBA_DECLARE_INIT0( new );
		RGBA_MULT(new,i_new,weight);

		uniform float c;
		for( c=0 ; c<3; c=c+1 )
		{
			float res = comp(new, c)<0.5 ? 2.0 * comp(new, c)*comp(io_result, c) :
				1 - 2*(1-comp(new, c))*(1-comp(io_result, c));
			setcomp( io_result, c, res );
		}
		io_result_a = new_a<0.5 ? 2.0*new_a*io_result_a :
			1 - 2*(1-new_a)*(1-io_result_a);
	}
	else if( i_mode == 11 )	/*OVERLAY*/
	{
		RGBA_DECLARE_INIT0( new );
		RGBA_MULT(new,i_new,weight);

		uniform float c;
		for( c=0; c<3; c=c+1 )
		{
			float res = comp(io_result, c)<0.5 ? 2.0 * comp(new, c)*comp(io_result, c) :
				1 - 2*(1-comp(new, c))*(1-comp(io_result, c));
			setcomp( io_result, c, res );
		}
		io_result_a = io_result_a<0.5 ? 2.0*new_a*io_result_a :
			1 - 2*(1-new_a)*(1-io_result_a);
	}
	else if( i_mode == 12  )	/*SCREEN*/
	{
		RGBA_DECLARE_INIT0( new );
		RGBA_MULT(new,i_new,weight);

		io_result = color(1) - (1-io_result)*(1-new);
		io_result_a = 1 - (1-io_result_a)*(1-new_a);
	}
	else if( i_mode == 13 )	/*SOFT LIGHT*/
	{
		RGBA_DECLARE_INIT0( new );
		RGBA_MULT(new,i_new,weight);

		uniform float c;
		for( c=0 ; c<3; c+=1 )
		{
			float scl = _SCL(comp(io_result,c),0,1,0.25,0.75); 
			float res = comp(new, c)<0.5 ? 2 * comp(new, c)*scl :
				1 - 2*(1-comp(new, c))*(1-scl);
			setcomp( io_result, c, res );
		}
		float scl = _SCL(io_result_a,0,1,0.25,0.75); 
		io_result_a = new_a<0.5 ? 2.0*new_a*scl :
			1 - 2*(1-new_a)*(1-scl);
	} 
	else if( i_mode == 14 )	/*Decal or SI3D "without" mode */
	{
		if ( i_new_a >= miEPS || RGB_INT(i_new) >= miEPS)
		{
			io_result = io_result*(1-weight)+i_new*weight;
			io_result_a = io_result_a*(1-weight_a)+i_new_a*weight_a;
		}
	}
	else if( i_mode == 15 )	/*SI3D "Alpha" mode */
	{
		io_result = io_result * (1-weight*i_new_a)+ i_new*weight*i_new_a;
		io_result_a = io_result_a*(1.0-weight_a)+i_new_a*weight_a;
	}
	else if( i_mode == 16 )	/*SI3D RGB Modulate mode */
	{
		if ( i_new_a >= miEPS || RGB_INT(i_new) >= miEPS)
		{
			io_result *= i_new * weight;
			io_result_a *= i_new_a * weight_a;
		}
	}
}

color sibu_gamma( color i_color; float i_gamma; )
{
	color result;

	if( i_gamma == 1.0 || i_gamma == 0.0 )	
	{
		/*gamma of 1 is no change*/
		/*gamma of 0 is undefined*/
		result = i_color;
	}
	else
	{
		float l_invgamma = 1.0/i_gamma;

		float R = comp(i_color, 0) > 0.0 ? pow( comp(i_color,0), l_invgamma) : 0.0;
		float G = comp(i_color, 1) > 0.0 ? pow( comp(i_color,1), l_invgamma) : 0.0;
		float B = comp(i_color, 2) > 0.0 ? pow( comp(i_color,2), l_invgamma) : 0.0;

		result = color( R, G, B );
	}

	return result;
}

#endif
