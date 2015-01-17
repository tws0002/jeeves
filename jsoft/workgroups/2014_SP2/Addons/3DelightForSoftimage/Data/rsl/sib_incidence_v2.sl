/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_incidence_v2_sl
#define __sib_incidence_v2_sl

/* Constants for sib_incidence_v2::mode */
#define SYSTEM_LIGHTLIST_CAMERA_LIGHT_DOT	11
#define CUSTOM_LIGHTLIST_CAMERA_LIGHT_DOT	10
#define SYSTEM_LIGHTLIST_NORMAL_LIGHT_DOT	9
#define CUSTOM_LIGHTLIST_NORMAL_LIGHT_DOT	8
#define CUSTOM_VECTOR		7
#define CAMERA_NORMAL_DOT	6
#define MZ			5
#define PZ			4
#define MY			3
#define PY			2
#define MX			1
#define PX			0

#include "sib_incidence.sl"

/* A really fucked-up shader if you ask me! -ak */

void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;
	point i_custom_vector;

	float i_invert;
	float i_light_intensity;
	float i_normal_shading;

	output float o_result;)
{
	extern point P;
	extern normal N;
	extern vector I;
	
	float incidence = 0;
	
	normal Nf = ShadingNormal( normalize(N) );

	if( i_mode <= CUSTOM_VECTOR )
	{
		sib_incidence(
			i_custom_vector, i_mode, 1, incidence );
	}
	else
	{
		if( i_mode == SYSTEM_LIGHTLIST_NORMAL_LIGHT_DOT ||
			i_mode == CUSTOM_LIGHTLIST_NORMAL_LIGHT_DOT )
		{
			illuminance( P )
			{
				vector Ln = normalize(L);
				float dot = Nf.Ln;

				if( i_normal_shading == 0 )
				{
					incidence += (dot + 1.0) * 0.5;
				}
				else if( Nf.L > 0 )
				{
					if( i_light_intensity == 1 )
					{
						incidence += dot * (Cl[0]+Cl[1]+Cl[2])/3;
					}
					else
					{
						incidence += dot;
					}
				}
			}
		}
		else
		{
			/* Camera/Light mode */
			illuminance( P )
			{
				vector Ln = normalize(L);
				incidence += Ln.normalize(I);
			}
			incidence = (incidence + 1.0) * 0.5;
		}
	}
	
	incidence = clamp( incidence, 0.0, 1.0 );
	
	/* apply bias */
	float bias = clamp( i_bias, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );
	incidence = BIAS(bias, incidence);
	
	/* apply gain */
	float gain = clamp( i_gain, miSCALAR_EPSILON, 1.0 - miSCALAR_EPSILON );
	incidence = GAIN(gain, incidence);
	
	/* apply invert */
	if ( i_invert )
		incidence = 1 - incidence;

	o_result = incidence;
}

void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;
	point i_custom_vector;

	float i_invert;
	float i_light_intensity;

	output float o_result;)
{
	sib_incidence_v2(
		i_mode, i_bias, i_gain, i_bump,
		i_custom_vector, i_invert, i_light_intensity, false, o_result );
}

void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;
	point i_custom_vector;

	float i_invert;

	output float o_result;)
{
	sib_incidence_v2(
		i_mode, i_bias, i_gain, i_bump,
		i_custom_vector, i_invert, false, false, o_result );
}

/* Softimage 2011 Camera/Lights mode */
void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;

	bool i_invert;
	
	output float o_result;)
{
	sib_incidence_v2(
		i_mode, i_bias, i_gain, i_bump,
		point(0), i_invert, false, false, o_result );
}

/* Softimage 2011 Surface/Camera mode */
void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;

	bool i_invert;
	bool i_light_intensity;
	
	output float o_result;)
{
	sib_incidence_v2(
		i_mode, i_bias, i_gain, i_bump,
		point(0), i_invert, i_light_intensity, false, o_result );
}

/* Softimage 2011 Surface/Lights mode */
void sib_incidence_v2(
	float i_mode, i_bias, i_gain;
	point i_bump;

	bool i_invert;
	bool i_light_intensity;
	bool i_normal_shading;
	
	output float o_result;)
{
	sib_incidence_v2(
		i_mode, i_bias, i_gain, i_bump,
		point(0), i_invert, i_light_intensity, i_normal_shading, o_result );
}

#endif
