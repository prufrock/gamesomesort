//
//  Lighting.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

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
