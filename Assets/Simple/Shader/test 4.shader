// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/test4"
{
	Properties//輸入外來資源如: diffuse、normal、occ
	{
			///test
		_Texture("Texture",2D) = "white" {}//匯入圖片 種類("顯示的名稱",輸入的類別) = "顏色預設" {}/
		_Color("Color",Color) = (1,1,1,1) //匯入顏色1111為白色

			///test1
		_Scale("Scale",Range(0,0.025)) = 0.0125 //制定參數範圍

			///test2//區域上色
		_BlockColor("BlockColor",Color) = (1,0,0,1)//預設紅色
		_Pos("Pos",Range(-1,1)) = -0.3
		_Range("Range",Range(0,2)) = 0.2

			//test3//波浪縮放
		_sPos("sPos",Range(-1,1)) = 0.1
		_sRange("sRange",Range(0,2)) = 0.2
		_sScale("sScale",Range(0,0.05)) = 0.02

			//test4//外框線
		_Outline("OutlineScale", Range(0,0.025)) = 0.01
		_OutlineColor("Outline Color",Color) = (0,0,1,1)

	}
		SubShader//實作方法
		{
			Tags{"Queue" = "Geometry" "RenderType" = "Opaque"}//設定shader種類
			//Tags { "RenderType"="Opaque"}///test1
				LOD 100 //設定shader的層級，用於之後畫質選擇的調整
			Pass //一個完整的渲染過程
			{
			Cull Front
				CGPROGRAM

				#pragma vertex vert //宣告
				#pragma fragment frag
				#include "UnityCG.cginc" //輸入shader liberary

				sampler2D _Texture; //將輸入的外來資源匯入這個實作中
				fixed4 _Color;
				fixed _Scale;

				///test2
				fixed4 _BlockColor;
				fixed _Pos;
				fixed _Range;

				//test3
				fixed _sPos;
				fixed _sRange;
				fixed _sScale;

				//test4
				fixed _Outline;
				fixed4 _OutlineColor;

				struct appdata { //向Unity索取資料的方法
					fixed4 vertex : POSITION;
					fixed4 normal : NORMAL; //索取法向量資料///test1
					fixed2 uv : TEXCOORD0; //TEXCOORD0 第一個UV位置
				};

				struct v2f { //回傳給unity的方法
					fixed4 vertex : SV_POSITION; //系統所需的特殊資料
					fixed2 uv : TEXCOORD0;
					fixed4 color : COLOR;
				};

				v2f vert(appdata i) //內容實作
				{
					v2f o;
					o.uv = i.uv;
					if (i.vertex.x <= _Pos && i.vertex.x >= _Pos - _Range)//test2
					{
						o.color = _BlockColor;
						//o.color = _Color;
					}
					else
					{
						o.color = fixed4(1,1,1,1);
					}
					//test3
					if (i.vertex.z <= _sPos && i.vertex.z >= _sPos - _sRange)//test3
					{
						o.color = _BlockColor;
						i.vertex.xyz += i.normal * _sScale;
						//o.color = _Color;
					}
					else
					{
						o.color = fixed4(1, 1, 1, 1);
					}

					//test4
					i.vertex.xyz += i.normal * _Outline;

					i.vertex.xyz += i.normal * _Scale; //實作，將物件頂點得位置依照法向量的方向乘以Scale的值放大///test1
					o.vertex = UnityObjectToClipPos(i.vertex); // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)' 進行位置的矩陣處理將它轉換成顯示的座標

					return o;
				}
				
				fixed4 frag(v2f v) : SV_Target //取得v2f得實作內容，將它輸出給unity顯示端，顯示shader的結果
				{
					return tex2D(_Texture, v.uv) * _Color * v.color * _OutlineColor; //將_Texture的貼圖依據UV位置投射到模型上
				}

				ENDCG
			}

			Pass //一個完整的渲染過程//test4 製造上一個pass的Mask，來達成外框線
				{
					CGPROGRAM

#pragma vertex vert //宣告
#pragma fragment frag
#include "UnityCG.cginc" //輸入shader liberary

					sampler2D _Texture; //將輸入的外來資源匯入這個實作中
				fixed4 _Color;

				struct appdata { //向Unity索取資料的方法
					fixed4 vertex : POSITION;
					fixed2 uv : TEXCOORD0; //TEXCOORD0 第一個UV位置
				};

				struct v2f { //回傳給unity的方法
					fixed4 vertex : SV_POSITION; //系統所淤的特殊資料
					fixed2 uv : TEXCOORD0;
				};

				v2f vert(appdata i) //內容實作
				{
					v2f o;
					o.uv = i.uv;
					o.vertex = UnityObjectToClipPos(i.vertex); // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)' 進行位置的矩陣處理將它轉換成顯示的座標

					return o;
				}

				fixed4 frag(v2f v) : SV_Target //取得v2f得實作內容，將它輸出給unity顯示端，顯示shader的結果
				{
					return tex2D(_Texture, v.uv); //將_Texture的貼圖依據UV位置投射到模型上
				}

					ENDCG
				}
			
		}
}