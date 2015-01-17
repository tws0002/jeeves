/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Developers. 2013                              */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

/******************************************************************************
 * = LIBRARY
 *     3delight for Softimage
 * = AUTHOR(S)
 *     Victor Yudin
 * = VERSION
 *     $Revision$
 * = DATE RELEASED
 *     $Date$
 * = RCSID
 *     $Id$
 ******************************************************************************/

#ifndef __3delightudim_h
#define __3delightudim_h

void _3DFS_3DelightUDIM(
		XSI_TEXTURE_DECLARE( i_udimclip );
		string i_filename;
		point i_space;
		output color o_outColor;)
{
	float ss = i_space[0];
	float tt = i_space[1];

	// Invert fractional part and leave integer part
	tt = 2 * floor( tt ) - tt + 1;

	o_outColor = texture( i_udimclip_name, ss, tt );
}

#endif

