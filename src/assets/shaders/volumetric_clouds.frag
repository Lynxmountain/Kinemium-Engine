#version 330 core

uniform vec3 cameraPos;
uniform mat4 invProj;
uniform mat4 invView;
uniform vec3 sunDir;
uniform vec3 sunColor;
uniform float time;
uniform float cloudHeight;
uniform float cloudThickness;

in vec2 fragTexCoord;
out vec4 fragColor;

// Noise functions
float hash(float n) { return fract(sin(n) * 43758.5453); }
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    return mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                   mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    p += time * 0.01;
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

vec3 reconstructWorldPos(float depth, vec2 uv) {
    vec4 ndc = vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 worldPos = invProj * ndc;
    worldPos /= worldPos.w;
    return (invView * worldPos).xyz;
}

void main() {
    vec3 worldPos = reconstructWorldPos(1.0, fragTexCoord);
    vec3 rayDir = normalize(worldPos - cameraPos);
    
    float tMin = (cloudHeight - cameraPos.y) / rayDir.y;
    float tMax = (cloudHeight + cloudThickness - cameraPos.y) / rayDir.y;
    if (tMin > tMax) {
        float temp = tMin;
        tMin = tMax;
        tMax = temp;
    }
    tMin = max(tMin, 0.0);
    
    if (tMin >= tMax) {
        fragColor = vec4(0.0);
        return;
    }
    
    const int steps = 64;
    float stepSize = (tMax - tMin) / float(steps);
    vec3 color = vec3(0.0);
    float transmittance = 1.0;
    
    for (int i = 0; i < steps; i++) {
        float t = tMin + float(i) * stepSize;
        vec3 pos = cameraPos + rayDir * t;
        
        float density = fbm(pos * 0.001) * smoothstep(cloudHeight, cloudHeight + cloudThickness, pos.y);
        if (density > 0.1) {
            float lightDensity = fbm(pos * 0.001 + sunDir * 100.0);
            vec3 light = sunColor * exp(-lightDensity * 0.5);
            
            color += light * density * transmittance * stepSize;
            transmittance *= exp(-density * stepSize);
        }
    }
    
    fragColor = vec4(color, 1.0 - transmittance);
}