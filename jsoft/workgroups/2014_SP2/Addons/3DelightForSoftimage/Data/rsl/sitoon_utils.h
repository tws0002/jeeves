/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sitoon_utils_h
#define __sitoon_utils_h

#define basis_RAY 0
#define basis_POINT 1
#define basis_NORMAL 2

#define space_WORLD 0
#define space_CAMERA 1
#define space_OBJECT 2

#define mix_mode_NORMAL		0
#define	mix_mode_ADD		 1
#define	mix_mode_MULTIPLY	 2
#define	mix_mode_SCREEN		 3
#define	mix_mode_OVERLAY	 4
#define	mix_mode_LIGHTEN	 5
#define	mix_mode_DARKEN		 6
#define	mix_mode_DIFFERENCE  7
#define	mix_mode_HUE		 8
#define	mix_mode_SATURATION	 9
#define	mix_mode_VALUE		 10
#define	mix_mode_SOFTLIGHT	 11
#define	mix_mode_HARDLIGHT	 12
#define	mix_mode_EXCLUSION	 13

#define incidence_dir_CAMERA 0
#define incidence_dir_CUSTOM 1
#define incidence_dir_OVER 2
#define incidence_dir_UNDER 3
#define incidence_dir_LEFT 4
#define incidence_dir_RIGHT 5
#define incidence_dir_OVERLEFT 	6
#define incidence_dir_OVERRIGHT 7
#define incidence_dir_UNDERLEFT 8
#define incidence_dir_UNDERRIGHT 9

#define	highlight_mode_NONE 0,
#define	highlight_mode_DIFFUSE 1
#define	highlight_mode_GLOSSY 2

/*
 * The fabled color mixing function. This is based loosely on the various
 * color compositing modes standard in various graphic software. A good 
 * reference has been the related pages at
 * http://www.adscape.com/eyedesign/photoshop/four/xref
 *
 * Note: this function does not alter the background alpha channel!
 */ 

/* linear interpolation */
#define LERP(X, S1, E1, S2, E2) ((((X)-(S1)/(E1-S1))*(E2-S2))+S2)

void sitoon_color_mix(
	output color o_result; output float o_result_a;

	RGBA_COLOR( foreground );
	RGBA_COLOR( background );

	float i_weight;
	uniform float i_mode; )
{
	color composite;

	if( i_mode == mix_mode_NORMAL )
		composite = foreground;
	else if( i_mode == mix_mode_ADD )
		composite = background + foreground;
	else if( i_mode == mix_mode_DIFFERENCE )
	{
		composite = color(
			abs( background[0] - foreground[0] ),
			abs( background[1] - foreground[1] ),
			abs( background[2] - foreground[2] ) );
	}
	else if( i_mode == mix_mode_MULTIPLY )
		composite = background * foreground;
	else if( i_mode == mix_mode_HUE )
	{
#define HSV_MIX( component ) \
		composite = ctransform( "hsv", background ); \
		color hsv_foreground = ctransform( "hsv", foreground ); \
		composite[component] = hsv_foreground[component]; \
		composite = ctransform( "hsv", "rgb", composite ); \

		HSV_MIX( 0 );
	}
	else if( i_mode == mix_mode_SATURATION )
	{
		HSV_MIX( 1 );
	}
	else if( i_mode == mix_mode_VALUE )
	{
		HSV_MIX( 2 );
	}
	else if( i_mode == mix_mode_LIGHTEN )
	{
		composite[0] = foreground[0] > background[0] ? foreground[0] : background[0];
		composite[1] = foreground[1] > background[1] ? foreground[1] : background[1];
		composite[2] = foreground[2] > background[2] ? foreground[2] : background[2];
	}
	else if( i_mode == mix_mode_DARKEN )
	{
		composite[0] = foreground[0] < background[0] ? foreground[0] : background[0];
		composite[1] = foreground[1] < background[1] ? foreground[1] : background[1];
		composite[2] = foreground[2] < background[2] ? foreground[2] : background[2];
	}
	else if( i_mode == mix_mode_SCREEN )
	{
		composite = 1 - (1-background)*(1-foreground);
	}
	else if( i_mode == mix_mode_OVERLAY )
	{
		composite[0] = background[0] < 0.5 ?
			2*foreground[0] * background[0] :
			1 - (2 * (1-foreground[0]) * (1-background[0]));
		composite[1] = background[1] < 0.5 ?
			2*foreground[1] * background[1] :
			1 - (2 * (1-foreground[1]) * (1-background[1]));
		composite[2] = background[2] < 0.5 ? 
			2*foreground[2] * background[2] :
			1 - (2 * (1-foreground[2]) * (1-background[2]));
	}
	else if( i_mode == mix_mode_SOFTLIGHT )
	{
		color l_background = (
			LERP(background[0], 0, 1, 0.25, 0.75),
			LERP(background[1], 0, 1, 0.25, 0.75),
			LERP(background[2], 0, 1, 0.25, 0.75) );

		composite[0] = foreground[0] < 0.5 ?
			2*foreground[0] * l_background[0] :
			1 - (2 * (1-foreground[0]) * (1-l_background[0]));
		composite[1] = foreground[1] < 0.5 ?
			2*foreground[1] * l_background[1] :
			1 - (2 * (1-foreground[1]) * (1-l_background[1]));
		composite[2] = foreground[2] < 0.5 ? 
			2*foreground[2] * l_background[2] :
			1 - (2 * (1-foreground[2]) * (1-l_background[2]));
	}
	else if( i_mode == mix_mode_HARDLIGHT )
	{
		composite[0] = foreground[0] < 0.5 ? 2 * foreground[0] * background[0] : 1 - (2 * (1-foreground[0]) * (1-background[0]));
		composite[1] = foreground[1] < 0.5 ? 2 * foreground[1] * background[1] : 1 - (2 * (1-foreground[1]) * (1-background[1]));
		composite[2] = foreground[2] < 0.5 ? 2 * foreground[2] * background[2] : 1 - (2 * (1-foreground[2]) * (1-background[2]));
	}
	else if( i_mode ==  mix_mode_EXCLUSION )
		composite = ((foreground) * (1-background)) + ((1-foreground) * (background));
	else
		composite = background;

	/* Combine operation result with background layer.
	 */
	o_result = i_weight*composite + (1-i_weight)*background;
	o_result_a = background_a;
}

void sitoon_which_dir( float i_preset, i_space; output vector o_dir )
{
	if( i_preset == incidence_dir_CAMERA )
	{
		extern vector I;
		o_dir = -I;
	}
	else
	{
		if( i_preset == incidence_dir_OVER )
			o_dir = vector(0,1,0);
		else if( i_preset == incidence_dir_UNDER )
			o_dir = vector(0,-1,0);
		else if( i_preset == incidence_dir_LEFT )
			o_dir = vector(-1,0,0);
		else if( i_preset == incidence_dir_RIGHT )
			o_dir = vector(1,0,0);
		else if( i_preset == incidence_dir_OVERLEFT )
			o_dir = vector(-1,1,0);
		else if( i_preset == incidence_dir_OVERRIGHT )
			o_dir = vector(1,1,0);
		else if( i_preset == incidence_dir_UNDERLEFT )
			o_dir = vector(-1,-1,0);
		else if( i_preset == incidence_dir_UNDERRIGHT )
			o_dir = vector(1,-1,0);

		if( i_space == space_WORLD )
			o_dir = vector "world" o_dir;
		else if( i_space == space_OBJECT )
			o_dir = vector "object" o_dir;
	}
}

float sitoon_incidence_vector(
	float i_threshold;	// highlight boundary
	float i_softness;	// boundary width
	vector i_vec; // direction of incident ray
	float i_invert	// invert incidence factor
	)
{
	extern normal N;
	extern vector I;

	float softness_half = i_softness/2,
		t_in = i_threshold - softness_half,
		t_out = i_threshold + softness_half;

	float factor = normalize(N).normalize(i_vec);
	if( t_out > t_in )
		factor = smoothstep(t_in, t_out, factor );
	else
		factor = filterstep( t_in, factor );

	if( i_invert!=0 )
		factor = 1 - factor;

	return factor;
}

float sitoon_ambient( )
{
	extern normal N;
	extern vector I;
	normal Nf = ShadingNormal( normalize(N) );
	float amount = ( diffuse(Nf) != 0 ) ? 0 : 1;
	return amount;
}

float sitoon_edge_width_scale(
	uniform float i_distanceFade;
	uniform float i_distanceFadeNear;
	uniform float i_distanceFadeFar;
	uniform float i_distanceScaleNear;
	uniform float i_distanceScaleFar;
	uniform float i_noise;
	uniform point i_noiseFrequency;
	uniform float i_noiseBasis;
	uniform float i_noiseSpace;
	uniform float i_noiseMin;
	uniform float i_noiseMax;
	uniform float i_neutralScale)
{
	extern varying point P;
	extern varying normal N;
	extern varying vector I;

	float scale = i_neutralScale;
	if(i_distanceFade > 0.0)
	{
		float d = zcomp(transform("camera", P));
		float range = i_distanceFadeFar - i_distanceFadeNear;
		float nd = clamp((d - i_distanceFadeNear) / range, 0.0, 1.0);
		float s = mix(i_distanceScaleNear, i_distanceScaleFar, nd);
		scale = mix(scale, s, i_distanceFade);
	}

	if(i_noise > 0.0)
	{
		string space = "world";
		if(i_noiseSpace == space_CAMERA)
		{
			space = "camera";
		}
		else if(i_noiseSpace == space_OBJECT)
		{
			space = "object";
		}

		point basis = point(vtransform(space, I));
		if(i_noiseBasis == basis_POINT)
		{
			basis = transform(space, P);
		}
		else if(i_noiseBasis == basis_NORMAL)
		{
			basis = point(ntransform(space, N));
		}

		basis[0] *= i_noiseFrequency[0]/2.0;
		basis[1] *= i_noiseFrequency[1]/2.0;
		basis[2] *= i_noiseFrequency[2]/2.0;

		float n = noise(basis);
		float cn = smoothstep(0.1, 0.9, n);
		float s = mix(i_noiseMin, i_noiseMax, cn);
		scale = mix(scale, s, i_noise);
	}

	return max(0.0001, scale);
}

#endif

