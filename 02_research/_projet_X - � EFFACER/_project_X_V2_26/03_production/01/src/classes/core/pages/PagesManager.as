package core.pages
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.getDefinitionByName;
	import gs.TweenLite;
	import gs.easing.*;
	import com.asual.swfaddress.*;
	
	import core.*;
	
	
	public class PagesManager extends Sprite
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _pagesContainer					:Sprite;		// sprite containing all pages
		private var _pagesById						:Array;			// references to all pages
		private var _previousPageId					:String = "";
		private var _currentPageId					:String = "";
		private var _savedPageId					:String = "";	// used when a page is being hidden
		private var _hiddingPage					:Boolean		// indicates if a page is being hidden
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function PagesManager()
		{	
			_pagesById = new Array();
			var pages:Array = Content.getPages();
			
			// create all the pages
			for (var i:int = 0 ; i < pages.length ; i++)
			{
				_pagesById[pages[i].id] = new GenericPage(pages[i].id);
			}
			
			_pagesContainer	= new Sprite();
			addChild(_pagesContainer)
		}
		
		/************************************************************
		 * Public methods
		 ************************************************************/
			
		public function changePage(__pageId:String, __language:String = ""):void
		{
			traceDebug("_onChangePage>>" + __pageId + " language:" + __language);
			
			// add here logic ...
			
			if (__pageId != "") _hideAndRevealPage(__pageId);
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _hideAndRevealPage(__pageId:String):void
		{
			// the current page is different from the previous one
			if (_currentPageId != "" && _currentPageId != __pageId)
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
			
			// add here logic ...
			
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
			
			if (_savedPageId != "")
			{
				_revealPage(_savedPageId);
			}
			
			_hiddingPage = false;
		}
	}
}