//
//  ShaderCommon.metal
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

#ifndef Lighting_h
#define Lighting_h

#import "Common.h"

// PBR functions
float3 computeSpecular(
                       constant SHDRLight *lights,
                       constant SHDRParams &params,
                       SHDRMaterial material,
                       float3 normal);

float3 computeDiffuse(
                      constant SHDRLight *lights,
                      constant SHDRParams &params,
                      SHDRMaterial material,
                      float3 normal);

#endif
