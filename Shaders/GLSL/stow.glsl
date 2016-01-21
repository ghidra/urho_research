//literally use this to stow the render to a quad for use later
//i seem to have to do this, otherwise i get weird alpha issues and the like, with every possible combination
#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

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
  gl_FragColor = diff;
}
