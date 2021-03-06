﻿Shader "Unlit/Lava"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "White" {}
		_NormalMap("Normal Map", 2D) = "White" {}
	}
	Subshader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"IgnoreProjection" = "True"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;

			struct VertexInput
			{
				float4 vertex: POSITION;
				float4 normal: NORMAL;
				float4 tangent: TANGENT;
				float4 texcoord: TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 pos : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 normalWorld: TEXCOORD1;
				float4 tangentWorld: TEXCOORD2;
				float3 binormalWorld: TEXCOORD3;
				float4 normalTexcoord: TEXCOORD4;
			};

			float3 normalFromColor(float4 color)
			{
				#if defined (UNITY_NO_DXT5nm)
				return color.xyz;

				#else
				// In this case red channel is alpha
				float3 normal = float3(color.a, color.g, 0.0);
				normal.z = sqrt(1 - dot(normal, normal));
				return normal;
				#endif
			}

			float3 WorldNormalFromNormalMap(sampler2D normalMap, float2 normalTexCoord, float3 tangentWorld, float3 binormalWorld, float3 normalWorld)
			{
				// Color at Pixel which we read from Tangent space normal map
				float4 colorAtPixel = tex2D(normalMap, normalTexCoord);

				// Normal value converted from Color value
				float3 normalAtPixel = normalFromColor(colorAtPixel);

				// Compose TBN matrix
				float3x3 TBNWorld = float3x3(tangentWorld, binormalWorld, normalWorld);
				return normalize(mul(normalAtPixel, TBNWorld));
			}

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				o.normalTexcoord.xy = (v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw);

				o.normalWorld = normalize(mul(v.normal, unity_WorldToObject));
				o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent));
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);

				return o;
			}

			half4 frag(VertexOutput i) : COLOR
			{
				float2 col;
				float t = _Time * .3;
				float2 uv = i.texcoord +float2(t, t * 2.0);
				float factor = 1.5;
				float2 v1;
				for (int i = 0; i < 12; i++)
				{
					uv *= -factor * factor;
					v1 = uv.yx / factor;
					uv += sin(v1 + col + t * 20.0) / factor;
					col += float2(sin(uv.x - uv.y + v1.x - col.y),sin(uv.y - uv.x + v1.y - col.x));
				}
				return float4(float3(col.x + 4.0,col.x - col.y / 2.0,col.x / 5.0) / 2.0,1.0);
			}

			ENDCG
		}
	}
}
