#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"

varying vec2 vTexCoord;

uniform vec2 cSheet;
uniform float cRate;

void VS()
{
  mat4 modelMatrix = iModelMatrix;
  vec3 worldPos = GetWorldPos(modelMatrix);
  gl_Position = GetClipPos(worldPos);

  vec4 projWorldPos = vec4(worldPos, 1.0);

  //time
  float frames = cSheet.x*cSheet.y;
  float frame = mod(floor(cElapsedTime*cRate),frames);
  float xoff = mod(frame,cSheet.x)*(1/cSheet.x);
  float yoff = floor(frame/cSheet.y)*(1/cSheet.y);

  vTexCoord = GetTexCoord(iTexCoord)*(1.0/cSheet)+vec2(xoff,yoff);
}

void PS()
{
  gl_FragColor = texture2D(sDiffMap, vTexCoord.xy);
}