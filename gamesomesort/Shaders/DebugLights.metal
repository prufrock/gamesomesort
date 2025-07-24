//
//  BasicIndexedShaders.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
#import "Common.h"

using namespace metal;

struct VertexOut {
  float4 position [[position]];
  float point_size [[point_size]];
};

vertex VertexOut vertex_debug(
                              constant float3 *vertices [[buffer(0)]],
                              constant SHDRUniforms &uniforms [[buffer(UniformsBuffer)]],
                              uint id [[vertex_id]]
                              )
{
  matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
  VertexOut out {
    .position = mvp * float4(vertices[id], 1),
    .point_size = 25.0
  };
  return out;
}

fragment float4 fragment_debug_point(
                                     float2 point [[point_coord]],
                                     constant float3 &color [[buffer(1)]]
                                     )
{
  float d = distance(point, float2(0.5, 0.5));
  // turn the square point into a circle by discarding fragments greater than the value provided. The value ends up
  // working like a radius.
  if (d > 0.5) {
    discard_fragment();
  }
  return float4(color, 1);
}

fragment float4 fragment_debug_line(
                                    constant float3 &color [[buffer(1)]]
                                    )
{
  return float4(color, 1);
}
