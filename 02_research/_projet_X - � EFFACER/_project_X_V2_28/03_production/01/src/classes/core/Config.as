package core
{
	public class Config
	{
		// core
		public static const SWF_ADDRESS_ENABLED				:Boolean = true;
		public static const MULTI_LANGUAGE					:Boolean = false;		// set to true if languages tag are used in the XML
		public static const DEFAULT_LOCALE					:String = "fr";			// must be set if MULTI_LANGUAGE is true
		
		public static const DEBUG_MODE						:Boolean = true;
		public static const APP_VERSION						:String = "1.0";
		public static const DEBUG_ALLOWED_URLS				:Array = ["http://127.0.0.1/", "http://projects.zeroun.com/", "file:///"];	// add here authorized urls otherwise the DebugWindow will not appear
		public static const LOCAL_ASSETS_BASE_PATH			:String = "../../00_local_assets/";

		public static const SITE_URL						:String = "http://127.0.0.1/projetX/_project_X_V2_28/03_production/01/deploy";
		public static const SITE_WIDTH						:int = 1000;
		public static const SITE_HEIGHT						:int = 584;

	}
}