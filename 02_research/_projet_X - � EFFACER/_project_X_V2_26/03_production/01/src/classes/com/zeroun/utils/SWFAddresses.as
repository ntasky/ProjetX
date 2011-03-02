package com.zeroun.utils 
{
	import com.asual.swfaddress.*;
	
    public class SWFAddresses {
		
		// extract the pageId from the adress
		// :NOTE: this function work only when the URL is formed like this : #/$locale/PAGE_ID/[SUBPAGE_ID/...] otherwise use native function SWFAddress.getValue();
		public static function getSWFAddressPageId():String
		{
			var pathNames:Array = SWFAddress.getPathNames();
			// removes the first element corresponding to the language
			pathNames.shift();
			
			return "/" + pathNames.join("/") + "/";
		}
		
		// extract the language without "/" from the adress
		// :NOTE: this function work only when the URL is formed like this : #/$locale/PAGE_ID/[SUBPAGE_ID/...]
		public static function getSWFAddressLanguage():String
		{
			return SWFAddress.getPathNames().shift();
		}
		
		// force the address with an optionnal language
		public static function setSWFAddress(__pageID:String, __language:String = ""):void
		{
			var addressLanguage:String = "";
			if (__language != "") addressLanguage = "/" + __language;
			
			SWFAddress.setValue(addressLanguage + __pageID);
		}
	}
}