#include "./common.glsl"

#iChannel0 "self"

// BRDF

vec3 getBRDFRay( in vec3 n, const in vec3 rd, const in int mId, inout bool specularBounce, inout uvec2 seed) {
    vec2 rand = get_random_numbers(seed);
    specularBounce = false;
    
    Material mat = getMaterial(mId);
    
    vec3 r = cosine_sample_hemisphere(rand);
    if(!matIsSpecular(mat)) {
        return r;
    } else {
        specularBounce = true;
        
        float n1, n2, ndotr = dot(rd,n);
        
        if( ndotr > FLOAT_EPSILON ) {
            n1 = 1.0; 
            n2 = 1.5;
            n = -n;
        } else {
            n1 = 1.5;
            n2 = 1.0; 
        }
                
        float r0 = (n1-n2)/(n1+n2); r0 *= r0;
		float fresnel = r0 + (1.-r0) * pow(1.0-abs(ndotr),5.);
        
        vec3 ref;
        ref = reflect( rd, n );
        
       if( rand.x < fresnel ) {
           ref = reflect( rd, n );
       } else {
           ref = refract( rd, n, n2/n1 );
       }
        
        return ref; // normalize( ref + 0.1 * r );
	}
}

// Trace

vec3 traceEyePath(in vec3 ro, in vec3 rd, 
    const in bool directLightSampling,
    inout uvec2 seed) {
    
    // return previewNormal(ro, rd);
    // return previewScene(ro, rd);
    
    vec2 rand = get_random_numbers(seed);
    
    vec3 tcol = vec3(0.);
    vec3 fcol = vec3(1.);
    
    bool specularBounce = true;
    
    // Trace length.
    for (int i = 0; i < MAX_PATH_LENGTH; ++i) {
        vec3 normal;
        // check intersect with scene. res.x: t, res.y: material id.
        vec2 res = intersectScene(ro, rd, normal);
        
        int matId = int(res.y);
        Material mat = getMaterial(matId);
        
        // if (res.y < -0.5) { return tcol; }
        
        if (matIsLight(mat)) {
            if (directLightSampling) {
                if (specularBounce) { tcol += fcol*LIGHTCOLOR; }
            } else {
                tcol += fcol*LIGHTCOLOR;
            }
                
            return tcol;
        }
        
        ro = ro + rd * res.x;
        rd = getBRDFRay(normal, rd, matId, specularBounce, seed);
        
        fcol *= mat.albedo;
        
        vec3 ld = sampleLight(ro, seed) - ro;
        
        if (directLightSampling) {
            vec3 nld = normalize(ld);
            if (!specularBounce && i < MAX_PATH_LENGTH-1) {
                float cos_a_max = sqrt(1. - clamp(lightSphere.w * lightSphere.w / dot(lightSphere.xyz-ro, lightSphere.xyz-ro), 0., 1.));
                float weight = 2. * (1. - cos_a_max);

                tcol += (fcol * LIGHTCOLOR) * (weight * clamp(dot( nld, normal ), 0., 1.));                
            }
        }
    }
    
    return tcol;
}

void mainImage(out vec4 out_color, in vec2 pixel_coord) {
    vec2 uv = pixel_coord/iResolution.xy;
    uint bit = uint(8.0 * uv.x) + 8u * uint(4.0 * uv.y);
    
    vec3 color = vec3(0.);
    
    bool directLightSampling = true;
    
    vec2 p = -1.0 + 2.0 * (pixel_coord.xy) / iResolution.xy;
    p.x *= iResolution.x / iResolution.y;
    
    // generate seed.
    uvec2 seed = uvec2(pixel_coord) ^ uvec2(iFrame << 16);

 
    vec3 ro = vec3(2.78, 2.73, -8.00);
    vec3 ta = vec3(2.78, 2.73,  0.00);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    
    vec3 col = vec3(0.0);
    vec3 tot = vec3(0.0);
    vec3 uvw = vec3(0.0);
    
    for (int i = 0; i < SAMPLE_COUNT; ++i) {
        vec2 rpof = 4.*(get_random_numbers(seed)-vec2(0.5)) / iResolution.xy;
        vec3 rd = normalize( (p.x+rpof.x)*uu + (p.y+rpof.y)*vv + 3.0*ww );
        
        initLightSphere(iTime*0.8);
        
        vec3 rof = ro;
        
        // seed = uvec2(pixel_coord+vec2(i)) ^ uvec2(iFrame << 16);
    
        col = traceEyePath(rof, rd, directLightSampling, seed);
        tot += col;
    }
    
    tot /= float(SAMPLE_COUNT);
    tot = aces_tonemapping(tot);

    
    color = tot;
    
#ifdef ACCU_AA
    vec3 prev_color = texture(iChannel0, uv).rgb;
    float weight = 1.0 / float(iFrame+10);
    color = (1.0 - weight) * prev_color + weight * color;
#endif

    out_color = vec4(color, 1.);
}

