package core
{
	public class Config
	{
		// core
		public static const SWF_ADDRESS_ENABLED				:Boolean = true;
		public static const LOCALES							:Array = ["en", "fr"];	// the first item is the default locale; array can be empty when locales are not used
		
		public static const DEBUG_MODE						:Boolean = true;
		public static const DEBUG_ALLOWED_URLS				:Array = ["http://127.0.0.1/", "http://dev.zero-un.com/", "http://client.zero-un.com/","http://test.zero-un.lan"];	// list of urls where debugging is allowed (DebugWindow will not appear unless root.loaderInfo.url begins with one of these addreses)
		public static const LOCAL_ASSETS_BASE_PATH			:String = "../../00_local_assets/";		// use this when some assets are so big they have to be stored outside of the version folder and shared by all versions
		
		public static const SITE_WIDTH						:int = 1000;
		public static const SITE_HEIGHT						:int = 584;
	}
}