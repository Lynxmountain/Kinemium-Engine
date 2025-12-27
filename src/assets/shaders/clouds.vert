#version 330 core

layout(location = 0) in vec3 vertexPosition; // mesh vertex
layout(location = 1) in vec3 vertexNormal;
layout(location = 2) in vec2 vertexTexCoord;

uniform mat4 mvp;

out vec3 fragPos; // world position for raymarch
out vec3 fragNormal;

void main() {
    fragPos = vertexPosition; // assume cube is scaled & translated by model matrix
    fragNormal = vertexNormal;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
