#include "Uniforms.glsl"
#include "Samplers.glsl"
#include "Transform.glsl"
#include "ScreenPos.glsl"

varying vec4 vScreenPos;

//#ifdef COMPILEPS 

#define HALFPI 1.570796
#define MIN_EPSILON 6e-7
#define MIN_NORM 1.5e-7
#define dE MengerSponge             // {"label":"Fractal type", "control":"select", "options":["MengerSponge", "SphereSponge", "Mandelbulb", "Mandelbox", "OctahedralIFS", "DodecahedronIFS"]}

#define maxIterations 8             // {"label":"Iterations", "min":1, "max":30, "step":1, "group_label":"Fractal parameters"}
#define stepLimit 60                // {"label":"Max steps", "min":10, "max":300, "step":1}

#define aoIterations 4              // {"label":"AO iterations", "min":0, "max":10, "step":1}

#define minRange 6e-5
#define bailout 4.0
#define antialiasing 0.5            // {"label":"Anti-aliasing", "control":"bool", "default":false, "group_label":"Render quality"}

uniform float cScale;                // {"label":"Scale",        "min":-10,  "max":10,   "step":0.01,     "default":2,    "group":"Fractal", "group_label":"Fractal parameters"}
uniform float cPower;                // {"label":"Power",        "min":-20,  "max":20,   "step":0.1,     "default":8,    "group":"Fractal"}
uniform float cSurfaceDetail;        // {"label":"Detail",   "min":0.1,  "max":2,    "step":0.01,    "default":0.6,  "group":"Fractal"}
uniform float cSurfaceSmoothness;    // {"label":"Smoothness",   "min":0.01,  "max":1,    "step":0.01,    "default":0.8,  "group":"Fractal"}
uniform float cBoundingRadius;       // {"label":"Bounding radius", "min":0.1, "max":150, "step":0.01, "default":5, "group":"Fractal"}
uniform vec3  cOffset;               // {"label":["Offset x","Offset y","Offset z"],  "min":-3,   "max":3,    "step":0.01,    "default":[0,0,0],  "group":"Fractal", "group_label":"Offsets"}
uniform vec3  cShift;                // {"label":["Shift x","Shift y","Shift z"],  "min":-3,   "max":3,    "step":0.01,    "default":[0,0,0],  "group":"Fractal"}

uniform float cCameraRoll;           // {"label":"Roll",         "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera", "group_label":"Camera parameters"}
uniform float cCameraPitch;          // {"label":"Pitch",        "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera"}
uniform float cCameraYaw;            // {"label":"Yaw",          "min":-180, "max":180,  "step":0.5,     "default":0,    "group":"Camera"}
uniform float cCameraFocalLength;    // {"label":"Focal length", "min":0.1,  "max":3,    "step":0.01,    "default":0.9,  "group":"Camera"}
uniform vec3  cCameraPosition;       // {"label":["Camera x", "Camera y", "Camera z"],   "default":[0.0, 0.0, -2.5], "control":"camera", "group":"Camera", "group_label":"Position"}

uniform int   cColorIterations;      // {"label":"Colour iterations", "dE": 4, "min":0, "max": 30, "step":1, "group":"Colour", "group_label":"Base colour"}
uniform vec3  cColor1;               // {"label":"Colour 1",  "default":[1.0, 1.0, 1.0], "group":"Colour", "control":"color"}
uniform float cColor1Intensity;      // {"label":"Colour 1 intensity", "default":0.45, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform vec3  cColor2;               // {"label":"Colour 2",  "default":[0, 0.53, 0.8], "group":"Colour", "control":"color"}
uniform float cColor2Intensity;      // {"label":"Colour 2 intensity", "default":0.3, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform vec3  cColor3;               // {"label":"Colour 3",  "default":[1.0, 0.53, 0.0], "group":"Colour", "control":"color"}
uniform float cColor3Intensity;      // {"label":"Colour 3 intensity", "default":0, "min":0, "max":3, "step":0.01, "group":"Colour"}
uniform bool  cTransparent;          // {"label":"Transparent background", "default":false, "group":"Colour"}
uniform float cGamma;                // {"label":"Gamma correction", "default":1, "min":0.1, "max":2, "step":0.01, "group":"Colour"}

uniform vec3  cLight;                // {"label":["Light x", "Light y", "Light z"], "default":[-16.0, 100.0, -60.0], "min":-300, "max":300,  "step":1,   "group":"Shading", "group_label":"Light position"}
uniform vec2  cMyAmbientColor;         // {"label":["Ambient intensity", "Ambient colour"],  "default":[0.5, 0.3], "group":"Colour", "group_label":"Ambient light & background"}
uniform vec3  cBackground1Color;     // {"label":"Background top",   "default":[0.0, 0.46, 0.8], "group":"Colour", "control":"color"}
uniform vec3  cBackground2Color;     // {"label":"Background bottom", "default":[0, 0, 0], "group":"Colour", "control":"color"}
uniform vec3  cInnerGlowColor;       // {"label":"Inner glow", "default":[0.0, 0.6, 0.8], "group":"Shading", "control":"color", "group_label":"Glows"}
uniform float cInnerGlowIntensity;   // {"label":"Inner glow intensity", "default":0.1, "min":0, "max":1, "step":0.01, "group":"Shading"}
uniform vec3  cOuterGlowColor;       // {"label":"Outer glow", "default":[1.0, 1.0, 1.0], "group":"Shading", "control":"color"}
uniform float cOuterGlowIntensity;   // {"label":"Outer glow intensity", "default":0.0, "min":0, "max":1, "step":0.01, "group":"Shading"}
uniform float cFog;                  // {"label":"Fog intensity",          "min":0,    "max":1,    "step":0.01,    "default":0,    "group":"Shading", "group_label":"Fog"}
uniform float cFogFalloff;           // {"label":"Fog falloff",  "min":0,    "max":10,   "step":0.01,    "default":0,    "group":"Shading"}
uniform float cSpecularity;          // {"label":"Specularity",  "min":0,    "max":3,    "step":0.01,    "default":0.8,  "group":"Shading", "group_label":"Shininess"}
uniform float cSpecularExponent;     // {"label":"Specular exponent", "min":0, "max":50, "step":0.1,     "default":4,    "group":"Shading"}

uniform vec2  cSize;                 // {"default":[400, 300]}
uniform vec2  cOutputSize;           // {"default":[800, 600]}
uniform float cAoIntensity;          // {"label":"AO intensity",     "min":0, "max":1, "step":0.01, "default":0.15,  "group":"Shading", "group_label":"Ambient occlusion"}
uniform float cAoSpread;             // {"label":"AO spread",    "min":0, "max":20, "step":0.01, "default":9,  "group":"Shading"}

uniform mat3  cObjectRotation;       // {"label":["Rotate x", "Rotate y", "Rotate z"], "group":"Fractal", "control":"rotation", "default":[0,0,0], "min":-360, "max":360, "step":1, "group_label":"Object rotation"}
uniform mat3  cFractalRotation1;     // {"label":["Rotate x", "Rotate y", "Rotate z"], "group":"Fractal", "control":"rotation", "default":[0,0,0], "min":-360, "max":360, "step":1, "group_label":"Fractal rotation 1"}
uniform mat3  cFractalRotation2;     // {"label":["Rotate x", "Rotate y", "Rotate z"], "group":"Fractal", "control":"rotation", "default":[0,0,0], "min":-360, "max":360, "step":1, "group_label":"Fractal rotation 2"}
uniform bool  cDepthMap;             // {"label":"Depth map", "default": false, "value":1, "group":"Shading"}


float aspectRatio = cOutputSize.x / cOutputSize.y;
float fovfactor = 1.0 / sqrt(1.0 + cCameraFocalLength * cCameraFocalLength);
float pixelScale = 1.0 / min(cOutputSize.x, cOutputSize.y);
float epsfactor = 2.0 * fovfactor * pixelScale * cSurfaceDetail;
vec3  w = vec3(0, 0, 1);
vec3  v = vec3(0, 1, 0);
vec3  u = vec3(1, 0, 0);
mat3  cameraRotation;

// Return rotation matrix for rotating around vector v by angle
mat3 rotationMatrixVector(vec3 v, float angle)
{
    float c = cos(radians(angle));
    float s = sin(radians(angle));
    
    return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
              (1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
              (1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z);
}
//----------------------------------------//
//#ifdef dEMengerSponge
// Pre-calculations
vec3 halfSpongeScale = vec3(0.5) * cScale;

// Adapted from Buddhis algorithm
// http://www.fractalforums.com/3d-fractal-generation/revenge-of-the-half-eaten-menger-sponge/msg21700/
vec3 MengerSponge(vec3 w)
{
    w *= cObjectRotation;
    w = (w * 0.5 + vec3(0.5)) * cScale;  // scale [-1, 1] range to [0, 1]

    vec3 v = abs(w - halfSpongeScale) - halfSpongeScale;
    float d1 = max(v.x, max(v.y, v.z));     // distance to the box
    float d = d1;
    float p = 1.0;
    float md = 10000.0;
    vec3 cd = v;
    
    for (int i = 0; i < int(maxIterations); i++) {
        vec3 a = mod(3.0 * w * p, 3.0);
        p *= 3.0;
        
        v = vec3(0.5) - abs(a - vec3(1.5)) + cOffset;
        v *= cFractalRotation1;

        // distance inside the 3 axis aligned square tubes
        d1 = min(max(v.x, v.z), min(max(v.x, v.y), max(v.y, v.z))) / p;
        
        // intersection
        d = max(d, d1);
        
        if (i < cColorIterations) {
            md = min(md, d);
            cd = v;
        }
    }
    
    // The distance estimate, min distance, and fractional iteration count
    return vec3(d * 2.0 / cScale, md, dot(cd, cd));
}
//#endif

//----------------------------------------//

vec3 rayDirection(vec2 pixel)
{
    vec2 p = (0.5 * cSize - pixel) / vec2(cSize.x, -cSize.y);
    p.x *= aspectRatio;
    vec3 d = (p.x * u + p.y * v - cCameraFocalLength * w);
    
    return normalize(cameraRotation * d);
}



// Intersect bounding sphere
//
// If we intersect then set the tmin and tmax values to set the start and
// end distances the ray should traverse.
bool intersectBoundingSphere(vec3 origin,
                             vec3 direction,
                             out float tmin,
                             out float tmax)
{
    bool hit = false;
    float b = dot(origin, direction);
    float c = dot(origin, origin) - cBoundingRadius;
    float disc = b*b - c;           // discriminant
    tmin = tmax = 0.0;

    if (disc > 0.0) {
        // Real root of disc, so intersection
        float sdisc = sqrt(disc);
        float t0 = -b - sdisc;          // closest intersection distance
        float t1 = -b + sdisc;          // furthest intersection distance

        if (t0 >= 0.0) {
            // Ray intersects front of sphere
            tmin = t0;
            tmax = t0 + t1;
        } else if (t0 < 0.0) {
            // Ray starts inside sphere
            tmax = t1;
        }
        hit = true;
    }

    return hit;
}




// Calculate the gradient in each dimension from the intersection point
vec3 generateNormal(vec3 z, float d)
{
    float e = max(d * 0.5, MIN_NORM);
    
    float dx1 = dE(z + vec3(e, 0, 0)).x;
    float dx2 = dE(z - vec3(e, 0, 0)).x;
    
    float dy1 = dE(z + vec3(0, e, 0)).x;
    float dy2 = dE(z - vec3(0, e, 0)).x;
    
    float dz1 = dE(z + vec3(0, 0, e)).x;
    float dz2 = dE(z - vec3(0, 0, e)).x;
    
    return normalize(vec3(dx1 - dx2, dy1 - dy2, dz1 - dz2));
}


// Blinn phong shading model
// http://en.wikipedia.org/wiki/BlinnPhong_shading_model
// base color, incident, point of intersection, normal
vec3 blinnPhong(vec3 color, vec3 p, vec3 n)
{
    // Ambient colour based on background gradient
    vec3 ambColor = clamp(mix(cBackground2Color, cBackground1Color, (sin(n.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0);
    ambColor = mix(vec3(cMyAmbientColor.x), ambColor, cMyAmbientColor.y);
    
    vec3  halfLV = normalize(cLight - p);
    float diffuse = max(dot(n, halfLV), 0.0);
    float specular = pow(diffuse, cSpecularExponent);
    
    return ambColor * color + color * diffuse + specular * cSpecularity;
}



// Ambient occlusion approximation.
// Based upon boxplorer's implementation which is derived from:
// http://www.iquilezles.org/www/material/nvscene2008/rwwtt.pdf
float ambientOcclusion(vec3 p, vec3 n, float eps)
{
    float o = 1.0;                  // Start at full output colour intensity
    eps *= cAoSpread;                // Spread diffuses the effect
    float k = cAoIntensity / eps;    // Set intensity factor
    float d = 2.0 * eps;            // Start ray a little off the surface
    
    for (int i = 0; i < aoIterations; ++i) {
        o -= (d - dE(p + n * d).x) * k;
        d += eps;
        k *= 0.5;                   // AO contribution drops as we move further from the surface 
    }
    
    return clamp(o, 0.0, 1.0);
}


// Calculate the output colour for each input pixel
vec4 render(vec2 pixel)
{
    vec3  ray_direction = rayDirection(pixel);
    float ray_length = minRange;
    vec3  ray = cCameraPosition + ray_length * ray_direction;
    vec4  bg_color = vec4(clamp(mix(cBackground2Color, cBackground1Color, (sin(ray_direction.y * HALFPI) + 1.0) * 0.5), 0.0, 1.0), 1.0);
    vec4  color = bg_color;
    
    float eps = MIN_EPSILON;
    vec3  dist;
    vec3  normal = vec3(0);
    int   steps = 0;
    bool  hit = false;
    float tmin = 0.0;
    float tmax = 10000.0;
    
    if (intersectBoundingSphere(ray, ray_direction, tmin, tmax)) {
        ray_length = tmin;
        ray = cCameraPosition + ray_length * ray_direction;
        
        for (int i = 0; i < stepLimit; i++) {
            steps = i;
            dist = dE(ray);
            dist.x *= cSurfaceSmoothness;
            
            // If we hit the surface on the previous step check again to make sure it wasn't
            // just a thin filament
            if (hit && dist.x < eps || ray_length > tmax || ray_length < tmin) {
                steps--;
                break;
            }
            
            hit = false;
            ray_length += dist.x;
            ray = cCameraPosition + ray_length * ray_direction;
            eps = ray_length * epsfactor;

            if (dist.x < eps || ray_length < tmin) {
                hit = true;
            }
        }
    }
    
    // Found intersection?
    float glowAmount = float(steps)/float(stepLimit);
    float glow;
    
    if (hit) {
        float aof = 1.0, shadows = 1.0;
        glow = clamp(glowAmount * cInnerGlowIntensity * 3.0, 0.0, 1.0);

        if (steps < 1 || ray_length < tmin) {
            normal = normalize(ray);
        } else {
            normal = generateNormal(ray, eps);
            aof = ambientOcclusion(ray, normal, eps);
        }
        
        color.rgb = mix(cColor1, mix(cColor2, cColor3, dist.y * cColor2Intensity), dist.z * cColor3Intensity);
        color.rgb = blinnPhong(clamp(color.rgb * cColor1Intensity, 0.0, 1.0), ray, normal);
        color.rgb *= aof;
        color.rgb = mix(color.rgb, cInnerGlowColor, glow);
        color.rgb = mix(bg_color.rgb, color.rgb, exp(-pow(ray_length * exp(cFogFalloff), 2.0) * cFog));
        color.a = 1.0;
    } else {
        // Apply outer glow and fog
        ray_length = tmax;
        color.rgb = mix(bg_color.rgb, color.rgb, exp(-pow(ray_length * exp(cFogFalloff), 2.0)) * cFog);
        glow = clamp(glowAmount * cOuterGlowIntensity * 3.0, 0.0, 1.0);
        color.rgb = mix(color.rgb, cOuterGlowColor, glow);
        if (cTransparent) color = vec4(0.0);
    }
    
    // if (depthMap) {
    //     color.rgb = vec3(ray_length / 10.0);
    // }
    
    return color;
}

//----------------------------------//

//#endif

void VS(){
	mat4 modelMatrix = iModelMatrix;
    vec3 worldPos = GetWorldPos(modelMatrix);
    gl_Position = GetClipPos(worldPos);
    //vScreenPos = GetScreenPosPreDiv(gl_Position);

    vScreenPos = GetScreenPos(gl_Position);
}

void PS(){
	//gl_FragColor = vec4(vScreenPos.xy / vScreenPos.w,0,1);

	vec4 color = vec4(0.0);
    float n = 0.0;
    cameraRotation = rotationMatrixVector(v, 180.0 - cCameraYaw) * rotationMatrixVector(u, -cCameraPitch) * rotationMatrixVector(w, cCameraRoll);

    color = render(vScreenPos.xy / vScreenPos.w);

    if (color.a < 0.00392) discard; // Less than 1/255
    
    gl_FragColor = color;
    //gl_FragColor = vec4(pow(color.rgb, vec3(1.0 / cGamma)), color.a);
    //gl_FragColor = vec4(cOffset, 1.0);

}