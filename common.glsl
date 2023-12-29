// refs:
// https://www.intel.com/content/www/us/en/developer/videos/path-tracing-workshop-part-2.html
// https://www.shadertoy.com/view/ldKBzG
// 


precision highp float;


#define MAX_PATH_LENGTH 6
#define SAMPLE_COUNT    1


// constants

#define M_PI            3.14159265358979323846
#define M_INVPI         0.31830988618379067154
#define M_INV2PI        0.15915494309189533577
#define M_INV4PI        0.07957747154594766788
#define M_PIOVER2       1.57079632679489661923
#define M_PIOVER4       0.78539816339744830961
#define M_SQRT2         1.41421356237309504880
#define FLOAT_EPSILON   0.00001
#define WORLD_MAX       1.0e38f

// colors

#define LIGHTCOLOR  vec3(16.86, 10.76, 8.2)*3. // lightcolor * exposure value

#define BLACKCOLOR  vec3(.000, .000, .000)
#define WHITECOLOR  vec3(.730, .736, .729)
#define BLUECOLOR   vec3(.440, .386, .231)
#define GREENCOLOR  vec3(.117, .513, .115)
#define REDCOLOR    vec3(.711, .056, .062)
#define YELLOWCOLOR vec3(.713, .470, .026)

// -----------------------------------------------------
// features

// #define FULL_BOX
#define ANIMATE_LIGHT
// #define ACCU_AA
// #define SPLIT_SCREEN

// -----------------------------------------------------


// -----------------------------------------------------
// rng - pcg.
// https://www.pcg-random.org/index.html

uvec2 pcg2d(uvec2 v)
{
    v = v * 1664525u + 1013904223u;
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v>>16u);
    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;
    v = v ^ (v>>16u);
    return v;
}

vec2 get_random_numbers(uvec2 seed) {
    seed = 1664525u * seed + 1013904223u;
    seed.x += 1664525u * seed.y;
    seed.y += 1664525u * seed.x;
    seed ^= (seed >> 16u);
    seed.x += 1664525u * seed.y;
    seed.y += 1664525u * seed.x;
    seed ^= (seed >> 16u);
    return vec2(seed) * 2.32830643654e-10;
    // return vec2(seed) / float(uint(0xffffffff));
}

// -----------------------------------------------------

// -----------------------------------------------------
// sampling

vec3 uniform_sample_hemisphere(vec2 p) {
    float z = p.x;
    float r = sqrt(max(0., 1.-z*z));
    float phi = 2.*M_PI*p.y;
    return vec3(r*cos(phi), r*sin(phi), z);
}

float uniform_hemisphere_pdf() { return M_INV2PI; }

vec3 uniform_sample_sphere(vec2 p) {
    float z = 1.-2.*p.x;
    float r = sqrt(max(0., 1.-z*z));
    float phi = 2.*M_PI*p.y;
    return vec3(r*cos(phi), r*sin(phi), z);
}

float uniform_sphere_pdf() { return M_INV4PI; }

vec2 uniform_sample_disk(vec2 p) {
    float r = sqrt(p.x);
    float theta = 2.*M_PI*p.y;
    return vec2(r*cos(theta),r*sin(theta));
}

vec2 concentric_sample_disk(vec2 p) {
    // map uniform number to [-1,1]
    vec2 poff = 2.*p-1.;
    // handle degeneracy at the origin
    if (poff.x == 0. && poff.y == 0.) { return vec2(0.); }
    // apply concentric mapping to point
    float theta, r;
    if (abs(poff.x) > abs(poff.y)) { 
        r = poff.x;
        theta = M_PIOVER4*(poff.y/poff.x);
    } else {
        r = poff.y;
        theta = M_PIOVER2-M_PIOVER4*(poff.x/poff.y);
    }
    
    return r*vec2(cos(theta), sin(theta));
}

vec3 cosine_sample_hemisphere(vec2 p) {
    vec2 d = concentric_sample_disk(p);
    float z = sqrt(max(0., 1.-d.x*d.x-d.y*d.y));
    return vec3(d.x, d.y, z);
}

float consine_hemisphere_pdf(float cos_theta) { return cos_theta * M_INVPI; }

// -----------------------------------------------------

// Ray & Geometry & Intersection functions.

struct ray_t {
    vec3 origin;
    vec3 direction;    
};

vec3 ray_at(in ray_t ray, float t) {
    return ray.origin + ray.direction * t;
}


// Sphere.
vec3 nSphere(in vec3 pos, in vec4 sph) {
    return (pos - sph.xyz) / sph.w;
}

float iSphere(in vec3 ro, in vec3 rd, in vec4 sph) {
    vec3 oc = ro - sph.xyz;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sph.w * sph.w;
    float h = b * b - c;
    if (h < FLOAT_EPSILON) return -1.0;

	float s = sqrt(h);
	float t1 = -b - s;
	float t2 = -b + s;
	
	return t1 < FLOAT_EPSILON ? t2 : t1;
}

// Plane.
vec3 nPlane(in vec3 ro, in vec4 obj) {
    return obj.xyz;
}

float iPlane(in vec3 ro, in vec3 rd, in vec4 pla) {
    return (-pla.w - dot(pla.xyz, ro)) / dot(pla.xyz, rd);
}

// Triangle
struct triangle_t {
    vec3 positions[3];
    vec3 normal;
    vec3 color;
    vec3 emission;
};

bool ray_triangle_intersection(
    vec3 ray_origin, 
    vec3 ray_direction, 
    triangle_t tri,
    out float out_t,
    out vec3 out_intersection_point) {
    
    vec3 edge1 = tri.positions[1] - tri.positions[0];
    vec3 edge2 = tri.positions[2] - tri.positions[0];
    vec3 ray_cross_e2 = cross(ray_direction, edge2);
    float det = dot(edge1, ray_cross_e2);

    if (det > -FLOAT_EPSILON && det < FLOAT_EPSILON)
        return false;

    float inv_det = 1.0 / det;
    vec3 s = ray_origin - tri.positions[0];
    float u = inv_det * dot(s, ray_cross_e2);

    if (u < 0.0 || u > 1.0)
        return false;

    vec3 s_cross_e1 = cross(s, edge1);
    float v = inv_det * dot(ray_direction, s_cross_e1);

    if (v < 0.0 || u + v > 1.0)
        return false;

    // At this stage we can compute t to find out where the intersection point is on the line.
    float t = inv_det * dot(edge2, s_cross_e1);
    out_t = t;
    
    if (t > FLOAT_EPSILON) // ray intersection
    {
        out_intersection_point = ray_origin + ray_direction * t;
        return true;
    }
    else // This means that there is a line intersection but not a ray intersection.
        return false;
}

struct sphere_t {
    vec3  center;
    float radius;
    vec3  color;
    vec3  emission;
};

vec3 get_sphere_normal(sphere_t sph, vec3 pos) {
    return normalize(pos - sph.center);
}

// Light

vec4 lightSphere;

void initLightSphere(float time) {
    // lightSphere = vec4(3.0+2.0*sin(time), 0.0+2.0*sin(time*0.9), 2.0+1.0*2.0*cos(time * 0.7), 0.5);
#ifdef ANIMATE_LIGHT
    lightSphere = vec4(3.0+2.0*sin(time), 2.0+2.0*sin(time*0.9), 3.+2.*cos(time * 0.7), 0.4);
#else    
    lightSphere = vec4(3., 3.5, 3., 0.5);
#endif    
}

vec3 sampleLight(const in vec3 ro, inout uvec2 seed) {
    vec2 rands = get_random_numbers(seed);
    vec3 n = uniform_sample_sphere(rands) * lightSphere.w;
    return lightSphere.xyz + n;
}

// texture samples.
// Tnx IQ for patterns
vec4 getTexture(in vec2 p, int id)
{
    const float N = 20.0;
    
    // coordinates
    vec2 i = step( fract(p), vec2(1.0/N));
    
    // patterns
    if(id==1) 
    {
        vec2 q = floor(p);
        return vec4(mod( q.x+q.y, 2.0 ));
    }
    else if(id==2) return vec4((1.0-i.x)*(1.0-i.y));
    else if(id==3) return vec4(1.0-i.x*i.y);   
    else if(id==4) return vec4(1.0-i.x-i.y+2.0*i.x*i.y); 
}

// aces tonemapping

vec3 aces_tonemapping(vec3 col) {
    const vec3 a = vec3(2.51);
    const vec3 b = vec3(0.03);
    const vec3 c = vec3(2.43);
    const vec3 d = vec3(0.59);
    const vec3 e = vec3(0.14);
    return clamp((col * (a * col + b)) / (col * (c * col + d) + e), vec3(0.), vec3(1.));
}

vec3 less_than(vec3 f, float value)
{
    return vec3(
        (f.x < value) ? 1.0f : 0.0f,
        (f.y < value) ? 1.0f : 0.0f,
        (f.z < value) ? 1.0f : 0.0f);
}

vec3 linear_to_srgb(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
        rgb * 12.92f,
        less_than(rgb, 0.0031308f)
    );
}

vec3 srgb_to_linear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
        rgb / 12.92f,
        less_than(rgb, 0.04045f)
	);
}


// ---------------------------------------------------------------------------
// Scene, Materials, 
// ---------------------------------------------------------------------------

struct Material {
    int id;
    
    vec3  albedo;
    float specular;
    float fresnelR0;
    float roughness;
    float metallic;
};

Material getMaterial(int mId) {
    Material mat;
    mat.id = mId;
    mat.albedo = vec3(0.);
    mat.metallic = 1.;
    mat.roughness = .1;
    mat.fresnelR0 = .3;
    mat.specular = 0.;
    
    if (mId == 0) { // Light
        mat.albedo = LIGHTCOLOR;
    }
    else if (mId == 10) {
        mat.albedo = WHITECOLOR;
    }
    else if (mId == 20) {
        mat.albedo = GREENCOLOR;
    }
    else if (mId == 30) {
        mat.albedo = REDCOLOR;
        // mat.specular = 1.;
    }
    else if (mId == 40) {
        mat.albedo = BLUECOLOR;
    }
    else if (mId == 50) {
        mat.albedo = WHITECOLOR;
    }
    else if (mId == 60) {
        mat.albedo = YELLOWCOLOR;
    }
    
    return mat;
}

bool matIsSpecular(const Material m) { return m.specular > 0.5; }

bool matIsLight(const Material m) { return m.id == 0; }

// Scene

vec2 intersectScene( in vec3 ro, in vec3 rd, inout vec3 normal ) {
	vec2 res = vec2( WORLD_MAX, -1.0 );
    float t;
	
	t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 10. ); normal = vec3( 0., 1., 0.); }
	t = iPlane( ro, rd, vec4( 0.0, 0.0,-1.0,8.0 ) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 10. ); normal = vec3( 0., 0.,-1.); }
    t = iPlane( ro, rd, vec4( 1.0, 0.0, 0.0,0.0 ) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 20. ); normal = vec3( 1., 0., 0.); }
#ifdef FULL_BOX
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 10. ); normal = vec3( 0., -1., 0.); }
    t = iPlane( ro, rd, vec4(-1.0, 0.0, 0.0,5.59) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 30. ); normal = vec3(-1., 0., 0.); }
#endif

	t = iSphere( ro, rd, vec4( 1.5,1.0, 2.7, 1.0) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 10. ); normal = nSphere( ro+t*rd, vec4( 1.5,1.0, 2.7,1.0) ); }
    t = iSphere( ro, rd, vec4( 4.0,1.0, 4.0, 1.0) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 40. ); normal = nSphere( ro+t*rd, vec4( 4.0,1.0, 4.0,1.0) ); }
    t = iSphere( ro, rd, vec4( 3.3,0.3, 1.3, 0.3) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 30. ); normal = nSphere( ro+t*rd, vec4( 3.3,0.3, 1.3, 0.3) ); }
    
    t = iSphere( ro, rd, vec4( 2.5,2.0, 1.7, 0.5) ); if( t>FLOAT_EPSILON && t<res.x ) { res = vec2( t, 10. ); normal = nSphere( ro+t*rd, vec4( 2.5,2.0, 1.7, 0.5) ); }
    
    t = iSphere( ro, rd, lightSphere ); 
    
    if( t > FLOAT_EPSILON && t < res.x ) {
        res = vec2( t, 0.0 );
        normal = nSphere( ro+t*rd, lightSphere );
    }
					  
    return res;		
}


// Denoise

vec3 getSceneNormal(in vec3 ro, in vec3 rd) {
    vec3 tcol = vec3(0.);
    vec3 fcol  = vec3(1.);
    
    vec3 normal;
    intersectScene( ro, rd, normal );
    return normal;
}

vec3 getSceneBase(in vec3 ro, in vec3 rd) {
    vec3 tcol = vec3(0.);
    vec3 fcol = vec3(1.);
    
    vec3 normal;
    // check intersect with scene. res.x: t, res.y: material id.
    vec2 res = intersectScene(ro, rd, normal);
    
    Material mat = getMaterial(int(res.y));
    if (res.y < -0.5) { return tcol; }
    
    if (matIsLight(mat)) {
        return LIGHTCOLOR;
    }
    
    return mat.albedo;
}

