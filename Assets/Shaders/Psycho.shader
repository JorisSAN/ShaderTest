Shader "Unlit/Psycho"
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

			float2x2 rot(float a) 
			{ 
				return float2x2(cos(a), -sin(a), sin(a), cos(a)); 
			}

			half4 frag(VertexOutput i) : COLOR
			{
				float3 col;
				float t;

				for (int c = 0; c < 3; c++) {
					float2 uv = (i.texcoord * 2. - float2(1, 1)) / 1;
					t = _Time + float(c) / 10.;
					t *= 10;
					for (int i = 0; i < 5; i++) {
						uv = abs(uv);
						uv -= .5;
						uv.x = uv.x * rot(t / float(i + 1))[1][0] + uv.y * rot(t / float(i + 1))[1][1];
						uv.y = uv.x * rot(t / float(i + 1))[0][0] + uv.y * rot(t / float(i + 1))[0][1];
					}
					col[c] = step(.5, frac(uv.x * 20.));
				}

				return float4(float3(col), 1.0);
			}

			ENDCG
		}
	}
}
