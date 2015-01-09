#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

#ifdef BASE
    varying vec4 vColor;
#endif
#ifdef EDGE
    varying vec4 vScreenPos;
#endif


void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    #ifdef EDGE
      vScreenPos = GetScreenPos(gl_Position);
    #endif

    #ifdef BASE
        //vColor = iColor;
        vColor = vec4(iNormal,1.0);
    #endif
}

void PS()
{


    #ifdef BASE
        //vec4 diffColor = cMatDiffColor;
        vec4 diffColor = vColor;
        gl_FragColor = diffColor;
    #endif

    #ifdef EDGE
      vec4 color = vec4(0.0,0.0,0.0,0.0);
      if(IsEdge(sEnvMap,vScreenPos.xy / vScreenPos.w, cGBufferInvSize)>1.0){
        color.rgba = vec4(1.0);
        //color = get_pixel(sEnvMap,vScreenPos.xy / vScreenPos.w,float(0)*(cGBufferInvSize.x),float(0)*(cGBufferInvSize.y));
        //color.rgba = diffColor;
        //color.g = IsEdge(sEnvMap,vScreenPos.xy / vScreenPos.w);
        //color.a = 1.0;
      }
      gl_FragColor = color;
    #endif
}
