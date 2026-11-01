#version 300 es
precision highp float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;
const vec3 palette[16] = vec3[16](@palette@);

void main() {
    vec3 source = texture(tex, v_texcoord).rgb;
    vec3 selected = palette[0];
    float best_distance = 4.0;
    for (int index = 0; index < 16; ++index) {
        vec3 delta = source - palette[index];
        float distance_squared = dot(delta * delta, vec3(0.299, 0.587, 0.114));
        if (distance_squared < best_distance) {
            best_distance = distance_squared;
            selected = palette[index];
        }
    }
    fragColor = vec4(selected, 1.0);
}
