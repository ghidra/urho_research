#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

uniform vec4 cObjectColor;
uniform float cObjectBlend;

varying vec4 vColor;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix);
  gl_Position = GetClipPos(worldPos);

  vec3 n = iNormal+vec3(1.0);
  n*=0.5;
  vColor = mix(cObjectColor,vec4(n,1.0),cObjectBlend);
}

void PS()
{

  vec4 diffColor = vColor;
  gl_FragColor = diffColor;

}
