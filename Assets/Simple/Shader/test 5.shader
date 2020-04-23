// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/test5"
{
	Properties//輸入外來資源如: diffuse、normal、occ
	{
		_Texture("Texture",2D) = "white" {}//匯入圖片 種類("顯示的名稱",輸入的類別) = "顏色預設" {}/
		_Color("Color",Color) = (1,1,1,1) //匯入顏色
		_Transparency("Transparensy",Range(0.0,1.0)) = 0.5
	}
		SubShader//實作方法
		{
				Tags{"Queue" = "Transparent" "RenderType" = "Transparent"}//設定shader種類
				LOD 100 //設定shader的層級，用於之後畫質選擇的調整
			Pass //一個完整的渲染過程
			{
			Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM

				#pragma vertex vert //宣告
				#pragma fragment frag
				#include "UnityCG.cginc" //輸入shader liberary

				sampler2D _Texture; //將輸入的外來資源匯入這個實作中
				fixed4 _Color;
				fixed _Transparency;

				struct appdata { //向Unity索取資料的方法
					fixed4 vertex : POSITION;
					fixed normal : NORMAL;
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
					fixed4 col = tex2D(_Texture, v.uv) * _Color;
				col.a = _Transparency;
					return col; //將_Texture的貼圖依據UV位置投射到模型上
					
				}

				ENDCG
			}
		}
}