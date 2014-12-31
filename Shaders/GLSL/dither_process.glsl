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

      vec4 dither = texture2D(sDiffMap,vScreenPos.xy / vScreenPos.w);
      vec4 outline = texture2D(sNormalMap,vScreenPos.xy / vScreenPos.w);

      //if(IsEdge(sEnvMap,vScreenPos.xy / vScreenPos.w, cGBufferInvSize)>1.0){
      //}
      gl_FragColor = dither+outline;
}
