
#define TRIANGLE_COUNT 32

vec3 get_primary_ray_direction(float x, float y, 
    vec3 camera_position, 
    vec3 left_bottom, 
    vec3 right, 
    vec3 up) {
    
    vec3 image_plane_pos = left_bottom + x * right + y * up;
    return normalize(image_plane_pos - camera_position);
}

bool ray_mesh_intersection(out float out_t, out triangle_t out_tri, vec3 origin, vec3 direction) {
    
    triangle_t tris[TRIANGLE_COUNT];
    // Index with 24 & 29 are two top planes.
    tris[0].positions[0] = vec3(0.000000133, -0.559199989, 0.548799932); tris[0].positions[1] = vec3(0.555999935, -0.559199989, 0.000000040); tris[0].positions[2] = vec3(0.000000133, -0.559199989, 0.000000040); tris[1].positions[0] = vec3(0.313999921, -0.455999970, 0.329999954); tris[1].positions[1] = vec3(0.313999921, -0.455999970, 0.000000040); tris[1].positions[2] = vec3(0.472000152, -0.406000137, 0.000000040); tris[2].positions[0] = vec3(0.000000133, -0.559199989, 0.000000040); tris[2].positions[1] = vec3(0.555999935, -0.559199989, 0.000000040); tris[2].positions[2] = vec3(0.555999935, -0.000000119, 0.000000040); tris[3].positions[0] = vec3(0.264999926, -0.296000093, 0.329999954); tris[3].positions[1] = vec3(0.264999926, -0.296000093, 0.000000040); tris[3].positions[2] = vec3(0.313999921, -0.455999970, 0.000000040); tris[4].positions[0] = vec3(0.423000127, -0.246999890, 0.000000040); tris[4].positions[1] = vec3(0.472000152, -0.406000137, 0.329999954); tris[4].positions[2] = vec3(0.472000152, -0.406000137, 0.000000040); tris[5].positions[0] = vec3(0.264999926, -0.296000093, 0.329999954); tris[5].positions[1] = vec3(0.313999921, -0.455999970, 0.000000040); tris[5].positions[2] = vec3(0.313999921, -0.455999970, 0.329999954); tris[6].positions[0] = vec3(0.313999921, -0.455999970, 0.329999954); tris[6].positions[1] = vec3(0.472000152, -0.406000137, 0.000000040); tris[6].positions[2] = vec3(0.472000152, -0.406000137, 0.329999954); tris[7].positions[0] = vec3(0.240000039, -0.271999955, 0.165000007); tris[7].positions[1] = vec3(0.082000092, -0.225000143, 0.165000007); tris[7].positions[2] = vec3(0.082000092, -0.225000143, 0.000000040); tris[8].positions[0] = vec3(0.240000039, -0.271999955, 0.165000007); tris[8].positions[1] = vec3(0.082000092, -0.225000143, 0.000000040); tris[8].positions[2] = vec3(0.240000039, -0.271999955, 0.000000040); tris[9].positions[0] = vec3(0.290000081, -0.113999903, 0.000000040); tris[9].positions[1] = vec3(0.240000039, -0.271999955, 0.165000007); tris[9].positions[2] = vec3(0.240000039, -0.271999955, 0.000000040); tris[10].positions[0] = vec3(0.082000092, -0.225000143, 0.000000040); tris[10].positions[1] = vec3(0.130000070, -0.064999968, 0.165000007); tris[10].positions[2] = vec3(0.130000070, -0.064999968, 0.000000040); tris[11].positions[0] = vec3(0.082000092, -0.225000143, 0.000000040); tris[11].positions[1] = vec3(0.082000092, -0.225000143, 0.165000007); tris[11].positions[2] = vec3(0.130000070, -0.064999968, 0.165000007); tris[12].positions[0] = vec3(0.000000133, -0.559199989, 0.000000040); tris[12].positions[1] = vec3(0.555999935, -0.000000119, 0.000000040); tris[12].positions[2] = vec3(0.000000133, -0.000000119, 0.000000040); tris[13].positions[0] = vec3(0.130000070, -0.064999968, 0.000000040); tris[13].positions[1] = vec3(0.290000081, -0.114000171, 0.165000007); tris[13].positions[2] = vec3(0.290000081, -0.113999903, 0.000000040); tris[14].positions[0] = vec3(0.290000081, -0.113999903, 0.000000040); tris[14].positions[1] = vec3(0.290000081, -0.114000171, 0.165000007); tris[14].positions[2] = vec3(0.240000039, -0.271999955, 0.165000007); tris[15].positions[0] = vec3(0.130000070, -0.064999968, 0.000000040); tris[15].positions[1] = vec3(0.130000070, -0.064999968, 0.165000007); tris[15].positions[2] = vec3(0.290000081, -0.114000171, 0.165000007); tris[16].positions[0] = vec3(0.000000133, -0.559199989, 0.000000040); tris[16].positions[1] = vec3(0.000000133, -0.000000119, 0.000000040); tris[16].positions[2] = vec3(0.000000133, -0.000000119, 0.548799932); tris[17].positions[0] = vec3(0.130000070, -0.064999968, 0.165000007); tris[17].positions[1] = vec3(0.082000092, -0.225000143, 0.165000007); tris[17].positions[2] = vec3(0.240000039, -0.271999955, 0.165000007); tris[18].positions[0] = vec3(0.130000070, -0.064999968, 0.165000007); tris[18].positions[1] = vec3(0.240000039, -0.271999955, 0.165000007); tris[18].positions[2] = vec3(0.290000081, -0.114000171, 0.165000007); tris[19].positions[0] = vec3(0.423000127, -0.247000158, 0.329999954); tris[19].positions[1] = vec3(0.423000127, -0.246999890, 0.000000040); tris[19].positions[2] = vec3(0.264999926, -0.296000093, 0.000000040); tris[20].positions[0] = vec3(0.423000127, -0.247000158, 0.329999954); tris[20].positions[1] = vec3(0.264999926, -0.296000093, 0.000000040); tris[20].positions[2] = vec3(0.264999926, -0.296000093, 0.329999954); tris[21].positions[0] = vec3(0.423000127, -0.246999890, 0.000000040); tris[21].positions[1] = vec3(0.423000127, -0.247000158, 0.329999954); tris[21].positions[2] = vec3(0.472000152, -0.406000137, 0.329999954); tris[22].positions[0] = vec3(0.555999935, -0.000000119, 0.548799932); tris[22].positions[1] = vec3(0.555999935, -0.000000119, 0.000000040); tris[22].positions[2] = vec3(0.555999935, -0.559199989, 0.000000040); tris[23].positions[0] = vec3(0.000000133, -0.559199989, 0.000000040); tris[23].positions[1] = vec3(0.000000133, -0.000000119, 0.548799932); tris[23].positions[2] = vec3(0.000000133, -0.559199989, 0.548799932); tris[24].positions[0] = vec3(0.000000133, -0.000000119, 0.548799932); tris[24].positions[1] = vec3(0.555999935, -0.559199989, 0.548799932); tris[24].positions[2] = vec3(0.000000133, -0.559199989, 0.548799932); tris[25].positions[0] = vec3(0.000000133, -0.559199989, 0.548799932); tris[25].positions[1] = vec3(0.555999935, -0.559199989, 0.548799932); tris[25].positions[2] = vec3(0.555999935, -0.559199989, 0.000000040); tris[26].positions[0] = vec3(0.472000152, -0.406000137, 0.329999954); tris[26].positions[1] = vec3(0.264999926, -0.296000093, 0.329999954); tris[26].positions[2] = vec3(0.313999921, -0.455999970, 0.329999954); tris[27].positions[0] = vec3(0.555999935, -0.000000119, 0.548799932); tris[27].positions[1] = vec3(0.555999935, -0.559199989, 0.000000040); tris[27].positions[2] = vec3(0.555999935, -0.559199989, 0.548799932); tris[28].positions[0] = vec3(0.472000152, -0.406000137, 0.329999954); tris[28].positions[1] = vec3(0.423000127, -0.247000158, 0.329999954); tris[28].positions[2] = vec3(0.264999926, -0.296000093, 0.329999954); tris[29].positions[0] = vec3(0.000000133, -0.000000119, 0.548799932); tris[29].positions[1] = vec3(0.555999935, -0.000000119, 0.548799932); tris[29].positions[2] = vec3(0.555999935, -0.559199989, 0.548799932);
    tris[0].normal = vec3(0.0, 1.0, 0.0); tris[1].normal = vec3(0.301707575, -0.953400513, 0.0); tris[2].normal = vec3(0.0, 0.0, 1.0); tris[3].normal = vec3(-0.956165759, -0.292825958, -0.0); tris[4].normal = vec3(0.955649049, 0.294507888, 0.0); tris[5].normal = vec3(-0.956165759, -0.292825958, 0.0); tris[6].normal = vec3(0.301707575, -0.953400513, 0.0); tris[7].normal = vec3(-0.285119946, -0.958491845, 0.0); tris[8].normal = vec3(-0.285119946, -0.958491845, -0.0); tris[9].normal = vec3(0.953400053, -0.301709030, 0.0); tris[10].normal = vec3(-0.957826408, 0.287347476, 0.0); tris[11].normal = vec3(-0.957826408, 0.287347476, 0.0); tris[12].normal = vec3(0.0, 0.0, 1.0); tris[13].normal = vec3(0.292825408, 0.956165927, 0.000001554); tris[14].normal = vec3(0.953399906, -0.301709496, -0.000000490); tris[15].normal = vec3(0.292826874, 0.956165478, -0.0); tris[16].normal = vec3(1.0, 0.0, 0.0); tris[17].normal = vec3(0.0, 0.0, 1.0); tris[18].normal = vec3(0.0, 0.0, 1.0); tris[19].normal = vec3(-0.296209850, 0.955122885, 0.000000776); tris[20].normal = vec3(-0.296208371, 0.955123343, 0.0); tris[21].normal = vec3(0.955648909, 0.294508341, 0.000000239); tris[22].normal = vec3(-1.0, 0.0, -0.0); tris[23].normal = vec3(1.0, 0.0, 0.0); tris[24].normal = vec3(0.0, 0.0, -1.0); tris[25].normal = vec3(-0.0, 1.0, 0.0); tris[26].normal = vec3(0.0, 0.0, 1.0); tris[27].normal = vec3(-1.0, -0.0, 0.0); tris[28].normal = vec3(0.0, 0.0, 1.0); tris[29].normal = vec3(0.0, 0.0, -1.0);
    tris[0].color = vec3(0.874000013, 0.874000013, 0.875000000); tris[1].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[2].color = vec3(0.874000013, 0.874000013, 0.875000000); tris[3].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[4].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[5].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[6].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[7].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[8].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[9].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[10].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[11].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[12].color = vec3(0.874000013, 0.874000013, 0.875000000); tris[13].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[14].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[15].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[16].color = vec3(0.289999992, 0.663999975, 0.324999988); tris[17].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[18].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[19].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[20].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[21].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[22].color = vec3(0.730000019, 0.246000007, 0.250999987); tris[23].color = vec3(0.289999992, 0.663999975, 0.324999988); tris[24].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[25].color = vec3(0.874000013, 0.874000013, 0.875000000); tris[26].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[27].color = vec3(0.730000019, 0.246000007, 0.250999987); tris[28].color = vec3(0.839039981, 0.839039981, 0.839999974); tris[29].color = vec3(0.839039981, 0.839039981, 0.839999974);
    tris[0].emission = vec3(0.0, 0.0, 0.0); tris[1].emission = vec3(0.0, 0.0, 0.0); tris[2].emission = vec3(0.0, 0.0, 0.0); tris[3].emission = vec3(0.0, 0.0, 0.0); tris[4].emission = vec3(0.0, 0.0, 0.0); tris[5].emission = vec3(0.0, 0.0, 0.0); tris[6].emission = vec3(0.0, 0.0, 0.0); tris[7].emission = vec3(0.0, 0.0, 0.0); tris[8].emission = vec3(0.0, 0.0, 0.0); tris[9].emission = vec3(0.0, 0.0, 0.0); tris[10].emission = vec3(0.0, 0.0, 0.0); tris[11].emission = vec3(0.0, 0.0, 0.0); tris[12].emission = vec3(0.0, 0.0, 0.0); tris[13].emission = vec3(0.0, 0.0, 0.0); tris[14].emission = vec3(0.0, 0.0, 0.0); tris[15].emission = vec3(0.0, 0.0, 0.0); tris[16].emission = vec3(0.0, 0.0, 0.0); tris[17].emission = vec3(0.0, 0.0, 0.0); tris[18].emission = vec3(0.0, 0.0, 0.0); tris[19].emission = vec3(0.0, 0.0, 0.0); tris[20].emission = vec3(0.0, 0.0, 0.0); tris[21].emission = vec3(0.0, 0.0, 0.0); tris[22].emission = vec3(0.0, 0.0, 0.0); tris[23].emission = vec3(0.0, 0.0, 0.0); tris[24].emission = vec3(0.0, 0.0, 0.0); tris[25].emission = vec3(0.0, 0.0, 0.0); tris[26].emission = vec3(0.0, 0.0, 0.0); tris[27].emission = vec3(0.0, 0.0, 0.0); tris[28].emission = vec3(0.0, 0.0, 0.0); tris[29].emission = vec3(0.0, 0.0, 0.0);

    tris[30].positions[0] = vec3(0.15, -0.15, 0.545); tris[30].positions[1] = vec3(0.4, -0.35, 0.545); tris[30].positions[2] = vec3(0.15, -0.35, 0.545);
    tris[30].normal = vec3(0.0, 0.0, -1.0); 
    tris[30].color = vec3(0.0, 0.0, 0.0);
    tris[30].emission = vec3(3.0, 3.0, 3.0);

    tris[31].positions[0] = vec3(0.15, -0.15, 0.545); tris[31].positions[1] = vec3(0.4, -0.35, 0.545); tris[31].positions[2] = vec3(0.4, -0.15, 0.545);
    tris[31].normal = vec3(0.0, 0.0, -1.0); 
    tris[31].color = vec3(0.0, 0.0, 0.0);
    tris[31].emission = vec3(100.0, 100.0, 100.0);
    
    out_t = WORLD_MAX;
    vec3 out_intersection_point = vec3(0.0);
    
    for (int i = 0; i < TRIANGLE_COUNT; ++i)
    {
        float t;
        if (ray_triangle_intersection(origin, direction, tris[i], t, out_intersection_point)
            // get the nearest triangle.
            && t < out_t)
        {
            out_t = t;
            out_tri = tris[i];
        }
    }
    
    return out_t < WORLD_MAX;
}

vec3 get_ray_radiance(vec3 origin, vec3 direction, inout uvec2 seed) {
    vec3 radiance = vec3(0.0);
    vec3 throughput_weight = vec3(1.0);
    for (int i = 0; i != MAX_PATH_LENGTH; ++i) {
        float t;
        triangle_t tri;
        // if ray intersected any mesh.
        if (ray_mesh_intersection(t, tri, origin, direction)) {
            radiance += throughput_weight * tri.emission;
            // get the intersected point.
            origin += t * direction;
            // get a random direction from intersection point.
            direction = sample_hemisphere(get_random_numbers(seed), tri.normal);
            
            throughput_weight *= tri.color * 1.0 * dot(tri.normal, direction);
        } else
            break;     
        }

    return radiance;
}

// intel path tracing extercises.
void mainImage2(out vec4 out_color, in vec2 pixel_coord) {
    vec3 camera_position = vec3(0.278, 0.8, 0.2744);
    vec3 middle = camera_position - vec3(0.0, 0.8, 0.0);
    vec3 up = vec3(0.0, 0.0, 0.56);
    float aspect = float(iResolution.x) / float(iResolution.y);
    vec3 right = aspect * vec3(-0.56, 0.0, 0.0);
    vec3 left_bottom = middle - 0.5 * right - 0.5 * up;

    vec2 tex_coord = pixel_coord / iResolution.xy;
    vec3 ray_direction = get_primary_ray_direction(
        tex_coord.x, tex_coord.y, camera_position, left_bottom, right, up);
    
    triangle_t tri;
    float t;
    out_color = vec4(0.0, 0.0, 0.0, 1.0);
    
    uvec2 seed = uvec2(pixel_coord) ^ uvec2(iFrame << 16);
    
    vec3 color = vec3(0.0);
    for (int i = 0; i < SAMPLE_COUNT; ++i) {
        color += get_ray_radiance(camera_position, ray_direction, seed);
    }
    color /= float(SAMPLE_COUNT);
    
    vec3 prev_color = texture(iChannel0, tex_coord).rgb;
    float weight = 1.0 / float(iFrame + 1);
    
    out_color.rgb = (1.0 - weight) * prev_color + weight * color.rgb;
}


void mainImage(out vec4 out_color, in vec2 pixel_coord) {
    out_color = vec4(1., 0.0, 0.0, 1.0);
}