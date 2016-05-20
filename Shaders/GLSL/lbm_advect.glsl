//Uncomment IMG define to use the image in channel2 
#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

#define VEL 0.025
//#define IMG

varying vec2 vTexCoord;
varying vec2 vScreenPos2;

#ifdef COMPILEPS
//uniform sampler2D sDetailMap1;
uniform sampler2D sDetailMap1;
#endif

void PS( )// out vec4 fragColor, in vec2 fragCoord
{
	if( cElapsedTimePS<=0.0 ) //initialisation
	{
		#ifdef IMG
			vec3 im = vec3(1.,1.,0.0);//texture2D(sDetailMap2, vScreenPos2 ).xyz;
			gl_FragColor = vec4(im,1.0);
		#else
			gl_FragColor  = vec4(vScreenPos2,0.0,1.0);
		#endif
	}
	else
	{
		vec2 res = 1.0/cGBufferInvSize;
		vec2 pix = vScreenPos2*res;//the pixel coordinate

		int ix = int(floor(pix.x/2.0));
		int iy = int(floor(pix.y/2.0));
		vec2 sam = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).yz;
		float solid = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).x;
		
		//vec2 sam = texture2D(iChannel0, u ).yz;
		
		vec2 dir=(normalize(sam));
		//dir -= vec2(0.5,0.5);
		
		vec3 col = texture2D( sDetailMap1, vScreenPos2-((dir*length(sam))*VEL*cDeltaTimePS) ).xyz;////this is it trying to do the ping pong.... if we need to, which we might
		
		if(solid>0.5)
			#ifdef IMG
				col=vec3(1.,1.,0.0);//texture2D(sDetailMap2, vScreenPos2 ).xyz;
			#else
				col=vec3(vScreenPos2,0.0);
			#endif
		gl_FragColor = vec4(col,1.0);
	}
}