package core
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	import gs.TweenLite;
	import gs.easing.*;
	import com.asual.swfaddress.*;
	import com.zeroun.components.debugwindow.DebugWindow;
	import com.zeroun.components.menu.*;
	import com.zeroun.utils.SWFAddresses;
	
	import loader.LoaderAccessor;
	import loader.ILoadable;
	import core.*;
	import core.pages.*;
	
	
	public class Main extends MovieClip implements ILoadable
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _menu						:Menu;
		private var _pagesManager				:PagesManager;
		private var _waitForSWFAddress			:Boolean;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Main()
		{	
			// :NOTE: do not change this line - make sure core.swf has been loaded through loader.swf
			LoaderAccessor.detectLoader(this);
						
			// :NOTE: do not change this line - invisible until all assets have been loaded
			visible = false;
			if (Config.SWF_ADDRESS_ENABLED) 
			{
				_waitForSWFAddress = true;
				SWFAddress.addEventListener(SWFAddressEvent.INIT, _onInitSWFAddress)
			}
			else _waitForSWFAddress = false;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// this function is required by Loader.Main, do not remove or change its signature 
		public function getXMLFilesToLoad():Array
		{
			if (Config.MULTI_LANGUAGE)
			{
				if (this.root.loaderInfo.loaderURL.indexOf("file:///") != -1)
				{
					Content.locale = Config.DEFAULT_LOCALE;
				}
				else if (Config.SWF_ADDRESS_ENABLED)
				{
					Content.locale = SWFAddresses.getSWFAddressLanguage();
				}
				else
				{
					Content.locale = Config.DEFAULT_LOCALE;
				}
			}
			else
			{
				Content.locale = "";
			}
			
			var c:Array = new Array();
			// add XML files to load here...
			c.push("content.xml");
			return c;
		}
		
		// this function is required by Loader.Main, do not remove or change its signature 
		public function getOtherFilesToLoad():Array
		{
			Content.setContentXML(LoaderAccessor.getXML("content.xml"));
			
			// add loading event listeners here...
			LoaderAccessor.getLoader().addEventListener("intermediate", _onContentLoaded);
			LoaderAccessor.getLoader().addEventListener("complete", _onContentLoaded);
				
			var c:Array = new Array();
			// add loading events and file paths (mp3, swf, jpg, png...) here...
			c.push("event:intermediate");
			c.push("event:complete");
			return c;
		}
		
		// this function is required by Loader.Main, do not remove or change its signature 
		// extract the language from the adress
		public function waitForSWFAddress():Boolean
		{
			return _waitForSWFAddress;
		}
		
		// this function is required by Loader.Main, do not remove or change its signature 
		public function resizeLayout():void
		{
			// add code when stage is resized here...
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
					_reveal();
					break;
			}
		}

		// called when all assets have been loaded (see _onContentLoaded)
		private function _reveal() : void
		{
			// add code to initialize the interface here...
			_pagesManager = new PagesManager();
			addChild(_pagesManager);
			
			// init menu (has to be before SWFAdress is initialized)
			_menu = new Menu(XML(LoaderAccessor.getXML("content.xml").pages).page, RollDownMenuItem, Content.locale, 100, 0);
			_menu.x = 10;
			_menu.y = 10;
			_menu.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickMenu);
			_menu.addEventListener(MenuEvent.ON_CLICK_SUB_ITEM, _onClickMenu);
			addChild(_menu);
			
			// :NOTE: do not change this line - init SWFAddress
			if (Config.SWF_ADDRESS_ENABLED) 
			{
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, _onChangeSWFAddress)
			}
			else
			{
				_goToPage("");
			}
			
			// reveal
			TweenLite.from(this, .5, { autoAlpha:0 } );
			
			// init debug window (used by traceDebug)
			if (Config.DEBUG_MODE) new DebugWindow(this, Config.APP_VERSION);
		}
		
		// called after a change of address or a click on the menu
		private function _goToPage(__address:String):void
		{
			var pageId:String;
			var language:String;
			
			if (Config.SWF_ADDRESS_ENABLED)
			{
				if (Config.MULTI_LANGUAGE) 
				{
					pageId = SWFAddresses.getSWFAddressPageId();
					language = SWFAddresses.getSWFAddressLanguage();
				}
				else 
				{
					pageId = SWFAddress.getValue();
				}
				
				// add logic to navigate from one page to another here...
				if (Config.DEBUG_MODE) traceDebug("Page content for " + pageId);
				
				// check here the validity of the address
				switch (pageId)
				{
					case "":
					case "/":
						_onDefaultSWFAddress();
						return;
						break;
				}
			}
			else
			{
				switch (__address)
				{
					case "":
					case "/":
					case null:
						pageId = Content.getDefaultPageId();
						break;
					default:
						pageId = __address;
						break;
				}
				
				if (Config.MULTI_LANGUAGE) 
				{
					language = Content.locale;
				}
			}
			
			// call pagesManager
			_pagesManager.changePage(pageId, language);
			
			// :NOTE: the menu MUST be updated from this function
			_menu.select(pageId);
		}
		
		// called when an item in the main menu is clicked
		// :NOTE: the menu should not update itself but rather wait for _goToPage to tell it to update
		private function _onClickMenu(__event:MenuEvent):void
		{
			// add language to the address
			var addressLanguage:String = "";
			if (Config.SWF_ADDRESS_ENABLED && Config.MULTI_LANGUAGE) 
			{
				addressLanguage = "/" + Content.locale;
			}
			
			// when using SWFAddress, _goToPage is called automatically through _onChangeSWFAddress
			if (Config.SWF_ADDRESS_ENABLED) 
			{
				SWFAddress.setValue(addressLanguage + __event.itemId)
			}
			else 
			{
				_goToPage(addressLanguage + __event.itemId);
			}
		}
		
		// this function is required by SWFAddress, do not remove or change its signature 
		// called when the SWFAddress is initialized
		private function _onInitSWFAddress(__event:SWFAddressEvent):void
		{
			_waitForSWFAddress = false;
			SWFAddress.removeEventListener(SWFAddressEvent.INIT, _onInitSWFAddress)
			if (Config.DEBUG_MODE) traceDebug ("_onInitSWFAddress!! >> " + SWFAddress.getValue() + ":" + _waitForSWFAddress);
		}
		
		// this function is required by SWFAddress, do not remove or change its signature 
		// called when the SWFAddress value (i.e. the address) changes
		private function _onChangeSWFAddress(__event:SWFAddressEvent):void
		{
			var tmpLocale:String;
			
			if (Config.MULTI_LANGUAGE)
			{
				tmpLocale = SWFAddresses.getSWFAddressLanguage();
				// check if the language in the URL has been changed manually (if so has to reload the site with the correct URL)
				if (tmpLocale == Content.locale) 
				{
					_goToPage(__event.value);
				}
				else 
				{
					navigateToURL(new URLRequest(Config.SITE_URL + SWFAddress.getValue()), "_self");
				}
			}
			else 
			{
				_goToPage(__event.value);
			}
		}
		
		private function _onDefaultSWFAddress():void
		{
			// add language to the address
			var addressLanguage:String = "";
			if (Config.MULTI_LANGUAGE) 
			{
				addressLanguage = "/" + Config.DEFAULT_LOCALE;
			}
			
			SWFAddress.setValue(addressLanguage + Content.getDefaultPageId());
		}
		
	}
}