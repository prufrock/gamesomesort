//
//  Lighting.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

float3 calculateSun(
                    SHDRLight light,
                    float3 normal,
                    SHDRParams params,
                    SHDRMaterial material
                    )
{
    float3 lightDirection = normalize(light.position);
    float nDotL = saturate(dot(normal, lightDirection));
    float3 diffuse = float3(material.baseColor) * (1.0 - material.metallic);
    return diffuse * nDotL * material.ambientOcclusion * light.color;
}

float3 calculatePoint(
                      SHDRLight light,
                      float3 fragmentWorldPosition,
                      float3 normal,
                      SHDRMaterial material
                      )
{
    float d = distance(light.position, fragmentWorldPosition);
    float3 lightDirection = normalize(light.position - fragmentWorldPosition);

    float attentuation = 1.0 /
    (light.attenuation.x + light.attenuation.y * d + light.attenuation.z * d * d);
    float diffuseIntensity = saturate(dot(normal, lightDirection));
    float3 color = light.color * material.baseColor * diffuseIntensity;
    color *= attentuation;
    if (color.r + color.g + color.b < 0.01) {
        color = 0;
    }
    return color;
}

float calculateShadow(
                      float4 shadowPosition,
                      depth2d<float> shadowTexture
                      )
{
    float3 position = shadowPosition.xyz / shadowPosition.w;
    float2 xy = position.xy;
    xy = xy * 0.5 + 0.5;
    xy.y = 1 - xy.y;
    constexpr sampler s(
                        coord::normalized,
                        filter::nearest,
                        address::clamp_to_edge,
                        compare_func::less
                        );
    float shadow_sample = shadowTexture.sample(s, xy);
    return (position.z > shadow_sample + 0.001) ? 0.5 : 1;
}
