package core
{
	import flash.display.*;
	import flash.events.*;
	
	import com.zeroun.components.debugwindow.DebugWindow;
	import com.zeroun.components.menu.*;
	
	import loader.LoaderAccessor;
	import loader.LoaderConfig;
	import loader.ILoadable;
	import core.pages.PagesManager;
	import core.events.StageEvent;
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
	
	
	public class Main extends MovieClip implements ILoadable
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _pagesMenu					:PagesMenu;			// menu for pages of the site
		private var _pagesManager				:PagesManager;		// everything concerning pages is handle by page manager
		private var _layersManager				:LayersManager;		// manage the depth of the display list
		
		private static var _this				:Main;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Main()
		{	
			// :NOTE: do not change this line - make sure core.swf has been loaded through loader.swf
			LoaderAccessor.detectLoader(this);
			
			// :NOTE: do not change this line - create the pageManager instance to handle SWFAddress
			_pagesManager = new PagesManager(Config.SWF_ADDRESS_ENABLED);
			
			// static accessor
			_this = this;
			
		}
		
		
		/************************************************************
		 * Getter setter
		 ************************************************************/
		
		public static function get pagesMenu():PagesMenu
		{
			return _this._pagesMenu;
		}
		
		public static function get pagesManager():PagesManager
		{
			return _this._pagesManager;
		}
		
		public static function get layersManager():LayersManager
		{
			return _this._layersManager;
		}
		
		public static function get instance():Main
		{
			return _this;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// this function is required by Loader.Main, do not change it. wait for SWFAddress to be initialized if enabled (always true if SWFAdress is not enabled)
		public function contentIsInitializable():Boolean
		{
			return _pagesManager.isInitializable;
		}
		 
		// this function is required by Loader.Main, do not remove or change its signature. put here all XML to load
		public function getXMLFilesToLoad():Array
		{
			// set the locale based on the current context (SWFAddress, list of languages in Config, etc.)
			Content.autoDetermineLocale();
			
			// add XML files to load here...
			return [LoaderAccessor.getFlashVar(LoaderConfig.FLASH_VARS_BASE_PATH) + "content.xml"];
		}
		
		// this function is required by Loader.Main, do not remove or change its signature. put here all other assets to load
		public function getOtherFilesToLoad():Array
		{
			// add loading event listeners here...
			LoaderAccessor.getLoader().addEventListener("intermediate", _onContentLoaded);
			LoaderAccessor.getLoader().addEventListener("complete", _onContentLoaded);
			LoaderAccessor.getLoader().addEventListener(LoaderConfig.LOADING_ANIMATION_COMPLETED, _onContentLoaded);
			
			Content.setContentXML(LoaderAccessor.getXML(LoaderAccessor.getFlashVar(LoaderConfig.FLASH_VARS_BASE_PATH) + "content.xml"));
				
			// add file paths (mp3, swf, jpg, png...) and loading events here...
			return ["event:intermediate", "event:complete"];
		}
		
		// this function is required by Loader.Main, do not remove or change its signature. called everytime the stage is resized.
		public function resizeLayout(__width:int = -1, __height:int = -1):void
		{
			// from this point an event is dispatched. so every instances has to listen to this event to be resized
			var w:int = (__width == -1) ? stage.stageWidth : __width;
			var h:int = (__height == -1) ? stage.stageHeight : __height;
			
			dispatchEvent(new StageEvent(StageEvent.RESIZE, w, h));
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// called when some assets have been loaded (see getOtherFilesToLoad)
		private function _onContentLoaded(__event:Event):void
		{
			switch(__event.type)
			{
				case "intermediate":
					//...
					break;
				case "complete":
					//...
					break;
				case LoaderConfig.LOADING_ANIMATION_COMPLETED:
					_initialize();
					break;
			}
		}

		// called when all assets have been loaded (see _onContentLoaded)
		private function _initialize() : void
		{
			// init debug window (used by traceDebug)
			//:NOTE: MovieClip(root).versionNumber is written by the jsfl.
			var version:int = (MovieClip(root).hasOwnProperty("versionNumber")) ? MovieClip(root).versionNumber : 0;
			if (Config.DEBUG_MODE) new DebugWindow(MovieClip(root), Config.DEBUG_ALLOWED_URLS, version);
			else
			{
				var customContextMenu:ContextMenu = new ContextMenu();
				var customContextMenuItem:ContextMenuItem = new ContextMenuItem("V." + version);
				customContextMenu.customItems.push(customContextMenuItem);
				MovieClip(root).contextMenu = customContextMenu;
			}
			// intialize all the fonts
			TextStyles.initializeTextFormats();
			
			// create the main view
			_layersManager = new LayersManager();
			
			// intialize menu
			_pagesMenu = new PagesMenu(XML(LoaderAccessor.getXML(LoaderAccessor.getFlashVar(LoaderConfig.FLASH_VARS_BASE_PATH) + "content.xml").pages).page, PagesMenuItem, Content.locale);
			_pagesMenu.x = 10;
			_pagesMenu.y = 10;
			_pagesMenu.addEventListener(MenuEvent.ON_CLICK_ITEM, _pagesManager.onClickMenu);
			_pagesMenu.addEventListener(MenuEvent.ON_CLICK_SUB_ITEM, _pagesManager.onClickMenu);
			_layersManager.menuLayer.addChild(_pagesMenu);
			
			// pagesManager has to be initialized to be used
			_pagesManager.initialize();
			_layersManager.contentLayer.addChild(_pagesManager);
			_layersManager.popupLayer.addChild(_pagesManager.popupContainer);
			
			// reveal the main view
			addChild(_layersManager);
			_layersManager.reveal();
			
			// reposition the elements
			resizeLayout();
		}
	}
}