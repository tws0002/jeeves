/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __mib_texture_vector_sl
#define __mib_texture_vector_sl

#define SELECT_INTERSECTION -1
#define SELECT_NORMAL -2
#define SELECT_MOTION -3
#define SELECT_CAMERADIR -4
#define SELECT_dPdU -5
#define SELECT_dPdV -6
#define SELECT_d2PdU2 -7
#define SELECT_d2PdV2 -8
#define SELECT_d2PdUdV -9
#define SELECT_RASTER -10
#define SELECT_TEX -11

#define SELSPACE_INTERNAL 0
#define SELSPACE_OBJECT 1
#define SELSPACE_WORLD 2
#define SELSPACE_CAMERA 3
#define SELSPACE_RASTER 4

#define PROJ_SPATIAL 0
#define PROJ_UV 1
#define PROJ_PLANARXY 2
#define PROJ_PLANARXZ 3
#define PROJ_PLANARYZ 4
#define PROJ_CYL 5
#define PROJ_SPH 6
#define PROJ_LOLLI 7
#define PROJ_CAMERA 8

#define VERTEX_INTERSECTION 0
#define VERTEX_1 1
#define VERTEX_2 2
#define VERTEX_3 3

/*
	NOTE: vertex is ignored, We always evaluate at intersection point.
*/
point mib_CoordLookup( float select, vertex )
{
	extern point P;
	extern normal N;
	extern vector dPdtime, dPdu, dPdv, I;
	extern float u, v, s, t, du, dv;

	point result;

	if( select == SELECT_INTERSECTION )
		result = P;
	else if( select == SELECT_NORMAL )
		result = point(N);
	else if( select == SELECT_MOTION )
		result = point(dPdtime); /* FIXME: check this */
	else if( select == SELECT_CAMERADIR )
		result = point(I); /* FIXME: check this */
	else if( select == SELECT_dPdU )
		result = point(dPdu);
	else if( select == SELECT_dPdV )
		result = point(dPdv);
	else if( select == SELECT_d2PdU2 ) 
		result = point( Deriv(dPdu, u) * du );
	else if( select == SELECT_d2PdV2 )
		result = point( Deriv(dPdv, v)  * dv);
	else if( select == SELECT_d2PdUdV )
		result = point( Deriv(dPdu, v) * dv ); 
	else if( select == SELECT_RASTER )
		result = transform( "raster", P );
	else if( select == SELECT_TEX )
		result = point( s, t, 0 ); 
	else
		result = P;

	return result;
}

/*
	NOTE: the case for select==SELECT_NORMAL is not correct in XSI!
*/
point mib_SpaceConversion(
	point pnt;
	float select, selspace; )
{
	point result;

	if( selspace==SELSPACE_INTERNAL )
	{
		result = transform( "world", pnt );
	}
	else if (select == SELECT_INTERSECTION)
	{
		if( selspace == SELSPACE_OBJECT )
			result = transform( "object", pnt );
		else if( selspace == SELSPACE_WORLD ) 
			result = transform( "world", pnt );
		else if( selspace == SELSPACE_CAMERA )
			result = transform( "camera", pnt );
		else if( selspace == SELSPACE_RASTER )
		{
			result = transform( "NDC", pnt );
			result[1] = 1-result[1];
		}
		else
			result = pnt;
	}
	else
	{
		if( selspace == SELSPACE_OBJECT )
			result = point( vtransform("object", vector( pnt )) );
		else if( selspace == SELSPACE_WORLD ) 
			result = point( vtransform("world", vector(pnt)) );
		else if( selspace == SELSPACE_CAMERA )
			result = point( vtransform("camera", vector(pnt)) );
		else
			result = pnt;
	}

	return result;
}

/*
	NOTE: check for correct Z (should it be -z or z?)
*/
point mib_ImplicitProjection( point pnt; float project )
{
	point result;

	/* Do projection */
	if( project == PROJ_SPATIAL )
		result = pnt; 
	else if( project == PROJ_PLANARXY )
		result = point( xcomp(pnt), ycomp(pnt), 0 ); 
	else if( project == PROJ_PLANARXZ )
		result = point( pnt[0], -pnt[2], 0 ); 
	else if( project == PROJ_PLANARYZ )
		result = point( pnt[1], -pnt[2], 0 ); 
	else if( project == PROJ_CYL )
	{
		float x;
		float y = ycomp(pnt);
		if( abs(zcomp(pnt)) >= 1e-6 || abs(xcomp(pnt)) >= 1e-6 )
			x  = (atan( xcomp(pnt), zcomp(pnt)) / (2 * PI) + 0.5);
		else
			x = 0;
		result = point(x, y, 0 );
	}
	else if( project == PROJ_SPH )
	{
		vector newp = normalize( vector(pnt) );
		float y = acos( -ycomp(newp) ) / PI;
		float x;
		if( abs(zcomp(newp)) >= 1e-6 || abs(xcomp(newp)) >= 1e-6 )
			x  = atan( xcomp(newp), zcomp(newp) ) / ( 2 * PI );
		else
			x = 0;
		result = point(x, y, 0 );
	}
	else if( project == PROJ_LOLLI )
	{
		vector newp = normalize( vector(pnt) );

		float dist = 0.5*(0.5 - asin(ycomp(newp)) / PI);
		float hyp = HYPOT(xcomp(newp), zcomp(newp) );

		if( abs(hyp) >= 1e-6 ) 
		{
			result = point(
					0.5 + dist * zcomp(newp)/hyp,
					0.5 - dist * xcomp(newp)/hyp, 
					0 );
		}
		else
		{
			if( ycomp(newp) < 0 )
				result = point( 0.5, 0, 0 );
			else
				result = point( 0.5, 0.5, 0 );
		}
	}
	else if( project == PROJ_CAMERA )
		result = point( xcomp(pnt)/2 + 0.5, ycomp(pnt)/2 + 0.5, zcomp(pnt) );
	else
		result = pnt;

	return result;
}

/*
	IMPLICIT version.
*/
void mib_texture_vector(
	float i_selection, i_selspace, i_vertex, i_project;
	output point o_result )
{
	extern float u, v;

	if( i_project == PROJ_UV )
		o_result = point( u, v, 0 );
	else
	{
		o_result = mib_CoordLookup( i_selection, i_vertex );
		o_result = mib_SpaceConversion( o_result, i_selection, i_selspace );
		o_result = mib_ImplicitProjection( o_result, i_project );
	}
}

/*
	EXPLICIT version.
*/
void mib_texture_vector(
	point i_selection;
	float i_selspace, i_vertex, i_project;
	output point o_result;)
{
	o_result = mib_SpaceConversion(
		i_selection, SELECT_INTERSECTION, i_selspace );
	o_result = mib_ImplicitProjection( o_result, i_project );
}
#endif
