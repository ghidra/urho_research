//fancy function to compute a color from the velocity
vec4 computeColor(float normal_value)
{
    vec3 color;
    if(normal_value<0.0) normal_value = 0.0;
    if(normal_value>1.0) normal_value = 1.0;
    float v1 = 1.0/7.0;
    float v2 = 2.0/7.0;
    float v3 = 3.0/7.0;
    float v4 = 4.0/7.0;
    float v5 = 5.0/7.0;
    float v6 = 6.0/7.0;
    //compute color
    if(normal_value<v1)
    {
      float c = normal_value/v1;
      color.x = 70.*(1.-c);
      color.y = 70.*(1.-c);
      color.z = 219.*(1.-c) + 91.*c;
    }
    else if(normal_value<v2)
    {
      float c = (normal_value-v1)/(v2-v1);
      color.x = 0.;
      color.y = 255.*c;
      color.z = 91.*(1.-c) + 255.*c;
    }
    else if(normal_value<v3)
    {
      float c = (normal_value-v2)/(v3-v2);
      color.x =  0.*c;
      color.y = 255.*(1.-c) + 128.*c;
      color.z = 255.*(1.-c) + 0.*c;
    }
    else if(normal_value<v4)
    {
      float c = (normal_value-v3)/(v4-v3);
      color.x = 255.*c;
      color.y = 128.*(1.-c) + 255.*c;
      color.z = 0.;
    }
    else if(normal_value<v5)
    {
      float c = (normal_value-v4)/(v5-v4);
      color.x = 255.*(1.-c) + 255.*c;
      color.y = 255.*(1.-c) + 96.*c;
      color.z = 0.;
    }
    else if(normal_value<v6)
    {
      float c = (normal_value-v5)/(v6-v5);
      color.x = 255.*(1.-c) + 107.*c;
      color.y = 96.*(1.-c);
      color.z = 0.;
    }
    else
    {
      float c = (normal_value-v6)/(1.-v6);
      color.x = 107.*(1.-c) + 223.*c;
      color.y = 77.*c;
      color.z = 77.*c;
    }
    return vec4(color.r/255.0,color.g/255.0,color.b/255.0,1.0);
}
#define B

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	vec3 m = texture2D(iChannel0, fragCoord.xy / iResolution.xy ).xyz;
    #ifdef A
    vec2 dir = vec2(m.yz);
    float mag = length(dir);

    dir=(normalize(dir));
    dir-=vec2(0.5,0.5);
    vec3 col = vec3(dir,mag*10.);//vec3(dir.x-.5)*(1.-float(m.x>0.5));
    fragColor=vec4(col,1.0);
    #else
    fragColor=vec4(m,1.0);
    #endif
    
}

void mainImage_B( out vec4 fragColor, in vec2 fragCoord )
{
    //only one pixel out of 4 stores the moments
    int ix = int(floor(fragCoord.x/2.0));
    int iy = int(floor(fragCoord.y/2.0));
    vec3 m = texture2D(iChannel0, (vec2(2*ix+1,2*iy+1)+0.5)/iResolution.xy).xyz;
    //vec3 d = texture2D(iChannel0, (vec2(2*ix,2*iy)+0.5)/iResolution.xy).xyz;
    float solid = m.x;
    float vx  = m.y;
    float vy  = m.z;
    float U = sqrt(vx*vx+vy*vy);
    //fragColor = vec4(vec3(vy*10.0),1.0);
    fragColor = computeColor(U/0.2);
    if(solid > 0.5)
        fragColor = vec4(0.0);
}