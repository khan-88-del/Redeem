//////////////////////////////////////////
//
// NOTE: This is *not* a valid shader file
//
///////////////////////////////////////////
Shader "BRMobile/Terrain/RoadSnow" {
Properties {
[Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 1
[Enum(One, 1, SrcAlpha, 5)] _SourceBlend ("Source Blend Mode", Float) = 1
[Enum(Zero, 0, OneMinusSrcAlpha, 10)] _DestBlend ("Dest Blend Mode", Float) = 0
[Space(20)] _MainTex ("Base (RGB) Trans (A)", 2D) = "white" { }
_Lightmap ("LightMap", 2D) = "white" { }
[NoScaleOffset] _ShadowBlob ("ShadowBlob", 2D) = "white" { }
}
SubShader {
 LOD 300
 Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "AlphaTest" "RenderType" = "Transparent" }
 Pass {
  LOD 300
  Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "AlphaTest" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
  Blend Zero Zero, Zero Zero
  ZWrite Off
  GpuProgramID 29465
Program "vp" {
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" }
"// hash: 3d8318ec48d8f954
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
#define SV_Target0 gl_FragData[0]
lowp vec3 u_xlat10_0;
lowp vec4 u_xlat10_1;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat10_1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    SV_Target0.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    SV_Target0.w = u_xlat10_1.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" }
"// hash: 3d8318ec48d8f954
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
#define SV_Target0 gl_FragData[0]
lowp vec3 u_xlat10_0;
lowp vec4 u_xlat10_1;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat10_1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    SV_Target0.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    SV_Target0.w = u_xlat10_1.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" }
"// hash: 3d8318ec48d8f954
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
#define SV_Target0 gl_FragData[0]
lowp vec3 u_xlat10_0;
lowp vec4 u_xlat10_1;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat10_1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    SV_Target0.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    SV_Target0.w = u_xlat10_1.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: 9eb4eda0ad8de6c0
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: 9eb4eda0ad8de6c0
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: 9eb4eda0ad8de6c0
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
"// hash: 6c6fbb74f1746697
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
float u_xlat0;
vec4 u_xlat1;
vec3 u_xlat2;
lowp vec3 u_xlat10_2;
void main()
{
    u_xlat0 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat0 = clamp(u_xlat0, 0.0, 1.0);
    u_xlat10_2.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat2.xyz = u_xlat1.xyz * u_xlat10_2.xyz + (-unity_FogColor.xyz);
    u_xlat1.xyz = vec3(u_xlat0) * u_xlat2.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
"// hash: 6c6fbb74f1746697
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
float u_xlat0;
vec4 u_xlat1;
vec3 u_xlat2;
lowp vec3 u_xlat10_2;
void main()
{
    u_xlat0 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat0 = clamp(u_xlat0, 0.0, 1.0);
    u_xlat10_2.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat2.xyz = u_xlat1.xyz * u_xlat10_2.xyz + (-unity_FogColor.xyz);
    u_xlat1.xyz = vec3(u_xlat0) * u_xlat2.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
"// hash: 6c6fbb74f1746697
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
float u_xlat0;
vec4 u_xlat1;
vec3 u_xlat2;
lowp vec3 u_xlat10_2;
void main()
{
    u_xlat0 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat0 = clamp(u_xlat0, 0.0, 1.0);
    u_xlat10_2.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat2.xyz = u_xlat1.xyz * u_xlat10_2.xyz + (-unity_FogColor.xyz);
    u_xlat1.xyz = vec3(u_xlat0) * u_xlat2.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
"// hash: 9e09957c26e2bd06
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
"// hash: 9e09957c26e2bd06
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
"// hash: 9e09957c26e2bd06
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
bvec3 u_xlatb7;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
"// hash: f236e12c3d95c652
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
#define SV_Target0 gl_FragData[0]
vec3 u_xlat0;
lowp vec4 u_xlat10_0;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
float u_xlat5;
float u_xlat8;
bool u_xlatb8;
mediump float u_xlat16_14;
void main()
{
    u_xlat10_0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    u_xlat0.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat8 = dot(u_xlat0.xy, u_xlat0.xy);
    u_xlatb8 = u_xlat8<1.5;
    if(u_xlatb8){
        u_xlat0.xy = u_xlat0.xy + vec2(1.0, 1.0);
        u_xlat0.xy = u_xlat0.xy * vec2(0.5, 0.5);
        u_xlat10_0.xyz = texture2D(_ShadowBlob, u_xlat0.xy).xyz;
        u_xlat5 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat5 = clamp(u_xlat5, 0.0, 1.0);
        u_xlat16_3.xyz = (-u_xlat10_0.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat0.xyz = vec3(u_xlat5) * u_xlat16_3.xyz + u_xlat10_0.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat0.xyz = u_xlat0.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat0.xyz = vec3(u_xlat16_14) * u_xlat0.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat0.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    SV_Target0.xyz = u_xlat16_2.xyz;
    SV_Target0.w = u_xlat10_0.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
"// hash: f236e12c3d95c652
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
#define SV_Target0 gl_FragData[0]
vec3 u_xlat0;
lowp vec4 u_xlat10_0;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
float u_xlat5;
float u_xlat8;
bool u_xlatb8;
mediump float u_xlat16_14;
void main()
{
    u_xlat10_0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    u_xlat0.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat8 = dot(u_xlat0.xy, u_xlat0.xy);
    u_xlatb8 = u_xlat8<1.5;
    if(u_xlatb8){
        u_xlat0.xy = u_xlat0.xy + vec2(1.0, 1.0);
        u_xlat0.xy = u_xlat0.xy * vec2(0.5, 0.5);
        u_xlat10_0.xyz = texture2D(_ShadowBlob, u_xlat0.xy).xyz;
        u_xlat5 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat5 = clamp(u_xlat5, 0.0, 1.0);
        u_xlat16_3.xyz = (-u_xlat10_0.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat0.xyz = vec3(u_xlat5) * u_xlat16_3.xyz + u_xlat10_0.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat0.xyz = u_xlat0.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat0.xyz = vec3(u_xlat16_14) * u_xlat0.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat0.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    SV_Target0.xyz = u_xlat16_2.xyz;
    SV_Target0.w = u_xlat10_0.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
"// hash: f236e12c3d95c652
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
#define SV_Target0 gl_FragData[0]
vec3 u_xlat0;
lowp vec4 u_xlat10_0;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
mediump vec3 u_xlat16_3;
float u_xlat5;
float u_xlat8;
bool u_xlatb8;
mediump float u_xlat16_14;
void main()
{
    u_xlat10_0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat10_1.xyz;
    u_xlat0.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat8 = dot(u_xlat0.xy, u_xlat0.xy);
    u_xlatb8 = u_xlat8<1.5;
    if(u_xlatb8){
        u_xlat0.xy = u_xlat0.xy + vec2(1.0, 1.0);
        u_xlat0.xy = u_xlat0.xy * vec2(0.5, 0.5);
        u_xlat10_0.xyz = texture2D(_ShadowBlob, u_xlat0.xy).xyz;
        u_xlat5 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat5 = clamp(u_xlat5, 0.0, 1.0);
        u_xlat16_3.xyz = (-u_xlat10_0.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat0.xyz = vec3(u_xlat5) * u_xlat16_3.xyz + u_xlat10_0.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat0.xyz = u_xlat0.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat0.xyz = vec3(u_xlat16_14) * u_xlat0.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat0.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    SV_Target0.xyz = u_xlat16_2.xyz;
    SV_Target0.w = u_xlat10_0.w;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
"// hash: c3ecad5c1dc82f3b
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
"// hash: c3ecad5c1dc82f3b
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
"// hash: c3ecad5c1dc82f3b
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    gl_Position = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat0.xyz = u_xlat16_1.xyz * u_xlat16_2.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 381e441917614460
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
float u_xlat3;
vec3 u_xlat5;
mediump vec3 u_xlat16_5;
lowp vec3 u_xlat10_5;
mediump vec3 u_xlat16_7;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_14;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat5.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat13 = dot(u_xlat5.xy, u_xlat5.xy);
    u_xlatb13 = u_xlat13<1.5;
    if(u_xlatb13){
        u_xlat5.xy = u_xlat5.xy + vec2(1.0, 1.0);
        u_xlat5.xy = u_xlat5.xy * vec2(0.5, 0.5);
        u_xlat10_5.xyz = texture2D(_ShadowBlob, u_xlat5.xy).xyz;
        u_xlat3 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3 = clamp(u_xlat3, 0.0, 1.0);
        u_xlat16_7.xyz = (-u_xlat10_5.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat5.xyz = vec3(u_xlat3) * u_xlat16_7.xyz + u_xlat10_5.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat1.xyz = u_xlat5.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_14) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlat1.x = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
    u_xlat16_5.xyz = u_xlat16_2.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = u_xlat1.xxx * u_xlat16_5.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 381e441917614460
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
float u_xlat3;
vec3 u_xlat5;
mediump vec3 u_xlat16_5;
lowp vec3 u_xlat10_5;
mediump vec3 u_xlat16_7;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_14;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat5.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat13 = dot(u_xlat5.xy, u_xlat5.xy);
    u_xlatb13 = u_xlat13<1.5;
    if(u_xlatb13){
        u_xlat5.xy = u_xlat5.xy + vec2(1.0, 1.0);
        u_xlat5.xy = u_xlat5.xy * vec2(0.5, 0.5);
        u_xlat10_5.xyz = texture2D(_ShadowBlob, u_xlat5.xy).xyz;
        u_xlat3 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3 = clamp(u_xlat3, 0.0, 1.0);
        u_xlat16_7.xyz = (-u_xlat10_5.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat5.xyz = vec3(u_xlat3) * u_xlat16_7.xyz + u_xlat10_5.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat1.xyz = u_xlat5.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_14) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlat1.x = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
    u_xlat16_5.xyz = u_xlat16_2.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = u_xlat1.xxx * u_xlat16_5.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 381e441917614460
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    vs_TEXCOORD2 = u_xlat0.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump vec4 unity_FogColor;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
lowp vec3 u_xlat10_1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
float u_xlat3;
vec3 u_xlat5;
mediump vec3 u_xlat16_5;
lowp vec3 u_xlat10_5;
mediump vec3 u_xlat16_7;
float u_xlat13;
bool u_xlatb13;
mediump float u_xlat16_14;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat5.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat13 = dot(u_xlat5.xy, u_xlat5.xy);
    u_xlatb13 = u_xlat13<1.5;
    if(u_xlatb13){
        u_xlat5.xy = u_xlat5.xy + vec2(1.0, 1.0);
        u_xlat5.xy = u_xlat5.xy * vec2(0.5, 0.5);
        u_xlat10_5.xyz = texture2D(_ShadowBlob, u_xlat5.xy).xyz;
        u_xlat3 = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3 = clamp(u_xlat3, 0.0, 1.0);
        u_xlat16_7.xyz = (-u_xlat10_5.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat5.xyz = vec3(u_xlat3) * u_xlat16_7.xyz + u_xlat10_5.xyz;
        u_xlat16_14 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_14 = clamp(u_xlat16_14, 0.0, 1.0);
        u_xlat1.xyz = u_xlat5.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_14) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlat1.x = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat1.x = clamp(u_xlat1.x, 0.0, 1.0);
    u_xlat16_5.xyz = u_xlat16_2.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = u_xlat1.xxx * u_xlat16_5.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 277e996e4d4f02c5
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 277e996e4d4f02c5
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
"// hash: 277e996e4d4f02c5
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform 	vec4 unity_FogParams;
uniform 	vec4 hlslcc_mtx4x4_CustomShadowMatrix[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD3;
varying highp vec4 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
vec4 u_xlat2;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    u_xlat2 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat2;
    u_xlat2 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat2;
    u_xlat1 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat2;
    gl_Position = u_xlat1;
    vs_TEXCOORD2 = u_xlat1.z * unity_FogParams.z + unity_FogParams.w;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[3] * in_POSITION0.wwww + u_xlat0;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4unity_WorldToShadow[1];
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4unity_WorldToShadow[2] * u_xlat0.zzzz + u_xlat1;
    vs_TEXCOORD3 = hlslcc_mtx4x4unity_WorldToShadow[3] * u_xlat0.wwww + u_xlat1;
    u_xlat1 = u_xlat0.yyyy * hlslcc_mtx4x4_CustomShadowMatrix[1];
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[0] * u_xlat0.xxxx + u_xlat1;
    u_xlat1 = hlslcc_mtx4x4_CustomShadowMatrix[2] * u_xlat0.zzzz + u_xlat1;
    u_xlat0 = hlslcc_mtx4x4_CustomShadowMatrix[3] * u_xlat0.wwww + u_xlat1;
    vs_TEXCOORD4 = u_xlat0 * vec4(0.5, 0.5, -0.5, 1.0) + vec4(0.5, 0.5, 0.5, 0.0);
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	vec3 _WorldSpaceCameraPos;
uniform 	vec4 hlslcc_mtx4x4unity_WorldToShadow[16];
uniform 	mediump vec4 _LightShadowData;
uniform 	vec4 unity_ShadowFadeCenterAndType;
uniform 	vec4 hlslcc_mtx4x4unity_MatrixV[4];
uniform 	mediump vec4 unity_FogColor;
uniform 	mediump float _WeatherDarkness;
uniform 	vec3 _LocalPlayerPos;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
uniform lowp sampler2D _ShadowBlob;
uniform lowp sampler2D _CustomShadowMap;
uniform highp sampler2D _ShadowMapTexture;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying highp float vs_TEXCOORD2;
varying highp vec4 vs_TEXCOORD4;
#define SV_Target0 gl_FragData[0]
vec4 u_xlat0;
vec3 u_xlat1;
mediump vec3 u_xlat16_1;
lowp vec3 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
mediump vec3 u_xlat16_2;
vec4 u_xlat3;
lowp vec4 u_xlat10_3;
bvec3 u_xlatb3;
lowp vec4 u_xlat10_4;
mediump float u_xlat16_5;
vec3 u_xlat7;
mediump vec3 u_xlat16_7;
lowp vec3 u_xlat10_7;
bvec3 u_xlatb7;
mediump vec3 u_xlat16_9;
mediump float u_xlat16_11;
float u_xlat13;
bool u_xlatb13;
float u_xlat19;
bool u_xlatb19;
mediump float u_xlat16_20;
void main()
{
    u_xlat0 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat10_1.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat16_2.xyz = u_xlat0.xyz * u_xlat10_1.xyz;
    u_xlat7.xy = vs_TEXCOORD1.xz + (-_LocalPlayerPos.xz);
    u_xlat19 = dot(u_xlat7.xy, u_xlat7.xy);
    u_xlatb19 = u_xlat19<1.5;
    if(u_xlatb19){
        u_xlat7.xy = u_xlat7.xy + vec2(1.0, 1.0);
        u_xlat7.xy = u_xlat7.xy * vec2(0.5, 0.5);
        u_xlat10_7.xyz = texture2D(_ShadowBlob, u_xlat7.xy).xyz;
        u_xlat3.x = (-vs_TEXCOORD1.y) + _LocalPlayerPos.y;
        u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0);
        u_xlat16_9.xyz = (-u_xlat10_7.xyz) + vec3(1.0, 1.0, 1.0);
        u_xlat7.xyz = u_xlat3.xxx * u_xlat16_9.xyz + u_xlat10_7.xyz;
        u_xlat16_20 = u_xlat10_1.x * 5.0 + -1.39999998;
        u_xlat16_20 = clamp(u_xlat16_20, 0.0, 1.0);
        u_xlat1.xyz = u_xlat7.xyz + vec3(-1.0, -1.0, -1.0);
        u_xlat1.xyz = vec3(u_xlat16_20) * u_xlat1.xyz + vec3(1.0, 1.0, 1.0);
        u_xlat2.xyz = u_xlat1.xyz * u_xlat16_2.xyz;
        u_xlat16_2.xyz = u_xlat2.xyz;
    //ENDIF
    }
    u_xlatb1 = 0.0<vs_TEXCOORD4.w;
    u_xlatb7.xyz = greaterThanEqual(vs_TEXCOORD4.xyzz, vec4(0.0, 0.0, 0.0, 0.0)).xyz;
    u_xlatb1 = u_xlatb7.x && u_xlatb1;
    u_xlatb3.xyz = greaterThanEqual(vec4(1.0, 1.0, 1.0, 0.0), vs_TEXCOORD4.xyzx).xyz;
    u_xlatb1 = u_xlatb1 && u_xlatb3.x;
    u_xlatb1 = u_xlatb7.y && u_xlatb1;
    u_xlatb1 = u_xlatb3.y && u_xlatb1;
    u_xlatb1 = u_xlatb7.z && u_xlatb1;
    u_xlatb1 = u_xlatb3.z && u_xlatb1;
    if(u_xlatb1){
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(-0.000976999989, 0.0, 0.0);
        u_xlat10_3 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_3, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.x = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.000976999989, 0.0, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.y = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, -0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.z = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat7.xyz = vs_TEXCOORD4.xyz + vec3(0.0, 0.000976999989, 0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, u_xlat7.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = (-u_xlat7.z) + u_xlat16_7.x;
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat3.w = u_xlatb7.x ? 1.0 : float(0.0);
        u_xlat10_4 = texture2D(_CustomShadowMap, vs_TEXCOORD4.xy);
        u_xlat16_7.x = dot(u_xlat10_4, vec4(1.0, 0.00392156886, 1.53787005e-05, 6.03086292e-08));
        u_xlat7.x = u_xlat16_7.x + (-vs_TEXCOORD4.z);
        u_xlatb7.x = u_xlat7.x<0.000199999995;
        u_xlat7.x = u_xlatb7.x ? 0.400000006 : float(0.0);
        u_xlat16_20 = dot(u_xlat3, vec4(0.200000003, 0.200000003, 0.200000003, 0.200000003));
        u_xlat16_20 = u_xlat7.x + u_xlat16_20;
        u_xlat16_20 = min(u_xlat16_20, 1.0);
    } else {
        u_xlat16_20 = 1.0;
    //ENDIF
    }
    u_xlat7.xyz = (-vs_TEXCOORD1.xyz) + _WorldSpaceCameraPos.xyz;
    u_xlat3.x = hlslcc_mtx4x4unity_MatrixV[0].z;
    u_xlat3.y = hlslcc_mtx4x4unity_MatrixV[1].z;
    u_xlat3.z = hlslcc_mtx4x4unity_MatrixV[2].z;
    u_xlat7.x = dot(u_xlat7.xyz, u_xlat3.xyz);
    u_xlat3.xyz = vs_TEXCOORD1.xyz + (-unity_ShadowFadeCenterAndType.xyz);
    u_xlat13 = dot(u_xlat3.xyz, u_xlat3.xyz);
    u_xlat13 = sqrt(u_xlat13);
    u_xlat13 = (-u_xlat7.x) + u_xlat13;
    u_xlat7.x = unity_ShadowFadeCenterAndType.w * u_xlat13 + u_xlat7.x;
    u_xlat7.x = u_xlat7.x * _LightShadowData.z + _LightShadowData.w;
    u_xlat7.x = clamp(u_xlat7.x, 0.0, 1.0);
    u_xlat3.xyz = vs_TEXCOORD1.yyy * hlslcc_mtx4x4unity_WorldToShadow[1].xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[0].xyz * vs_TEXCOORD1.xxx + u_xlat3.xyz;
    u_xlat3.xyz = hlslcc_mtx4x4unity_WorldToShadow[2].xyz * vs_TEXCOORD1.zzz + u_xlat3.xyz;
    u_xlat3.xyz = u_xlat3.xyz + hlslcc_mtx4x4unity_WorldToShadow[3].xyz;
    u_xlat13 = texture2D(_ShadowMapTexture, u_xlat3.xy).x;
    u_xlatb13 = u_xlat3.z<u_xlat13;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);
    u_xlat13 = max(u_xlat13, _LightShadowData.x);
    u_xlat16_5 = u_xlat7.x + u_xlat13;
    u_xlat7.xy = (-vs_TEXCOORD4.xy) + vec2(0.5, 0.5);
    u_xlat16_11 = max(abs(u_xlat7.y), abs(u_xlat7.x));
    u_xlat16_7.x = (-u_xlat16_11) + 0.5;
    u_xlat16_7.x = u_xlat16_7.x * 10.0;
    u_xlat16_7.x = clamp(u_xlat16_7.x, 0.0, 1.0);
    u_xlat16_20 = u_xlat16_20 + (-u_xlat16_5);
    u_xlat16_20 = u_xlat16_7.x * u_xlat16_20 + u_xlat16_5;
    u_xlat16_20 = (u_xlatb1) ? u_xlat16_20 : u_xlat16_5;
    u_xlat16_1.x = max(u_xlat16_20, _LightShadowData.x);
    u_xlat16_1.x = min(u_xlat16_1.x, 1.0);
    u_xlat16_7.xyz = (-vec3(_WeatherDarkness)) + vec3(0.819999993, 0.725000024, 0.412);
    u_xlat16_1.xyz = u_xlat16_1.xxx * u_xlat16_7.xyz + vec3(0.180000007, 0.275000006, 0.588);
    u_xlat19 = max(vs_TEXCOORD2, unity_FogColor.w);
    u_xlat19 = clamp(u_xlat19, 0.0, 1.0);
    u_xlat16_1.xyz = u_xlat16_2.xyz * u_xlat16_1.xyz + (-unity_FogColor.xyz);
    u_xlat0.xyz = vec3(u_xlat19) * u_xlat16_1.xyz + unity_FogColor.xyz;
    SV_Target0 = u_xlat0;
    return;
}

#endif
"
}
}
Program "fp" {
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" "FOG_LINEAR" "ENABLE_DUMMY_SHADOW" }
""
}
}
}
}
SubShader {
 LOD 200
 Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "AlphaTest" "RenderType" = "Transparent" }
 Pass {
  LOD 200
  Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "AlphaTest" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
  Blend Zero Zero, Zero Zero
  ZWrite Off
  GpuProgramID 130125
Program "vp" {
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
"// hash: d83981e15fae470e
#ifdef VERTEX
#version 100

uniform 	vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform 	vec4 hlslcc_mtx4x4unity_MatrixVP[4];
attribute highp vec4 in_POSITION0;
attribute highp vec2 in_TEXCOORD0;
attribute highp vec2 in_TEXCOORD1;
varying highp vec4 vs_TEXCOORD0;
varying highp vec3 vs_TEXCOORD1;
varying mediump float vs_TEXCOORD2;
vec4 u_xlat0;
vec4 u_xlat1;
void main()
{
    u_xlat0 = in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1];
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz + u_xlat0;
    u_xlat1 = u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3];
    vs_TEXCOORD1.xyz = hlslcc_mtx4x4unity_ObjectToWorld[3].xyz * in_POSITION0.www + u_xlat0.xyz;
    u_xlat0 = u_xlat1.yyyy * hlslcc_mtx4x4unity_MatrixVP[1];
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat1.xxxx + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat1.zzzz + u_xlat0;
    u_xlat0 = hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat1.wwww + u_xlat0;
    gl_Position = u_xlat0;
    u_xlat0.x = u_xlat0.z * -0.00294000003 + 1.05879998;
    u_xlat0.x = max(u_xlat0.x, 0.5);
    u_xlat0.x = min(u_xlat0.x, 1.0);
    vs_TEXCOORD2 = u_xlat0.x;
    vs_TEXCOORD0.xy = in_TEXCOORD0.xy;
    vs_TEXCOORD0.zw = in_TEXCOORD1.xy;
    return;
}

#endif
#ifdef FRAGMENT
#version 100

#ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
#else
    precision mediump float;
#endif
precision highp int;
uniform 	mediump float _WeatherDarkness;
uniform lowp sampler2D _MainTex;
uniform lowp sampler2D _Lightmap;
varying highp vec4 vs_TEXCOORD0;
varying mediump float vs_TEXCOORD2;
#define SV_Target0 gl_FragData[0]
mediump vec3 u_xlat16_0;
lowp vec3 u_xlat10_0;
vec4 u_xlat1;
mediump vec3 u_xlat16_2;
void main()
{
    u_xlat10_0.xyz = texture2D(_Lightmap, vs_TEXCOORD0.zw).xyz;
    u_xlat1 = texture2D(_MainTex, vs_TEXCOORD0.xy);
    u_xlat16_2.xyz = u_xlat10_0.xyz * u_xlat1.xyz;
    u_xlat16_0.x = (-_WeatherDarkness) + 1.0;
    u_xlat16_0.xyz = u_xlat16_2.xyz * u_xlat16_0.xxx + vec3(-0.430000007, -0.620000005, -0.889999986);
    u_xlat1.xyz = vec3(vs_TEXCOORD2) * u_xlat16_0.xyz + vec3(0.430000007, 0.620000005, 0.889999986);
    SV_Target0 = u_xlat1;
    return;
}

#endif
"
}
}
Program "fp" {
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" }
""
}
SubProgram "gles hw_tier00 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
SubProgram "gles hw_tier01 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
SubProgram "gles hw_tier02 " {
Keywords { "DIRECTIONAL" "SHADOWS_SCREEN" }
""
}
}
}
}
Fallback "BRMobile/AlphaBlendVertexLit"
}