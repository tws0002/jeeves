/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __BA_utils_sl
#define __BA_utils_sl

#define bool float
#define false 0
#define true 1

float BA_bias(float i_a; float i_b)
{
	return i_a >= 0.0 && i_a <= 1.0
			? i_a / ( (1.0/i_b - 2.0) * (1.0-i_a) + 1.0 )
			: clamp(i_a, 0.0, 1.0);
}

#endif
