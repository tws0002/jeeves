/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_texture_checkerboard_sl
#define __mib_texture_checkerboard_sl

void mib_texture_checkerboard(
	point i_coord;
	float i_xsize, i_ysize, i_zsize;

	RGBA_COLOR( i_color000 );
	RGBA_COLOR( i_color001 );
	RGBA_COLOR( i_color010 );
	RGBA_COLOR( i_color011 );
	RGBA_COLOR( i_color100 );
	RGBA_COLOR( i_color101 );
	RGBA_COLOR( i_color110 );
	RGBA_COLOR( i_color111 );

	output color o_result;
	output float o_result_a; )
{
	float index = 0;

	if( i_coord[0] > i_xsize )
		index = 4;
	if( i_coord[1] > i_ysize )
		index += 2;	
	if( i_coord[2] > i_zsize )
		index += 1;

	if( index == 0 )
	{
		RGBA_ASSIGN( o_result, i_color000 );
	}
	else if( index == 1 )
	{
		RGBA_ASSIGN( o_result, i_color001 );
	}
	else if( index == 2 )
	{
		RGBA_ASSIGN( o_result, i_color010 );
	}
	else if( index == 3 )
	{
		RGBA_ASSIGN( o_result, i_color011 );
	}
	else if( index == 4 )
	{
		RGBA_ASSIGN( o_result, i_color100 );
	}
	else if( index == 5 )
	{
		RGBA_ASSIGN( o_result, i_color101 );
	}
	else if( index == 6 )
	{
		RGBA_ASSIGN( o_result, i_color110 );
	}
	else
	{
		RGBA_ASSIGN( o_result, i_color111 );
	}
}

/*
	This version is only used when "copy alpha" is enabled.
	It is called from txt3d_checkerboard()
*/
void mib_texture_checkerboard(
	point i_coord;
	float i_xsize, i_ysize, i_zsize;

	float i_color000;
	float i_color001;
	float i_color010;
	float i_color011;
	float i_color100;
	float i_color101;
	float i_color110;
	float i_color111;

	output float o_result; )
{
	float index = 0;

	if( i_coord[0] > i_xsize )
		index = 4;
	if( i_coord[1] > i_ysize )
		index += 2;	
	if( i_coord[2] > i_zsize )
		index += 1;

	if( index == 0 )
	{
		o_result = i_color000;
	}
	else if( index == 1 )
	{
		o_result = i_color001;
	}
	else if( index == 2 )
	{
		o_result = i_color010;
	}
	else if( index == 3 )
	{
		o_result = i_color011;
	}
	else if( index == 4 )
	{
		o_result = i_color100;
	}
	else if( index == 5 )
	{
		o_result = i_color101;
	}
	else if( index == 6 )
	{
		o_result = i_color110;
	}
	else
	{
		o_result = i_color111;
	}
}


#endif
