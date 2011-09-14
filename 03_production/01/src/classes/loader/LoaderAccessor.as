package loader
{
	import loader.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	
	public class LoaderAccessor
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		private static const LOADER_SWF_URL	:String = "loader.swf";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private static var _instanceOfMain	:MovieClip;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function LoaderAccessor(){}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public static function detectLoader(__instance:MovieClip):void
		{
			// save reference to the main instance
			_instanceOfMain = __instance;
			// has the current swf been launched directly instead of through loader.swf?
			if (_instanceOfMain.root.loaderInfo.loaderURL == _instanceOfMain.root.loaderInfo.url)
			{
				// display message in traceDebug panel
				traceDebug("* * * * * * * * * * * * * * * * * * * * * * * * * *");
				traceDebug("*                                                 *");
				traceDebug("*  WARNING!                                       *");
				traceDebug("*  You should not test this movie clip directly.  *");
				traceDebug("*  Please use loader.swf instead.                 *");
				traceDebug("*                                                 *");
				traceDebug("* * * * * * * * * * * * * * * * * * * * * * * * * *");
				
				// only if we're in the Flash IDE, start loading loader.swf and add it to the display list
				if (Capabilities.playerType == "External")
				{
					var l:Loader = new Loader();
					var f:Function = function(__event:Event) {
						l.contentLoaderInfo.removeEventListener(Event.COMPLETE, f);
					}
					l.contentLoaderInfo.addEventListener(Event.COMPLETE, f);
					l.load(new URLRequest(LOADER_SWF_URL));
					_instanceOfMain.parent.addChild(l);
				}
				
				// remove current swf from the display list
				_instanceOfMain.parent.removeChild(_instanceOfMain);
			}
		}
		
		public static function getLoader():ILoaderMain
		{
			return _instanceOfMain.root.loaderInfo.loader.parent as ILoaderMain;
		}
		
		public static function hideLoadingAnimation(__quick:Boolean = false):void
		{
			return getLoader().hideLoadingAnimation(__quick);
		}
		
		public static function getXML(__path:String):XML
		{
			return getLoader().getXML(__path);
		}
		
		public static function getAsset(__path:String):*
		{
			return getLoader().getAsset(__path);
		}
		
		public static function getFlashVar(__var:String):String
		{
			return getLoader().getFlashVar(__var);
		}
		
		public static function getDownloadSpeed():Number
		{
			return getLoader().getDownloadSpeed();
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
}