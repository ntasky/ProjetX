package com.zeroun.utils 
{
	public class Colors
	{
		// returns the perceived luminance (0..1) of a color
		public static function getBrightness(__rgb:int):Number
		{
			var r:Number = (__rgb >> 16) / 0xFF;
			var g:Number = ((__rgb >> 8) & 0xFF) / 0xFF;
			var b:Number = (__rgb & 0xFF) / 0xFF;
			return Math.sqrt(0.241 * r * r + 0.691 * g * g + 0.068 * b * b);
		}
		
		// returns the color in base 16 (ex : 16777215 => FFFFFF)
		public static function getHexColor(__color:int):String
		{
			return (__color.toString(16));
		}
	}
}