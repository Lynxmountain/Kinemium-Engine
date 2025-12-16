#version 330

out vec4 fragColor;

void main()
{
    // Write the fragment depth directly
    // OpenGL automatically handles depth, but for color attachment we need to output it
    float depth = gl_FragCoord.z;
    fragColor = vec4(depth, depth, depth, 1.0);
}