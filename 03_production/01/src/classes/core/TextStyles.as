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
		
		public static const ALIGN_LEFT				:String = "left";
		public static const ALIGN_RIGHT				:String = "right";
		public static const ALIGN_CENTER			:String = "center";
		public static const ALIGN_NONE				:String = "none";
		 
		public static const COLOR_WHITE				:int = 0xFFFFFF;
		public static const COLOR_BLACK				:int = 0x000000;
		
		// font instance names
		private static const ARIAL_REGULAR			:String = "ArialRegular";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public static var arialRegular11			:TextFormat = new TextFormat();
		public static var arialRegularBold12		:TextFormat = new TextFormat();
		
		
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
			
			/*	ARIAL_REGULAR	*/
			fontClassName = getDefinitionByName(ARIAL_REGULAR) as Class;
			font = new fontClassName();
			arialRegular11.font = font.fontName;
			arialRegular11.size = 11;
			arialRegular11.color = 0x00FF00;
			arialRegular11.letterSpacing = 0;
			arialRegular11.leading = 4;
			
			arialRegularBold12 = _cloneTextFormat(arialRegular11);
			arialRegularBold12.size = 12;
			arialRegularBold12.bold = true;
			
		}
		
		public static function formatTextField(__textfield:TextField, __text:String, __format:TextFormat = null, __autosize:String = ALIGN_LEFT, __mouseEnabled:Boolean = false, __underline:Boolean = false ):void
		{
			__textfield.autoSize = __autosize;
			__textfield.embedFonts = true;
			__textfield.htmlText = (__text == null) ? "" : __text.split("\r\n").join("\r");
			if (__format != null) 
			{
				__format.underline = __underline;
				__textfield.setTextFormat(__format);
			}
			
			__textfield.mouseEnabled = __mouseEnabled;
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