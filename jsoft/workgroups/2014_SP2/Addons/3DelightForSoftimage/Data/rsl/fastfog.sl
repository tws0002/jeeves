/*
	An important important parameter for radiative transfer calculations is
	the phase or scattering function. For molecular scattering this amounts
	to is a simple analytical function.
	The "normalized phase function" describes the fraction of the scattered
	radiation that appears per unit solid angle in the direction 0 :

		normalized_phase_function = 1 + cos^2( 0 );
*/

#define MAX_SPOTS 100

#define EPSILON 1e-4

#define bool float
#define true 1
#define false 0

class fastfog(
	float density = 0.3;
	float absorption  = 0.2;
	color scattering = 1.0;
	color smoke_color  = color(1, 1, 1);
	float optimization = 1;
	float stepsize  = 0.25;
	float bias = 0;
	float jitter = 0;

	/* maximum distance to march inside the volume cone. Only active
	   when optimization = 1. */
	float maxdist = 1e30;

	string use_category = ""; )
{
	color colorexp( color c )
	{
		return color( exp(c[0]), exp(c[1]), exp(c[2]) );
	}

	constant float total_steps ;

	uniform point spot_from[ MAX_SPOTS ];
	uniform vector spot_dir[ MAX_SPOTS ];
	uniform float spot_coneangle[ MAX_SPOTS ];

	uniform float num_valid_lights = 0;

	public void construct()
	{
		total_steps = 0;
	}

	public void begin()
	{
		uniform shader lights[];
		lights = getlights( "category", use_category );
		float num_lights = min( MAX_SPOTS, arraylength(lights) );

		if( optimization != 0 )
		{
			if( num_lights > 0 )
			{
				uniform float l; for( l=0; l<num_lights; l+=1 )
				{
					uniform point from, to;
					uniform vector dir;
					uniform float coneangle;

					if( getvar(lights[l], "coneangle", coneangle)==false )
					{
						continue;
					}

					if( getvar(lights[l], "from", from)==false &&
						getvar(lights[l], "__from", from)==false )
					{
						continue;	
					}

					if( getvar(lights[l], "dir", dir)==false &&
						getvar(lights[l], "__dir", dir)==false )
					{
						if( getvar(lights[l], "to", to)==true ||
							getvar(lights[l], "__to", to)==true )
						{
							dir = to - from;
						}
						else
							continue;
					}

					spot_from[num_valid_lights] = transform( "world", from );
					spot_dir[num_valid_lights] = normalize( transform("world",dir));

					if( coneangle > 2 * PI )
						coneangle = radians(coneangle);
					spot_coneangle[num_valid_lights] = coneangle;

					num_valid_lights += 1;
				}
			}
#if 0
			if( num_valid_lights == 0 )
				printf( "fastfog.sl: no spot lights to optimize. Disabling optimization.\n" );
#endif
		}
	}

	/*
		RayConeIntersection

		Intersects a ray with a cone.

		NOTES
		The cone is assumed to have an acute angle between cone axis and cone edge.
		The return value is 'true' if and only if there is an intersection.  If
		there is an intersection, the number of intersections is stored in
		riQuantity.

		It is possible half the line is entirely on the cone surface.  In this
		case, the riQuantity is set to -1 and akPoint[] values are unassigned (the
		ray of intersection is V+(t*Dot(D,A))*D where V is the cone vertex, D is
		the line direction, and t >= 0.
	*/
	float RayConeIntersection(
		point i_ray_origin; vector i_ray_dir;
		/*uniform*/ point i_cone_vertex; /*uniform*/ vector i_cone_axis;
		/*uniform*/ float i_cone_cos_angle;

		output float o_num_intersections;
		output float o_start, o_end; )
	{
		// set up quadratic Q(t) = c2*t^2 + 2*c1*t + c0
		float fAdD = i_cone_axis.i_ray_dir;
		float fDdD = i_ray_dir.i_ray_dir;
		float fCosSqr = i_cone_cos_angle*i_cone_cos_angle;
		vector kE = i_ray_origin - i_cone_vertex;
		float fAdE = i_cone_axis.kE;
		float fDdE = i_ray_dir.kE;
		float fEdE = kE.kE;
		float fC2 = fAdD*fAdD - fCosSqr*fDdD;
		float fC1 = fAdD*fAdE - fCosSqr*fDdE;
		float fC0 = fAdE*fAdE - fCosSqr*fEdE;
		point akPoint[2];
		float ret = 0;

		// Solve the quadratic.  Keep only those X for which Dot(A,X-V) > 0.
		if (abs(fC2) >= EPSILON)
		{
			// c2 != 0
			float fDiscr = fC1*fC1 - fC0*fC2;
			if (fDiscr < 0.0)
			{
				// no real roots
				o_num_intersections = 0;
				ret = 0;
			}
			else if (fDiscr > 0.0)
			{
				// two distinct real roots
				float fRoot = sqrt(fDiscr);
				float fInvC2 = 1 / fC2;
				o_num_intersections = 0;

				float fT = (-fC1 - fRoot) * fInvC2;
				akPoint[o_num_intersections] = i_ray_origin + fT * i_ray_dir;
				kE = akPoint[o_num_intersections] - i_cone_vertex;
				if (kE.i_cone_axis > 0.0)
				{
					o_num_intersections = 1;
					o_start = fT;
				}
				fT = (-fC1 + fRoot)*fInvC2;
				akPoint[o_num_intersections] = i_ray_origin + fT*i_ray_dir;
				kE = akPoint[o_num_intersections] - i_cone_vertex;
				if (kE.i_cone_axis > 0)
				{
					o_num_intersections += 1;
					o_end = fT;
				}
				ret = 1;
			}
			else
			{
				// one repeated real root
				akPoint[0] = i_ray_origin - (fC1/fC2)*i_ray_dir;
				o_start = - (fC1/fC2);
				kE = akPoint[0] - i_cone_vertex;
				if (kE.i_cone_axis > 0)
					o_num_intersections = 1;
				else
					o_num_intersections = 0;

				ret = 1;
			}
		}
		else if (abs(fC1) >= EPSILON)
		{
			// c2 = 0, c1 != 0
			akPoint[0] = i_ray_origin - (0.5*fC0/fC1)*i_ray_dir;
			o_start = - 0.5 * fC0 / fC1;
			kE = akPoint[0] - i_cone_vertex;
			if (kE.i_cone_axis > 0)
				o_num_intersections = 1;
			else
				o_num_intersections = 0;

			ret = 1;
		}
		else if (abs(fC0) >= EPSILON)
		{
			// c2 = c1 = 0, c0 != 0
			ret = 0;
		}
		else
		{
			// c2 = c1 = c0 = 0, cone contains ray V+t*D where V is cone vertex
			// and D is the line direction.
			o_num_intersections = -1;
			ret = 1;
		}

		if (o_start > o_end)
		{
			float tmp = o_end;
			o_end = o_start;
			o_start = tmp;
		}

		return ret;
	}

	void FindIntegrationBounds(
		point i_ray_origin;
		vector i_ray_dir;
		output float o_start; output float o_end;)
	{
		float num_intersections = 0;
		uniform float i; for(i = 0; i < num_valid_lights; i += 1)
		{
			uniform float coneCosAngle = cos(spot_coneangle[i]);
			float start = -1, end = -1;

			float found = RayConeIntersection(
					i_ray_origin, i_ray_dir,
					spot_from[i], spot_dir[i], coneCosAngle,
					num_intersections, start, end);

			if( num_intersections == 1 )
			{
				/* Is the ray origin inside or outside the cone? */
				vector co = normalize(i_ray_origin - spot_from[i]);
				float dotProd = co.spot_dir[i];
				if (dotProd < coneCosAngle)
				{
					/* outside -> we need to set o_start */
					if (start == -1)
						start = end;
					end = 1e30;
				}
				else
				{
					/* inside -> we need to set o_end */
					if (end == -1)
						end = start;
					start = -1;
				}
			}

			if( num_intersections > 0)
			{
				o_start = min(start, o_start);
				o_end   = max(end, o_end);
			}
		}
	}

	color Li( point i_P; vector i_ray; float i_extinction_coef )
	{
		color Li = 0;

		illuminance(i_P)
		{
			if( Cl[0]!=0 || Cl[1]!=0 || Cl[2]!= 0 )
			{
				vector L_world = transform( "world", L );
				float dist_squared = L_world.L_world;
				float dist = sqrt( dist_squared );

				float tmp = -i_ray.L_world;
				float rayleigh_phase_function = 0.75 * (1 + tmp*tmp / dist_squared);

				Li += Cl * rayleigh_phase_function;
			}
		}

		return Li;
	}
	
	public void volume( output color Ci, Oi; )
	{
		point surf_pos = transform("world", P);        
		point eye_pos = transform("world", P-I);        

		vector ray = surf_pos - eye_pos;     
		float distance_to_surface = length( ray );
		vector ray_dir = ray / distance_to_surface;       

		float start = 0;
		float end = distance_to_surface - 1e-4;

		if( optimization == 1 )
		{
			float integration_start = 1e30;
			float integration_end = -1;

			FindIntegrationBounds(
				eye_pos, normalize(ray), integration_start, integration_end );

			start = max(integration_start, start);
			if (integration_end > 0)
				end = min(integration_end, end);

			if( end - start > maxdist )
				end = start + maxdist;	
		}

		float extinction_coef = density*absorption;

		color Cv = 0, Ov = 0;

		if( start<end && stepsize>EPSILON )
		{
			/* 't' is the current position along the integration line.
			   step is the integration step. */
			float t = start;
			float step = min( stepsize, end-start );

			vector vector_step = step * ray_dir;
			point current_pos = eye_pos + t*ray_dir;

			color last_li = Li(current_pos, ray_dir, extinction_coef);
			float last_dtau = 0.5;

			while( t <= end )
			{
				t += step;
				current_pos += vector_step;
			
				/* The shading point is positioned in the middle of the current
				   'step' and is brought back to 'current' space as is expected
				   by illuminance(). */	
				float jit = jitter > 0 ? (random() - 0.5)*jitter : 0;
				point P_shading = transform("world", "current",
						current_pos + vector_step*(0.5+jit) );

				color current_li = Li(P_shading, ray_dir, extinction_coef);
				float current_dtau = 0.5;

				/* From Advanced RenderMan:

					Find the blocking and light scattering contribution of 
					the portion of the volume covered by this step.
				*/
				float tau = extinction_coef * step/2 *
					(current_dtau + last_dtau);
				color lighttau = extinction_coef * step/2 *
					(current_li*current_dtau + last_li*last_dtau);

				/* Composite with exponential extinction of background light */
				Cv += (1-Ov) * lighttau;
				Ov += (1-Ov) * (1 - colorexp (-tau*scattering));

				last_dtau = current_dtau;
				last_li = current_li;
			}
		}

		Ci = Cv + (1-Ov) * Ci;
		Oi = Ov + (1-Ov) * Oi;
	}
}
