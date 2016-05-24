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
  vec2 res = 1.0/cGBufferInvSize;

  //vec2 half = res-1.0;//make it so we land in the middle of a pixel
  //vec2 pix = (vScreenPos2*half)+0.5;//fragcoord at half pixel...this seems to be crap
  //vec2 hpix = pix*(1.0/half);//normalized

	//vec4 stow_color =  texture2D(sDiffMap,hpix);
	vec4 lbm_color =  texture2D(sDetailMap1,vTexCoord);

	//only one pixel out of 4 stores the moments
  int ix = int(floor(gl_FragCoord.x/2.0));
	int iy = int(floor(gl_FragCoord.y/2.0));
	vec3 m = texture2D(sDetailMap1, (vec2(2*ix+1,2*iy+1)+0.5)/res).xyz;
  //vec3 m = texture2D(sDetailMap1, (vec2(2*ix-0,2*iy-0)+0.5)/res).xyz;//RED
  //vec3 m = texture2D(sDetailMap1, (vec2(2*ix-1,2*iy-0)+0.5)/res).xyz;//GREEN
  //vec3 m = texture2D(sDetailMap1, (vec2(2*ix-0,2*iy-1)+0.5)/res).xyz;//BLUE
  //vec3 m = texture2D(sDetailMap1, vTexCoord).xyz;

	//
	//vec2 center = res/2.0;
	//vec2 dir = normalize(pix-center);

	//gl_FragColor = vec4(lbm_color.xyz*2.0,lbm_color.a);
	//gl_FragColor = vec4(lbm_color);
	gl_FragColor = vec4(m*10.0,1.0);
  //gl_FragColor = vec4(res-vec2(1279.5,799.5),0.0,1.0);
	//gl_FragColor = vec4(0.0,dir,1.0);
	//gl_FragColor = vec4(stow_color,1.0);
  //gl_FragColor = vec4(pix*(1.0/half),0.0,1.0);
  //if( mod(int(floor(pix.x)), 2) == 0)
  //{
  //  gl_FragColor = vec4(1.0);
  //}
  //else
  //{
  //  gl_FragColor = vec4(vec3(0.0),1.0);
  //}
}