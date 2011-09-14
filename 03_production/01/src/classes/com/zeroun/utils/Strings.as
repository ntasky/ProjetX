package com.zeroun.utils 
{
    public class Strings {
		
		// return a string with only the numbers
		public static function getOnlyNumbers(__str:String):String
		{
			var numbers:String 	= "0123456789";
			var tmpStr:String 	= ""//"NaN";
			var tmpArr:Array 	= __str.split("");
			
			for (var i:int = 0; i < tmpArr.length; i++) {
				if (numbers.indexOf(tmpArr[i]) != -1) {
					tmpStr += tmpArr[i];
				}
			}
			return tmpStr;
		}
		
		// return a string with only the letters
		public static function getOnlyLetters(__str:String):String
		{
			var letters:String	= "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
			var tmpStr:String 	= "";
			var tmpArr:Array 	= __str.split("");
			
			for (var i:int = 0; i < tmpArr.length; i++) {
				if (letters.indexOf(tmpArr[i]) != -1) {
					tmpStr += tmpArr[i];
				}
			}
			
			return tmpStr;
		}
		
		// return if a string is a Number
		public static function isANumber(__str:String):Boolean
		{
			return !isNaN(Number(__str));
		}
		
		// return if the field is empty
		public static function isEmpty(__str:String):Boolean
		{
			if (__str.length == 0) return true;
			else 
			{
				var result:Boolean = true;
				for (var i:Number = 0; i < __str.length; i++)
				{
					if (__str.charCodeAt(i) != 32 && __str.charCodeAt(i) != 13)
					{
						result = false;
						break;
					}
				}
				return result;
			}
		}
		
		// return if the field contains spaces
		public static function containsSpaces(__str:String):Boolean
		{
			return (__str.indexOf(" ") != -1);
		}
		
		// return if the field is a valid email
		public static function isValidEmail(__str:String):Boolean
		{
			var regExp:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			return regExp.test(__str);
		}
		
		public static function capitalizeWord(__word:String):String
		{
			var firstChar:String = __word.substr(0, 1); 
			var restOfString:String = __word.substr(1, __word.length); 
			return firstChar.toUpperCase()+restOfString.toLowerCase(); 
		}
		
	}
}