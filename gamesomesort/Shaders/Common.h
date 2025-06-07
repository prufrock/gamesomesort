//
//  ShaderCommon.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

// Added for xcode 16, may change later
// https://forums.kodeco.com/t/xcode-16-errata-for-metal-by-tutorials-4th-edition/205784
typedef uint32_t uint;

typedef enum {
  VertexBuffer = 0,
  UVBuffer = 1,
  TangentBuffer = 2,
  BitangentBuffer = 3,
  ModelMatrixBuffer = 4,
  NormalMatrixBuffer = 5,
  EntityIdBuffer = 6,
  UniformsBuffer = 11,
  ParamsBuffer = 12,
  LightBuffer = 13,
  MaterialBuffer = 14,
  ColorBuffer = 20
} RNDRBufferIndices;

typedef enum {
  Position = 0,
  Normal = 1,
  UV = 2,
  Tangent = 3,
  Bitangent = 4
} RNDRAttributes;

typedef struct {
  // move from world space into camera space without the projection part.
  matrix_float4x4 viewMatrix;
  // move from camera space into clip space.
  matrix_float4x4 projectionMatrix;
} RNDRUniforms;

#endif
