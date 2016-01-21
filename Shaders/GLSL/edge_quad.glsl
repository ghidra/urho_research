#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord;
varying vec2 vScreenPos;
varying vec4 vScreenPos4;


#ifdef COMPILEPS

float color_difference(in vec4 sc, in vec4 nc){
  float dif = abs(sc.r-nc.r)+abs(sc.g-nc.g)+abs(sc.b-nc.b);
  float adif = 0.0;
  if (dif>0.01){//threshold or tolerence
    adif=1.0;
  }
  return adif;
}

vec4 get_pixel(in sampler2D tex, in vec2 coords, in float dx, in float dy) {
 return texture2D(tex,coords + vec2(dx, dy));
}

// returns pixel color
float IsEdge(in sampler2D tex, in vec2 coords, in vec2 size){
  float dxtex =  size.x;//1920.0; //image width;
  float dytex = size.y;//1.0 / 1080.0; //image height;
  //float pix[9];
  //float pix[5];
  float cd[8];
  //int k = -1;
  //float delta;

  /*pix[0] = avg_intensity(get_pixel(tex,coords,float(0)*dxtex,float(0)*dytex));//color of itself
  pix[1] = avg_intensity(get_pixel(tex,coords,float(-1)*dxtex,float(-1)*dytex));
  pix[2] = avg_intensity(get_pixel(tex,coords,float(-1)*dxtex,float(0)*dytex));
  pix[3] = avg_intensity(get_pixel(tex,coords,float(-1)*dxtex,float(1)*dytex));
  pix[4] = avg_intensity(get_pixel(tex,coords,float(0)*dxtex,float(1)*dytex));*/
  vec4 sc = get_pixel(tex,coords,float(0)*dxtex,float(0)*dytex);
  cd[0] = color_difference( sc, get_pixel(tex,coords,float(-1)*dxtex,float(-1)*dytex) );//color of itself
  cd[1] = color_difference( sc, get_pixel(tex,coords,float(-1)*dxtex,float(0)*dytex) );
  cd[2] = color_difference( sc, get_pixel(tex,coords,float(-1)*dxtex,float(1)*dytex) );
  cd[3] = color_difference( sc, get_pixel(tex,coords,float(0)*dxtex,float(1)*dytex) );

  vec4 alt1 = get_pixel(tex,coords,float(1)*dxtex,float(1)*dytex);
  vec4 alt2 = get_pixel(tex,coords,float(1)*dxtex,float(0)*dytex);
  vec4 alt3 = get_pixel(tex,coords,float(1)*dxtex,float(-1)*dytex);
  vec4 alt4 = get_pixel(tex,coords,float(0)*dxtex,float(-1)*dytex);

  //cd[4] = color_difference( sc, alt1 );
  if( length(alt1.rgb) < 0.1 ){ cd[4] = color_difference( sc, alt1 ); }else{ cd[4]=0.0; }
  if( length(alt2.rgb) < 0.1 ){ cd[5] = color_difference( sc, alt2 ); }else{ cd[5]=0.0; }
  if( length(alt3.rgb) < 0.1 ){ cd[6] = color_difference( sc, alt3 ); }else{ cd[6]=0.0; }
  if( length(alt4.rgb) < 0.1 ){ cd[7] = color_difference( sc, alt4 ); }else{ cd[7]=0.0; }
  //check the other angle incase its over alpha, so we can add it too
  // read neighboring pixel intensities
  /*for (int i=-1; i<2; i++) {
    for(int j=-1; j<2; j++) {
      k++;
      pix[k] = avg_intensity(get_pixel(tex,coords,float(i)*dxtex,float(j)*dytex));
    }
  }*/

  // average color differences around neighboring pixels
  //delta = ( abs(pix[1]-pix[0]) + abs(pix[2]-pix[0]) + abs(pix[3]-pix[0]) + abs(pix[4]-pix[0]) ) / 4.0;
  //delta = ( abs(pix[0]-pix[2]) + abs(pix[1]-pix[2]) + abs(pix[3]-pix[2]) ) / 3.0;
  //delta = ( abs(pix[1]-pix[7]) + abs(pix[5]-pix[3]) + abs(pix[0]-pix[8]) + abs(pix[2]-pix[6]) ) / 4.0;
  //delta = (abs(pix[1]-pix[7])+abs(pix[5]-pix[3]) +abs(pix[0]-pix[8])+abs(pix[2]-pix[6]))/4.0;
  //return threshold(0.0,0.1,clamp(1.8*delta,0.0,1.0));
  return cd[0]+cd[1]+cd[2]+cd[3]+cd[4]+cd[5]+cd[6]+cd[7];
}
#endif

void VS()
{


  mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    vTexCoord = GetQuadTexCoord(gl_Position);
    vScreenPos = GetScreenPosPreDiv(gl_Position);
    vScreenPos4 = GetScreenPos(gl_Position);

}

void PS()
{

  vec4 edge = texture2D(sNormalMap,vScreenPos);
  vec4 diff = texture2D(sDiffMap,vScreenPos);
  
  vec4 color = vec4(0.0,0.0,0.0,0.0);
  if(IsEdge(sNormalMap,vScreenPos4.xy / vScreenPos4.w, cGBufferInvSize)>1.0){
    color.rgba = vec4(1.0);
  }
  gl_FragColor = color+diff;
  //gl_FragColor = edge;
}
