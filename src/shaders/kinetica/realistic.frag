#version 330

in vec3 fragPosition;
in vec2 fragTexCoord;
in vec3 fragNormal;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec3 viewPos;
uniform float time;
uniform vec3 globalAmbient;
uniform float brightness;
uniform vec3 dirLightDir;
uniform vec3 dirLightColor;
uniform int pointLightCount;
uniform struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
} pointLights[10];

// Volumetric fog uniforms
uniform float fogDensity;
uniform vec3 fogColor;
uniform float fogStart;
uniform float fogEnd;

out vec4 finalColor;

const float PI = 3.14159265359;

// Fresnel-Schlick approximation
vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// GGX/Trowbridge-Reitz normal distribution
float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;
    
    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
    
    return num / denom;
}

// Smith's Schlick-GGX geometry function
float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;
    
    float num = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    
    return num / denom;
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);
    
    return ggx1 * ggx2;
}

vec3 calculateLight(vec3 lightDir, vec3 lightColor, vec3 normal, vec3 viewDir, vec3 albedo, float metallic, float roughness, vec3 F0) {
    vec3 H = normalize(viewDir + lightDir);
    
    // Cook-Torrance BRDF
    float NDF = DistributionGGX(normal, H, roughness);
    float G = GeometrySmith(normal, viewDir, lightDir, roughness);
    vec3 F = fresnelSchlick(max(dot(H, viewDir), 0.0), F0);
    
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - metallic;
    
    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(normal, viewDir), 0.0) * max(dot(normal, lightDir), 0.0) + 0.0001;
    vec3 specular = numerator / denominator;
    
    float NdotL = max(dot(normal, lightDir), 0.0);
    return (kD * albedo / PI + specular) * lightColor * NdotL;
}

void main() {
    // Sample texture
    vec4 texelColor = texture(texture0, fragTexCoord);
    vec3 albedo = pow(texelColor.rgb, vec3(2.2)); // Convert to linear space
    
    // Material properties (you can make these uniforms later)
    float metallic = 0.0;  // 0 = dielectric, 1 = metal
    float roughness = 0.6; // 0 = smooth, 1 = rough
    float ao = 1.0;        // Ambient occlusion
    
    vec3 normal = normalize(fragNormal);
    vec3 viewDir = normalize(viewPos - fragPosition);
    
    // Base reflectivity for dielectrics (0.04) and metals (albedo color)
    vec3 F0 = vec3(0.04);
    F0 = mix(F0, albedo, metallic);
    
    // Ambient lighting (IBL approximation)
    vec3 ambient = globalAmbient * albedo * ao * brightness;
    
    vec3 Lo = vec3(0.0);
    
    // Directional light (sun)
    if (length(dirLightDir) > 0.01) {
        vec3 L = normalize(-dirLightDir);
        Lo += calculateLight(L, dirLightColor * brightness, normal, viewDir, albedo, metallic, roughness, F0);
    }
    
    // Point lights
    for (int i = 0; i < pointLightCount; i++) {
        vec3 L = normalize(pointLights[i].position - fragPosition);
        float distance = length(pointLights[i].position - fragPosition);
        
        // Realistic inverse square falloff
        float attenuation = pointLights[i].intensity / (distance * distance);
        vec3 radiance = pointLights[i].color * attenuation;
        
        Lo += calculateLight(L, radiance, normal, viewDir, albedo, metallic, roughness, F0);
    }
    
    vec3 color = ambient + Lo;
    
    // HDR tonemapping (Reinhard)
    color = color / (color + vec3(1.0));
    
    // Gamma correction
    color = pow(color, vec3(1.0/2.2));
    
    // Apply vertex color tint
    color *= fragColor.rgb;
    
    finalColor = vec4(color, texelColor.a * fragColor.a);
}