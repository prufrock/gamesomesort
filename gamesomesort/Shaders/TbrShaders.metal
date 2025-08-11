//
//  TBRShaders.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 7/18/25.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#import "Common.h"
#import "Lighting.h"

struct VertexIn {
  float4 position [[attribute(Position)]];
  float3 normal [[attribute(Normal)]];
  float2 uv [[attribute(UV)]];
  float3 tangent [[attribute(Tangent)]];
  float3 bitangent [[attribute(Bitangent)]];
};

struct VertexOut {
  float4 position [[position]];
  float3 normal;
  float2 uv;
  float3 worldPosition;
  float3 worldNormal;
  float3 worldTangent;
  float3 worldBitangent;
  float4 shadowPosition;
};

vertex VertexOut tbr_vertex_main(
                                 VertexIn in [[stage_in]],
                                 constant SHDRUniforms &uniforms [[buffer(UniformsBuffer)]]
                                 )
{
  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
  float4 worldPosition = uniforms.modelMatrix * in.position;
  VertexOut out {
    .position = position,
    .normal = in.normal,
    .uv = in.uv,
    .worldPosition = worldPosition.xyz / worldPosition.w,
    .worldNormal = uniforms.normalMatrix * in.normal,
    .worldTangent = uniforms.normalMatrix * in.tangent,
    .worldBitangent = uniforms.normalMatrix * in.bitangent,
    .shadowPosition = uniforms.shadowProjectionMatrix * uniforms.shadowViewMatrix * uniforms.modelMatrix * in.position
  };
  return out;
}

fragment float4 tbr_fragment_main(
                              constant SHDRParams &params [[buffer(ParamsBuffer)]],
                              VertexOut in [[stage_in]],
                              constant SHDRLight *lights [[buffer(LightBuffer)]],
                              constant SHDRMaterial &_material [[buffer(MaterialBuffer)]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              texture2d<float> normalTexture [[texture(NormalTexture)]],
                              texture2d<float> roughnessTexture [[texture(RoughnessTexture)]],
                              texture2d<float> metallicTexture [[texture(MetallicTexture)]],
                              texture2d<float> aoTexture [[texture(AOTexture)]],
                              depth2d<float> shadowTexture [[texture(ShadowTexture)]]
                              )
{
  SHDRMaterial material = _material;
  constexpr sampler textureSampler(
                                   filter::linear,
                                   mip_filter::linear,
                                   max_anisotropy(8),
                                   address::repeat
                                   );
  if (!is_null_texture(baseColorTexture)) {
    material.baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
  }

  if (!is_null_texture(roughnessTexture)) {
    material.roughness = roughnessTexture.sample(textureSampler, in.uv * params.tiling).r;
  }

  if (!is_null_texture(metallicTexture)) {
    material.metallic = metallicTexture.sample(textureSampler, in.uv * params.tiling).r;
  }

  if (!is_null_texture(aoTexture)) {
    material.ambientOcclusion = aoTexture.sample(textureSampler, in.uv * params.tiling).r;
  }

  float3 normal;
  if (is_null_texture(normalTexture)) {
    normal = in.worldNormal;
  } else {
    normal = normalTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    normal = normal * 2 - 1;
    normal = float3x3(in.worldTangent, in.worldBitangent, in.worldNormal) * normal;
  }
  normal = normalize(normal);

  float3 diffuseColor = computeDiffuse(lights, params, material, normal);

  float3 specularColor = computeSpecular(lights, params, material, normal);

  if(!is_null_texture(shadowTexture)) {
    float shadow = calculateShadow(in.shadowPosition, shadowTexture);
    diffuseColor *= shadow;
  }

  return float4(diffuseColor + specularColor, 1);
}
