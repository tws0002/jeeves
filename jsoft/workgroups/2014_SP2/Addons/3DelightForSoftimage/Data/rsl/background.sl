/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Team.                                         */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

/*
	IsEnvironment

	returns 1.0 if the given texture is an environment texture.

	NOTES
	- Environment textures are made using tdlmake with any of the following
	  options: -envlatl -envcube, -twofish and -lightprobe.
*/
float IsEnvironment( uniform string tex )
{
	string texture_type = "";
	
	textureinfo( tex, "type", texture_type );
	
	uniform float is_env = 0.0;

	return texture_type == "environment" ? 1.0 : 0.0;
}

/*
	We have both 'bgcolor' and 'background' as background colors since some
	older background imager shaders used 'background'.
*/
imager
background(
	color bgcolor = 1, background = 1;
	color bgcoloroffset = 0;
	float bgintensity = 1;
	string bgtexture = "";
	string bgspace = "world";
	float solidalpha = 1;)
{
	color texture_color;

	if( bgtexture == "" )
	{
		texture_color = 1;
	}
	else if( IsEnvironment(bgtexture) == 1.0 )
	{
		/* Find out the coordinates, in camera space, of the current pixel. To
		   do so, we first tranform from NDC (wich is defined in the [0..1] x
		   [0..1] square) to screen space. This gives us the 'x' & 'y'
		   coordinates in camera space. The 'z' coordinate is actually the
		   distance of the screen space to the camera center and we need the
		   FOV to find out this value (D = 1/tan(fov * 0.5)). With the camera
		   space coordinate of the pixel in hand, we can easily compute a world
		   space vector that can then be used in the environment() function.
		   Please refer to The RenderMan Companion p.168 for a visualization of
		   this operation.

		   NOTE: (u, v) coordinates in an imager shader are defined in the
		   [0..1]x[0..1] square, which is our starting NDC coordinate system. */

		point screen_space = transform( "NDC", "screen", point(u, v, 0) );

		/* Compute distance from camera EYE to screen as explained above.
		   We need the field of view of the render for that. */
		uniform float fov = 70;
		option( "FieldOfView", fov );
		float D = 1.0 / tan( radians(fov) * 0.5 );

		/* Make our world vector using the (x, y) coordinates on the screen
		   plane and 'D'. */

		vector world_vector = vtransform( bgspace,
			vector(xcomp(screen_space), ycomp(screen_space), D) );

	    texture_color = environment( bgtexture, world_vector );
	}
	else
		texture_color = texture( bgtexture, u, v );

	Ci += ( 1-alpha ) * bgintensity * (bgcolor * background * texture_color + bgcoloroffset );

	if( solidalpha == 1 )
	{
		Oi = 1;
		alpha = 1;
	}
}
