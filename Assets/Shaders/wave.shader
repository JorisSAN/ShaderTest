Shader "Unlit/wave"
{
	Properties
	{
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

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

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

			half4 frag(VertexOutput i) : COLOR
			{
				float2 uv = i.texcoord;
				float r = 0.3;
				float t = _Time * 10;

				float2 pCoord = uv * 30.;
				float xWaveSize = (1. + sin(t * 0.7)) * 2;
				float yWaveSize = (1. + sin(t * 0.5)) * 2;
				pCoord.x += t + xWaveSize * cos(0.25 * pCoord.y + t * 2.);
				pCoord.y += t + yWaveSize * sin(0.25 * pCoord.x + t * 3.);
				float dist = length(frac(pCoord) - float2(.5, .5));
				float result = 1. - dist * 3.;
				float py = smoothstep(r, r - .2, result);

				float3 col = float3(uv.x * py, uv.y * py, (1. - uv.y) * py);

				return float4(col,1.0);
			}

			ENDCG
		}
	}
}
