#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos2;
//varying vec4 vScreenPos4;

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
  return texture2D(sDiffMap,vScreenPos2);
}