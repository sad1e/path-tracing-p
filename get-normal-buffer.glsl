#include "./common.glsl"

void mainImage(out vec4 out_color, in vec2 pixel_coord) {
    vec2 uv = pixel_coord/iResolution.xy;
    uint bit = uint(8.0 * uv.x) + 8u * uint(4.0 * uv.y);
    
    vec3 color = vec3(0.);
    
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
        
        col = getSceneNormal(rof, rd);
        tot += col;
    }
    
    tot /= float(SAMPLE_COUNT);

    
    color = tot;

    out_color = vec4(color, 1.);
}