package com.zeroun.utils 
{
    public class Numbers
	{
		// get a random number beetween 2 forced values
		public static function getRandomBetween(__min:Number, __max:Number):Number
		{
			return Math.random() * (__max - __min) + __min;
		}
		
		// get a random int beetween 2 forced values
		public static function getRandomIntBetween(__min:int, __max:int):int
		{
			return int(Math.random() * (__max - __min) + __min);
		}
		
		// return the distance beetween 2 points
		public static function getDistance(__x1:Number, __y1:Number, __x2:Number, __y2:Number):Number
		{
			var dx:Number = __x2 - __x1;
			var dy:Number = __y2 - __y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		// return the angle beetween 2 points
		public static function getAngle(__x1:Number, __y1:Number, __x2:Number, __y2:Number):Number
		{
			var dx:Number = __x2 - __x1;
			var dy:Number = __y2 - __y1;
			return Math.atan2(-dy, dx);		// :NOTE: -dy because the y-axis on screen is upside down
		}
		
		// get a relative number
		public static function getRelative(__targetMin:Number, __targetMax:Number, __sourceMin:Number, __sourceMax:Number, __sourceValue:Number):Number
		{
			var sourceValue:Number =  forceBetween(__sourceValue, __sourceMin, __sourceMax);
			if (sourceValue == __sourceMin) return __targetMin;
			else if (sourceValue == __sourceMax) return __targetMax;
			else return (((__targetMax - __targetMin) / (__sourceMax - __sourceMin) * sourceValue) + (__targetMin - __sourceMin * (__targetMax - __targetMin) / (__sourceMax - __sourceMin)));
		}
		
		// get force a number beetween 2 forced values
		public static function forceBetween(__value:Number, __min:Number, __max:Number):Number
		{
			var result:Number;
			var min:Number = (__min < __max) ? __min : __max;
			var max:Number = (__max > __min) ? __max : __min;
			if (__value < min)
			{
				result = min;
			}
			else if (__value > max)
			{
				result = max;
			}
			else
			{
				result = __value;
			}
			return result;
		}
		
		// transform the number of seconds in HHMMSS format
		public static function StoHHMMSS(__seconds:int):String
		{
			var rest:int = __seconds;
			var hh:int = rest / 3600;
			rest -= 3600 * hh;
			var mm:int = rest / 60;
			rest -= 60 * mm;
			
			var resultHh:String;
			if (hh < 10) resultHh = "0" + hh.toString();
			else resultHh = hh.toString();
			
			var resultMm:String;
			if (mm < 10) resultMm = "0" + mm.toString();
			else resultMm = mm.toString();
			
			var resultRest:String;
			if (rest < 10) resultRest = "0" + rest.toString();
			else resultRest = rest.toString();
			
			return resultHh + ":" + resultMm + ":" + resultRest;
		}
		
		// transform the number of seconds in MMSS format
		public static function StoMMSS(__seconds:int):String
		{
			var rest:int = __seconds;
			var mm:int = rest / 60;
			rest -= 60 * mm;
			
			var resultMm:String;
			if (mm < 10) resultMm = "0" + mm.toString();
			else resultMm = mm.toString();
			
			var resultRest:String;
			if (rest < 10) resultRest = "0" + rest.toString();
			else resultRest = rest.toString();
			
			return resultMm + ":" + resultRest;
		}
		
		// get a radian value from a angle in degree
		public static function degreeToRadian(__value:Number):Number
		{
			return (__value * Math.PI) / 180;
		}
		
		// get a degree value from a angle in radian
		public static function radianToDegree(__value:Number):Number
		{
			return __value * 180 / Math.PI;
		}
	}
}