#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec4 vScreenPos;

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

  float cd[8];

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
  return cd[0]+cd[1]+cd[2]+cd[3]+cd[4]+cd[5]+cd[6]+cd[7];
}
#endif


void VS()
{
    mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);

    vScreenPos = GetScreenPos(gl_Position);

}

void PS(){

      vec2 uv = vScreenPos.xy / vScreenPos.w;
      vec2 shalf = 1.0/(cGBufferInvSize.xy);//this is actually the size of the render halfsize for example
      vec2 s = shalf*2.0;//ie 1920x1080, this is the fullsize

      vec2 mult = (2.0*(uv*s) + 0.5)/(2.0*s);
      //vec2 buffsize = 1.0 / ( (2.0*(vec2(1.0,1.0)*shalf) + 0.5) / (2.0*shalf) );

      //vec2 nuv = uv-(cGBufferInvSize.xy*300.0);


      //vec4 color = texture2D(sEnvMap,vScreenPos.xy / vScreenPos.w);
      //vec4 color = texture2D(sEnvMap,mult);

      //gl_FragColor = color;

      //-------------------

      vec4 color = vec4(0.0,0.0,0.0,0.0);
      if(IsEdge(sEnvMap,mult, cGBufferInvSize.xy*0.5)>1.0){
        color.rgba = vec4(1.0);
        //color = get_pixel(sEnvMap,vScreenPos.xy / vScreenPos.w,float(0)*(cGBufferInvSize.x),float(0)*(cGBufferInvSize.y));
        //color.rgba = diffColor;
        //color.g = IsEdge(sEnvMap,vScreenPos.xy / vScreenPos.w);
        //color.a = 1.0;
      }
      gl_FragColor = color;

}
