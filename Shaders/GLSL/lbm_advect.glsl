//Uncomment IMG define to use the image in channel2 
#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

#define VEL 0.4
#define FADE 0.4
//#define IMG

varying vec2 vTexCoord;
varying vec2 vScreenPos2;

#ifdef COMPILEPS
//uniform sampler2D sDetailMap1;
uniform sampler2D sDetailMap1;
uniform sampler2D sDetailMap2;
uniform sampler2D sDetailMap3;
#endif

void PS( )// out vec4 fragColor, in vec2 fragCoord
{
	vec2 res = 1.0/cGBufferInvSize;

	if( cElapsedTimePS<0.2 )// && firstpass>0
	{
        #ifdef LEGACY
			gl_FragColor = vec4(vTexCoord,0.0,1.0);
		#endif	
		
		gl_FragColor = vec4(vec3(texture2D( sDetailMap3, vTexCoord).xyz),0.0);

	}
	else
	{
		int ix = int(floor(gl_FragCoord.x/2.0));
		int iy = int(floor(gl_FragCoord.y/2.0));
		vec2 sam = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).yz;
		float solid = texture2D(sDiffMap, (vec2(2*ix+1,2*iy+1)+0.5)/res).x;
		vec2 dir=(normalize(sam));
		vec2 sample_pos = vTexCoord+(sam*cDeltaTimePS*VEL);
		
		vec4 adv = texture2D( sDetailMap1, sample_pos);//get the advection render itself
		vec4 mat = texture2D( sDetailMap2, sample_pos);//the rendered view port, whoms blue chanel is useful
		vec4 stw = texture2D( sDetailMap3, sample_pos);//this is the render before any of this process began

		#ifdef LEGACY
			if(solid>0.5)
			{
				col=vec3(vTexCoord,0.0);
			}
		#endif

		float a = clamp( mat.b+(adv.a-(FADE*cDeltaTimePS)),0.0,1.0);//the alpha is addative of the incoming matte, and the advected matte
		gl_FragColor = vec4(mix(adv.xyz,stw.xyz,mat.b),a);
	}

}