//in here, I am just gonna grab the stow buffer to get luminance to determine what get velocity, and also give it a random velocity
//i seem to have to do this, otherwise i get weird alpha issues and the like, with every possible combination
#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

#include "functions.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetQuadTexCoord(gl_Position);
    vScreenPos = GetScreenPosPreDiv(gl_Position);
}

void PS()
{
  vec4 diff = texture2D(sDiffMap,vScreenPos);
  float l = bias(lum(diff.xyz),0.3);
  //ok, use that bias a multiplier on the velocity...
  	//IF I WANT TO USE SOME DOT IN HERE
  	vec2 res = 1.0/cGBufferInvSize;
  	float solid = 0.0;
  	for(int i=0; i<78; i++)
	{
		highp float px = rand(vec2(0.23,0.44)*float(i));
    	highp float py = rand(vec2(0.81,0.19)*float(i));
    	if( distance(vec2(px,py)*res,vScreenPos*res) < 5.0 )
    		solid = 1.0;
	}

  gl_FragColor = vec4(l);
}
