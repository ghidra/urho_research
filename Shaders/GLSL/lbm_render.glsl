#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos2;
//varying vec4 vScreenPos4;

uniform sampler2D sDetailMap1;

void VS()
{
	mat4 modelMatrix = iModelMatrix;
	vec3 worldPos = GetWorldPos(modelMatrix);
	gl_Position = GetClipPos(worldPos);
	vTexCoord = GetQuadTexCoord(gl_Position);
	vScreenPos2 = GetScreenPosPreDiv(gl_Position);
 	// vScreenPos4 = GetScreenPos(gl_Position);
}

void PS()
{
	vec4 stow_color =  texture2D(sDiffMap,vScreenPos2);
	vec4 lbm_color =  texture2D(sDetailMap1,vTexCoord);

	vec2 res = 1.0/cGBufferInvSize;
	vec2 pix = vScreenPos2*res;//the pixel coordinate
	vec2 pix2 = vTexCoord*res;//the pixel coordinate
	//only one pixel out of 4 stores the moments
    	int ix = int(floor(pix2.x/2.0));
	int iy = int(floor(pix2.y/2.0));
	vec3 m = texture2D(sDetailMap1, (vec2(2*ix+1,2*iy+1)+0.5)/res).xyz;

	//
	vec2 center = res/2.0;
	vec2 dir = normalize(pix2-center);

	//gl_FragColor = vec4(lbm_color.xyz*2.0,lbm_color.a);
	gl_FragColor = vec4(lbm_color);
	//gl_FragColor = vec4(m*1.0,1.0);
	//gl_FragColor = vec4(0.0,dir,1.0);
	//gl_FragColor = vec4(stow_color,1.0);
}