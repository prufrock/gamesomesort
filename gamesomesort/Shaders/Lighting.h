//
//  ShaderCommon.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

float calculateShadow(
                      float4 shadowPosition,
                      depth2d<float> shadowTexture
                      );

float3 calculateSun(
                    SHDRLight light,
                    float3 normal,
                    SHDRParams params,
                    SHDRMaterial material
                    );

float3 calculatePoint(
                      SHDRLight light,
                      float3 fragmentWorldPosition,
                      float3 normal,
                      SHDRMaterial material
                      );

// PBR functions
float3 computeSpecular(
                       constant SHDRLight *lights,
                       constant SHDRParams &params,
                       SHDRMaterial material,
                       float3 normal);

float3 computeDiffuse(
                      constant SHDRLight *lights,
                      float3 fragmentWorldPosition,
                      constant SHDRParams &params,
                      SHDRMaterial material,
                      float3 normal);

#endif
