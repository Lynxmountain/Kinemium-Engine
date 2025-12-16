// shadow.vs - FIXED
#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;

out vec2 fragTexCoord;
out vec3 fragNormal;
out vec3 fragPosition;
out vec4 fragPosLightSpace;

uniform mat4 matModel;
uniform mat4 matView;
uniform mat4 matProjection;
uniform mat4 lightSpaceMatrix;

void main()
{
    fragTexCoord = vertexTexCoord;
    
    // Transform normal by model matrix
    fragNormal = normalize(mat3(matModel) * vertexNormal);
    
    // World-space position
    vec4 worldPos = matModel * vec4(vertexPosition, 1.0);
    fragPosition = worldPos.xyz;
    
    // FIX: Transform WORLD position to light space, not model space
    fragPosLightSpace = lightSpaceMatrix * worldPos;  // Changed this line!
    
    // Final clip-space position
    gl_Position = matProjection * matView * worldPos;
}