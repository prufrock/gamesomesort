//
//  BasicIndexedShaders.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

float G1V(float nDotv, float k)
{
  return 1.0f / (nDotv * (1.0f - k) + k);
}

// http://filmicworlds.com/blog/optimizing-ggx-shaders-with-dotlh/
float3 computeSpecular(
                       constant SHDRLight *lights,
                       constant SHDRParams &params,
                       SHDRMaterial material,
                       float3 normal
                       ) {
  float3 viewDirection = normalize(params.cameraPosition);
  float3 specularTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    SHDRLight light = lights[i];
    // only sunlight for now
    if (light.type != Sun) {
      continue;
    }
    float3 lightDirection = normalize(light.position);
    float3 F0 = mix(0.04, material.baseColor, material.metallic);
    // a little bit of bias makes it so you can see some shine when there's zero roughness
    // adjusting this higher reduces some flickering on the surface of objects
    float bias = 0.9;
    float roughness = material.roughness + bias;
    float alpha = roughness * roughness;
    float3 halfVector = normalize(viewDirection + lightDirection);
    float nDotL = saturate(dot(normal, lightDirection));
    float nDotV = saturate(dot(normal, viewDirection));
    float nDotH = saturate(dot(normal, halfVector));
    float lDotH = saturate(dot(lightDirection, halfVector));

    float3 F;
    float D, vis;

    // Distribution
    float alphaSqr = alpha * alpha;
    float pi = 3.14159f;
    float denom = nDotH * nDotH * (alphaSqr - 1.0) + 1.0f;
    D = alphaSqr / (pi * denom * denom);

    // Fresnel
    float lDotH5 = pow(1.0 - lDotH, 5);
    F = F0 + (1.0 - F0) * lDotH5;

    // V
    float k = alpha / 2.0f;
    vis = G1V(nDotL, k) * G1V(nDotV, k);

    float3 specular = nDotL * D * F * vis;
    specularTotal += specular;
  }
  return specularTotal;
}

float3 computeDiffuse(
                      constant SHDRLight *lights,
                      float3 fragmentWorldPosition,
                      constant SHDRParams &params,
                      SHDRMaterial material,
                      float3 normal
                      )
{
  float3 diffuseTotal = 0;
  for (uint i = 0; i < params.lightCount; i++) {
    SHDRLight light = lights[i];
    switch (light.type) {
      case Sun: {
        diffuseTotal += calculateSun(light, normal, params, material);
        break;
      }
      case Point: {
        diffuseTotal += calculatePoint(light, fragmentWorldPosition, normal, material);
        break;
      }
      case Spot: {
        break;
      }
      case Ambient: {
        break;
      }
      case unused: {
        break;
      }
    }
  }
  return diffuseTotal;
}
