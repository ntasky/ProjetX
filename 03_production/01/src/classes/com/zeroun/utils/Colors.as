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
		
		// mixes two colors together and returns the resulting rgb value
        public static function mixTwoColors(__color1:int, __color2:int, __ratioColor1:Number = 0.5):int
        {
            var r1:int = __color1 >> 16;
            var g1:int = (__color1 >> 8) & 0xFF;
            var b1:int = __color1 & 0xFF;

            var r2:int = __color2 >> 16;
            var g2:int = (__color2 >> 8) & 0xFF;
            var b2:int = __color2 & 0xFF;

            var u:Number = __ratioColor1;
            var v:Number = 1 - u;

            var r:int = Math.round(u * r1 + v * r2);
            var g:int = Math.round(u * g1 + v * g2);
            var b:int = Math.round(u * b1 + v * b2);

            return (r << 16 | g << 8 | b);
        }

	}
}