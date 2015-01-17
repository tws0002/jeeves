/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_environment_sl
#define __sib_environment_sl

#define TEX_ERR					-1
#define TEX_MX					0		/* order must remains as is... */
#define TEX_PX					1
#define TEX_MY					2
#define TEX_PY					3
#define TEX_MZ					4
#define TEX_PZ					5
#define SPHERICAL				0
#define CYLINDRICAL				1
#define CUBIC_STRIP				2
#define CUBIC_CROSS_SIDEWAYS			3
#define CUBIC_CROSS				4
#define ONEQUARTER				0.25
#define HALF					0.5
#define THREEQUARTERS			0.75
#define ONETHIRD				0.33333333
#define TWOTHIRDS				0.66666666

float SelectFace(
	output point coord;		/* returned lookup coordinate */
	point i_point;	/* viewpoint (state->org) */
	vector i_dir;	/* view direction */
	point i_size )	/* box size */
{
	float s, face=TEX_ERR;
	vector dir = normalize( i_dir );
	point size = i_size * 0.5;

	while( 1 == 1 )
	{
		if( abs(dir[0]) >= 1e-6 )
		{
			s = ( size[0] - i_point[0] ) / dir[0];

			if( s >= 0.0 ) 
			{
				point x = i_point + dir * s;
				if( x[1] >= -size[1] && x[1] <= size[1] &&
					x[2] >= -size[2] && x[2] <= size[2] && dir[0] > 0)
				{
					coord = point( 1 - 0.5 * (x[1]/size[1] + 1), 0.5 * (x[2]/size[2] + 1.0), 0 );
					/* rotate 90cw */
					coord = point( coord[1], 1-coord[0], 0 );
					face = TEX_PX;
					break;
				}
			}

			s = -(size[0] + i_point[0]) / dir[0];
			if( s >= 0.0 ) 
			{
				point x = i_point + dir * s;
				if( x[1] >= -size[1] && x[1] <= size[1] &&
						x[2] >= -size[2] && x[2] <= size[2] && dir[0] < 0.0)
				{
					coord = point( 0.5 * (x[1]/size[1] + 1), 0.5 * (x[2]/size[2] + 1), 0 );
					/* rotate 90ccw */
					coord = point( 1-coord[1], coord[0], 0 );
					face = TEX_MX;
					break;
				}
			}
		}

		if( abs(dir[1]) >= 1e-6 )
		{
			s = -(size[1] + i_point[1]) / dir[1];

			if( s >= 0 )
			{
				point x = i_point + dir * s;
				if (x[0] >= -size[0] && x[0] <= size[0] &&
						x[2] >= -size[2] && x[2] <= size[2] && dir[1] < 0.0) 
				{
					coord = point( 1 - 0.5 * (x[0]/size[0] + 1.0), 0.5 * (x[2]/size[2] + 1.0), 0);
					face = TEX_PZ;
					break;
				}
			}
			s = (size[1] - i_point[1]) / dir[1];

			if( s >= 0.0 )
			{
				point x = i_point + dir * s;
				if( x[0] >= -size[0] && x[0] <= size[0] &&
						x[2] >= -size[2] && x[2] <= size[2] && dir[1] > 0.0)
				{
					/* rotate 180 */
					coord = point( 1 - 0.5 * (x[0]/size[0] + 1), 1 - 0.5 * (x[2]/size[2] + 1), 0);
					face = TEX_MZ;
					break;
				}
			}
		}

		if( abs(dir[2]) >= 1e-6 ) 
		{
			s = (size[2] - i_point[2]) / dir[2];
			if( s >= 0.0 )
			{
				point x = i_point + dir * s;
				if (x[0] >= -size[0] && x[0] <= size[0] &&
						x[1] >= -size[1] && x[1] <= size[1] && dir[2] > 0 )
				{
					coord = point( 1 - 0.5*(x[0] / size[0] + 1), 0.5 * (x[1]/size[1] + 1), 0 );
					face = TEX_MY;
					break;
				}
			}
			s = -(i_point[2] + size[2]) / dir[2];
			if( s >= 0 )
			{
				point x = i_point + dir * s;
				if (x[0] >= -size[0] && x[0] <=size[0] &&
						x[1] >= -size[1] && x[1] <=size[1] && dir[2] < 0)
				{
					coord = point( 0.5 * (x[0] / size[0] + 1), 0.5 * (x[1] / size[1] + 1), 0 );
					face = TEX_PY;
					break;
				}
			}
		}
		/* BAD FACE */
		break;
	}

	return face;
}

/* Intersect ray (r, dir) in canonical cylinder space with canonical
   cylinder, which is defined by x^2 + y^2 -r^2 = 0, r = 1, z axis
   from [-1..+1].
   calculate texture parameters in intersection point, z[-1..+1]
   is mapped to v[0..1], rotation counterclockwise around z axis,
   +x,y=+0 is mapped to u=0, +x,y=-0 is mapped to u=1. the cylinder
   can be cut with the begin, end parameters in radians.
 */
float IntersectCylinder(
	point r; vector dir;
	output point tex;
	float begin, end)
{
	float result = false;
	float a = dir[0]*dir[0] + dir[1]*dir[1];

	while( a != 0 )
	{
		float b = 2.0 * (r[0] * dir[0] + r[1] * dir[1]);
		float c = r[0] * r[0] + r[1] * r[1] - 1.0;

		b /= a;
		c /= a;
		float d = b * b * 0.25 - c;

		if( d >= 0 )
		{
			d = sqrt( d );
			b *= -0.5;

			float t1 = b + d;
			float t2 = b - d;

			if( t1 >= 0 )
			{
				/* this is true here: t1 > t2 */
				if( t2 >= 0 )
				{
					/* both positive: use smaller value */
					float t = t1;
					t1 = t2;
					t2 = t;
				}

				float z = r[2] + t1 * dir[2];

				if( z<-1 || z>1 )
				{
					if( t2 >= 0 ) 
					{
						/* ray has two positive intersections:
						   use the farther, which is inside the
						   infinite cylinder */
						t1 = t2;
						z = r[2] + t1 * dir[2];

						if( z < -1 || z > 1 )
							break;
					}
					else
					{
						/* ray has a negative and a positive
						   intersection: cylinder not hit within
						   definition */
						break;
					}
				}

				float x = r[0] + t1 * dir[0];
				float y = r[1] + t1 * dir[1];

				if( x == 0 )
					tex[0] = (y >= 0) ? PI*0.5 : 3.0*PI*0.5;
				else
				{
					if( y >= 0 )
					{
						if( x > 0 )
							tex[0] = atan(y/x);		/* 0..90 */
						else
							tex[0] = PI - atan(y/(-x));	/* 90..180 */
					}
					else
					{
						if (x > 0 )
							tex[0] = 2*PI - atan(-y/x);	/* 270..360 */
						else
							tex[0] = PI + atan(y/x);	/* 180..270 */
					}
				}

				if( !(begin == 0 && end == 0) &&
						(tex[0] < begin || tex[0] > end))
					break;

				tex[0] *= 1.0 / (2 * PI);
				tex[1] = (z + 1.0) * 0.5;
				tex[2] = 0;

				result = true;
			}
		}

		break;
	}

	return result;
}

void sib_environment(
	XSI_TEXTURE_DECLARE( i_tex );
	uniform float i_mode;
	float i_reflection_intensity;
	float i_background_intensity;
	float i_fg_intensity;
	float i_open, i_close;
	matrix i_transform;

	output color o_result;
	output float o_result_a; )
{
	/* In case we have an unknown "mode". */
	o_result = o_result_a = 0;

	extern vector reflection_dir;
	vector dir = reflection_dir;

	if( i_mode == SPHERICAL )
	{
		dir = vtransform( i_transform, dir );
		float norm = length(dir);

		float theta;

		/* avoid calling atan2(0, 0), which return NaN on some platforms */
		if( dir[0]==0 && dir[2]==0 )
			theta = 0;
		else
			theta = -atan(dir[0], dir[2]) / (2*PI);
		theta -= floor(theta);

		float _s = theta;
		float _t = asin(dir[1]/norm) / PI + 0.5;

		o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), _s, _t);
	}
	else if( i_mode == CYLINDRICAL )
	{
		matrix rot90onX = (1, 0, 0, 0, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1);
		point position = transform( i_transform, 0 );

		/* begin & end are in degree, but converted to radian
		   for cylinder_intersect function */
		float begin = radians(i_open);
		float end  = radians(i_close);

		/* 3D transformation of the env map rotate on X by 90deg,
		   since the canonical cylinder axis is align with Z axis */

		dir = vtransform( rot90onX, dir );
		dir = vtransform( i_transform, dir );

		/* intersect ray with canonical cylinder */
		point coord = 0;
		if( IntersectCylinder(position, dir, coord, begin, end) !=0 )
		{
			o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);
		}
	}
	else if( i_mode == CUBIC_STRIP )
	{
		point size = 1;
		point position = transform( i_transform, 0 );

		dir = vtransform( i_transform, dir );

		point coord = 0;
		float face = SelectFace( coord, position, dir, size );

		if( face != TEX_ERR ) 
		{
			coord -= vector( floor(coord[0]), floor(coord[1]), floor(coord[2]) );
			coord[0] = 1.0 - coord[0]; /*flip X*/
			coord[0] = (coord[0] + face) / 6.0;
			o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);
		}
	}
	else if( i_mode == CUBIC_CROSS_SIDEWAYS )
	{
		/* Cubic Renderman Layout
		 * ________________
		 * |     T         |
		 * |  L  F   R  Ba |
		 * |     Bo        |
		 * |_______________|
		 */
		point size = 1;
		point position = transform( i_transform, 0 );

		dir = vtransform( i_transform, dir );

		point coord = 0;
		float face = SelectFace( coord, position, dir, size );

		if( face != TEX_ERR )
		{
			coord -= vector( floor(coord[0]), floor(coord[1]), floor(coord[2]) );
			coord[0] = 1.0 - coord[0]; /*flip X*/

			/* face select will assume the following face alignement in the image */
			/* x+ x- y+ y- z+ z- */
			/* we need to remap every face into the renderman layout */
			/* we need to resize the coord to allow offset */
			coord[0] /= 4; /*4 face wide*/
			coord[1] /= 3; /*3 face height*/

			if( face == TEX_MX ) /*right*/
				coord[1] += ONETHIRD;
			else if( face == TEX_PX ) /*left*/
				coord += vector( HALF, ONETHIRD, 0 );
			else if( face == TEX_PY ) /*Back*/
				coord += vector( THREEQUARTERS, ONETHIRD, 0 );
			else if( face == TEX_MY ) /*Front*/
				coord += vector( ONEQUARTER, ONETHIRD, 0 );
			else if( face == TEX_PZ ) /*Bottom*/
				coord[0] += ONEQUARTER;
			else if( face == TEX_MZ ) /*Top*/
				coord += vector( ONEQUARTER, TWOTHIRDS, 0 );

			o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);
		}
	}
	else if( i_mode == CUBIC_CROSS )
	{
		/* Cross Layout
		 * ____________
		 * |    T     |
		 * | L  F   R |
		 * |    Bo    |
		 * |    Ba    |
		 * |__________|
		 */
		point size = 1;
		point position = transform( i_transform, 0 );

		dir = vtransform( i_transform, dir );

		point coord = 0;
		float face = SelectFace( coord, position, dir, size );

		if( face != TEX_ERR )
		{	
			coord -= vector( floor(coord[0]), floor(coord[1]), floor(coord[2]) );

			/* special case for back */
			if ( face == TEX_PY )
			{
				coord[0] = 1.0 - coord[0];
				coord[1] = 1.0 - coord[1];
			}

			/* face select will assume the following face alignement in the image */
			/* x+ x- y+ y- z+ z- */
			/* we need to remap every face into the renderman layout */
			/* we need to resize the coord to ease offset */
			coord[0] *= (1.0 / 3.0); /*3 face height*/
			coord[1] *= (1.0 / 4.0); /*4 face wide*/

			if( face == TEX_MX ) /*right*/
			{
				coord[0] += TWOTHIRDS;
				coord[1] += HALF;
			}
			else if( face == TEX_PX ) /*left*/
				coord[1] += HALF;
			else if( face == TEX_PY ) /*Back*/
				coord[0] += ONETHIRD;
			else if( face == TEX_MY ) /*Front*/
				coord += vector( ONETHIRD, HALF, 0 );
			else if( face == TEX_PZ ) /*Bottom*/
				coord += vector( ONETHIRD, ONEQUARTER, 0 );
			else if( face == TEX_MZ ) /*Top*/
				coord += vector( ONETHIRD, THREEQUARTERS, 0 );

			o_result = xsi_textureLookupRGB(XSI_TEXTURE_USE(i_tex), coord[0], coord[1]);
		}
	}

	extern float reflection_type;

	if( reflection_type == XSI_ENV_RAY_REFLECTION )
		o_result *= i_reflection_intensity;
	else if( reflection_type == XSI_ENV_RAY_BACKGROUND )
		o_result *= i_background_intensity;
	else /* reflection_type == XSI_ENV_RAY_FOREGROUND */
		o_result *= i_fg_intensity;

	o_result_a = 1;
}
#endif
