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

struct GBufferOut {
  float4 albedo [[color(RenderTargetAlbedo)]];
  float4 normal [[color(RenderTargetNormal)]];
  float4 position [[color(RenderTargetPosition)]];
};

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

  float3 diffuseColor = computeDiffuse(lights, in.worldPosition, params, material, normal);

  float3 specularColor = computeSpecular(lights, params, material, normal);

  if(!is_null_texture(shadowTexture)) {
    float shadow = calculateShadow(in.shadowPosition, shadowTexture);
    diffuseColor *= shadow;
  }

  return float4(diffuseColor + specularColor, 1);
}

fragment GBufferOut tbr_fragment_gBuffer(
                                 VertexOut in [[stage_in]],
                                 depth2d<float> shadowTexture [[texture(ShadowTexture)]],
                                 constant SHDRMaterial &material [[buffer(MaterialBuffer)]],
                                 texture2d<float> baseColorTexture [[texture(BaseColor)]]
                                 )
{
  GBufferOut out;

  constexpr sampler textureSampler(
                                   filter::linear,
                                   mip_filter::linear,
                                   max_anisotropy(8),
                                   address::repeat
                                   );
  if (!is_null_texture(baseColorTexture)) {
    out.albedo = baseColorTexture.sample(textureSampler, in.uv).rgba;
  } else {
    out.albedo = float4(material.baseColor, 1.0);
  }

  // Figure out if the fragment is in shadow.
  // The alpha value of the albedo isn't used, so the shadow value can be stored there.
  out.albedo.a = calculateShadow(in.shadowPosition, shadowTexture);
  out.normal = float4(normalize(in.worldNormal), 1.0);
  out.position = float4(in.worldPosition, 1.0);

  return out;
}

// A quad to render to.
constant float3 quadVertices[6] = {
  float3(-1,  1,  0),
  float3( 1, -1,  0),
  float3(-1, -1,  0),
  float3(-1,  1,  0),
  float3( 1,  1,  0),
  float3( 1, -1,  0)
};

vertex VertexOut tbr_vertex_quad(uint vertexID [[vertex_id]]) {
  VertexOut out {
    .position = float4(quadVertices[vertexID], 1)
  };

  return out;
}

fragment float4 tbr_fragment_deferredSun(
                                     VertexOut in [[stage_in]],
                                     constant SHDRParams &params [[buffer(ParamsBuffer)]],
                                     constant SHDRLight *lights [[buffer(LightBuffer)]],
                                     texture2d<float> albedoTexture [[texture(BaseColor)]],
                                     texture2d<float> normalTexture [[texture(NormalTexture)]]
                                     ) {
  // read the textures at the current position of the fragment
  uint2 coord = uint2(in.position.xy);
  float4 albedo = albedoTexture.read(coord);
  float3 normal = normalTexture.read(coord).xyz;

  // create a simple material based on the texture
  SHDRMaterial material {
    .baseColor = albedo.xyz,
    .ambientOcclusion = 1.0
  };

  // calculate the sun light on the fragment
  float3 color = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    SHDRLight light = lights[i];
    color += calculateSun(light, normal, params, material);
  }
  // mix in the shadow that was stuffed into the alpha channel
  color *= albedo.a;
  return float4(color, 1);
}


struct PointLightIn {
  float4 position [[attribute(Position)]];
};

struct PointLightOut {
  float4 position [[position]];
  // don't interpolate the instanceId, so mark it as flat
  uint instanceId [[flat]];
};

vertex PointLightOut tbr_vertex_pointLight(
                                           PointLightIn in [[stage_in]],
                                           constant SHDRUniforms &uniforms [[buffer(UniformsBuffer)]],
                                           constant SHDRLight *lights [[buffer(LightBuffer)]],
                                           uint instanceId [[instance_id]]
                                           ) {
  // use the instanceId to find the light
  float4 lightPosition = float4(lights[instanceId].position, 0);
  // no scaling or rotation, so skip the model matrix
  float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * (in.position + lightPosition);

  PointLightOut out {
    .position = position,
    .instanceId = instanceId
  };
  return out;
}

fragment float4 tbr_fragment_pointLight(
                                    PointLightOut in [[stage_in]],
                                    constant SHDRParams &params [[buffer(ParamsBuffer)]],
                                    texture2d<float> normalTexture [[texture(NormalTexture)]],
                                    texture2d<float> positionTexture [[texture(PositionTexture)]],
                                    constant SHDRLight *lights [[buffer(LightBuffer)]]
                                    ) {
  uint2 coords = uint2(in.position.xy);
  float3 normal = normalTexture.read(coords).xyz;
  float3 worldPosition = positionTexture.read(coords).xyz;

  SHDRMaterial material {
    .baseColor = 1
  };

  SHDRLight light = lights[in.instanceId];
  float3 color = calculatePoint(
                                light,
                                worldPosition,
                                normal,
                                material
                                );
  // reduce the intensity a bit, because blending makes them brighter
  color *= 0.5;
  return float4(color, 1);
}
