#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

uniform mat4 cPalette;
uniform vec4 cLuma;

varying vec2 vTexCoord;
varying vec4 vScreenPos;

#ifdef COMPILEPS

//0, 32, 8, 40, 2, 34, 10, 42,
//48, 16, 56, 24, 50, 18, 58, 26,
//12, 44, 4, 36, 14, 46, 6, 38,
//60, 28, 52, 20, 62, 30, 54, 22,
// 3, 35, 11, 43, 1, 33, 9, 41,
//51, 19, 59, 27, 49, 17, 57, 25,
//15, 47, 7, 39, 13, 45, 5, 37,
//63, 31, 55, 23, 61, 29, 53, 21

const vec4 ma = vec4(0.0,12.0,3.0,15.0);
const vec4 mb = vec4(8.0,4.0,11.0,7.0);
const vec4 mc = vec4(2.0,14.0,1.0,13.0);
const vec4 md = vec4(10.0,6.0,9.0,5.0);
const mat4 dm = mat4(ma,mb,mc,md);


float find_closest(int x, int y, float c0){

  float limit = 0.0;
  limit = ( dm[x][y] + 1.0 )/16.0;

  if(c0 < limit)
    return 0.0;
  return 1.0;
}

float compare(vec3 c1, vec3 c2){
  vec3 lum = vec3(0.299, 0.587, 0.114);
  vec3 l1 = c1*lum;
  vec3 l2 = c2*lum;
  float l1f = l1.x+l1.y+l1.z;
  float l2f = l2.x+l2.y+l2.z;
  float ldiff = l1f-l2f;
  ldiff*=ldiff;
  vec3 diffr = c1-c2;
  diffr*=lum;
  float diffrf = diffr.x+diffr.y+diffr.z;
  return diffrf*0.75+ldiff;
}

vec3 mix(vec3 color, int mat){
  float x = 0.09/255.0;
  vec3 e = vec3(0.0);
  vec3 result[16];
  for(int c=0; c<16; c++){
    // Current temporary value
    vec3 t = vec3( color.r + e.x * x, color.g + e.y * x, color.b + e.z * x );
    // Clamp it in the allowed RGB range
    if(t.x<0.0) t.x=0.0; else if(t.x>1.0) t.x=1.0;
    if(t.y<0.0) t.y=0.0; else if(t.y>1.0) t.y=1.0;
    if(t.z<0.0) t.z=0.0; else if(t.z>1.0) t.z=1.0;
    // Find the closest color from the palette
    float least_penalty = 7833.0;//1e99
    int chosen = int(mod(c,4));
    for(int index=0; index<4; index++){
        vec4 pc = cPalette[index];
        float penalty = compare(pc.xyz,t);
        if(penalty < least_penalty){
          least_penalty = penalty;
          chosen=index;
        }
    }
    vec4 cc = cPalette[chosen];
    result[c] = cc.xyz;
    vec4 pc2 = cc;
    e = e+(color.xyz-pc2.xyz);
  }
  return result[mat];
}

#endif

void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPos(gl_Position);
    vTexCoord = GetTexCoord(iTexCoord);
}

void PS(){

    //dither_array();
    vec2 screenuv = vScreenPos.xy / vScreenPos.w;

    vec4 lum = vec4(0.299, 0.587, 0.114, 0);
    //vec4 lum = vec4(0.15, 0.15, 0.15, 0);
    //vec4 lum = vec4(0.1, 0.2, 0.15, 0);

    float grayscale = dot(texture2D(sEnvMap, screenuv), lum);
    vec3 rgb = texture2D(sEnvMap, screenuv).rgb;


    vec2 xy = (vScreenPos.xy / vScreenPos.w)*(1.0/cGBufferInvSize);
    //int x = int(mod(xy.x, 8));
    //int y = int(mod(xy.y, 8));
    int x = int(mod(xy.x, 4));
    int y = int(mod(xy.y, 4));

    float map_value = ( dm[x][y] + 1.0 )/16.0;
    vec3 resulting_color = mix(rgb,int(map_value));

    vec3 finalRGB;
    finalRGB.r = find_closest(x, y, rgb.r);
    finalRGB.g = find_closest(x, y, rgb.g);
    finalRGB.b = find_closest(x, y, rgb.b);

    float final = find_closest(x, y, grayscale);
    //gl_FragColor = vec4(final,final,final,1.0);
    gl_FragColor = vec4(resulting_color, 1.0);
}
