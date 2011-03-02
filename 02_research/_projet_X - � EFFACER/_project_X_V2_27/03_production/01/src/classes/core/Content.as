package core
{
	import flash.system.Capabilities;
	import core.Config;
	
	
	public class Content
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
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
		
		public static function setContentXML(__contentXML:XML):void
		{
			_contentXML = __contentXML;
		}
		
		public static function getString(__id:String):String
		{
			var xmlList:XMLList = _contentXML.strings.string.(@id == __id);
			// override some settings when testing the SWF files locally
			var testingLocally:Boolean = (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External");

			var result:String;
			// no languages tag are specified
			if (xmlList.hasSimpleContent())
			{
				result = _formatText(xmlList.toString());
			}
			else if (_locale == "") result = "";
			else result = _formatText(xmlList[_locale].toString());
			
			result = result.length > 0 ? result : "undefined language";
			return result;
		}
		
		public static function getDefaultPageId():String
		{
			return _contentXML.pages.page[0].@id;
		}
		
		public static function get locale():String
		{
			return _locale;
		}
		
		public static function set locale(__value:String):void
		{
			_locale = __value;
		}
		
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