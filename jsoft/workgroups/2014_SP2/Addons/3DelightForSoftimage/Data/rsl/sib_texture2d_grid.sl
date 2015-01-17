/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texture2d_grid_sl
#define __sib_texture2d_grid_sl

#define SIB_TEXTURE2D_GRID_PARAMS \
	RGBA_COLOR( i_line_col ); \
	RGBA_COLOR( i_fill_col ); \
	float i_uwidth, i_vwidth, i_contrast, i_diffusion 

#define SIB_TEXTURE2D_GRID_PARAMS_LIST \
	RGBA_COLOR_PARAM(i_line_col), RGBA_COLOR_PARAM(i_fill_col), \
	i_uwidth, i_vwidth, i_contrast, i_diffusion

#define SIB_TEXTURE2D_GRID_PARAMS_LIST_COPYALPHA \
	i_line_col_a*i_alpha_factor, i_line_col_a, i_fill_col_a*i_alpha_factor, i_fill_col_a, \
	i_uwidth, i_vwidth, i_contrast, i_diffusion

/* This texture paints a grid of two colours.  They can be contrasted with the
   contrast parameter. The diffuse parameter controls how far the grid smears
   into the surroundings.  */

void sib_texture2d_grid( 
	point i_coord;
	SIB_TEXTURE2D_GRID_PARAMS;
	output color o_result;
	output float o_result_a; )
{
	float uw = i_uwidth * 0.5;
	float vw = i_vwidth * 0.5;
	
	float _u = SLICE( i_coord[0] );
	float _v = SLICE( i_coord[1] );
	
	/* mirror about 0.5 */
	_u = _u>0.5? 1.0-_u : _u;
	_v = _v>0.5? 1.0-_v : _v;

	float f1 = uw<1e-6 ? 1 : filterstep( uw, _u );
	float f2 = vw<1e-6 ? 1 : filterstep( vw, _v );

	RGBA_COLOR( result );

	/* Non ant-aliased code is in comment. Remove the last RGB_MIX below
	   and the commented lines to switch to the non-antialiased version */
	//if( _u>uw && _v>vw )
	{
		RGBA_CONTRAST(result, i_fill_col, i_line_col, i_contrast );

		if( i_diffusion != 0 )
		{
			RGBA_COLOR( tmp );
			RGBA_CONTRAST(tmp, i_line_col, i_fill_col, i_contrast);
			RGBA_MIX(result, result, tmp, exp(-((_u-uw)*(_v-vw)*4.0)/i_diffusion));
		}
	}
	//else
	{
		RGBA_CONTRAST( o_result, i_line_col, i_fill_col, i_contrast );
	}

	RGBA_MIX( o_result, o_result, result, f1*f2 );
}

#endif
