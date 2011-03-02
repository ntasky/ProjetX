package com.zeroun.utils 
{
    public class RegExps {
		
		// return true if the String is a Name (ex: George);
		public static function checkName(p_string:String):Boolean
		{
			var regExp:RegExp = /[]$/;
					
			return (regExp.test(p_string));
		}
		
		// return true if the String is a email
		public static function checkEmail(p_string:String):Boolean
		{
			// :NOTE: the first regex is more precise but refuses email like a@domain.com because there is only one letter before the @
			//var regExp:RegExp = /[\w \! \# \$ \% \& \' \* \+ \- \/ \= \? \^ \_ \` \" \. \{ \| \} \~]+[\w \! \# \$ \% \& \' \" \* \+ \- \/ \= \? \^ \_ \` \{ \| \} \~](\@)[a-z]+(\.)[a-z]{2}([a-z])?(\.[a-z]{2}([a-z]?))?$/;
			var regExp:RegExp = /[\w \! \# \$ \% \& \' \* \+ \- \/ \= \? \^ \_ \` \" \. \{ \| \} \~](\@)[a-z]+(\.)[a-z]{2}([a-z])?(\.[a-z]{2}([a-z]?))?$/;
					
			return (regExp.test(p_string));
		}	
	}
}