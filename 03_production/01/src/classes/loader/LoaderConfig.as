package loader
{
	import flash.display.*;
	
	public class LoaderConfig
	{

		// stage
		public static const STAGE_SCALE_MODE			:String = StageScaleMode.NO_SCALE;
		public static const STAGE_SCALE_ALIGN			:String = StageAlign.TOP_LEFT;
		
		// loading
		public static const FLASH_VARS_BASE_PATH		:String = "swfRootPath";
		public static const LOADING_ANIMATION_COMPLETED	:String = "loading_animation_completed";
		public static const CORE_SWF_FILENAME			:String = "core.swf";
		public static const CORE_SWF_PERCENTAGE			:Number = 95;				// portion of the loading bar allocated to core.swf
		public static const CORE_XML_PERCENTAGE			:Number = 5;				// portion of the loading bar allocated to the main XML file(s)
																				// this means that the portion of the loading bar allocated to the other external assets (jpeg, mp3, etc.) is 100 - CORE_SWF_PERCENTAGE - CORE_XML_PERCENTAGE
	}
	
}