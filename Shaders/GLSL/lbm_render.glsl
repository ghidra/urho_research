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
	vec4 lbm_color =  texture2D(sDetailMap1,vScreenPos2);

	vec2 res = 1.0/cGBufferInvSize;
	vec2 pix = vScreenPos2*res;//the pixel coordinate
	//only one pixel out of 4 stores the moments
    	int ix = int(floor(pix.x/2.0));
	int iy = int(floor(pix.y/2.0));
	vec3 m = texture2D(sDiffMap1, (vec2(2*ix+1,2*iy+1)+0.5)/res).xyz;

	//gl_FragColor = vec4(lbm_color.xyz*2.0,lbm_color.a);
	//gl_FragColor = vec4(lbm_color);
	gl_FragColor = vec4(m*5.0,1.0);
	//gl_FragColor = vec4(stow_color,1.0);
}