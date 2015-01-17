/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texture2d_ripple_sl
#define __sib_texture2d_ripple_sl

#define SIB_TEXTURE2D_RIPPLE_PARAMS \
	float i_amplitude; \
	point i_origin; \
	float i_time, i_freq, i_decay; \
	float i_group_vel, i_phase_vel; \
	float i_spread_start, i_spread_rate

#define SIB_TEXTURE2D_RIPPLE_PARAMS_LIST \
	i_amplitude, i_origin, i_time, i_freq, i_decay, \
	i_group_vel, i_phase_vel, \
	i_spread_start, i_spread_rate 

void sib_texture2d_ripple(
	point i_coord;

	SIB_TEXTURE2D_RIPPLE_PARAMS;

	output float o_result;)
{
	float total = 0.0;
	
	if(i_time>0.0 && i_amplitude>0 )
	{
		float dist = HYPOT(xcomp(i_coord) - xcomp(i_origin), ycomp(i_coord) - ycomp(i_origin) );
		float spread = i_spread_start + i_spread_rate * i_time;

		/* see if we are within the spread */
		if( spread>0.0 &&	
			dist > (i_time*i_group_vel)-0.5*spread &&
			dist < (i_time*i_group_vel)+0.5*spread)
		{
			/* calculate envelope. Assume cosine shape */
			total = cos((PI*2.0)/spread *
				  (dist - i_time * i_group_vel)) * 0.5+0.5;

			/* use to modulate individual ripples */
			total *= cos(PI*2.0 * i_freq * (dist - i_time) +
				   PI*2.0 * (dist - i_time * i_phase_vel));
			
			/* amplitude decreases as a result in growth of ripple area. */	
			/* now, adjust amplitude, decreasing linearly with spread
			 * The amplitude given is the one at the initial spread. */		

			total *= i_amplitude * i_spread_start/spread;

			/*
			 * for added reality, decrease linearly with envelope breath, too (i.e. radius of
			 * envelope center. (an approximation, I know.))
			 */
			total /= 1.0+(i_time * i_group_vel);

			/* finally, allow for exponential decay because of water friction */
			total *= exp( -i_decay*i_time);
		}
	}

	o_result = clamp(total + 0.5, 0.0, 1.0);
}

#endif
