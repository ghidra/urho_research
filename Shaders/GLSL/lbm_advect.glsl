//Uncomment IMG define to use the image in channel2 

#define VEL 0.025
//#define IMG

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 u = vec2(fragCoord.xy / iResolution.xy);
    if( iFrame==0) //initialisation
    {
        #ifdef IMG
        	vec3 im = texture2D(iChannel2, u ).xyz;
        	fragColor = vec4(im,1.0);
        #else
        	fragColor = vec4(u,0.0,1.0);
        #endif
    }
    else
    {
        int ix = int(floor(fragCoord.x/2.0));
    	int iy = int(floor(fragCoord.y/2.0));
    	vec2 sam = texture2D(iChannel0, (vec2(2*ix+1,2*iy+1)+0.5)/iResolution.xy).yz;
        float solid = texture2D(iChannel0, (vec2(2*ix+1,2*iy+1)+0.5)/iResolution.xy).x;
        
        //vec2 sam = texture2D(iChannel0, u ).yz;
        
        vec2 dir=(normalize(sam));
        //dir -= vec2(0.5,0.5);
        
        vec3 col = texture2D(iChannel1, u-((dir*length(sam))*VEL) ).xyz;
        if(solid>0.5)
            #ifdef IMG
            	col=texture2D(iChannel2, u ).xyz;
        	#else
                col=vec3(u,0.0);
        	#endif
        fragColor = vec4(col,1.0);
    }
}