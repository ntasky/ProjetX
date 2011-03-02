package core
{
	import flash.system.Capabilities;
	
	import com.zeroun.utils.SWFAddresses;
	
	import core.Config;
	import core.pages.PageType;
	
	
	public class Content
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		private static const UNDEFINED_LANGUAGE		:String = "undefined language";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private static var _contentXML			:XML;
		private static var _locale				:String = "";
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Content(){}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// assign the XML where to get datas
		public static function setContentXML(__contentXML:XML):void
		{
			_contentXML = __contentXML;
		}
		
		public static function get locale():String
		{
			return _locale;
		}
		
		public static function set locale(__value:String):void
		{
			_locale = __value;
		}
		
		public static function autoDetermineLocale():void
		{
			// default value for the locale is ""
			var locale:String = "";
			
			// get the locale
			if (Config.LOCALES.length > 0)
			{
				// online and SWF_ADDRESS enabled?
				if ((Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX") && Config.SWF_ADDRESS_ENABLED)
				{
					var tmpLocale:String = SWFAddresses.getSWFAddressLocale();
					// locale may be null if there is no locale value in the address (for ex. if the address is empty)
					if (tmpLocale == null || !Content.isValidLocale(tmpLocale) )
					{
						locale = Config.LOCALES[0];
					}
					else
					{
						locale = tmpLocale;
					}
				}
				else
				{
					locale = Config.LOCALES[0];
				}
			}
			
			// set value for locale
			Content.locale = locale;
		}
		
		public static function isValidLocale(__locale:String):Boolean
		{
			var result:Boolean = false;
			
			for (var i:int = 0; i < Config.LOCALES.length; i++)
			{
				if (__locale == Config.LOCALES[i])
				{
					return true;
				}
			}
			
			return result;
		}
				
		// get the string by passing its ID. has to be in the node <root><strings><string id="some_id"/><strings></root>
		public static function getString(__id:String):String
		{
			var xmlList:XMLList = _contentXML.strings.string.(@id == __id);
			var result:String;
			// no languages tag are specified
			if (xmlList.hasSimpleContent())
			{
				result = _formatText(xmlList.toString());
			}
			else if (_locale == "") 
			{
				result = "";
			}
			else 
			{
				result = _formatText(xmlList[_locale].toString());
			}
			
			result = (result.length > 0) ? result : UNDEFINED_LANGUAGE;
			return result;
		}
		
		// return the page type. a page can be either default or popup
		public static function getPageType(__pageId:String):String
		{
			switch(_contentXML.pages.page.(@id == __pageId).@type.toString())
			{
				case "popup":
					return PageType.POPUP;
					break;
				default:
					return PageType.PAGE;
					break;
			}
		}
		
		public static function isPageLinkable(__pageId:String):Boolean
		{
			return _contentXML.pages.page.(@id == __pageId).@linkable.toString() == "1";
		}
		
		// return the first page of the pages
		public static function getDefaultPageId():String
		{
			return _contentXML.pages.page[0].@id;
		}
		
		// get all the pages
		public static function getPages():Array
		{
			var a:Array = new Array();
			var pages:XMLList = _contentXML.pages.page;
			
			for each (var page:XML in pages)
			{
				var o:Object = {
					id:page.@id,
					data:page
				}
				a.push(o);
			}
			
			return (a);
		}
		
		// get pageData
		public static function getPageData(__pageId:String):XMLList
		{
			return _contentXML.pages.page.(@id == __pageId);
		}
		
		////////// EX ////////////
		
		/*
		public static function getData():Array
		{
			var a:Array = new Array();
			var items:XMLList = _contentXML.menu.item;
			
			for each (var data:XML in items)
			{
				var o:Object = {
					label:data,
					url:data.@link,
					target:data.@target
				}
				a.push(o);
			}
			
			return (a);
		}
		*/
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		 
		private static function _formatText(__value:String):String
		{
			var s:String;
			s = __value;
			s = s.split("\r\n").join("\r");						// remove double end of line characters (\r\n appear in files created on Windows)
			s = s.split(String.fromCharCode(8356)).join("£");	// the English pound sign isn't decoded properly from the XML, causing the character to be invisible in textfields
			return s;
		}
		
	}
	
}