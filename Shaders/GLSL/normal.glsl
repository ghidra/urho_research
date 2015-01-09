#include "Uniforms.glsl"
#include "Transform.glsl"

varying vec4 vColor;

void VS(){
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vec3 n = GetWorldNormal(iModelMatrix)+vec3(1.0);
    n*=0.5;
    vColor = vec4(n,GetDepth(gl_Position));
}

void PS(){
    vec4 diffColor = vColor;
    gl_FragColor = diffColor;
}
