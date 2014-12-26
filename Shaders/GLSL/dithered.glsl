#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

uniform vec4 cObjectColor;

#ifdef BASE
    varying vec4 vColor;
#endif

#ifdef EDGE
  varying vec2 vTexCoord;
  varying vec4 vScreenPos;
#endif

#ifdef COMPILEPS
float find_closest(int x, int y, float c0){

  int dither[64] = int[64](
    0, 32, 8, 40, 2, 34, 10, 42,
  48, 16, 56, 24, 50, 18, 58, 26,
  12, 44, 4, 36, 14, 46, 6, 38,
  60, 28, 52, 20, 62, 30, 54, 22,
   3, 35, 11, 43, 1, 33, 9, 41,
  51, 19, 59, 27, 49, 17, 57, 25,
  15, 47, 7, 39, 13, 45, 5, 37,
  63, 31, 55, 23, 61, 29, 53, 21);

  float limit = 0.0;
  if(x < 8){
    limit = ( float(dither[(x*8)+y]+1) )/64.0;
  }


  //if(c0 < limit){
  //  return 0.0;
  //}else{
  //  return 1.0;
  //}
  return 1.0;
}
#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    #ifdef BASE
        //vColor = iColor;
        vec3 n = iNormal+vec3(1.0);
        n*=0.5;
        vColor = mix(cObjectColor,vec4(n,1.0),0.1);
    #endif

    #ifdef EDGE
      vScreenPos = GetScreenPos(gl_Position);
      vTexCoord = GetTexCoord(iTexCoord);
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
      //vec4 lum = vec4(0.299, 0.587, 0.114, 0);
      //float grayscale = dot(texture2D(sEnvMap, vTexCoord), lum);
      //vec3 rgb = texture2D(sEnvMap, vTexCoord).rgb;

      //vec2 xy = vScreenPos.xy / vScreenPos.w;
      //int x = int(mod(xy.x, 8));
      //int y = int(mod(xy.y, 8));

      //vec3 finalRGB;
      //finalRGB.r = find_closest(x, y, rgb.r);
      //finalRGB.g = find_closest(x, y, rgb.g);
      //finalRGB.b = find_closest(x, y, rgb.b);

      //float final = find_closest(x, y, grayscale);
      //gl_FragColor = vec4(finalRGB, 1.0);
      gl_FragColor = vec4(0.299, 0.587, 0.114, 0);
    #endif
}
