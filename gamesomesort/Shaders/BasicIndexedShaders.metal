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

struct RNDRVertexIn
{
  float3 position [[attribute(Position)]];
};

struct RNDRVertexOut {
  float4 position [[position]];
  float point_size [[point_size]];
};

vertex RNDRVertexOut indexed_main(
                                  RNDRVertexIn in [[stage_in]],
                                  constant RNDRUniforms &uniforms [[buffer(UniformsBuffer)]],
                                  constant matrix_float4x4 *indexedModelMatrix [[buffer(ModelMatrixBuffer)]],
                                  uint vid [[vertex_id]],
                                  uint iid [[instance_id]]
                                  )
{
  RNDRVertexOut vertex_out {
    .position = uniforms.projectionMatrix * uniforms.viewMatrix * indexedModelMatrix[iid] * float4(in.position, 1),
    .point_size = 20.0
  };

  return vertex_out;
}

fragment float4 fragment_main(constant float4 &color [[buffer(0)]]) {
  return color;
}
