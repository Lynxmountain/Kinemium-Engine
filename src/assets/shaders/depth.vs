#version 330

layout(location = 0) in vec3 vertexPosition;

uniform mat4 lightSpaceMatrix;
uniform mat4 matModel;
uniform int lightType;
uniform vec3 lightPos;
uniform float far_plane;

out float fragDepth;

void main()
{
    vec4 worldPos = matModel * vec4(vertexPosition, 1.0);
    fragDepth = length(worldPos.xyz - lightPos);
    gl_Position = lightSpaceMatrix * worldPos;
}
