#ifdef TEXTURENOISE

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    
    vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
    vec2 rg = texture2D( sNormalMap, (uv+0.5)/256.0, -100.0 ).yx;//this function was not available on the laptop
    return mix( rg.x, rg.y, f.z );
}

#else

float hash( float n ) { return fract(sin(n)*753.5453123); }
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
  
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

#endif

const mat3 mmm = mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );
float fbm( in vec3 x )
{
  float f = 0.0;
  vec3 q = 8.0*x;
    f  = 0.5000*noise( q ); q = mmm*q*2.01;
    f += 0.2500*noise( q ); q = mmm*q*2.02;
    f += 0.1250*noise( q ); q = mmm*q*2.03;
    f += 0.0625*noise( q ); q = mmm*q*2.01;

    return f*1.2;
}

float bias(float t, float b)
{
    return (t / ((((1.0/b) - 2.0)*(1.0 - t))+1.0));
}

float gain(float t,float g)
{
    if(t < 0.5)
    {     
        return bias(t * 2.0,g)/2.0;   
    }else{
        return bias(t * 2.0 - 1.0,1.0 - g)/2.0 + 0.5; 
    }
}

float fit(float v, float l1, float h1, float l2, float h2)
{
    return clamp( l2 + (v - l1) * (h2 - l2) / (h1 - l1), l2,h2);

}
float lum(vec3 rgb)
{
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}
