package core.pages
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.Capabilities;
	
	import com.asual.swfaddress.*;
	import com.zeroun.utils.SWFAddresses;
	import com.zeroun.components.menu.MenuEvent;
	
	import core.Config;
	import core.Content;
	import core.Main;
	import core.LayersManager;
	import core.events.PageEvent;
	import core.pages.pages.*;
	
	
	public class PagesManager extends Sprite
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		private const ID_PAGE_NOT_FOUND				:String = "id_page_not_found";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _pagesContainer					:Sprite;		// sprite containing all pages
		private var _popupContainer					:Sprite;		// sprite containing all pages
		private var _pagesById						:Array;			// references to all pages
		private var _previousPageId					:String = "";
		private var _currentPageId					:String = "";
		private var _savedPageId					:String = "";	// used when a page is being hidden
		private var _savedPopupId					:String = "";	// used when a popup is being hidden
		private var _currentPopupId					:String = "";
		private var _hiddingPage					:Boolean		// indicates if a page is being hidden
		private var _hiddingPopup					:Boolean		// indicates if a popup is being hidden
		private var _pageArgs						:*;
		private var _isInitializable				:Boolean;		// true when SWFaddress is initalized (or when SWFAddress is not used)
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function PagesManager(__SWFAdressEnabled:Boolean = false )
		{	
			// this line is used when export in the IDE 
			if (Capabilities.playerType == "StandAlone" || Capabilities.playerType == "External")
			{
				_isInitializable = true;
			}
			else if (__SWFAdressEnabled)
			{
				SWFAddress.addEventListener(SWFAddressEvent.INIT, _onInitSWFAddress)
			}
			else 
			{
				_isInitializable = true;
			}
		}
		
		
		/************************************************************
		 * Getter setter
		 ************************************************************/
		
		// wait for SWFAddress to be initialized (always true if SWFAddress is not enabled)
		public function get isInitializable():Boolean
		{
			return _isInitializable;
		}
		
		public function get popupContainer():Sprite
		{
			return _popupContainer;
		}
		
		public function get currentPageId():String
		{
			return _currentPageId;
		}
		
		public function get currentPopupId():String
		{
			return _currentPopupId;
		}
		
		public function get currentPage():*
		{
			return _pagesById[_currentPageId];
		}
		
		public function get currentPopup():*
		{
			return _pagesById[_currentPopupId];
		}
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initialize():void
		{
			_pagesContainer	= new Sprite();
			addChild(_pagesContainer);
			
			_popupContainer = new Sprite();
			
			_pagesById = new Array();
			
			// :NOTE: do not change this line - init SWFAddress
			if (Config.SWF_ADDRESS_ENABLED) 
			{
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, _onChangeSWFAddress);
			}
			else
			{
				_goToAddress("");
			}
		}
		
		// called when an item in the main menu is clicked
		// :NOTE: the menu should not update itself but rather wait for goToAdress to tell it to update
		public function onClickMenu(__event:MenuEvent):void
		{
			gotoPage(__event.itemId);
		}
		
		// called when the background of a popup is clicked
		public function onClickPopupBackground(__event:*):void
		{
			_pagesById[_currentPopupId].removeEventListener(PageEvent.POPUP_CLOSE_REQUEST, onClickPopupBackground);
			// the _currentPageId contains the id of the page under the popup
			if (Content.isPageLinkable(_currentPopupId))
			{
				gotoPage(_currentPageId);
			}
			else
			{
				_closePopup();
			}
		}
		
		// go to a page
		public function gotoPage(__pageId:String, __args:* = null):void
		{
			_pageArgs = __args;
			// add language to the address
			var addressLocale:String = "";
			var linkablePage:Boolean = Content.isPageLinkable(__pageId);
			// when using SWFAddress, goToAdress is called automatically through _onChangeSWFAddress
			if (Config.SWF_ADDRESS_ENABLED && linkablePage && (__pageId != _currentPageId || (__pageId == _currentPageId && Main.layersManager.popupIsOpen)))
			{
				if (Config.LOCALES.length > 0) 
				{
					addressLocale = "/" + Content.locale;
				}
				SWFAddress.setValue(addressLocale + __pageId);
				_pageArgs = __args;
			}
			else 
			{
				_goToAddress(__pageId, linkablePage);
			}
		}
		
		public function changeLocale(__locale:String):void
		{
			if (__locale != Content.locale)
			{
				Content.locale = __locale;
				
				// add language to the address
				var addressLocale:String = "";
				
				// when using SWFAddress, goToAdress is called automatically through _onChangeSWFAddress
				if (Config.SWF_ADDRESS_ENABLED) 
				{
					if (Config.LOCALES.length > 0) 
					{
						addressLocale = "/" + Content.locale;
					}
					navigateToURL(new URLRequest(SWFAddress.getBaseURL() + "/redirect.php?" + addressLocale + _currentPageId), "_self");
				}
				else 
				{
					_goToAddress(_currentPageId);
				}
			}
		}
		
		public function getPageById(__id:String):GenericPage
		{
			return _pagesById[__id];
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _hideAndRevealPage(__pageId:String, __canReload:Boolean = true):void
		{
			// the current page is the same => force page to reload
			if (_currentPageId == __pageId)
			{
				if (__canReload)
				{
					_pagesById[_currentPageId].reload();
				}
			}
			// the current page is different from the previous one
			else if (_currentPageId != "" && _currentPageId != __pageId)
			{
				_previousPageId = _currentPageId;
				// :NOTE: invalidate the _currentPageId while hiding and save the next pageId to show
				_savedPageId = __pageId;
				_currentPageId = "";
				_hiddingPage = true;
				
				// :NOTE: hide function has to be called after savedPageId is set 
				// hide and wait for the page to be hidden
				_pagesById[_previousPageId].addEventListener(PageEvent.PAGE_HIDDEN, _onPageHidden);
				_pagesById[_previousPageId].hide();
			}
			// page is being hidden so the next Id has to be updated and wait for the hiding to be complete
			else if (_hiddingPage)
			{
				// update the next page to be seen will hidding the previous one
				_savedPageId = __pageId;
			}
			else
			{
				// reveal directly the page
				_savedPageId = __pageId;
				_previousPageId = "";
				_revealPage(_savedPageId);
			}
		}
		
		// reveal the page
		private function _revealPage(__pageId:String):void
		{
			// :NOTE: prevents a page to be revealed when another is finishing hidding (happens when reveal is called while hidding)
			_currentPageId = __pageId;
			_savedPageId = "";
			
			// :NOTE: addChild must be generaly placed before a reveal, like that the instance has access to the stage property
			_pagesContainer.addChild(_pagesById[_currentPageId]);
			_pagesById[_currentPageId].reveal();
		}
		
		// called when the current page is hidden
		private function _onPageHidden(__event:PageEvent):void
		{
			var id:String = __event.pageId;
			_pagesById[id].removeEventListener(PageEvent.PAGE_HIDDEN, _onPageHidden);
			_pagesContainer.removeChild(_pagesById[id]);
			
			_hiddingPage = false;
			
			if (_savedPageId != "")
			{
				_revealPage(_savedPageId);
			}
		}
		
		private function _hideAndRevealPopup(__pageId:String):void
		{
			// the current popup is the same => force page to reload
			if (_currentPopupId == __pageId)
			{
				_pagesById[_currentPopupId].reload();
			}
			// the current popup is different from the previous one
			else if (_currentPopupId != "" && _currentPopupId != __pageId)
			{
				_savedPopupId = __pageId;
				_closePopup(false);
			}
			// page is being hidden so the next Id has to be updated and wait for the hiding to be complete
			else if (_hiddingPopup)
			{
				// update the next popup to be seen will hidding the previous one
				_savedPopupId = __pageId;
			}
			else
			{
				_openPopup(__pageId);
			}
		}
		
		private function _openPopup(__pageId:String):void
		{
			_currentPopupId = __pageId;
			_savedPopupId = "";
			Main.layersManager.showOpaqueBackground(LayersManager.POPUP_CONTENT_TYPE);
			_popupContainer.addChild(_pagesById[_currentPopupId]);
			_pagesById[_currentPopupId].reveal();
			_pagesById[_currentPopupId].addEventListener(PageEvent.POPUP_CLOSE_REQUEST, onClickPopupBackground);
			dispatchEvent(new PageEvent(PageEvent.POPUP_OPENED, _currentPopupId));
		}
		
		private function _closePopup(__hideBackground:Boolean = true):void
		{
			_hiddingPopup = true;
			if (__hideBackground)
			{
				Main.layersManager.hideOpaqueBackground(LayersManager.POPUP_CONTENT_TYPE);
			}
			_pagesById[_currentPopupId].addEventListener(PageEvent.PAGE_HIDDEN, _onPopupHidden);
			_pagesById[_currentPopupId].hide();
		}
		
		// called when a popup is about to be closed
		private function _onClosePopupRequest(__event:*):void
		{
			_pagesById[_currentPopupId].removeEventListener(PageEvent.POPUP_CLOSE_REQUEST, _onClosePopupRequest);
			// the _currentPageId contains the id of the page under the popup
			if (Content.isPageLinkable(_currentPopupId))
			{
				gotoPage(_currentPageId);
			}
			else
			{
				_closePopup();
			}
		}
		
		// called when the current popup is hidden
		private function _onPopupHidden(__event:PageEvent):void
		{
			_pagesById[_currentPopupId].removeEventListener(PageEvent.PAGE_HIDDEN, _onPopupHidden);
			_popupContainer.removeChild(_pagesById[_currentPopupId]);
			
			_hiddingPopup = false;
			_currentPopupId = "";
			
			if (_savedPopupId != "")
			{
				_openPopup(_savedPopupId);
			}
			
		}
		
		// called after a change of address or a click on the menu
		private function _goToAddress(__address:String, __linkablePage:Boolean = true):void
		{
			var pageId:String;
			var locale:String;
			
			// get the pageId and the language
			if (Config.SWF_ADDRESS_ENABLED && __linkablePage)
			{
				if (Config.LOCALES.length > 0) 
				{
					locale = SWFAddresses.getSWFAddressLocale();
					// locale may be null if the adress doesn't contain it
					locale = (locale == null) ? Config.LOCALES[0] : locale;
					if (!Content.isValidLocale(locale))
					{
						pageId = ID_PAGE_NOT_FOUND;
					}
					else
					{
						pageId = SWFAddresses.getSWFAddressPageId();
					}
				}
				else
				{
					pageId = __address;
				}
			}
			else
			{
				if (Config.LOCALES.length > 0) 
				{
					locale = Content.locale;
					if (!Content.isValidLocale(locale))
					{
						pageId = ID_PAGE_NOT_FOUND;
					}
					else
					{
						pageId = __address;
					}
				}
				else
				{
					pageId = __address;
				}
			}
			
			pageId = _getPage(pageId);
			
			if (Config.DEBUG_MODE) traceDebug("PagesManager._goToAddress >> __address: " + __address + " pageId: " + pageId + " locale: " + locale + " => args :" + _pageArgs);
			
			//  check the type of the page and open it
			if (Content.getPageType(pageId) == PageType.PAGE)
			{
				if (Main.layersManager.popupIsOpen)
				{
					_closePopup();
					// back to the previous page but without reloading it;
					_hideAndRevealPage(pageId, false);
				}
				else
				{
					_hideAndRevealPage(pageId);
				}
			}
			else
			{
				_hideAndRevealPopup(pageId);
			}
			
			dispatchEvent(new PageEvent(PageEvent.PAGE_CHANGED, pageId));
			
			// :NOTE: the menu MUST be updated from this function and nowhere else
			if (__linkablePage)
			{
				if (Main.pagesMenu != null)
				{
					Main.pagesMenu.select(pageId);
				}
			}
		}
		
		/************************************************************
		 * SWFADDRESS methods
		 ************************************************************/
		
		private function _getPage(__pageId:String):String
		{
			var pageId:String;
			switch(__pageId)
			{
				case null:
				case "":
				case "/":
				case "/home/":
					pageId = Content.getDefaultPageId();
					if (_pagesById[__pageId] == null )	_pagesById[__pageId] = new SamplePage(__pageId, _pageArgs);
					break;
				case "/portfolio/1/":
					pageId = __pageId;
					if (_pagesById[__pageId] == null )	_pagesById[__pageId] = new SamplePopup(__pageId, _pageArgs);
					break;
				case "/portfolio/":
				case "/portfolio/2/":
				case "/contact/":
				case "/contact/join/":
					pageId = __pageId;
					if (_pagesById[__pageId] == null )	_pagesById[__pageId] = new SamplePage(__pageId, _pageArgs);
					break;
				// page not found (404 error)
				default:
					pageId = ID_PAGE_NOT_FOUND;
					if (_pagesById[__pageId] == null )	_pagesById[__pageId] = new SamplePage(__pageId, _pageArgs);
					break;
			}
			return pageId;
		}
		 
		// this function is required by SWFAddress, do not remove or change its signature 
		// called when the SWFAddress is initialized
		private function _onInitSWFAddress(__event:SWFAddressEvent):void
		{
			_isInitializable = true;
			SWFAddress.removeEventListener(SWFAddressEvent.INIT, _onInitSWFAddress)
			if (Config.DEBUG_MODE) traceDebug ("PagesManager._onInitSWFAddress >> " + SWFAddress.getValue() + ":" + __event.value);
		}
		
		// this function is required by SWFAddress, do not remove or change its signature 
		// called when the SWFAddress value (i.e. the address) changes
		private function _onChangeSWFAddress(__event:SWFAddressEvent):void
		{
			if (Config.DEBUG_MODE) traceDebug ("PagesManager._onChangeSWFAddress >> " + __event.value);
			
			if (Config.LOCALES.length > 0)
			{
				// check if the language in the URL has been changed manually (if so has to reload the site with the correct URL)
				if (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX")
				{
					if (SWFAddresses.getSWFAddressLocale() == null || SWFAddresses.getSWFAddressLocale() == Content.locale)
					{
						_goToAddress(__event.value);
					}
					else
					{
						// forces the page to reload;
						navigateToURL(new URLRequest(SWFAddress.getBaseURL() + "/redirect.php?" + SWFAddress.getValue()), "_self");
					}
				}
				else 
				{
					_goToAddress(__event.value);
				}
			}
			else
			{
				_goToAddress(__event.value);
			}
		}
	}
}