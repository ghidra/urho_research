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
uniform sampler2D sDetailMap2;
#endif

void PS( )// out vec4 fragColor, in vec2 fragCoord
{
	vec2 res = 1.0/cGBufferInvSize;
	
	int firstpass=0;
	#ifdef FIRSTPASS
	firstpass=1;
	#endif

	if( cElapsedTimePS<=0.0 && firstpass>0 )
	{
		gl_FragColor  = vec4(vTexCoord,0.0,1.0);
	}
	else
	{
		int ix = int(floor(gl_FragCoord.x/2.0));
		int iy = int(floor(gl_FragCoord.y/2.0));
		vec2 sam = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).yz;
		float solid = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).x;
		
		//vec2 sam = texture2D(iChannel0, u ).yz;
		
		vec2 dir=(normalize(sam));
		//dir -= vec2(0.5,0.5);
		
		vec3 col = texture2D( sDetailMap1, vTexCoord-(dir*length(sam)*VEL*cDeltaTimePS) ).xyz;////this is it trying to do the ping pong.... if we need to, which we might
		//vec3 col = vec3(vTexCoord-((dir*length(sam)*VEL*cDeltaTimePS)),0.0);////this is it trying to do the ping pong.... if we need to, which we might
		//vec3 col = texture2D(sDetailMap2,vTexCoord-((dir*length(sam)))).xyz;////this is it trying to do the ping pong.... if we need to, which we might
		if(solid>0.5)
		{
			//#ifdef IMG
			//col=vec3(1.,1.,0.0);//texture2D(sDetailMap2, vScreenPos2 ).xyz;
			//#else
			//col=vec3(vScreenPos2,0.0);
			//#endif
			col=texture2D(sDetailMap1, vTexCoord ).xyz;
			//col=vec3(vTexCoord,0.0);
		}
		//float cc = length(sam);
		//gl_FragColor=vec4(vec3(cc),1.0);
		gl_FragColor = vec4(col,1.0);
	}
	//gl_FragColor  = vec4(vTexCoord,0.0,1.0);
	//gl_FragColor = vec4(abs(sam),0.0,1.0);
}