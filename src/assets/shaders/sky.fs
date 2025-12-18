#version 330
uniform vec3 sunDirection;
uniform float sunHeight;
uniform float sunSize;
in vec3 fragPosition;
out vec4 fragColor;

void main() {
    vec3 viewDir = normalize(fragPosition);
    float up = clamp(dot(viewDir, vec3(0,1,0)), 0.0, 1.0);
    
    // Day/night colors
    vec3 dayTop = vec3(0.24, 0.47, 1.0);
    vec3 dayHorizon = vec3(0.67, 0.82, 1.0);
    vec3 nightTop = vec3(0.02, 0.04, 0.12);
    vec3 nightHorizon = vec3(0.08, 0.12, 0.24);
    
    float t = clamp(sunHeight * 0.5 + 0.5, 0.0, 1.0);
    vec3 top = mix(nightTop, dayTop, t);
    vec3 horizon = mix(nightHorizon, dayHorizon, t);
    vec3 sky = mix(horizon, top, up);
    
    // Sun
    float sunDot = max(dot(viewDir, sunDirection), 0.0);
    vec3 sun = vec3(1.0, 0.95, 0.8) * pow(sunDot, sunSize);
    
    fragColor = vec4(sky + sun, 1.0);
}