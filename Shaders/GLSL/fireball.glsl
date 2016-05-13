#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec2 vTexCoord2;
varying vec4 vTexCoord4;

varying vec3 vNormal;
varying vec4 vWorldPos;
varying vec4 vIPos;

#ifdef COMPILEVS
uniform mat3  cObjectRotation; 
uniform sampler2D sNormalMap;
#endif

//#ifdef COMPILEPS
//https://www.shadertoy.com/view/4sfGzS
//https://www.shadertoy.com/view/MdfGRX#

#define USE_PROCEDURAL

#ifdef USE_PROCEDURAL

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

#else

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( sNormalMap, (uv+0.5)/256.0, -100.0 ).yx;//this function was not available on the laptop
        //vec2 rg = texture2D( sNormalMap, (uv+0.5)/256.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

#endif

const mat3 m = mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );
float fbm( in vec3 x )
{
	float f = 0.0;
	vec3 q = 8.0*x;
    f  = 0.5000*noise( q ); q = m*q*2.01;
    f += 0.2500*noise( q ); q = m*q*2.02;
    f += 0.1250*noise( q ); q = m*q*2.03;
    f += 0.0625*noise( q ); q = m*q*2.01;

    return f*1.2;
}

//#endif


void VS()
{
  	mat4 modelMatrix = iModelMatrix;

  	//modify positions
  	float n = fbm(iPos.xyz+vec3(0.0,-cElapsedTime,0.0));
  	vec3 disp = iNormal*(n*0.5);
    //get the dot of normal and direction
    float d = dot( iNormal, vec3(0.0,1.0,0.0) );
    float cd = clamp(d,0.25,1.0);
  	vec3 worldPos = ((iPos+vec4(disp,0.0)*d*cd*2.0) * modelMatrix).xyz;

  	//vec3 worldPos = GetWorldPos(modelMatrix);
  	gl_Position = GetClipPos(worldPos);

 	vTexCoord2 = iTexCoord;

 	vNormal = GetWorldNormal(modelMatrix);
    vWorldPos = vec4(worldPos, GetDepth(gl_Position));
    //vIPos = iPos;//this comes from Transform.glsl
    vIPos = (iPos*vec4(1.0,0.2,1.0,1.0))+vec4(0.0,-cElapsedTime,0.0,0.0);//usetime

    vec3 tangent = GetWorldTangent(modelMatrix);
    vec3 bitangent = cross(tangent, vNormal) * iTangent.w;
    vTexCoord4 = vec4(GetTexCoord(iTexCoord), bitangent.xy);
}

void PS()
{
	vec4 diffColor = cMatDiffColor;
	vec4 diffInput = texture2D(sDiffMap, vTexCoord2);

	//vec3 n = vec3(fbm(vTexCoord4.xyz));
	//vec3 n = vec3(fbm(vWorldPos.xyz));
	vec3 n = vec3(fbm(vIPos.xyz));

	//gl_FragColor = diffColor * diffInput;
	gl_FragColor = vec4(n,1.0);
}