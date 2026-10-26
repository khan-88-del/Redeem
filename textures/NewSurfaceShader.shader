Shader "Custom/FFTerrainCompletePBR"
{
    Properties
    {
        // TERE BASE TEXTURES (Working!)
        _GrassTex ("🌿 Grass Texture", 2D) = "white" {}
        _RockTex ("🪨 Rock Texture", 2D) = "white" {}
        _SandTex ("🏜️ Sand Texture", 2D) = "white" {}
        _MaskTex ("🎯 RGB Mask", 2D) = "white" {}
        
        // BW SAND SYSTEM
        _BWMask ("⚫ BW Mask (Black=Beach Sand)", 2D) = "white" {}
        _BeachSandTex ("🏖️ Beach Sand Texture", 2D) = "white" {}
        
        // NEW SLOTS ADDED 🎯
        _LightmapShadow ("💡 Lightmap Shadow (allterrain_lightmap_shadow)", 2D) = "white" {}
        _ShadowBlob ("🌑 Character Shadow (TerrainCharaShadow)", 2D) = "black" {}
        
        // NORMAL MAPS
        _GrassNormal ("🌿 Grass Normal", 2D) = "bump" {}
        _RockNormal ("🪨 Rock Normal", 2D) = "bump" {}
        _SandNormal ("🏜️ Sand Normal", 2D) = "bump" {}
        _BeachNormal ("🏖️ Beach Sand Normal", 2D) = "bump" {}
        
        // PER-TEXTURE METALLIC STRENGTH (Naya!)
        _GrassMetallic ("🌿 Grass Metallic", Range(0,1)) = 0.0
        _RockMetallic ("🪨 Rock Metallic", Range(0,1)) = 0.3
        _SandMetallic ("🏜️ Sand Metallic", Range(0,1)) = 0.1
        _BeachMetallic ("🏖️ Beach Metallic", Range(0,1)) = 0.05
        
        // GLOBAL CONTROLS
        _NormalStrength ("🔧 Normal Strength", Range(0,2)) = 1.0
        _Smoothness ("✨ Global Smoothness", Range(0,1)) = 0.3
        _Tiling ("📏 Tiling", Vector) = (20,20,0,0)
        
        // SHADOW CONTROLS
        _ShadowStrength ("🌑 Shadow Strength", Range(0,1)) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _GrassTex, _RockTex, _SandTex, _MaskTex;
        sampler2D _BWMask, _BeachSandTex;
        sampler2D _LightmapShadow, _ShadowBlob;  // 🔥 NEW SAMPLERS
        sampler2D _GrassNormal, _RockNormal, _SandNormal, _BeachNormal;
        
        float4 _Tiling;
        float _NormalStrength;
        float _Smoothness;
        float _ShadowStrength;  // 🔥 NEW
        
        // PER-TEXTURE METALLIC
        float _GrassMetallic, _RockMetallic, _SandMetallic, _BeachMetallic;

        struct Input
        {
            float2 uv_GrassTex;
            float2 uv_RockTex;
            float2 uv_SandTex;
            float2 uv_MaskTex;
            float2 uv_LightmapShadow;  // 🔥 NEW UV
            float2 uv_ShadowBlob;      // 🔥 NEW UV
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // TERA PERFECT TILING
            float2 uvGrass = IN.uv_GrassTex * _Tiling.xy;
            float2 uvRock = IN.uv_RockTex * _Tiling.xy;
            float2 uvSand = IN.uv_SandTex * _Tiling.xy;
            float2 uvMask = IN.uv_MaskTex * _Tiling.xy;
            float2 uvLightmap = IN.uv_LightmapShadow * _Tiling.xy;  // 🔥
            float2 uvShadow = IN.uv_ShadowBlob * _Tiling.xy;        // 🔥

            // TEXTURES SAMPLE
            float4 grass = tex2D(_GrassTex, uvGrass);
            float4 rock = tex2D(_RockTex, uvRock);
            float4 sand = tex2D(_SandTex, uvSand);
            float4 mask = tex2D(_MaskTex, uvMask);

            // TERA RGB BLENDING
            float4 col = grass * mask.r + rock * mask.g + sand * mask.b;

            // BW SAND OVERLAY
            float bwMaskValue = tex2D(_BWMask, uvMask).r;
            float beachWeight = 1.0 - bwMaskValue;
            float4 beachSand = tex2D(_BeachSandTex, uvSand);
            col.rgb = lerp(col.rgb, beachSand.rgb, beachWeight);

            // 🔥 SHADOW SYSTEM (Lightmap + Character Shadows)
            float lightmapShadow = tex2D(_LightmapShadow, uvLightmap).r;
            float charaShadow = tex2D(_ShadowBlob, uvShadow).r;
            float totalShadow = min(lightmapShadow, charaShadow);  // Combine shadows
            col.rgb *= lerp(1.0, totalShadow, _ShadowStrength);    // Apply shadows

            // NORMAL BLENDING
            fixed3 grassN = UnpackNormal(tex2D(_GrassNormal, uvGrass));
            fixed3 rockN = UnpackNormal(tex2D(_RockNormal, uvRock));
            fixed3 sandN = UnpackNormal(tex2D(_SandNormal, uvSand));
            fixed3 beachN = UnpackNormal(tex2D(_BeachNormal, uvSand));

            fixed3 finalNormal = grassN * mask.r + 
                               rockN * mask.g + 
                               sandN * mask.b + 
                               beachN * beachWeight;

            // 🔥 BLENDED METALLIC (Per-texture!)
            float metallic = _GrassMetallic * mask.r +
                           _RockMetallic * mask.g + 
                           _SandMetallic * mask.b +
                           _BeachMetallic * beachWeight;

            o.Albedo = col.rgb;
            o.Normal = normalize(finalNormal) * _NormalStrength;
            o.Metallic = saturate(metallic);  // 0-1 clamp
            o.Smoothness = _Smoothness;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
