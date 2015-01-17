#ifndef __mi_bump_flakes_sl
#define __mi_bump_flakes_sl

/*
	animatedcellnoise

	This is a mix of cell noise and regular noise. It is cell noise by its
	point parameter but smooth noise by its float parameter. So you can think
	of it as a 3D cell noise which changes smoothly in the 4th dimension.
*/
point animatedcellnoise( point i_p; float i_t )
{
	/* This is so each cell changes direction at a different time. */
	float t = cellnoise(i_p) + i_t;

	float tbase = floor(t);

	point n1 = cellnoise( i_p, tbase );
	float d = t - tbase;
	point n2 = cellnoise( i_p, tbase + 1 );
	n1 += d * (n2 - n1);

	return n1;
}

/*
	SuspendedParticles

	simulates a medium filled with particles of a given radius.

	RETURNS
	total number of particles enclosing "Pn".
	
	NOTES
	- taken from 3dfm/rsl/noise_utils.h
	- if particle radius is "infinit", this will give a "worley" noise.
	- the 'octave' parameter is needed to make jitter different for all octaves
*/
float
SuspendedParticles(
	point Pn; float i_time;
	float particleradius;
	float jitter;
	float octave;
	output float f1;  output point pos1;
	output float f2;  output point pos2;
	output point particlesPos[];
    )
{
	point thiscell = 
		point( floor(xcomp(Pn))+0.5, floor(ycomp(Pn))+0.5,
		floor(zcomp(Pn))+0.5);

	f1 = f2 = 1e36;
	uniform float i, j, k;

	float curr_particle = 0;
	for (i = -1;  i <= 1;  i += 1)
	{
		for (j = -1;  j <= 1;  j += 1)
		{
			for (k = -1;  k <= 1;  k += 1)
			{
				point testcell = thiscell + vector(i,j,k);
				if( jitter > 0 )
				{
					vector jit = animatedcellnoise(
						testcell, i_time + 1000 * octave) - 0.5;
					testcell += jitter * jit;
				}
				float dist = distance( testcell, Pn );
				if( dist < particleradius )
				{
					particlesPos[curr_particle] = testcell;
					curr_particle += 1;
					if (dist < f1)
					{
						f2 = f1;  pos2 = pos1;
						f1 = dist;  pos1 = testcell;
					}
					else if (dist < f2)
					{
						f2 = dist;  pos2 = testcell;
					}
				}
			}
		}
	}
	
	return curr_particle;
}

void mi_bump_flakes_with_normal(
	float i_flake_density;
	float i_flake_strength;
	float i_flake_scale;
	output normal o_nrm;
	output color o_result; )
{
	void flakes(
		float i_density;
		float i_cellSize;
		output float flake_mult;				
		output vector flake_nrml; )
	{
		float vtof(vector v)
		{
			return (xcomp(v) + ycomp(v) + zcomp(v))/3;
		}

		extern float s;
		extern float t;

		float edgeDist;
		float outside;

		varying point pp = point(2*s,t,0);

		point particle_positions[27];

		float mysize = 2.2/i_cellSize;

		point Pn = pp * mysize + vector(2*noise(pp*mysize));

		float radius = sqrt((0.5*0.5 + 0.5*0.5) * i_density * 2) ; //i_density

		point p1, p2;
		float f1, f2;
		float num_particles = SuspendedParticles( 
				Pn, 0, radius,
				1.0, 0, f1,
				p1, f2, p2,
				particle_positions ); //i_randomness

		flake_mult = 0.3;
		flake_nrml = vector(0);
		if( num_particles != 0 )
		{
			flake_nrml = cellnoise ( p1 + vector(1, 7, 1023) ) - 0.5;
			flake_mult += 0.3 * vtof(flake_nrml);
			flake_nrml = normalize(flake_nrml);
		}		
	}

	extern normal N;

	float flake_mult;
	vector flake_nrml;
	flakes(i_flake_density, i_flake_scale, flake_mult, flake_nrml);

	o_nrm = normalize(normalize(N) + flake_nrml * i_flake_strength * 0.15);
	o_result = flake_mult;
}

void mi_bump_flakes(
	float i_flake_density;
	float i_flake_strength;
	float i_flake_scale;
	output color o_result;)
{
	normal tmp_nrml;
	mi_bump_flakes_with_normal(
			i_flake_density,
			i_flake_strength,
			i_flake_scale,
			tmp_nrml,
			o_result);
}

/* Softimage 2013 SP1 */
void mi_bump_flakes(
	float i_flake_density;
	float i_flake_strength;
	float i_flake_scale;

	RGBA_DECLARE_OUTPUT( o_result ) )
{
	normal tmp_nrml;
	mi_bump_flakes_with_normal(
			i_flake_density,
			i_flake_strength,
			i_flake_scale,
			tmp_nrml,
			o_result);
	o_result_a = 1.0;
}

#endif
