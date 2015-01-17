/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __implicit_texture_sl
#define __implicit_texture_sl

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

#define PROJTYPE_PLANAR 0
#define PROJTYPE_CYL 1
#define PROJTYPE_SPH 2
#define PROJTYPE_LOLLI 3

#define PROJPLANE_PLANARXY 0
#define PROJPLANE_PLANARXZ 1
#define PROJPLANE_PLANARYZ 2

point CoordLookup( float select )
{
	extern point P;
	extern normal N;
	extern vector dPdtime, dPdu, dPdv, I;
	extern float u, v, s, t, du, dv;

	point result;

	if( select == SELECT_INTERSECTION )
		result = transform( "world", P );
	else if( select == SELECT_NORMAL )
		result = point( normalize(ntransform("world", N)) );
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
		result = transform( "world", P );

	return result;
}

/*
	NOTE: the case for select==SELECT_NORMAL is not correct in XSI!
*/
point SpaceConversion(
	point pnt;
	float project, projplane, select, selspace; )
{
	point plane_project(
		point i_point; float i_projplane )
	{
		extern float projplane;
		point result = i_point;
		if( i_projplane == PROJPLANE_PLANARXZ )
			result = point( result[0], -result[2], result[1] );
		else if( projplane == PROJPLANE_PLANARYZ )
			result = point( -result[2], result[1], result[0] );
		return result;
	}

	point result;

	if (select == SELECT_INTERSECTION)
	{
		if( selspace == SELSPACE_OBJECT )
		{
			result = transform( "world", "object", pnt );
			result = plane_project( result, projplane );

			uniform point bbox_center;
			uniform vector bbox_size;
			if( attribute( "user:bbox_size", bbox_size) !=0 &&
				attribute("user:bbox_center", bbox_center) != 0 )
			{ 
				if( project == PROJTYPE_PLANAR )
				{
					result -= vector bbox_center;
					result /= bbox_size;
					result += 0.5;
				}
				else if( project == PROJTYPE_CYL )
				{
					/* Normalize Y component */
					result[1] -= bbox_center[1];
					result[1] /= bbox_size[1];
					result[1] += 0.5;
				}
			}
		}
		else if( selspace == SELSPACE_WORLD )
			result = transform( "world", "world", pnt );
		else if( selspace == SELSPACE_CAMERA )
			result = transform( "world", "camera", pnt );
		else if( selspace == SELSPACE_RASTER )
			result = transform( "NDC", pnt );
		else if( selspace == SELSPACE_INTERNAL )
		{
			result = pnt; 
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
	
	result[2] = 0;

	return result;
}

/*
	NOTE: check for correct Z (should it be -z or z?)
*/
point ImplicitProjection( point pnt; float project )
{
	point result;

	/* Do projection */
	if( project == PROJTYPE_PLANAR )
	{
		result = pnt; 
	}
	else if( project == PROJTYPE_CYL )
	{
		float x;
		if( abs(pnt[0]) >= 1e-6 || abs(pnt[2]) >= 1e-6 )
			x  = atan( pnt[0], pnt[2]) / (2 * PI) + 0.5;
		else
			x = 0;

		if( x < 0) 
			x += 1.0 ;

		result = point(x, pnt[1], 0 );
	}
	else if( project == PROJTYPE_SPH )
	{
		float x, y;
		float length = length(vector(pnt));

		if( abs(pnt[2])>=1e-6 || abs(pnt[0])>=1e-6 )
			x  = atan( pnt[0], pnt[2] ) / ( 2 * PI ) + 0.5;
		else
			x = 0;

		if( x < 0) 
			x += 1.0 ;

		if( length != 0.0 )
			y = asin(pnt[1] / length) / PI + 0.5;
		else
			y = 0.5;

		result = point(x, y, 0 );
	}
	else if( project == PROJTYPE_LOLLI )
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
	else
		result = pnt;

	return result;
}

void implicit_texture(
	float i_selection, i_selspace, i_projtype, i_projplane;
	output point o_result )
{
	o_result = CoordLookup( i_selection );
	o_result = SpaceConversion(
			o_result, i_projtype, i_projplane, i_selection, i_selspace );
	o_result = ImplicitProjection( o_result, i_projtype );

}

#endif
