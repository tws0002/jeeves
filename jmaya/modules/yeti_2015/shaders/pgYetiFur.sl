/*
 *  pgYetiFur.sl
 *  pgYeti
 *
 *  Created by colin on Jan 5, 2011.
 *
 * (c) 2010-Present Peregrine Labs a division of Peregrine Visual Storytelling Ltd.
 * All rights reserved.
 *
 * The coded instructions, statements, computer programs, and/or related
 * material (collectively the "Data") in these files contain unpublished
 * information proprietary to Peregrine Visual Storytelling Ltd. ("Peregrine") 
 * and/or its licensors, which is protected by U.S. and Canadian federal 
 * copyright law and by international treaties.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. PEREGRINE
 * DOES NOT MAKE AND HEREBY DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTIES
 * INCLUDING, BUT NOT LIMITED TO, THE WARRANTIES OF NON-INFRINGEMENT,
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, OR ARISING FROM A COURSE 
 * OF DEALING, USAGE, OR TRADE PRACTICE. IN NO EVENT WILL PEREGRINE AND/OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUES, DATA, OR PROFITS, OR SPECIAL,
 * DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES, EVEN IF PEREGRINE AND/OR ITS
 * LICENSORS HAS BEEN ADVISED OF THE POSSIBILITY OR PROBABILITY OF SUCH DAMAGES.
 *
 *
 */

/* Based on shading model presented by Hanson et al. for Stuart Little */
surface pgYetiFur (
	uniform color base_opacity = color(0.78);
	uniform color tip_opacity = color(0.6);
	string opacity_map = "";
	uniform color occlusion_color = color(0.7);
	
	/* textures */
	string base_map = "";
	string tip_map = "";
	uniform float surf_s = 0.0;
	uniform float surf_t = 0.0;
	uniform color surf_n = (0.0,1.0,0.0);			// vectors are treated as colors and should be cast to avoid prman transforming them
	uniform float fur_id = 0.0;
	uniform float flip_surf_s = 0.0;
	uniform float flip_surf_t = 1.0;				// yeti flips t by default
	
	/* diffuse */
        varying color diffuse_color = color(1.0, 1.0, 1.0);
	float Kd = 0.18;
	uniform float do_diffuse_mix = 1.0;
	
	uniform color hsv_adjust = color(0.0,0.0,0.0);
	
	/* fur properties */
	float max_hue_shift = 0.05;
	float max_sat_shift = 0.05;
	float max_val_shift = 0.05;
	float max_map_deviation = 0.03;
	
	/* specular */
	float Ks = 1.0;
	uniform color specular_color = color(1);
	float specular0_level = 0.3;
	float specular1_level = 0.2;
	float specular0_roughness = 0.008;
	float specular1_roughness = 0.15;
	float specular_deviation = 0.0;
	
				  )
{
    float T_Dot_nL = 0;
    float T_Dot_e = 0;
    float Alpha = 0;
    float Beta = 0;
    float kajiya = 0;
        
    vector Ln, b, sLn;
    float ss = surf_s;
    float tt = surf_t;
    
    if ( flip_surf_s == 1.0 )
    {
    	ss = 1.0 - ss;
    }
    
    if ( flip_surf_t == 1.0 )
    {
    	tt = 1.0 - tt;
    }
    
    vector deviation = cellnoise(fur_id, -fur_id) * 2.0 - 1.0;
    ss += xcomp(deviation) * max_map_deviation;
    tt += ycomp(deviation) * max_map_deviation;

    color Cdiff = 0;
    color Cspec = 0;
    
    /* surf_n comes in as a color, so we need to cast it into a vector correctly before using */
    vector sN = normalize(vector "object" (surf_n));
         
    color base_map_value = diffuse_color;
    color tip_map_value = diffuse_color;
    
	if ( base_map != "" )
	{
		base_map_value *= texture( base_map, ss, tt );
		tip_map_value = base_map_value;
	}
	
	if ( tip_map != "" )
	{
		tip_map_value = diffuse_color * texture( tip_map, ss, tt );
	}
	
	color opacity_map_value = ( 1.0,1.0,1.0);
	if ( opacity_map != "" )
	{
		opacity_map_value = texture( opacity_map, ss, tt );
	}
	
	color color_map_value = mix( base_map_value, tip_map_value, v );
	
	color hsv_color_map_value = ctransform( "rgb", "hsv", color_map_value );
	
	hsv_color_map_value += hsv_adjust;
	
	hsv_color_map_value[0]= max( hsv_color_map_value[0] + deviation[0] * max_hue_shift, 0.0 );
	hsv_color_map_value[1]=  max( hsv_color_map_value[1] + deviation[1] * max_sat_shift, 0.0 );
	hsv_color_map_value[2]=  max( hsv_color_map_value[2] + deviation[1] * max_val_shift, 0.0 );
	
	color_map_value = ctransform( "hsv", "rgb", hsv_color_map_value );
	
	vector T = normalize (dPdv); /* tangent along length of hair */
    vector V = -normalize(I);    /* V is the view vector */
    
    float diffuse_mix = 0.0;
    
    if ( do_diffuse_mix == 1 )
    {
    	diffuse_mix = max(T.sN,0.0);
    	diffuse_mix *= diffuse_mix;
    }
    
    float cosang, bDiff, snDiff;
    
    color occlusion = mix( occlusion_color, color( 1.0, 1.0, 1.0 ), v );

    /* Loop over lights, catch highlights as if this was a thin cylinder */
    illuminance (P) {
        Ln = normalize( L );
        
        sLn = Ln + deviation * specular_deviation;
        sLn = normalize( sLn );
    
    	/* specular */
        T_Dot_nL = T.sLn;
        T_Dot_e = T.V;
        Alpha = acos(T_Dot_nL);
        Beta = acos(T_Dot_e);

        kajiya = sin(Alpha) * sin(Beta) - T_Dot_nL * T_Dot_e;
                
		Cspec += Cl * specular0_level * pow(kajiya, 1/specular0_roughness);
		Cspec += Cl * specular1_level * pow(kajiya, 1/specular1_roughness);
		
		/* diffuse */
		b = -normalize(normalize(Ln^T)^T);
		bDiff = max(Ln.b,0.0);
		snDiff = max(Ln.sN,0.0) * PI; 
				
		Cdiff += mix(  bDiff, snDiff, diffuse_mix ) * Cl;
    }
	
	Cdiff *= Cs * Kd * color_map_value * occlusion;
	Cspec *= Ks * specular_color * occlusion;
	Ci = Cdiff + Cspec;
	Oi = Os * mix( base_opacity, tip_opacity, v ) * opacity_map_value;
	
	/* pre-multiply the result */
	Ci *= Oi;
}
