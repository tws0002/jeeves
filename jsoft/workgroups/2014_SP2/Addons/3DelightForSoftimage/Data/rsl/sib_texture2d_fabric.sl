/*
	Copyright (c) 2007 TAARNA Studios International.
	Copyright (c) The 3Delight Developers. 2012
*/

#ifndef __sib_texture2d_fabric_sl
#define __sib_texture2d_fabric_sl

 /* This function calculates the brightness of a point on a strand. The
  * returned value br is 0 if the strand is fully bright,  1 if it
  * is totally blackened.  This has no particular theoretical background
  * but it looks good enough for us to be satisfied.
  */
float get_ubright( float i_u, i_v, uo, vo, uw; )
{   
    float br;

    float _u = i_u - uo;
    float _v = i_v - vo;
    
    if( uw!=0 ) 
	{
		br = abs(_u) * 1.75 / uw;
		br *= br;
    } else
		br = 1.0;  /* this shouldn't ever be the case, but... */
	    
    if( _v<-0.25 || _v>0.25 )
	{
		br += (abs(_v)-0.25) * 2.0;
    }

	br = clamp(br, 0.0, 1.0);
    
    return br;
}

/* a symmetric function (a macro). Rudiments from ancient times. */
#define GET_VBRIGHT(u, v, uo, vo, vw)	get_ubright(v, u, vo, uo, vw)

/* macros to enhance readability */
#define NS2U(x, y) (NOISE_2DL((x) *  1.0  + 17.0, (y) * 0.1  + 13.0))	/* macros for brightnessnoise */
#define NS2V(x, y) (NOISE_2DL((x) *  0.11 + 11.0, (y) * 1.0  + 77.0))	/* offset added to avoid regularity */
#define WNS2U(x, y) (NOISE_2DL((x) * 0.9  + 21.0, (y) * 0.1  - 17.0)) /* macros for widthnoise */
#define WNS2V(x, y) (NOISE_2DL((x) * 0.1  - 13.0, (y) * 1.03 + 5.0))

#define SIB_TEXTURE2D_FABRIC_PARAMS \
	RGBA_COLOR( i_uthreadcol ); \
	RGBA_COLOR( i_vthreadcol );	 \
	RGBA_COLOR( i_gapcol ); \
	float i_uthreadwidth, i_vthreadwidth; \
	float i_uwave, i_vwave; \
	float i_random; \
	float i_widthspread, i_brightspread

#define SIB_TEXTURE2D_FABRIC_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_uthreadcol), RGBA_COLOR_PARAM(i_vthreadcol), RGBA_COLOR_PARAM(i_gapcol), \
	i_uthreadwidth, i_vthreadwidth, i_uwave, i_vwave, i_random, i_widthspread, i_brightspread

#define SIB_TEXTURE2D_FABRIC_PARAMS_LIST_COPY_ALPHA \
	i_uthreadcol_a*i_alpha_factor, i_uthreadcol_a, \
	i_vthreadcol_a*i_alpha_factor, i_vthreadcol_a, \
	i_gapcol_a*i_alpha_factor, i_gapcol_a, \
	i_uthreadwidth, i_vthreadwidth, i_uwave, i_vwave, i_random, i_widthspread, i_brightspread

/* Softimage 2013 */
void sib_texture2d_fabric(
	point i_coord;
	SIB_TEXTURE2D_FABRIC_PARAMS;

	float i_noisetype;
	XSI_TEXTURE_DECLARE(i_permfiledat);
	XSI_TEXTURE_DECLARE(i_valfiledat);

	output color o_result;
	output float o_result_a; )
{
	RGBA_COLOR( ret );

    /* Store original uv values before transforming */
	float _u, _v;
    float ou = _u = xcomp(i_coord);
    float ov = _v = ycomp(i_coord);
	
    /* uv noise applied. As this is an inverse transformation, noise is
     * applied before the sine.
     */
    if( i_random != 0 )
    {
		_u += SNOISE_2DL(ov, ou) * i_random;
		_v += SNOISE_2DL(ou, ov) * i_random;
    }
	
    if( i_uwave!=0 )
		_u += sin(ov * PI * 2.0) * i_uwave;
    if( i_vwave!=0 )
		_v += sin(ou * PI * 2.0) * i_vwave;
    
    /* The fabric is composed of two kinds of cells, even cells
     * and odd cells.  In the uv unit square there are four cells,
     * two of each kind.  We thus slice the uv matrix into 0.5 by
     * 0.5 squares and handle them slightly differently.
     */
    
    /* store modified uv values before slicing */
    ou = _u;
    ov = _v;
    
    /* manually slice because we want to keep the floor */
    float iu = floor(ou * 2.0);
    float iv = floor(ov * 2.0);
    _u = ((ou * 2.0) - iu) * 0.5;
    _v = ((ov * 2.0) - iv) * 0.5;
    iu *= 0.5;
    iv *= 0.5;
    
    /* calculate the two basic thread widths */
    float wv = 0.5 * i_vthreadwidth;
    float wu = 0.5 * i_uthreadwidth;

    if( i_widthspread != 0 )
	{
		wv *= (1.0 - WNS2V(ou, iv) * i_widthspread);
		wu *= (1.0 - WNS2U(iu, ov) * i_widthspread);
	}
    
    if (_u>=wu && _v>=wv)
	{
		/* this is the gap, the same position in each case. */
		RGBA_ASSIGN( o_result, i_gapcol );
	}
	else
	{
		float bs=0, br=0;

		/* now, here we distinguish between the even and odd case */
		if( mod(floor(iu*2.0 - iv*2.0), 2) == 0 ) 
		{ 
			/* odd case */
			if (_v >= wv) 
			{	/* the smaller strand */
				br = get_ubright(ou, ov, iu + wu*0.5, iv + 0.5 + 0.5*wv, wu);
				RGBA_ASSIGN( ret, i_uthreadcol );
				if( i_brightspread != 0 )
					bs = NS2U(iu, ov);
			} 
			else 
			{
				/* the other one */
				float wt = 0.5 * i_uthreadwidth;
		
				/* calculate the extra threadwidth
				 * so we can position the center of 
				 * the strand correctly
				 */
				if( i_widthspread != 0 )
					wt *= (1.0 - WNS2U((iu - 0.5), ov) * i_widthspread);
				br = GET_VBRIGHT(ou, ov, iu + 0.5*wt, iv + 0.5*wv, wv);
				RGBA_ASSIGN( ret, i_vthreadcol );
				if( i_brightspread != 0 )
					bs = NS2V(ou, iv);
			}
		}
		else 
		{
			/*  even case */
			if (_u >= wu) 
			{
				br = GET_VBRIGHT(ou, ov, iu + 0.5 + 0.5*wu, iv + 0.5*wv, wv);
				RGBA_ASSIGN( ret, i_vthreadcol );
				if( i_brightspread != 0 )
					bs = NS2V(ou, iv);
			}
			else 
			{
				float wt = 0.5 * i_vthreadwidth;
				if( i_widthspread != 0 )
					wt *= (1.0 - WNS2V(ou, (iv - 0.5)) * i_widthspread);
				br = get_ubright(ou, ov, iu + 0.5 * wu, iv + 0.5*wt, wu);
				RGBA_ASSIGN( ret, i_uthreadcol );
				if( i_brightspread != 0 )
					bs = NS2U(iu, ov);
			}
		}
		/* darken the thread */
		RGBA_SMULT( ret, 1-bs );

		/* mix thread and gap colours */	
		RGBA_MIX( o_result, ret, i_gapcol, br );
	}
}

/* Old Softimage */
void sib_texture2d_fabric(
	point i_coord;
	SIB_TEXTURE2D_FABRIC_PARAMS;
	output color o_result;
	output float o_result_a; )
{
	XSI_TEXTURE_DECLARE(buffer);

	sib_texture2d_fabric(
			i_coord,
			SIB_TEXTURE2D_FABRIC_PARAMS_LIST,

			0,
			XSI_TEXTURE_USE(buffer),
			XSI_TEXTURE_USE(buffer),

			o_result,
			o_result_a );
}

/* undefine our temporary macros */
#undef NS2V
#undef NS2U
#undef WNS2V
#undef WNS2U
#undef GET_VBRIGHT

#endif
