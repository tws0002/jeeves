/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_illum_h
#define __xsi_illum_h

/*
	ShadingNormal

	A wrapper for faceforward which avoids faceforward for single-sided
	primitives or when using double-sided shading. This is to prevent artefacts
	around silhouette edges caused by the way "Sides 2" is usually shaded. Note
	that we don't explicitely check for double-sided shading as it also sets
	Sides to 1.

	Additionally, when baking geometry we want to disable the culling and
	leave RiSides to 1 in order to get the correct shading on the surfaces that
	are facing away from the viewer.
*/
normal ShadingNormal( normal i_N )
{
	extern vector I;
	normal Nf = i_N;

	uniform float sides = 2;
	attribute("Sides", sides);

	/* faceforward totally kills the rt sss */
	uniform string __raytype;
	rayinfo( "type", __raytype );
	uniform float __is_subsurface_ray = (__raytype == "subsurface") ? 1:0;

	if( sides == 2 && __is_subsurface_ray != 1 )
	{
		Nf = faceforward(Nf, I);
	}

	return Nf;
}

float fresnel( float cos_phi, n )
{
	// calculates fresnel coefficient for a surface with an
	// index of refraction of n, and an angle of phi between
	// m (normal at hit pt) and s (dir from hit pt to light).
	// the equation is given by:

	// F = 1/2 * (g-c)^2 / (g+c)^2 * { 1 + [ (c(g+c)-1) / (c(g-c)+1) ]^2 }
	// where c = cos(phi), g = sqrt( n^2 + c^2 - 1 )

	float F; // the fresnel coefficient
	float c; // cos(phi)
	float g; // sqrt( n^2 + c^2 - 1 )
	float temp;

	c = cos_phi;
	g = sqrt( (n*n) + (c*c) - 1 );
	if(g<0) g=0;

	F = 0.5;
	F *= ((g-c)*(g-c))/((g+c)*(g+c));
	temp = ((c * (g+c)) - 1) / ((c * (g-c)) + 1);
	temp *= temp;
	temp += 1;
	F *= temp;
	return F;
}

/* Follows some known microfacet distribution functions:
	- gaussian (used by Torrence-Sparrow)
	- cosine (used by Phong)
	- beckman (used by cook-torrence)
	- towbridge-reith (used by Blinn)
*/
float gaussian_distribution( float sigma, roughness )
{
	/* */
	float beta = sqrt( -log(1/2) / (roughness*roughness) );

	/* */
	float c2 = -sqrt(2) / beta;

	return exp( -sqr(c2*acos(sigma)) );
}

float beckmann_distribution( float sigma, roughness )
{
	float tmp = tan(acos(sigma))/roughness;
	tmp *= tmp;
	if( tmp < 1e-6 )
		tmp = 1e-6;
	float denum =(4 * roughness* roughness* pow(sigma, 4));
	return denum < 1e-6 ? 0.0 : exp(-tmp)/denum;	
}

float cosine_distribution( float sigma, roughness )
{
	return pow(sigma, roughness);
}

float trowbridge_distribution( float sigma, roughness )
{
	/* Compute the angle (beta) at which this function = 1/2 */
	float rr = sqr( roughness );
	float cos_beta =( sqrt( (4*rr-1)/(rr-1) ) );
	cos_beta *= cos_beta;

	/* Compute c3 as described in "Models of light reflection ..." by Blinn */
	float c = sqrt( (cos_beta-1) / (cos_beta-sqrt(2)) );	
	float cc = c * c;

	/* and finally the distribution */
	return sqr( cc / (sigma*sigma *(cc-1) + 1) );
}

/*
 * Blinn specular.
 *
 * By mental ray shader documentation:
 * Blinn
 * Perform Blinn illumination, which is a like Cook-Torrance illumination 
 * but without the color shift with angles. It only requires one index of
 * refraction. "mental_ray/shaders/node8.html#mi_shader__mib_illum_blinn"
 *
 * Nf         - forward facing normal
 * V          - view vector
 * refrac     - index of refraction
 * roughness  - surface roughness
 */
color blinn_specular(
	normal i_Nf;		/* Nf = faceforward (normalize(N), I) */
	vector i_V;			/* V  = -normalize(I) */
	float  i_ior;
	float  i_roughness;) 
{
	extern point P;

	color S = 0;

	illuminance("specular", P, i_Nf, PI/2)
	{
		float nonspecular = 0;
		lightsource("__nonspecular", nonspecular);

		vector Ln = normalize(L);
		vector R = reflect(-Ln, i_Nf);
		vector h  = normalize(Ln + i_V);
		float nh = max(0.00001, i_Nf.h);
		float nv = max(0.00001, i_Nf.i_V);
		float nl = max(0.00001, i_Nf.Ln);
		float vh = max(0.00001, i_V.h);

		/* Compute G */
		float a = 2 * nh * nv / vh;
		float b = 2 * nh * nl / vh;
		float g = min(a, b, 1);

		/* Compute the fresnel term */
		float lh = max(0, h.Ln );

		float f = fresnel( lh, i_ior < 1 ? 1 : i_ior );
		
		float d = tan(acos(nh))/i_roughness;
		d *= d;
		d = exp(-d);

		color rho_s = f * g * d / (2 * nv*nl);
		
		S += Cl * (1-nonspecular) * rho_s;
	}
	return S;
}

/**
 * cooktorr specular.
 *
 * Nf         - forward facing normal
 * V          - view vector
 * refrac     - index of refraction
 * roughness  - surface roughness
 */
color cooktorr_specular(
	normal Nf;		/* Nf = faceforward (normalize(N), I) */
	vector V;		/* V  = -normalize(I) */
	color  refrac;
	float  roughness;) 
{
	extern point P;

	color S = 0;

	illuminance("specular", P, Nf, PI/2)
	{
		float nonspecular = 0;
		lightsource("__nonspecular", nonspecular);

		vector Ln = normalize(L);
		vector h  = normalize(Ln + V);
		float nh = max(0.001, Nf.h);
		float nv = max(0.001, Nf.V);
		float nl = max(0.001, Nf.Ln);
		float vh = max(0.001, V.h);

		/* Compute G */
		float a = 2 * nh * nv / vh;
		float b = 2 * nh * nl / vh;
		float g = min(a, b, 1);

		/* Compute the fresnel term */
		float lh = max(0, h.Ln );

		color f =
			( fresnel( lh, refrac[0] < 1 ? 1 : refrac[0] ),
			  fresnel( lh, refrac[1] < 1 ? 1 : refrac[1] ),
			  fresnel( lh, refrac[2] < 1 ? 1 : refrac[2] ));

		float d = beckmann_distribution( nh, roughness );

		color rho_s = f * g * d / (PI * nv*nl);
		S += Cl * (1-nonspecular) * rho_s;
	}
	return S;
}


/*
	returns the ambience of the underlying object 
*/
color xsi_ambience( )
{
	color ambience = 0.0;
	if( 1 == islightcategory( "incandescence" ) )
	{
		option( "user:xsi_ambience", ambience );
	}
	return ambience;
}

/*
 * Credit: Taken from Advanced Renderman so that would probably be
 * Larry Gritz.
 * 
 * Greg Ward Larson's anisotropic specular local illumination model.
 * The derivation and formulae can be found in:  Ward, Gregory J.
 * "Measuring and Modeling Anisotropic Reflection," ACM Computer
 * Graphics 26(2) (Proceedings of Siggraph '92), pp. 265-272, July, 1992.
 * Notice that compared to the paper, the implementation below appears
 * to be missing a factor of 1/pi, and to have an extra L.N term.
 * This is not an error!  It is because the paper's formula is for the
 * BRDF, which is only part of the kernel of the light integral, whereas
 * shaders must compute the result of the integral.
 *
 * Inputs:
 *   N - unit surface normal
 *   V - unit viewing direction (from P toward the camera)
 *   xdir - a unit tangent of the surface defining the reference
 *          direction for the anisotropy.
 *   xroughness - the apparent roughness of the surface in xdir.
 *   yroughness - the roughness for the direction of the surface
 *          tangent perpendicular to xdir.
 */
color ward_specular(
	normal N;
	vector V;
	vector xdir;
	vector ydir;
	float xroughness, yroughness;)
{
    extern point P;
    float sqr (float x) { return x*x; }

    float cos_theta_r = clamp (N.V, 0.0001, 1);
    vector X = xdir / xroughness;
    vector Y = ydir / yroughness;

    color C = 0;
    illuminance ("specular", P, N, PI/2)
	{
		float nonspec = 0;
		lightsource ("__nonspecular", nonspec);

		if (nonspec < 1) 
		{
			vector LN = normalize( L );
			float cos_theta_i = LN . N;

			if( cos_theta_i > 0.0 )
			{
				vector H = normalize (V + LN);
				float rho = exp (-2 * (sqr(X.H) + sqr(Y.H)) / (1 + H.N))
					/ sqrt (cos_theta_i * cos_theta_r);
				C += Cl * ((1-nonspec) * cos_theta_i * rho);
			}
		}
	}

    return C / ( 4 * xroughness * yroughness);
}

/*
 * DESCRIPTION:
 *   Makes a rough surface using a BRDF which is more accurate than
 *   Lambert.  Based on Oren & Nayar's model (see Proc. SIGGRAPH 94).
 *
 *   Lambertian (isotropic) BRDF is a simple approximation, but not
 *   an especially accurate one for rough surfaces.  Truly rough surfacs
 *   tend to act more like retroreflectors than like isotropic scatterers.
 * 
 * PARAMETERS:
 *   Ka, Kd - ambient and diffuse strength.
 *   sigma - roughness (0 is lambertian, larger values are rougher)
 *
 * AUTHOR:  Larry Gritz
 *
 * REFERENCES:
 *   Oren, Michael and Shree K. Nayar.  "Generalization of Lambert's
 *         Reflectance Model," Computer Graphics Annual Conference
 *         Series 1994 (Proceedings of SIGGRAPH '94), pp. 239-246.
 */
color orennayar( color i_diffuse; float sigma; )
{
	extern point P;
	extern normal N;
	extern vector I; 

	normal Nf = ShadingNormal( normalize(N) );
	vector IN = normalize (I);
	vector Eye = -IN;
	float theta_r = acos( Eye . Nf );
	float sigma2 = sigma*sigma;

	color lightC = 0;

	illuminance( "diffuse", P, Nf, PI/2 )
	{
		float nondiff = 0;
		lightsource ("__nondiffuse", nondiff);

		if (nondiff < 1) 
		{
			vector LN = normalize(L);
			float cos_theta_i = LN . Nf;
			float cos_phi_diff =
				normalize(Eye-Nf*(Eye.Nf)) . normalize(LN - Nf*(LN.Nf));
			float theta_i = acos (cos_theta_i);
			float alpha = max (theta_i, theta_r);
			float beta = min (theta_i, theta_r);
			float C1 = 1.0 - 0.5 * sigma2/(sigma2+0.33);
			float C2 = 0.45 * sigma2 / (sigma2 + 0.09);
			if (cos_phi_diff >= 0)
				C2 *= sin(alpha);
			else
				C2 *= (sin(alpha) - pow(2*beta/PI,3));

			float C3 = 0.125 * sigma2 /
				(sigma2+0.09) * pow ((4*alpha*beta)/(PI*PI),2);

			color L1 = i_diffuse *
				(cos_theta_i * (C1 + cos_phi_diff * C2 * tan(beta) +
				(1 - abs(cos_phi_diff)) * C3 * tan((alpha+beta)/2)));
			color L2 = (i_diffuse * i_diffuse) *
				(0.17 * cos_theta_i * sigma2/(sigma2+0.13) *
				(1 - cos_phi_diff*(4*beta*beta)/(PI*PI)));
			lightC += (L1 + L2) * Cl * (1-nondiff);
		}
	}

	return lightC;
}

/*
 * Oren and Nayar's generalization of Lambert's reflection model.
 * The roughness parameter gives the standard deviation of angle
 * orientations of the presumed surface grooves.  When roughness=0,
 * the model is identical to Lambertian reflection.
 */
color
LocIllumOrenNayar (normal N;  vector V;  float roughness;)
{
    /* Surface roughness coefficients for Oren/Nayar's formula */
    float sigma2 = roughness * roughness;
    float A = 1 - 0.5 * sigma2 / (sigma2 + 0.33);
    float B = 0.45 * sigma2 / (sigma2 + 0.09);
    /* Useful precomputed quantities */
    float  theta_r = acos (V . N);        /* Angle between V and N */
    vector V_perp_N = normalize(V-N*(V.N)); /* Part of V perpendicular to N */

    /* Accumulate incoming radiance from lights in C */
    color  C = 0;
    extern point P;
    illuminance ("diffuse", P, N, PI/2) {
	/* Must declare extern L & Cl because we're in a function */
	extern vector L;  extern color Cl;
	float nondiff = 0;
	lightsource ("__nondiffuse", nondiff);
	if (nondiff < 1) {
	    vector LN = normalize(L);
	    float cos_theta_i = LN . N;
	    float cos_phi_diff = V_perp_N . normalize(LN - N*cos_theta_i);
	    float theta_i = acos (cos_theta_i);
	    float alpha = max (theta_i, theta_r);
	    float beta = min (theta_i, theta_r);
	    C += (1-nondiff) * Cl * cos_theta_i * 
		(A + B * max(0,cos_phi_diff) * sin(alpha) * tan(beta));
	}
    }
    return C;

}

/*
 * LocIllumGlossy - a possible replacement for specular(), with a
 * more uniformly bright core and a sharper falloff.  It's a nice
 * specular function to use for something made of glass or liquid.
 * Inputs:
 *  roughness - related to the size of the highlight, larger is bigger
 *  sharpness - 1 is infinitely sharp, 0 is very dull
 */
color LocIllumGlossy(
	normal N;  vector V;
	float roughness, sharpness; )
{
    color C = 0;
    float w = .18 * (1-sharpness);
    extern point P;
    float angle = PI/2 * (1-sharpness);

    if( roughness != 0 )
    {
	    illuminance ("specular", P, N, PI/2)
	    {
		    float nonspec = 0;
		    lightsource ("__nonspecular", nonspec);
		    if (nonspec < 1)
		    {
			    vector H = normalize(normalize(L)+V);
			    float blinn = pow(max(0,N.H), 1/roughness);
			    C += Cl * (1-nonspec) * smoothstep(.72-w, .72+w, blinn);
		    }
	    }
    }

    return C;
}

void SetPhongChannels(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);
	float i_shiny;
	point i_bump;
	output color o_diffuse;
	output color o_specular;
	output color o_ambient;
	output normal o_Nf; )
{
	extern normal N;
	extern vector I;

	if(i_bump != 0)
	{
		o_Nf = normalize(N) + ntransform("world", "current", normal(i_bump)); 
		o_Nf = normalize(o_Nf);
	}
	else
	{
		o_Nf = ShadingNormal( normalize(N) );
	}
	
	o_diffuse =  i_diffuse != 0 ? diffuse(o_Nf) * i_diffuse : 0;
	o_specular = i_specular != 0 ? i_specular * specularstd(o_Nf, normalize(-I), 1/i_shiny) : 0;
	o_ambient = i_ambient != 0 ? xsi_ambience() * i_ambient : i_ambient;
}

void SetBlinnChannels(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);
	float i_roughness;
	float i_ior;
	output color o_diffuse;
	output color o_specular;
	output color o_ambient;
	output normal o_Nf; )
{
	extern normal N;
	extern vector I;

	o_Nf = ShadingNormal( normalize(N) );
	vector V = -normalize(I);

	o_diffuse = i_diffuse != 0 ? diffuse(o_Nf) * i_diffuse : 0;
	o_specular = i_specular != 0 ? i_specular * blinn_specular(o_Nf, V, i_ior, i_roughness) : 0;
	o_ambient = i_ambient != 0 ? xsi_ambience() * i_ambient : 0;
}

void SetLambertChannels(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	point i_bump;
	output color o_diffuse;
	output color o_ambient;
	output normal o_Nf; )
{
	extern normal N;
	extern vector I;
	if(i_bump != 0)
	{
		o_Nf = ntransform("world", "camera", normal(i_bump));
	}
	else
	{
		o_Nf = ShadingNormal( normalize(N) );
	}
	
	o_diffuse = i_diffuse != 0 ? diffuse(o_Nf) * i_diffuse : 0;
	o_ambient = i_ambient != 0 ? i_ambient * xsi_ambience() : 0;
}

void SetCookTorranceChannels(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_specular);
	float i_roughness;
	RGBA_DECLARE(i_ior_tuple);
	output color o_diffuse;
	output color o_specular;
	output color o_ambient;
	output normal o_Nf; )
{
	extern normal N;
	extern vector I;

	o_Nf = ShadingNormal( normalize(N) );
	vector V = -normalize(I);
	
	o_diffuse = i_diffuse != 0 ? diffuse(o_Nf) * i_diffuse : 0;
	o_specular = i_specular != 0 ? i_specular * cooktorr_specular(o_Nf, V, i_ior_tuple, i_roughness) : 0;

	/* This is a fudge factor to match mental ray. */
	o_specular *= 0.32;

	o_ambient = i_ambient != 0 ? i_ambient * xsi_ambience() : 0;
}

void SetWardChannels(
	RGBA_DECLARE(i_ambient);
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE(i_glossy);
	float i_roughness_x, i_roughness_y;
	float i_surfderiv_mode;

	output color o_diffuse;
	output color o_specular;
	output color o_ambient;

	output normal o_Nf; )
{
	extern normal N;
	extern vector I, dPdu, dPdv;

	o_Nf = ShadingNormal( normalize(N) );
	vector V = -normalize(I);

	o_diffuse = i_diffuse != 0 ? diffuse(o_Nf) * i_diffuse : 0;

	if( i_glossy != 0 )
	{
		vector xdir, ydir;

		if( i_surfderiv_mode == -5 )
		{
			xdir = normalize(dPdu);
			ydir = normalize(dPdv);
		}
		else
		{
			xdir = normalize(dPdv);
			ydir = normalize(dPdu);
		}

		o_specular = i_glossy * 
			ward_specular(o_Nf, V, xdir, ydir, 1/i_roughness_x, 1/i_roughness_y);

		o_specular /= PI;
	}
	else
		o_specular = 0;

	o_ambient = i_ambient != 0 ? i_ambient * xsi_ambience() : 0;
}

float straussF (float x)
{
	float kf = 1.12;
	float kf2 = kf*kf;
	float denom = ( 1.0/((1.0-kf)*(1.0-kf)) - 1.0/kf2 );
	return ( ( 1.0/((x-kf)*(x-kf)) - 1.0/kf2 ) / denom);
}

float straussG (float x)
{
	float kg = 1.01;
	float kg2 = kg*kg;
	float denom = ( 1.0/((1.0-kg)*(1.0-kg)) - 1.0/kg2 );
	return (1.0/((1.0-kg)*(1.0-kg)) - 1.0/((x-kg)*(x-kg)) ) / denom;
}

void SetStraussChannels(
	RGBA_DECLARE( i_diffuse );
	float i_smoothness;
	float i_metalness;
	
	RGBA_DECLARE( i_ambience );
	point i_bump;
	
	output color o_diffuse;
	output color o_specular;
	output color o_ambient;
	output normal o_Nf; )
{
	extern normal N;
	extern vector I;
	extern point P;
	
	vector Ln, V, H;
	color Qa, Qd, Qs, Css;
	float NL, NV, f;
	float theta_i, theta_r;
	float rn, rj, rd, rs, d;
	float kj = 0.1;
	
	if(i_bump != 0)
	{
		o_Nf = ntransform("world", "camera", normal(i_bump));
	}
	else
	{
		o_Nf = ShadingNormal( normalize(N) );
	}
	
	V = -normalize(I);
	NV = o_Nf.V;
	
	o_diffuse = 0;
	o_specular = 0;
	o_ambient = 0;
	float tt = 0.0;
	
	illuminance( P ) {
		float nondiffuse = 0;
		float nonspecular = 0;
		lightsource("__nondiffuse", nondiffuse);
		lightsource("__nonspecular", nonspecular);
		
		Ln = normalize(L);
		NL = o_Nf.Ln;
		H = normalize( Ln - o_Nf*NL*2 );
		theta_i = 2*acos(abs(NL))/PI;
		theta_r = 2*acos(abs(NV))/PI;
		rd = (1-i_smoothness*i_smoothness*i_smoothness)*(1-tt);
		d = 1-i_metalness*i_smoothness;
		rn = 1-tt-rd;
		f = straussF((theta_i+theta_r)/2);
		//f = F(theta_i);
		rj = min(1, rn+(rn+kj)*f*straussG(theta_i)*straussG(theta_r));
		rs = pow(-(H.V), 3/(1.0001-i_smoothness))*rj;
		Css = 1 + i_metalness*(1-f)*(i_diffuse-1);
		
		o_diffuse += Cl*max(NL*d*rd*i_diffuse,0)*(1-nondiffuse);
		o_specular += Cl*max(rs*Css*(1/pow(i_smoothness,i_smoothness+1)),0)*(1-nonspecular); // (1/pow(i_smoothness,2)) - correction
	}
	
	o_ambient = (1-i_smoothness)*i_ambience*i_diffuse;
}

#define GET_CL( CL ) { CL = Cl; if( unshadowed != 0 ) \
	lightsource("o_unshadowed_cl", CL); }

float sq(float a;)
{
	return a*a;
}

color getGaussian(vector i_I; vector i_N; float i_roughness;
	uniform float i_keyLightsOnly, unshadowed)
{
	extern point P;
	color C = 0;
	
	illuminance( "specular", P )
	{
		float isKeyLight = 1;
		
		if( i_keyLightsOnly != 0 )
		{
			lightsource( "iskeylight", isKeyLight );
		}
		
		if( isKeyLight != 0 )
		{
			float nonspecular = 0;
			lightsource( "__nonspecular", nonspecular );
		
			if( nonspecular < 1 )
			{
				vector Ln = normalize(L);
				vector Hn = normalize(-i_I + Ln);
				
				float spec = exp( -sq( acos(i_N.Hn) / i_roughness ) );
				
				varying color cur_cl;
				GET_CL(cur_cl);
				
				C += cur_cl * spec * (1-nonspecular);
			}
		}
	}
	return C;
}

color getGaussianG(vector i_I; vector i_N; float i_roughness;
	uniform float i_keyLightsOnly, unshadowed)
{
	extern point P;
	color C = 0;
	
	illuminance( "specular", P )
	{
		float isKeyLight = 1;
		
		if( i_keyLightsOnly != 0 )
		{
			lightsource( "iskeylight", isKeyLight );
		}
		
		if( isKeyLight != 0 )
		{
			float nonspecular = 0;
			lightsource( "__nonspecular", nonspecular );
		
			if( nonspecular < 1 )
			{
				vector Ln = normalize(L);
				vector Hn = normalize(-i_I + Ln);
				
				float spec = exp( -sq( acos(i_N.Hn) / i_roughness ) );
				spec = smoothstep(0, 1/3, spec);
				
				varying color cur_cl;
				GET_CL(cur_cl);
				
				C += cur_cl * spec * (1-nonspecular);
			}
		}
	}
	return C;
}

#endif
