//该Shader标识Shader常用语法
Shader "MyShader/Shader1"
{
	//属性域
	Properties
	{
		//name ("DisplayName",PropertyType) = DefaultValue
		_MainTex("Texture", 2D) = "white" {}
		_Int("Int",Int) = 2
		_Float("Float",Float) = 0.2
		_Range("Range",Range(1,2)) = 1.5
		_Color("Color",Color) = (1,1,1,1)
		_Vector("Vector",Vector) = (2,6,3,1)
		_2D("2D",2D) = "" {}
		_3D("3D",3D) = "" {}
		_Cube("Cube",Cube) = ""{}
	}

		//不同显卡的子着色器
	SubShader
	{
		//状态 		[RenderSetup]可选
		//Cull		设置剔除模式 Cull Back剔除背面/Front正面/Off关闭
		//ZTezt		设置深度测试时所用的参数 ZTest Less Greater/LEqual/GEqual/NotEqual/Always
		//ZWrite	开启/关闭深度写入 ZWrite On/Off
		//Blend		开启并设置混合模式Blends SrcFactor DstFactor
		//当在SubShader块中设置了上述渲染状态时，将会应用到所有的Pass中，如果需要单独的设置可以在Pass语义块中单独进行设置

		//标签 可选,渲染标签 Tags{"TagName1" = "Value" "TagName2" = "Value2"}
		Tags { "RenderType" = "Opaque" }

		LOD 100

		Pass
		{
			Name "MyPass"
			//CG代码
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		// make fog work
		#pragma multi_compile_fog

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			UNITY_TRANSFER_FOG(o,o.vertex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			// sample the texture
			fixed4 col = tex2D(_MainTex, i.uv);
		// apply fog
		UNITY_APPLY_FOG(i.fogCoord, col);
		return col;
	}
	ENDCG
}
	}
}
