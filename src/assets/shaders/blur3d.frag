#version 330 core

in vec2 fragTexCoord;
out vec4 finalColor;

uniform sampler2D texture0;
uniform vec2 resolution;   // Texture size in pixels
uniform vec2 direction;    // Blur direction (e.g., vec2(1,0) horizontal)
uniform float blurRadius;  // Multiplier for distance between samples

const int KERNEL_SIZE = 9;

// Precomputed Gaussian weights for 9-tap blur
const float weights[KERNEL_SIZE] = float[](
    0.19648255,  // center
    0.29690696,
    0.09448926,
    0.01038184,
    0.00386503,
    0.00135263,
    0.00042953,
    0.00012239,
    0.00003166
);

void main() {
    vec2 texelSize = 1.0 / resolution;
    vec4 color = vec4(0.0);

    // Center sample
    color += texture(texture0, fragTexCoord) * weights[0];

    // Sample along the blur direction
    for (int i = 1; i < KERNEL_SIZE; ++i) {
        vec2 offset = direction * texelSize * float(i) * blurRadius;
        color += texture(texture0, fragTexCoord + offset) * weights[i];
        color += texture(texture0, fragTexCoord - offset) * weights[i];
    }

    finalColor = color;
}
