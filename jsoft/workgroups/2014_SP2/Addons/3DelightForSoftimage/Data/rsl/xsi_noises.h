/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_noises_h
#define __xsi_noises_h

#define mi_noise_1d(x) ( float(noise(x)) )
#define mi_noise_2d(x, y) ( float(noise(x, y)) )
#define mi_noise_3d(p) ( float(noise(p)) )

/* FIXME */
#define sibu_noise_3d_uni( p ) mi_noise_3d( p )

/* These noise functions give values [0,1] but without NOISE_MUL */
#define NOISE_1DL(x) mi_noise_1d(x)
#define NOISE_2DL(x, y)	mi_noise_2d(x, y)
#define NOISE_3DL(v) mi_noise_3d(v)

/* These noise functions give values [-1,1] but without NOISE_MUL */
#define SNOISE_1DL(x)	 (NOISE_1DL(x) * 2.0 - 1.0)
#define SNOISE_2DL(x, y) (NOISE_2DL(x, y) * 2.0 - 1.0)
#define SNOISE_3DL(v)	 (NOISE_3DL(v) * 2.0 - 1.0)

/* define different fractal parameters and parameter lists */
#define SIBU_FRACTAL_PARAMS \
	float i_noise_type, i_absolute, i_iter_max; \
	float i_level_min, i_level_decay, i_freq_mul
#define SIBU_FRACTAL_PARAMS_LIST \
	i_noise_type, i_absolute, i_iter_max, i_level_min, i_level_decay, i_freq_mul

#define sibu_rpnoise4 sibu_pnoise4
#define sibu_rpnoise3 noise
#define sibu_rpnoise2 noise
#define sibu_rpnoise1 noise
#define sibu_pnoise4(a,b) ((noise(a,b)-0.5)*2)
#define sibu_pnoise3 noise
#define sibu_pnoise2 noise
#define sibu_pnoise1 noise

float mi_noise_3d_grad(
	point i_p;
	output point o_grad;)
{
	float res = noise( i_p );

	//o_grad = Deriv( point(res, res, res), i_p );
	//o_grad = normalize( o_grad );

	o_grad = noise( i_p );
	return res;
}

float sibu_fractal_4d(
	point v; float i_t;
	SIBU_FRACTAL_PARAMS )
{
	float noise_type = mod( i_noise_type, 2 );
	float t = i_t;
	point tv = v;
	
	/* calculate decay if multiplicity is not 2 */
	float level_decay = max( i_level_decay, 0.0 );
	float l_mult = i_freq_mul!= 2.0 ?  pow(level_decay, i_freq_mul-1.0) : level_decay;
	float result = 0.0;

	float level, i=0;
	for( level=1.0; level>=i_level_min && i<i_iter_max; i+=1 )
	{
		if( i_absolute != 0 )
		{
			if( i_noise_type == 0 )
				result += level * abs( sibu_pnoise4(tv, t) );
			else
				result += level * abs( sibu_rpnoise4(tv, t) );
		}
		else
		{
			if( i_noise_type == 0 )
				result += level * sibu_pnoise4(tv, t);
			else
				result += level * sibu_rpnoise4(tv, t);
		}

		tv *= i_freq_mul;
		t *= i_freq_mul;

		level *= l_mult;
	}

	return result;
}

float ozlib_fractal3D1D(
	point i_pos;
	float i_absolute;
	point i_frequencies;
	float i_amplitude, i_ratio, i_iter_l; )
{
	float i;
	float wh = floor( i_iter_l );
	
	float res = 0;

	if( i_amplitude != 0 ) 
	{
		float a = 2.0*i_amplitude;
		point vec = i_pos * i_frequencies;

		if( i_absolute != 0 ) 
		{
			float offset = 0.0;
			if( wh != 0 )
			{	
				for( i=0; i < wh; i=i+1 )
				{
					res += a * abs( mi_noise_3d(vec) - 0.5 );
					vec *= 2;
					offset += a;
					a *= i_ratio;
				}
			}

			float fr = i_iter_l - wh;

			if( fr != 0 )
			{
				res += fr * a * abs(mi_noise_3d(vec) - 0.5);
				offset += fr*a;
			}
			res -= offset*0.25;	
		}
		else
		{
			if( wh!= 0 )	
			{
				for(i=0; i < wh; i = i + 1 )
				{
					res += a * (mi_noise_3d(vec) - 0.5);
					vec *= 2;
					a *= i_ratio;
				}
			}

			float fr = i_iter_l - wh;

			if( fr != 0 )
				res += fr * a * abs(mi_noise_3d(vec) - 0.5);
		}
	}

	return res;
}

/* This function gets a position vector and an accompanying struct
 * and returns UV coordinates according to fractal calculations
 */
#define FRACTAL_3D2D_PARAMS_LIST \
	i_absolute, i_frequencies, i_uamplitude, i_vamplitude, i_ratio, i_iter_l
point sibu_frac3D2D(
	point i_pos;
	float i_absolute;
	point i_frequencies;
	float i_uamplitude, i_vamplitude, i_ratio, i_iter_l; )
{
	float i; 
	point res = 0;	
	float wh = floor(i_iter_l);

	if( i_uamplitude!=0 || i_vamplitude!=0 )
	{
		float au = 2.0 * i_uamplitude;
		float av = 2.0 * i_vamplitude;

		point vec1 = i_pos * i_frequencies;
		point vec2;
		vec2[0] = i_pos[1] * i_frequencies[0] + 111.0;
		vec2[1] = i_pos[2] * i_frequencies[1] - 17.0;
		vec2[2] = i_pos[0] * i_frequencies[2] - 31.0;
	
		if(i_absolute!=0)
		{
			float offsetu = 0, offsetv = 0;
			if(wh!=0)
			{
				for(i=0; i < wh; i+=1 )
				{
					res[0] += au * abs( mi_noise_3d(vec1) - 0.5);
					res[1] += av * abs( mi_noise_3d(vec2) - 0.5);

					vec1 *= 2;
					vec2 *= 2;

					offsetu += au;
					offsetv += av;

					au *= i_ratio;
					av *= i_ratio;
				}
			}			
			float fr = i_iter_l - wh; 
			if( fr != 0 )
			{
				res[0] += fr * au * abs( mi_noise_3d(vec1) - 0.5);
				res[1] += fr * av * abs( mi_noise_3d(vec2) - 0.5);

				offsetu += fr*au;
				offsetv += fr*av;
			}
			res[0] -= offsetu*0.25;
			res[1] -= offsetv*0.25;
		}
		else
		{
			if(wh!=0)
			{
				for(i=0; i < wh; i+=1)
				{
					res[0] += au * ( mi_noise_3d(vec1) - 0.5);
					res[1] += av * ( mi_noise_3d(vec2) - 0.5);

					vec1 *= 2;
					vec2 *= 2;

					au *= i_ratio;
					av *= i_ratio;
				}
			}

			float fr = i_iter_l - wh; 
			if( fr != 0 )
			{
				res[0] += fr * au * ( mi_noise_3d(vec1) - 0.5);
				res[1] += fr * av * ( mi_noise_3d(vec2) - 0.5);
			}			
		}
	}

	return res;
}

/* Voronoi cell noise (a.k.a. Worley noise) -- 3-D, 2-feature version.
 * Added seed parameter */
void voronoi_f1f2_3d(
	point P;
	float jitter;
	float seed;
	output float feature_hash;
	output float f1;  output point pos1;
	output float f2;  output point pos2;)
{
    point thiscell = point (floor(P[0])+0.5, floor(P[1])+0.5, floor(P[2])+0.5);
    f1 = f2 = 1000;
    uniform float i, j, k;
    for (i = -1;  i <= 1;  i += 1)
    {
        for (j = -1;  j <= 1;  j += 1)
	{
		for (k = -1;  k <= 1;  k += 1)
		{
			point testcell = thiscell + vector(i,j,k);
			point pos = testcell + 
				jitter * (vector cellnoise (testcell, seed) - 0.5);
			vector offset = pos - P;
			float dist = offset . offset; /* actually dist^2 */
			if (dist < f1)
			{
				f2 = f1;  pos2 = pos1;
				f1 = dist;  pos1 = pos;
				feature_hash = cellnoise(testcell, seed);
			}
			else if (dist < f2)
			{
				f2 = dist;  pos2 = pos;
			}
		}
	}
    }
    f1 = sqrt(f1);  f2 = sqrt(f2);
}
/* Voronoi cell noise (a.k.a. Worley noise) -- 3-D, 1-feature version.
 * Added seed parameter */
void voronoi_f1_3d (point P;
	       float jitter;
		   float seed;
	       output float f1;
	       output point pos1;
    )
{
    point thiscell = point (floor(xcomp(P))+0.5, floor(ycomp(P))+0.5,
			    floor(zcomp(P))+0.5);
    f1 = 1000;
    uniform float i, j, k;
    for (i = -1;  i <= 1;  i += 1) {
        for (j = -1;  j <= 1;  j += 1) {
            for (k = -1;  k <= 1;  k += 1) {
		point testcell = thiscell + vector(i,j,k);
                point pos = testcell + 
		            jitter * (vector cellnoise (testcell, seed) - 0.5);
		vector offset = pos - P;
                float dist = offset . offset; /* actually dist^2 */
                if (dist < f1) {
                    f1 = dist;  pos1 = pos;
                }
            }
	}
    }
    //f1 = f1;
}

#endif
