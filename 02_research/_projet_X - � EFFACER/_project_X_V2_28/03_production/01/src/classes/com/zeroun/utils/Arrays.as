package com.zeroun.utils 
{
    public class Arrays
	{
		// shuffle an array
		public static function shuffle(__array:Array):void
		{
			var n:int = __array.length;
			var j:int;
			var temp:*;
			for (var i:int = 0; i < n; i ++)
			{
				j = Math.floor(Math.random() * n);
				temp = __array[j];
				__array[j] = __array[i];
				__array[i] = temp;
			}
		}
	}
}