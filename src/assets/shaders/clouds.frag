#version 330 core

out vec4 fragColor;

uniform vec3 cameraPos;
uniform vec3 sunDir;
uniform vec3 sunColor;
uniform float time;
uniform vec2 iResolution;

uniform sampler2D cloudShadowMap;
uniform mat4 lightSpaceMatrix;

// simple hash noise
float hash(vec3 p){
    p = fract(p * 0.3183099 + vec3(0.1));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// cloud density
float map(vec3 p){
    vec3 cloudCenter = vec3(0.0, 3.0, 0.0); // center of cloud volume
    p -= cloudCenter;
    return clamp(1.5 - p.y + 1.75*hash(p*0.3), 0.0, 1.0);
}

// sample shadow map
float shadow(vec3 pos){
    vec4 lightPos = lightSpaceMatrix * vec4(pos, 1.0);
    lightPos.xyz /= lightPos.w;
    vec2 uv = lightPos.xy * 0.5 + 0.5;
    float depth = texture(cloudShadowMap, uv).r;
    return (lightPos.z > depth + 0.01) ? 0.0 : 1.0;
}

// raymarch the clouds
vec4 raymarch(vec3 ro, vec3 rd){
    vec4 sum = vec4(0.0);
    float t = 0.0;
    for(int i=0;i<100;i++){
        vec3 pos = ro + rd * t;
        float den = map(pos);
        if(den > 0.01){
            float dif = clamp((den - map(pos + 0.3*sunDir))/0.25,0.0,1.0);
            float sh = shadow(pos); // shadow factor
            vec3 lin = vec3(0.65,0.65,0.75)*1.1 + 0.8*sunColor*dif*sh;
            vec4 col = vec4(mix(vec3(1.0,0.93,0.84), vec3(0.25,0.3,0.4), den), den);
            col.xyz *= lin;
            col.w = min(col.w*0.1, 1.0);
            col.rgb *= col.a;
            sum += col * (1.0 - sum.a);
        }
        t += 0.02; // smaller step size for volume
        if(sum.a > 0.99) break;
    }
    return clamp(sum,0.0,1.0);
}

void main(){
    vec2 uv = (gl_FragCoord.xy / iResolution) * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;

    // simple camera forward ray
    vec3 ro = cameraPos;
    vec3 rd = normalize(vec3(uv, 1.5));

    fragColor = raymarch(ro, rd);
}
