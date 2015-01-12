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



//0, 32, 8, 40, 2, 34, 10, 42,      0 +32 -24 +32 -38 +32 -24 +32
//48, 16, 56, 24, 50, 18, 58, 26,  +6 -32 +40 -32 +26 -32 +40 -32
//12, 44, 4, 36, 14, 46, 6, 38,   -24 +32 -40 +32 -22 +32 -40 +32
//60, 28, 52, 20, 62, 30, 54, 22, +22 -32 +24 -32 +42 -32 +24 -32
// 3, 35, 11, 43, 1, 33, 9, 41,   -19 +32 -24 +32 -42 +32 -24 +32
//51, 19, 59, 27, 49, 17, 57, 25, +10 -32 +40 -32 +22 -32 +40 -32
//15, 47, 7, 39, 13, 45, 5, 37,   -10 +32 -40 +32 -26 +32 -40 +32
//63, 31, 55, 23, 61, 29, 53, 21  -26 -32 +24 -32 +38 -32 +24 -32


//int d[64];

const vec4 ma = vec4(0.0,12.0,3.0,15.0);
const vec4 mb = vec4(8.0,4.0,11.0,7.0);
const vec4 mc = vec4(2.0,14.0,1.0,13.0);
const vec4 md = vec4(10.0,6.0,9.0,5.0);
const mat4 dm = mat4(ma,mb,mc,md);

//void dither_array(){
//  d[0]=0;d[1]=32;d[2]=8;d[3]=40;d[4]=2;d[5]=34;d[6]=10;d[7]=42;
//  d[8]=48;d[9]=16;d[10]=56;d[11]=24;d[12]=50;d[13]=18;d[14]=58;d[15]=26;
//  d[16]=12;d[17]=44;d[18]=4;d[19]=36;d[20]=14;d[21]=46;d[22]=6;d[23]=38;
//  d[24]=60;d[25]=28;d[26]=52;d[27]=20;d[28]=62;d[29]=30;d[30]=54;d[31]=22;
//  d[32]=3;d[33]=35;d[34]=11;d[35]=43;d[36]=1;d[37]=33;d[38]=9;d[39]=41;
//  d[40]=51;d[41]=19;d[42]=59;d[43]=27;d[44]=49;d[45]=17;d[46]=57;d[47]=25;
//  d[48]=15;d[49]=47;d[50]=7;d[51]=39;d[52]=13;d[53]=45;d[54]=5;d[55]=37;
//  d[56]=63;d[57]=31;d[58]=55;d[59]=23;d[60]=61;d[61]=29;d[62]=53;d[63]=21;
//}

float find_closest(int x, int y, float c0){

  float limit = 0.0;
  //if(x < 8){
  //  limit = ( float(d[(x*8)+y]+1) )/64.0;
  //}
  //if(x < 4){
  //limit = ( dm[x][y] + 1.0 )/64.0;
  limit = ( dm[x][y] + 1.0 )/16.0;
  //}

  if(c0 < limit)
    return 0.0;
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

      vec3 finalRGB;
      finalRGB.r = find_closest(x, y, rgb.r);
      finalRGB.g = find_closest(x, y, rgb.g);
      finalRGB.b = find_closest(x, y, rgb.b);

      float final = find_closest(x, y, grayscale);
      //gl_FragColor = vec4(finalRGB, 1.0);
      gl_FragColor = vec4(final,final,final,1.0);
      //gl_FragColor = vec4(0.0);
    #endif
}
