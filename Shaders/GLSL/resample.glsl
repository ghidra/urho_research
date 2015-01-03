#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

//#ifdef GL_ES
//#extension GL_OES_standard_derivatives : enable
//precision highp float;
//#endif
//GL_TEXTURE_MIN_FILTER = GL_NEAREST;
//GL_TEXTURE_MAX_FILTER = GL_TEXTURE_MIN_FILTER;


varying vec4 vScreenPos;

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPos(gl_Position);

}

void PS(){

      vec2 uv = vScreenPos.xy / vScreenPos.w;
      vec2 shalf = 1.0/(cGBufferInvSize.xy);//this is actually the size of the render halfsize for example
      vec2 s = shalf*2.0;//ie 1920x1080, this is the fullsize

      vec2 mult=(2.0*(uv*s) + 1.0)/(4.0*shalf);

      //vec2 nuv = uv-(cGBufferInvSize.xy*300.0);


      //vec4 color = texture2D(sEnvMap,vScreenPos.xy / vScreenPos.w);
      vec4 color = texture2D(sEnvMap,mult);

      gl_FragColor = color;
}
