//
//  BasicIndexedShaders.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#include <metal_stdlib>
using namespace metal;

#import "Common.h"

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_depth(
                           const VertexIn in [[stage_in]],
                           constant SHDRUniforms &uniforms [[buffer(UniformsBuffer)]]
                           ) {
  matrix_float4x4 mvp = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix;
  return mvp * in.position;
}

vertex float4 vertex_depth_instanced(
                                     const VertexIn in [[stage_in]],
                                     constant SHDRUniforms &uniforms [[buffer(UniformsBuffer)]],
                                     constant matrix_float4x4 *indexedModelMatrix [[buffer(ModelMatrixBuffer)]],
                                     uint iid [[instance_id]]
                                     ) {
  matrix_float4x4 mvp = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * indexedModelMatrix[iid];
  return mvp * in.position;
}
