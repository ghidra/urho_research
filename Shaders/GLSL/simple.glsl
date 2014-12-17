#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

#if defined(DIFFMAP) || defined(ALPHAMAP)
    varying vec2 vTexCoord;
#endif
#ifdef VERTEXCOLOR
    varying vec4 vColor;
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    #ifdef VERTEXCOLOR
        //vColor = iColor;
        vec3 n = iNormal+vec3(1.0);
        n*=0.5;
        vColor = vec4(n,1.0);
    #endif
}

void PS()
{
    vec4 diffColor = cMatDiffColor;

    #ifdef VERTEXCOLOR
        diffColor *= vColor;
        gl_FragColor = diffColor;
    #endif
}
