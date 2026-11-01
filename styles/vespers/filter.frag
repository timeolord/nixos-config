#version 300 es
precision highp float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
const vec3 palette[16] = vec3[16](@palette@);
const bool ordered_dither = @dither@;
const float dither_pixel_size = 2.0;
const float dither_strength = 2.0;
const vec3 color_weights = vec3(0.299, 0.587, 0.114);
const int bayer[16] = int[16](
     0,  8,  2, 10,
    12,  4, 14,  6,
     3, 11,  1,  9,
    15,  7, 13,  5
);

void main() {
    vec3 source = texture(tex, v_texcoord).rgb;
    int first_index = 0;
    int second_index = 1;
    float best_distance = 4.0;
    float second_distance = 4.0;
    for (int index = 0; index < 16; ++index) {
        vec3 delta = source - palette[index];
        float distance_squared = dot(delta * delta, color_weights);
        if (distance_squared < best_distance) {
            second_distance = best_distance;
            second_index = first_index;
            best_distance = distance_squared;
            first_index = index;
        } else if (distance_squared < second_distance) {
            second_distance = distance_squared;
            second_index = index;
        }
    }
    vec3 selected = palette[first_index];
    if (ordered_dither) {
        vec3 first_color = palette[min(first_index, second_index)];
        vec3 second_color = palette[max(first_index, second_index)];
        vec3 segment = second_color - first_color;
        float blend_ratio = clamp(dot((source - first_color) * color_weights, segment)
            / max(dot(segment * color_weights, segment), 0.000001), 0.0, 1.0);
        float centered_ratio = blend_ratio * 2.0 - 1.0;
        blend_ratio = 0.5 + 0.5 * sign(centered_ratio) * pow(abs(centered_ratio), dither_strength);
        ivec2 pixel = ivec2(floor(gl_FragCoord.xy / dither_pixel_size)) % 4;
        float threshold = (float(bayer[pixel.y * 4 + pixel.x]) + 0.5) / 16.0;
        selected = blend_ratio > threshold ? second_color : first_color;
    }
    fragColor = vec4(selected, 1.0);
}
