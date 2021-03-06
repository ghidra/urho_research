#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"


varying vec4 vScreenPos;


#ifdef COMPILEPS

vec4 get_pixel(in sampler2D tex, in vec2 coords, in float dx, in float dy) {
 return texture2D(tex,coords + vec2(dx, dy));
}

#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPos(gl_Position);

}

void PS(){

      vec4 color = vec4(0.0,0.0,0.0,0.0);

      vec2 uv = vScreenPos.xy / vScreenPos.w;
      vec2 s = 1.0/cGBufferInvSize.xy;//ie 1920
      vec2 uv_scl = uv*s;
      float modx = mod(uv_scl.x,2.0);
      float mody = mod(uv_scl.y,2.0);
      vec2 uv_mod = vec2(uv_scl.x-modx,uv_scl.y-mody);
      vec2 uv_half = uv_mod/2.0;
      vec2 uv_rescl = uv_mod*(cGBufferInvSize.xy*2.0);

      vec2 mult = (uv);

      //vec2 uv_rescl = uv*cGBufferInvSize.xy;

      vec4 dither = texture2D(sDiffMap,vScreenPos.xy / vScreenPos.w);
      //vec4 outline = texture2D(sNormalMap,vScreenPos.xy / vScreenPos.w);
      vec4 outline = texture2D(sNormalMap,mult);

      //if(IsEdge(sEnvMap,vScreenPos.xy / vScreenPos.w, cGBufferInvSize)>1.0){
      //}
      gl_FragColor = dither+outline;
      //gl_FragColor = outline;
}
