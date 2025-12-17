#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec2 resolution;
uniform float blurRadius;

out vec4 finalColor;

void main()
{
    vec2 texelSize = 1.0 / resolution;
    vec4 result = vec4(0.0);
    float total = 0.0;
    
    // Box blur - simple but effective
    for (float x = -blurRadius; x <= blurRadius; x += 1.0)
    {
        for (float y = -blurRadius; y <= blurRadius; y += 1.0)
        {
            vec2 offset = vec2(x, y) * texelSize;
            result += texture(texture0, fragTexCoord + offset);
            total += 1.0;
        }
    }
    
    finalColor = (result / total) * fragColor;
}