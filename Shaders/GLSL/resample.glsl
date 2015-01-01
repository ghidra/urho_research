#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


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
      vec2 s = 1.0/cGBufferInvSize.xy;//ie 1920

      vec2 uv_flr = floor(uv*s);
      vec2 uv_rescl = uv_flr*cGBufferInvSize.xy;
      //vec2 uv_rescl = vec2(uv);

      //vec4 color = texture2D(sEnvMap,vScreenPos.xy / vScreenPos.w);
      vec4 color = texture2D(sEnvMap,uv_rescl,1.0);

      gl_FragColor = color;
}
