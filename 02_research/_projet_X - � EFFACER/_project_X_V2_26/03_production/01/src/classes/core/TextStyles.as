package core
{
	import flash.display.*;
	import flash.text.*;
	import flash.utils.getDefinitionByName;
	
	
	public class TextStyles
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		// used in product description on a light background
		//...
		// used in product description on a dark background
		public static const COLOR_WHITE				:int = 0xFFFFFF;
		public static const COLOR_BLACK				:int = 0x000000;
		
		// font instance names
		private static const GOTHAM_MEDIUM			:String = "GothamMedium";
		private static const GOTHAM_BOOK			:String = "GothamBook";
		private static const GOTHAM_BOLD			:String = "GothamBold";
		private static const ARIAL_REGULAR			:String = "ArialRegular";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public static var gothamBook10					:TextFormat = new TextFormat();
		public static var gothamBook12					:TextFormat = new TextFormat();
		public static var gothamBook14					:TextFormat = new TextFormat();
		public static var gothamMedium10				:TextFormat = new TextFormat();
		public static var gothamMedium11				:TextFormat = new TextFormat();
		public static var gothamMedium12				:TextFormat = new TextFormat();
		public static var gothamBold10					:TextFormat = new TextFormat();
		public static var gothamBold12					:TextFormat = new TextFormat();
		public static var gothamBold14					:TextFormat = new TextFormat();
		public static var ArialRegular11				:TextFormat = new TextFormat();
		public static var topNavigationLandscapeTitle	:TextFormat = new TextFormat();
		
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function TextStyles(){}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		
		public static function initializeTextFormats():void
		{
			var fontClassName:Class;
			var font:Font;
			
			/*	GOTHAM_BOOK	*/
			
			fontClassName = getDefinitionByName(GOTHAM_BOOK) as Class;
			font = new fontClassName();
			gothamBook12.font = font.fontName;
			gothamBook12.size = 12;
			gothamBook12.letterSpacing = 0;
			gothamBook12.leading = 0;
			
			gothamBook10 = _cloneTextFormat(gothamBook12);
			gothamBook10.size = 10;
			
			gothamBook14 = _cloneTextFormat(gothamBook12);
			gothamBook14.size = 14;
			
			/*	GOTHAM_MEDIUM	*/
			
			fontClassName = getDefinitionByName(GOTHAM_MEDIUM) as Class;
			font = new fontClassName();
			gothamMedium11.font = font.fontName;
			gothamMedium11.size = 11;
			gothamMedium11.letterSpacing = 0;
			gothamMedium11.leading = 0;
			
			gothamMedium12 = _cloneTextFormat(gothamMedium11);
			gothamMedium12.size = 12;
			
			gothamMedium10 = _cloneTextFormat(gothamMedium11);
			gothamMedium10.size = 10;
			
			topNavigationLandscapeTitle = _cloneTextFormat(gothamMedium11);
			
			/*	GOTHAM_BOLD	*/
			
			fontClassName = getDefinitionByName(GOTHAM_BOLD) as Class;
			font = new fontClassName();
			gothamBold10.font = font.fontName;
			gothamBold10.size = 10;
			gothamBold10.letterSpacing = 0;
			gothamBold10.leading = 0;
			
			gothamBold12 = _cloneTextFormat(gothamBold10);
			gothamBold12.size = 12;
			
			gothamBold14 = _cloneTextFormat(gothamBold10);
			gothamBold14.size = 14;
			
			/*	ARIAL_REGULAR	*/
			
			fontClassName = getDefinitionByName(ARIAL_REGULAR) as Class;
			font = new fontClassName();
			ArialRegular11.font = font.fontName;
			ArialRegular11.size = 11;
			ArialRegular11.letterSpacing = 0;
			ArialRegular11.leading = 4;
		}
		
		public static function formatTextField(__textfield:TextField, __text:String, __format:TextFormat, __autosize:String = "left", __mouseEnabled:Boolean = false, __underline:Boolean = false ):void
		{
			__textfield.autoSize = __autosize;
			__textfield.embedFonts = true;
			__textfield.htmlText = (__text == null) ? "" : __text.split("\r\n").join("\r");
			__format.underline = __underline;
			__textfield.setTextFormat(__format);
			__textfield.mouseEnabled = __mouseEnabled;
		}
		
		public static function formatHTMLTextField(__textfield:TextField, __text:String):void
		{
			var text:String = __text;
			text = text.replace("<title>" , "<font size='18'>");
			text = text.replace("</title>" , "</font>");
			text = text.replace("<title1>" , "<font size='18'>");
			text = text.replace("</title1>" , "</font>");
			text = text.replace("<title2>" , "<font size='18'>");
			text = text.replace("</title2>" , "</font>");
			text = text.replace("Zéro Un" , "<a href='http://www.zeroun.com'  target='_blank'>Zéro Un</a>");
			__textfield.htmlText = text;
			__textfield.embedFonts = true;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private static function _cloneTextFormat(__source:TextFormat):TextFormat
		{
			var tf:TextFormat 	= new TextFormat();
			tf.font				= __source.font;
			tf.size				= __source.size;
			tf.bold				= __source.bold;
			tf.color			= __source.color;
			tf.letterSpacing	= __source.letterSpacing;
			tf.leading			= __source.leading;
			return tf;
		}
		
	}
	
}