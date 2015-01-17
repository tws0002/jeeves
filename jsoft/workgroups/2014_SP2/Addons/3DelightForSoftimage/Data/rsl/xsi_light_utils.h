/*
	Copyright (c) TAARNA Studios International.
*/

#define true 1
#define false 0
#define bool float

bool EvaluateShadow( 
	point Ps;
	uniform string shadowname;
	float shadowsamples, shadowblur, shadowbias;
	output color o_shadow )
{
	uniform float __ReceivesShadows = 1;
	attribute("user:__xsi_ReceivesShadows", __ReceivesShadows);

	if( __ReceivesShadows != 0 && shadowname!="" )
	{
		/* NOTE: Don't use shadowmap's bias in ray-trace mode since it 
		   is not the way things are organized in Softimage (completely
		   different UI page for shadow maps. */

		uniform string rayTracingSubset = "";
		uniform float _bias;

		if(shadowname == "raytrace")
		{
			uniform string identifier;
			attribute("light:identifier:name", identifier);
			rayTracingSubset = concat("xsi_LitBy_", identifier);

			/* This will cause 3Delight to evaluate the trace bias 
			   attribute. */
			_bias = -1; 
		}
		else
			_bias = shadowbias;

		float samples = ( shadowblur == 0 ) ? 1 : shadowsamples;
		uniform float is_bakepass = 0;
		if( samples > 1 &&
			option("user:xsi_bakepass", is_bakepass) == 1 &&
			is_bakepass == 1 )
		{
			/* Using division factor for shadow samples in bake pass.
			   This can be a massive speed up for a complex lighting. */
			samples = ceil( samples/8 );
		}
 
		o_shadow = shadow(
			shadowname, Ps,
			"samples", samples,
			"blur", shadowblur,
			"bias", _bias,
			"subset", rayTracingSubset );

		return true;
	}

	return false;
}


/* Superellipse soft clipping
 * Input:
 *   - point Q on the x-y plane
 *   - the equations of two superellipses (with major/minor axes given by
 *        a,b and A,B for the inner and outer ellipses, respectively)
 * Return value:
 *   - 0 if Q was inside the inner ellipse
 *   - 1 if Q was outside the outer ellipse
 *   - smoothly varying from 0 to 1 in between
 *
 * CREDITS: taken from Advanced RenderMan. So probably by Larry Gritz.
 */
float
clipSuperellipse (point Q;          /* Test point on the x-y plane */
		  float a, b;       /* Inner superellipse */
		  float A, B;       /* Outer superellipse */
		  float roundness;  /* Same roundness for both ellipses */
		 )
{
    float result = 0;
    float x = abs(xcomp(Q)), y = abs(ycomp(Q));
    if (x != 0 || y != 0) {  /* avoid degenerate case */
	if (roundness < 1.0e-6) {
	    /* Simpler case of a square */
	    result = 1 - (1-smoothstep(a,A,x)) * (1-smoothstep(b,B,y));
	} else if (roundness > 0.9999) {
	    /* Simple case of a circle */
	    float sqr (float x) { return x*x; }
	    float q = a * b / sqrt (sqr(b*x) + sqr(a*y));
	    float r = A * B / sqrt (sqr(B*x) + sqr(A*y));
	    result = smoothstep (q, r, 1);
	} else {
	    /* Harder, rounded corner case */
	    float re = 2/roundness;   /* roundness exponent */
	    float q = a * b * pow (pow(b*x, re) + pow(a*y, re), -1/re);
	    float r = A * B * pow (pow(B*x, re) + pow(A*y, re), -1/re);
	    result = smoothstep (q, r, 1);
	}
    }
    return result;
}



