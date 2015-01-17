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

#ifndef __sib_integer_to_color_sl
#define __sib_integer_to_color_sl

void sib_integer_to_color(
	float i_input;

	RGBA_DECLARE_OUTPUT( o_result ) )
{
	o_result = cellnoise( i_input );
	o_result_a = 1;
}

#endif

