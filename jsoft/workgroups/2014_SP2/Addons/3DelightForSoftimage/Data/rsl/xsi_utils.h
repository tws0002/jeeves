/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_utils_h
#define __xsi_utils_h

/*  The effect of the following macro is to shift the number
 * value so that it is placed in [0,1[. 
 */
#define SLICE(x)	((x) - floor(x))

#define HYPOT(a, b)  sqrt((a)*(a)+(b)*(b))

/* Revised versions of Perlin's Bias and Gain functions, Christophe Schlick, 
 * Graphics Gems IV,  pg 401
 * t is the variable,  while a is the bias factor.
 * if (a) is 0,  a special case is invoked
 */
#define BIAS(a, t) ((a)!=0.0?((t)/((1.0/(a)-2.0)*(1.0-(t))+1.0)):0.0)

#define GAIN(a, t) \
	((a)!=0.0?((t)<0.5?		\
		(t)/((1.0/(a)-2.0)*(1.0-2.0*(t))+1.0) \
		:((1.0/(a)-2.0)*(1.0-2.0*(t))-(t))/ \
		((1.0/(a)-2.0)*(1.0-2.0*(t))-1.0)) \
	 :((t)<0.5?0.0:1.0)) /* a==0 special case */
	
#define LINE(L, H, C) (((C)-(L))/((H)-(L)))

float sqr( float x ) { return x*x; }

/* A bump function. Use the "uniform trick" to make sure we don't
   have artifacts because of varying conditionals. */
#define XSI_BUMP( p, n, disp ) \
{ \
	uniform float compute_bump = 0; \
 \
	if( p!=0 ) \
		compute_bump = 1; \
 \
	if( compute_bump == 1 ) \
	{ \
		n = normalize( calculatenormal( P + n*length(disp)) ); \
	} \
}

#define INTERP_LINEAR 0
#define INTERP_CIRCULAR_UP 1
#define INTERP_CIRCULAR_DOWN 2
#define INTERP_COSINE_UP 3
#define INTERP_COSINE_DOWN 4

#define BAKE_PREPARATION \
{ \
	uniform float rendermap = 0; \
	uniform float bakepass = 0; \
	attribute("user:__xsi_rendermap", rendermap); \
	option("user:xsi_bakepass", bakepass); \
	if (rendermap == 1 || bakepass == 1) \
	{ \
		I = -normalize(N); \
	} \
}

#define RENDERMAP_BAKE(path, variable) \
{ \
	uniform float rendermap = 0; \
	attribute("user:__xsi_rendermap", rendermap); \
	if(rendermap == 1) \
	{ \
		bake(path, Scene_x_uvprop[0], 1 - Scene_x_uvprop[1], variable); \
	} \
}

#define RENDERMAP_ADV_BAKE(path, refraction, reflection, ambient, diffuse, specular) \
{ \
	uniform float rendermap = 0; \
	if(__raytype == "camera" && \
		attribute("user:__xsi_rendermap", rendermap) == 1 && \
		rendermap == 1) \
	{ \
		color bake_variable = \
			Refraction*refraction + \
			Reflection*reflection + \
			Ambient*ambient + \
			Specular*specular + \
			Diffuse*diffuse; \
		bake(path, Scene_x_uvprop[0], 1 - Scene_x_uvprop[1], bake_variable); \
	} \
}

#define COLORBLEEDING_BLOCKER_BEGIN \
	uniform float __xsi_gi_receiver = 1; \
	if(__raytype == "diffuse" && \
		attribute("user:__xsi_gi_receiver", __xsi_gi_receiver) == 1.0 && \
		__xsi_gi_receiver == 0) \
	{ \
		Ci = 0.0; \
		Oi = 1.0; \
	} \
	else \
	{

#define COLORBLEEDING_BLOCKER_END \
	}

float sibu_interpolate(
	float interp_type, old_start, old_end, value, new_start, new_end )
{
	/* first, slide the values to between zero and one, do the scaling, and
	   the place it back in the specified range*/

	float result = (value-old_start)/(old_end-old_start);
	result = clamp( result, 0.0, 1.0 );

	if( interp_type == INTERP_CIRCULAR_UP )
		result=sqrt(1-sqr(result-1));
	else if( interp_type == INTERP_CIRCULAR_DOWN )
		result=1-sqrt(1-sqr(result));
	else if( interp_type == INTERP_COSINE_UP )
		result=cos(-PI/2+(PI/2*result));
	else if( interp_type == INTERP_COSINE_DOWN )
		result=1+cos(-PI+(PI/2*result));

	/*now scale the value back into the specified range*/
	return (new_end-new_start)*result+new_start;
}

/* Antialiased smoothstep(e0,e1,x).  
 * Compute the box filter of smoothstep(e0,e1,t) from x-dx/2 to x+dx/2.
 * Strategy: divide domain into 3 regions: t < e0, e0 <= t <= e1,
 * and t > e1.  Region 1 has integral 0.  Region 2 is computed by
 * analytically integrating smoothstep, which is -2t^3+3t^2.  Region 3
 * is trivially 1.
 */
float filteredsmoothstep (float e0, e1, x, dx)
{
    float integral (float t) {
	return -0.5*t*t * (t*t + t);
    }

    /* Compute x0, x1 bounding region of integration, and normalize so that
     * e0==0, e1==1
     */
    float edgediff = e1 - e0;
    float x0 = (x-e0)/edgediff;
    float fw = dx / edgediff;
    x0 -= 0.5*fw;
    float x1 = x0 + fw;

    /* Region 1 always contributes nothing */
    float int = 0;
    /* Region 2 - compute integral in region between 0 and 1 */
    if (x0 < 1 && x1 > 0)
	int += integral(min(x1,1)) - integral(max(x0,0));
    /* Region 3 - is 1.0 */
    if (x1 > 1)
	int += x1-max(1,x0);
    return int / fw;
}

// Clamp a given scalar to the [0, 1] range.
#define SATURATE(x) (clamp((x), 0, 1))

#endif
