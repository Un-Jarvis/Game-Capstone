Shader "EGA/HDRP/Particles/Blend_DistortTexture"
{
    Properties
    {
		_MainTex("MainTex", 2D) = "white" {}
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_Emission("Emission", Float) = 2
		_Noise("Noise", 2D) = "white" {}
		_NoisespeedUV("Noise speed U/V", Vector) = (0,0,0,0)
		_Mask("Mask", 2D) = "white" {}
		_Distortionpower("Distortion power", Float) = 0
		[Toggle(_USEDEPTH_ON)] _Usedepth("Use depth?", Float) = 0
		_Depthpower("Depth power", Float) = 1
		_Opacity("Opacity", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {
        Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		//ZTest Off
		ZWrite Off

		HLSLINCLUDE
		#pragma target 4.5
		#pragma multi_compile_instancing
		ENDHLSL

		
        Pass
        {
			
            Name "Depth prepass"
            Tags { "LightMode"="DepthForwardOnly" }
            ColorMask 0
			
        
            HLSLPROGRAM
        
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define _SURFACE_TYPE_TRANSPARENT 1
				#define _BLENDMODE_ALPHA 1
				#pragma shader_feature _USEDEPTH_ON

        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_DEPTH_ONLY
        
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/Unlit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float4 normalOS : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif 
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					float4 ase_texcoord1 : TEXCOORD1;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC; 
					#endif
				};

				CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				sampler2D _Mask;
				float4 _Mask_ST;
				sampler2D _Noise;
				float4 _NoisespeedUV;
				float _Distortionpower;
				float4 _Color;
				float _Depthpower;
				float _Opacity;
				CBUFFER_END
				                
                struct SurfaceDescription
                {
                    float Alpha;
                    float AlphaClipThreshold;
                };

				void BuildSurfaceData(FragInputs fragInputs, SurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
				}
        
				void GetSurfaceAndBuiltinData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{ 
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif

					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData);
					ZERO_INITIALIZE(BuiltinData, builtinData);
					builtinData.opacity =  surfaceDescription.Alpha;
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur =0.0;
				}

				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh   )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float4 ase_clipPos = TransformWorldToHClip( TransformObjectToWorld(inputMesh.positionOS));
					float4 screenPos = ComputeScreenPos( ase_clipPos , _ProjectionParams.x );
					outputPackedVaryingsMeshToPS.ase_texcoord1 = screenPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					inputMesh.positionOS.xyz +=  float3( 0, 0, 0 ) ;
					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);  
					return outputPackedVaryingsMeshToPS;
				}

				void Frag(  PackedVaryingsMeshToPS packedInput
							#ifdef WRITE_NORMAL_BUFFER
							, out float4 outNormalBuffer : SV_Target0
								#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target1
								#endif
							#else
							, out float4 outColor : SV_Target0
							#endif

							#ifdef _DEPTHOFFSET_ON
							, out float outputDepth : SV_Depth
							#endif
							
						)
				{
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;

					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0

					SurfaceData surfaceData;
					BuiltinData builtinData;
					SurfaceDescription surfaceDescription = (SurfaceDescription)0;
					float2 uv_Mask = packedInput.ase_texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
					float2 appendResult21 = (float2(_NoisespeedUV.x , _NoisespeedUV.y));
					float2 uv29 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float4 tex2DNode13 = tex2D( _MainTex, ( ( (( tex2D( _Mask, uv_Mask ) * tex2D( _Noise, ( ( appendResult21 * _Time.y ) + uv29 ) ) )).rg * uv29 * _Distortionpower ) + uv29 ) );
					float temp_output_62_0 = ( tex2DNode13.a * _Color.a * packedInput.ase_color.a );
					float4 screenPos = packedInput.ase_texcoord1;
					float4 ase_screenPosNorm = screenPos / screenPos.w;
					ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
					float screenDepth49 = LinearEyeDepth( SampleCameraDepth( screenPos.xy/screenPos.w ).r,_ZBufferParams);
					float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
					float clampResult53 = clamp( distanceDepth49 , 0.0 , 1.0 );
					#ifdef _USEDEPTH_ON
					float staticSwitch47 = ( temp_output_62_0 * clampResult53 );
					#else
					float staticSwitch47 = temp_output_62_0;
					#endif
					
					surfaceDescription.Alpha = ( staticSwitch47 * _Opacity );
					surfaceDescription.AlphaClipThreshold =  0;

					GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
					#ifdef WRITE_MSAA_DEPTH
					// In case we are rendering in MSAA, reading the an MSAA depth buffer is way too expensive. To avoid that, we export the depth to a color buffer
					depthColor = packedInput.positionCS.z;
					#endif
				#elif defined(SCENESELECTIONPASS)
					// We use depth prepass for scene selection in the editor, this code allow to output the outline correctly
					outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#else
					outColor = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				}
        
            ENDHLSL
        }
		
        Pass
        {
			
            Name "Forward Unlit"
            Tags { "LightMode"="ForwardOnly" }
        
            ColorMask RGBA
			
            HLSLPROGRAM
        
				#pragma vertex Vert
				#pragma fragment Frag

				#define _SURFACE_TYPE_TRANSPARENT 1
				#define _BLENDMODE_ALPHA 1
				#pragma shader_feature _USEDEPTH_ON

        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"

                #define SHADERPASS SHADERPASS_FORWARD_UNLIT
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/Unlit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
		        #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
	        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float4 normalOS : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					float4 ase_texcoord1 : TEXCOORD1;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC; 
					#endif 
				};

				CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				sampler2D _Mask;
				float4 _Mask_ST;
				sampler2D _Noise;
				float4 _NoisespeedUV;
				float _Distortionpower;
				float4 _Color;
				float _Emission;
				float _Depthpower;
				float _Opacity;
				CBUFFER_END
				                
		            
				struct SurfaceDescription
				{
					float3 Color;
					float Alpha;
					float AlphaClipThreshold;
				};
        
		
				void BuildSurfaceData(FragInputs fragInputs, SurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.color = surfaceDescription.Color;
				}
        
				void GetSurfaceAndBuiltinData(SurfaceDescription surfaceDescription , FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData);
					ZERO_INITIALIZE(BuiltinData, builtinData); 
					builtinData.opacity = surfaceDescription.Alpha;
					builtinData.distortion = float2(0.0, 0.0); 
					builtinData.distortionBlur = 0.0;
				}
        
         
				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float4 ase_clipPos = TransformWorldToHClip( TransformObjectToWorld(inputMesh.positionOS));
					float4 screenPos = ComputeScreenPos( ase_clipPos , _ProjectionParams.x );
					outputPackedVaryingsMeshToPS.ase_texcoord1 = screenPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					inputMesh.positionOS.xyz +=  float3( 0, 0, 0 ) ;
					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					return outputPackedVaryingsMeshToPS;
				}

				float4 Frag(PackedVaryingsMeshToPS packedInput) : SV_Target
				{
					
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
				
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0);

					SurfaceData surfaceData;
					BuiltinData builtinData;
					SurfaceDescription surfaceDescription = (SurfaceDescription)0;
					float2 uv_Mask = packedInput.ase_texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
					float2 appendResult21 = (float2(_NoisespeedUV.x , _NoisespeedUV.y));
					float2 uv29 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float4 tex2DNode13 = tex2D( _MainTex, ( ( (( tex2D( _Mask, uv_Mask ) * tex2D( _Noise, ( ( appendResult21 * _Time.y ) + uv29 ) ) )).rg * uv29 * _Distortionpower ) + uv29 ) );
					
					float temp_output_62_0 = ( tex2DNode13.a * _Color.a * packedInput.ase_color.a );
					float4 screenPos = packedInput.ase_texcoord1;
					float4 ase_screenPosNorm = screenPos / screenPos.w;
					ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
					float screenDepth49 = LinearEyeDepth( SampleCameraDepth( screenPos.xy/screenPos.w ).r,_ZBufferParams);
					float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
					float clampResult53 = clamp( distanceDepth49 , 0.0 , 1.0 );
					#ifdef _USEDEPTH_ON
					float staticSwitch47 = ( temp_output_62_0 * clampResult53 );
					#else
					float staticSwitch47 = temp_output_62_0;
					#endif
					
					surfaceDescription.Color =  ( ( tex2DNode13 * _Color * packedInput.ase_color * tex2DNode13.a * _Color.a * packedInput.ase_color.a ) * _Emission ).rgb;
					surfaceDescription.Alpha = ( staticSwitch47 * _Opacity );
					surfaceDescription.AlphaClipThreshold =  0;

					GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

					BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

					float4 outColor = ApplyBlendMode(bsdfData.color + builtinData.emissiveColor, builtinData.opacity);
					outColor = EvaluateAtmosphericScattering(posInput, V, outColor);

					return outColor;
				}

            ENDHLSL
        }

		Pass
		{
			
            Name "META"
            Tags { "LightMode"="Meta" }
        
            Cull Off
        
            HLSLPROGRAM
        
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define _SURFACE_TYPE_TRANSPARENT 1
				#define _BLENDMODE_ALPHA 1
				#pragma shader_feature _USEDEPTH_ON

				
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define ATTRIBUTES_NEED_COLOR
        
        
			    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Unlit/Unlit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

				struct AttributesMesh
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 tangentOS : TANGENT;
					float4 uv0 : TEXCOORD0;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 color : COLOR;
					
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					float4 ase_texcoord1 : TEXCOORD1;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

                CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				sampler2D _Mask;
				float4 _Mask_ST;
				sampler2D _Noise;
				float4 _NoisespeedUV;
				float _Distortionpower;
				float4 _Color;
				float _Depthpower;
				float _Opacity;
				CBUFFER_END
				                
                struct SurfaceDescription
                {
                    float3 Color;
                    float Alpha;
                    float AlphaClipThreshold;
                };
                    
				void BuildSurfaceData(FragInputs fragInputs, SurfaceDescription surfaceDescription, float3 V, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.color = surfaceDescription.Color;
				}
        
				void GetSurfaceAndBuiltinData(SurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
       
				#if _ALPHATEST_ON
					DoAlphaTest(surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold);
				#endif

					BuildSurfaceData(fragInputs, surfaceDescription, V, surfaceData);
					ZERO_INITIALIZE(BuiltinData, builtinData);
					builtinData.opacity = surfaceDescription.Alpha;
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
				}
       
				CBUFFER_START(UnityMetaPass)
				bool4 unity_MetaVertexControl;
				bool4 unity_MetaFragmentControl;
				CBUFFER_END

				float unity_OneOverOutputBoost;
				float unity_MaxOutputValue;

				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh   )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float4 ase_clipPos = TransformWorldToHClip( TransformObjectToWorld(inputMesh.positionOS));
					float4 screenPos = ComputeScreenPos( ase_clipPos , _ProjectionParams.x );
					outputPackedVaryingsMeshToPS.ase_texcoord1 = screenPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					inputMesh.positionOS.xyz +=  float3( 0, 0, 0 ) ;
					inputMesh.normalOS =  inputMesh.normalOS ;

					float2 uv;

					if (unity_MetaVertexControl.x)
					{
						uv = inputMesh.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					}
					else if (unity_MetaVertexControl.y)
					{
						uv = inputMesh.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					}

					outputPackedVaryingsMeshToPS.positionCS = float4(uv * 2.0 - 1.0, inputMesh.positionOS.z > 0 ? 1.0e-4 : 0.0, 1.0);
					return outputPackedVaryingsMeshToPS;
				}

				float4 Frag(PackedVaryingsMeshToPS packedInput) : SV_Target
				{			
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
                
				
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
		
					SurfaceData surfaceData;
					BuiltinData builtinData;
					SurfaceDescription surfaceDescription = (SurfaceDescription)0;
					float2 uv_Mask = packedInput.ase_texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
					float2 appendResult21 = (float2(_NoisespeedUV.x , _NoisespeedUV.y));
					float2 uv29 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float4 tex2DNode13 = tex2D( _MainTex, ( ( (( tex2D( _Mask, uv_Mask ) * tex2D( _Noise, ( ( appendResult21 * _Time.y ) + uv29 ) ) )).rg * uv29 * _Distortionpower ) + uv29 ) );
					float temp_output_62_0 = ( tex2DNode13.a * _Color.a * packedInput.ase_color.a );
					float4 screenPos = packedInput.ase_texcoord1;
					float4 ase_screenPosNorm = screenPos / screenPos.w;
					ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
					float screenDepth49 = LinearEyeDepth( SampleCameraDepth( screenPos.xy/screenPos.w ).r,_ZBufferParams);
					float distanceDepth49 = abs( ( screenDepth49 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depthpower ) );
					float clampResult53 = clamp( distanceDepth49 , 0.0 , 1.0 );
					#ifdef _USEDEPTH_ON
					float staticSwitch47 = ( temp_output_62_0 * clampResult53 );
					#else
					float staticSwitch47 = temp_output_62_0;
					#endif
					
					surfaceDescription.Color =  float3( 1, 1, 1 );
					surfaceDescription.Alpha = ( staticSwitch47 * _Opacity );
					surfaceDescription.AlphaClipThreshold =  0;

					GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);
					BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);
					LightTransportData lightTransportData = GetLightTransportData(surfaceData, builtinData, bsdfData);
					float4 res = float4(0.0, 0.0, 0.0, 1.0);
					if (unity_MetaFragmentControl.x)
					{
						res.rgb = clamp(pow(abs(lightTransportData.diffuseColor), saturate(unity_OneOverOutputBoost)), 0, unity_MaxOutputValue);
					}

					if (unity_MetaFragmentControl.y)
					{
						res.rgb = lightTransportData.emissiveColor;
					}

					return res;
				}

            ENDHLSL
		}
    }
    FallBack "Hidden/InternalErrorShader"
}