#include "./common.glsl"
#iChannel0 "file://./taa.glsl"

void mainImage(out vec4 out_color, in vec2 pixel_coord) {
    out_color = texture(iChannel0, pixel_coord / iResolution.xy);
    out_color.rgb = aces_tonemapping(out_color.rgb);
    out_color.rgb = linear_to_srgb(out_color.rgb);
}
