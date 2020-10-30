Shader "Unlit/Zebre"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_Speed("Speed", Float) = 1
		_Deformation("Deformation", Float) = 3.7
		_Spirale("Spirale", Float) = 0.5
		_Noise("Noise", Float) = 2.4
		_StartLine("Start Line", Float) = 50
		_MainTex("Main Texture", 2D) = "White" {}
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

			#define mod(x,y) (x-y*floor(x/y))

			uniform half4 _Color;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float _Speed;
			uniform float _Deformation;
			uniform float _Spirale;
			uniform float _Noise;
			uniform float _StartLine;

			struct VertexInput
			{
				float4 vertex: POSITION;
				float4 texcoord: TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 pos : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				return o;
			}

			float3 permute(float3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }

			float snoise(float2 v) {
				const float4 C = float4(0.211324865405187, 0.366025403784439,
					-0.577350269189626, 0.024390243902439);
				float2 i = floor(v + dot(v, C.yy));
				float2 x0 = v - i + dot(i, C.xx);
				float2 i1;
				i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod(i, 289.0);
				float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0))
					+ i.x + float3(0.0, i1.x, 1.0));
				float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy),
					dot(x12.zw, x12.zw)), 0.0);
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac(p * C.www) - 1.0;
				float3 h = abs(x) - 0.5;
				float3 ox = floor(x + 0.5);
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot(m, g);
			}

			half4 frag(VertexOutput i) : COLOR
			{
				float2 uv = i.texcoord;
				float t = _Time * _Speed + uv.y;
				float a = snoise(uv * _Noise + float2(0., -t)) * _Deformation * uv.y;
				uv += float2(sin(a), cos(a)) * uv.y * _Spirale;
				float k = sin(uv.x * _StartLine) * 3.0;
				return float4(k,k,k,k);
			}

			ENDCG
		}
	}
}
