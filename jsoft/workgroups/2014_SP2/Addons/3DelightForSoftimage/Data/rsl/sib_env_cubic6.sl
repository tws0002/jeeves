/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_env_cubic6_sl
#define __sib_env_cubic6_sl

#define TEX_ERR	-1
#define TEX_MX	0		/* order must remains as is... */
#define TEX_PX	1
#define TEX_MY	2
#define TEX_PY	3
#define TEX_MZ	4
#define TEX_PZ	5

float face_select_mi(
	output point o_coord;
	point i_point;
	vector i_dir;
	point i_size )
{
	float face = TEX_ERR;
	vector dir = normalize( i_dir );
	point size = i_size * 0.5;

	while( 1==1 )
	{
		if( abs(dir[0]) >= 1e-6 ) 
		{
			float s = (size[0] - i_point[0]) / dir[0];

			if( s >= 0.0 )
			{
				point x =  i_point + s*dir;
				if( x[1] >= -size[1] && x[1] <= size[1] &&
					x[2] >= -size[2] && x[2] <= size[2] && dir[0] > 0)
				{
					o_coord = point(
							1.0 - 0.5 * (x[1] / size[1] + 1.0), 
							0.5 * (x[2] / size[2] + 1.0),
							0.0 );
					face = TEX_PX;
					break;
				}
			}

			s = -(size[0] + i_point[0]) / dir[0];

			if (s >= 0.0)
			{
				point x =  i_point + s*dir;
				if( x[1] >= -size[1] && x[1] <= size[1] &&
					x[2] >= -size[2] && x[2] <= size[2] && dir[0] < 0)
				{
					o_coord = point(
						0.5 * (x[1] / size[1] + 1.0),
						0.5 * (x[2] / size[2] + 1.0),
						0.0 );
					face = TEX_MX;
					break;
				}
			}
		}

		if( abs(dir[1]) >= 1e-6 )
		{
			float s = -(size[1] + i_point[1]) / dir[1];
			if (s >= 0.0) 
			{
				point x =  i_point + s*dir;
				if (x[0] >= -size[0] && x[0] <= size[0] &&
					x[2] >= -size[2] && x[2] <= size[2] && dir[1] < 0) 
				{
					o_coord[0] = 1.0 - 0.5 * (x[0] / size[0] + 1.0);
					o_coord[1] = 0.5 * (x[2] / size[2] + 1.0);
					o_coord[2] = 0.0;
					face = TEX_MZ;
					break;
				}
			}
			s = (size[1] - i_point[1]) / dir[1];
			if (s >= 0.0) 
			{
				point x =  i_point + s*dir;
				if (x[0] >= -size[0] && x[0] <= size[0] &&
					x[2] >= -size[2] && x[2] <= size[2] && dir[1] > 0)
				{
					o_coord[0] = 0.5 * (x[0] / size[0] + 1.0);
					o_coord[1] = 0.5 * (x[2] / size[2] + 1.0);
					o_coord[2] = 0.0;
					face = TEX_PZ;
					break;
				}
			}
		}
		if( abs(dir[2]) >= 1e-6 ) {
			float s = (size[2] - i_point[2]) / dir[2];

			if (s >= 0.0)
			{
				point x =  i_point + s*dir;
				if (x[0] >= -size[0] && x[0] <= size[0] &&
					x[1] >= -size[1] && x[1] <= size[1] && dir[2] > 0)
				{
					o_coord[0] = 0.5 * (x[0] / size[0] + 1.0);
					o_coord[1] = 0.5 * (x[1] / size[1] + 1.0);
					o_coord[2] = 0.0;
					face = TEX_PY;
					break;
				}
			}
			s = -(i_point[2] + size[2]) / dir[2];
			if (s >= 0.0)
			{
				point x =  i_point + s*dir;
				if (x[0] >= -size[0] && x[0] <=size[0] &&
					x[1] >= -size[1] && x[1] <=size[1] && dir[2] < 0) 
				{
					o_coord[0] = 0.5 * (x[0] / size[0] + 1.0);
					o_coord[1] = 0.5 * (x[1] / size[1] + 1.0);
					o_coord[2] = 0.0;
					face = TEX_MY;
					break;
				}
			}
		}
	}

	return face;
}

void sib_env_cubic6(
	point i_point, i_size;

	XSI_TEXTURE_DECLARE( i_tex_mx );
	XSI_TEXTURE_DECLARE( i_tex_px );
	XSI_TEXTURE_DECLARE( i_tex_my );
	XSI_TEXTURE_DECLARE( i_tex_py );
	XSI_TEXTURE_DECLARE( i_tex_mz );
	XSI_TEXTURE_DECLARE( i_tex_pz );

	output color o_result;
	output float o_result_a; )
{
	point coord;
	float face;
	
	extern vector reflection_dir;
	face = face_select_mi( coord, i_point, reflection_dir, i_size ); 

	if( face != TEX_ERR )
	{
		coord -= point( floor(coord[0]), floor(coord[1]), floor(coord[2]) );

		XSI_TEXTURE_DECLARE( face_texture );

		if( face == TEX_MX )
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_mx );
		}
		else if( face == TEX_PX )
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_px );
		}
		else if( face == TEX_MY )
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_my );
		}
		else if( face == TEX_PY )
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_py );
		}
		else if( face == TEX_MZ )
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_mz );
		}
		else 
		{
			XSI_TEXTURE_ASSIGN( face_texture, i_tex_pz );
		}
		xsi_textureLookupRGBA(
			XSI_TEXTURE_USE(face_texture), coord[0], coord[1], RGBA_USE(o_result));
	}
	else
	{
		o_result = 0;
		o_result_a = 0;
	}
}

#endif
