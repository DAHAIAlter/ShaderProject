// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Shader1"{
	Properties{
		//该Shader标识Shader常用语法
		//属性域
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
	SubShader{
		//状态[RenderSetup]可选
		//Cull		设置剔除模式 Cull Back剔除背面/Front正面/Off关闭
		//ZTezt		设置深度测试时所用的参数 ZTest Less Greater/LEqual/GEqual/NotEqual/Always
		//ZWrite	开启/关闭深度写入 ZWrite On/Off
		//Blend		开启并设置混合模式Blends SrcFactor DstFactor
		//当在SubShader块中设置了上述渲染状态时，将会应用到所有的Pass中，如果需要单独的设置可以在Pass语义块中单独进行设置

		//标签 可选,渲染标签 Tags{"TagName1" = "Value" "TagName2" = "Value2"}
		//Queue					控制渲染顺序，指定该物体属于哪一个渲染队列，通过这种方式可以保证所有的透明物体可以在所有不透明物体后面被渲染，也可以自定义使用的渲染队列来控制物体的渲染顺序
		//RenderType			对着色器进行分类，例如这是一个不透明的着色器，或者是一个透明的着色器等，这样可以被用于做瑟琪替换(Shader Replacement)功能
		//DisableBatching		一些Shader在使用Unity的批处理功能的时候会出现问题，例如使用了模型空间下的坐标进行顶点动画，这时可以通过该标签来直接指明是否对该SubShader使用批处理
		//ForceNoShadowCasting	控制该SubShader的物体是否会投射阴影
		//IgnoreProjector		如果该标签为"True"，那么使用该SubShader的物体将不会受Projector的影响，通常用于半透明物体
		//CanUseSpriteAtlas		当该SubShader是用于精灵(sprites)时，将该标签设置为"False"
		//PreviewType			指明材质面板将如何预览该材质，默认情况下，材质将显示为一个球型，我们可以通过吧标签的值设为"Panel""SkyBox"来改变预览类型

		Tags { "RenderType" = "Opaque" }
		LOD 100
		Pass{
		//Pass的名字，可以通过这个名称来直接使用其他UnityShader的Pass，而且Unity会强制把所有Pass名称转换成大写字母显示
		//例 UsePass "Shader1/MYPASS"
		Name "MyPass"
		//Pass也可以设置标签，注意和SubShader代码域中的标签区分开，Pass中的标签时用于告诉引擎我们希望怎样来渲染该物体
		//LightMode		定义该Pass在Unity的渲染流水线中的角色
		//RequireOption	用于指定当前满足某些条件时才渲染该Pass，它的值是一个由空格分隔的字符串。目前，Unity支持的选项有SoftVegetation。在后买你的版本中可能会增加更多的选项
		}
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

	//表面着色器(Surface Shader)是Unity自己创造的一种着色器代码类型代码量少但是代价大
	//代码书写在CGPROGRAM和ENDCG之间，而且中间使用的是Cg/HLSL语言，UnityShader中用的Cg/HLSL语言和原生语法类似但是不完全相同
	SubShader{
		Tags { "RenderType" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lmabert
		struct Input {
			float4 color : COLOR;
		};
		void surf(Input IN, inout SurfaceOutPut o) {
			o.Albedo = 1;
		}
		ENDCG
	}
	//顶点/片元着色器(Vertex/Fragment Shader),与表面着色器类似，代码需要在CGRPROGRAM和ENDCG之间，但是顶点/片元着色器是写在Pass语义块内，因为我们需要区分不同Pass的代码块，语言也为Cg/HLSL
	SubShader{
		Pass{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			float4 vert(float4 v:POSITION) :SV_POSOTION{
				return UnityObjectToClipPos (v)
			}
			fixed4 frag() : SV_Target
			{
				return fixed4(1.0,0.0,0.0,1.0)
			}
			ENDCG
		}
	}
	//固定函数着色器(Fixed Function Shader)针对不可编程管线实现简单效果的解决方案，而实现语法为ShaderLab的语法
	SubShader{
		Pass{
			Material{
				Diffuse [_Color]
			}
			Lighting On
		}
	
	}

	//Fallback 最低级的Unity Shader 可关闭，当显卡无法处理该SubShader的时候就使用Fallback，或者也可以关闭Fallback，但这样的话就意味着入过所有的SubShader都无法在显卡上运行，那么就不管这个任务了
	//而且Fallback会影响阴影的投射，因为Fallback中包含了通用的Pass，所以我们不需要为每个SubShader设置阴影的Pass。
}
