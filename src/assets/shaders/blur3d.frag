#version 330 core

in vec2 fragTexCoord;
out vec4 finalColor;

uniform sampler2D texture0;
uniform vec2 resolution;
uniform vec2 direction;
uniform float blurRadius;

void main()
{
    vec2 texel = direction * blurRadius / resolution;

    vec4 color = texture(texture0, fragTexCoord) * 0.227027;

    color += texture(texture0, fragTexCoord + texel * 1.384615) * 0.316216;
    color += texture(texture0, fragTexCoord - texel * 1.384615) * 0.316216;

    color += texture(texture0, fragTexCoord + texel * 3.230769) * 0.070270;
    color += texture(texture0, fragTexCoord - texel * 3.230769) * 0.070270;

    finalColor = color;
}
