/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_bumpmap_gen_sl
#define __sib_bumpmap_gen_sl

#include "mib_bump_map.sl"
#include "mib_texture_remap.sl"

void sib_bumpmap_gen(
	XSI_TEXTURE_DECLARE(i_tex);
	point i_coord;
	point i_basis;
	
	float i_project_basis;
	
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;		
	point i_min, i_max;
	
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_inuse;

	float i_relnormal;
	point i_normal;	

	float i_clamp;
	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear_true;
	float i_bump_filtered;
	float i_bump_basis;

	output point o_result )
{
	if( i_inuse == false )
	{
		extern normal N;
		o_result = point(ntransform("world", N));
	}
	else
	{
		point coord;

		mib_texture_remap(
			i_coord,
			1, i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			false, false, false,
			i_min, i_max, 0,
			coord );

		RGBA_DECLARE( tex );

		if( i_alpha==false )
		{
			tex = xsi_textureLookupRGB( XSI_TEXTURE_USE(i_tex), coord[0], coord[1] );
			tex_a = 1.0;
		}
		else
		{
			tex_a = xsi_textureLookupA( XSI_TEXTURE_USE(i_tex), coord[0], coord[1] );
			tex = 0;
		}

		mib_bump_map(
			0, 0,
			coord, 
			i_step, i_factor, i_torus_u, i_torus_v,
			i_alpha,
			tex, tex_a, i_clamp,
			o_result );
	}
}

void sib_bumpmap_gen(
	RGBA_DECLARE(i_tex);
	point i_coord;
	point i_basis;
	
	float i_project_basis;
	
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;		
	point i_min, i_max;
	
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_inuse;

	float i_relnormal;
	point i_normal;	

	float i_clamp;
	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear_true;
	float i_bump_filtered;
	float i_bump_basis;

	output point o_result )
{
	if( i_inuse == false )
	{
		extern normal N;
		o_result = point(ntransform("world", N));
	}
	else
	{
		point coord;

		mib_texture_remap(
			i_coord,
			1, i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			false, false, false,
			i_min, i_max, 0,
			coord );

		RGBA_DECLARE( tex );
		if( i_alpha==false )
		{
			tex = i_tex;
			tex_a = 1.0;
		}
		else
		{
			tex_a = i_tex_a;	
			tex = 0;
		}

		mib_bump_map(
			0, 0,
			coord, 
			i_step, i_factor, i_torus_u, i_torus_v,
			i_alpha,
			tex, tex_a, i_clamp,
			o_result );
	}
}

void sib_bumpmap_gen(
	color i_tex_no_alpha;

	point i_coord;
	point i_basis;
	
	float i_project_basis;
	
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;		
	point i_min, i_max;
	
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_inuse;

	float i_relnormal;
	point i_normal;	

	float i_clamp;
	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear_true;
	float i_bump_filtered;
	float i_bump_basis;

	output point o_result )
{
	RGBA_DECLARE(i_tex);
	i_tex = i_tex_no_alpha;
	i_tex_a = 1.0;

	if( i_inuse == false )
	{
		extern normal N;
		o_result = point(ntransform("world", N));
	}
	else
	{
		point coord;

		mib_texture_remap(
			i_coord,
			1, i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			false, false, false,
			i_min, i_max, 0,
			coord );

		RGBA_DECLARE( tex );
		if( i_alpha==false )
		{
			tex = i_tex;
			tex_a = 1.0;
		}
		else
		{
			tex_a = i_tex_a;	
			tex = 0;
		}

		mib_bump_map(
			0, 0,
			coord, 
			i_step, i_factor, i_torus_u, i_torus_v,
			i_alpha,
			tex, tex_a, i_clamp,
			o_result );
	}
}
void sib_bumpmap_gen(
	RGBA_DECLARE(i_tex);
	point i_coord;
	point i_basis;
	
	float i_project_basis;

	float unused_project_old, unused_selspace_old;
	matrix unused_tspace_xform_old;
	
	point i_repeats;
	float i_alt_x, i_alt_y, i_alt_z;		
	point i_min, i_max;
	
	point i_step;
	float i_factor;
	float i_torus_u, i_torus_v;
	float i_alpha;
	float i_inuse;

	float i_relnormal;
	point i_normal;	

	float i_clamp;
	float i_eccmax;
	float i_maxminor;
	float i_disc_r;
	float i_bilinear_true;
	float i_bump_filtered;
	float i_bump_basis;

	output point o_result )
{
	if( i_inuse == false )
	{
		extern normal N;
		o_result = point(ntransform("world", N));
	}
	else
	{
		point coord;

		mib_texture_remap(
			i_coord,
			1, i_repeats,
			i_alt_x, i_alt_y, i_alt_z,
			false, false, false,
			i_min, i_max, 0,
			coord );

		RGBA_DECLARE( tex );
		if( i_alpha==false )
		{
			tex = i_tex;
			tex_a = 1.0;
		}
		else
		{
			tex_a = i_tex_a;	
			tex = 0;
		}

		mib_bump_map(
			0, 0,
			coord, 
			i_step, i_factor, i_torus_u, i_torus_v,
			i_alpha,
			tex, tex_a, i_clamp,
			o_result );
	}
}

#endif
