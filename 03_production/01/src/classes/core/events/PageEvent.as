package core.events
{
	import flash.events.*;
	
	public class PageEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const PAGE_REVEALED			:String = "page_revealed";			// event dispatched when a page is revealed
		public static const PAGE_HIDDEN				:String = "page_hidden";			// event dispatched when a page is hidden
		public static const PAGE_CHANGED			:String = "page_changed";			// event dispatched when a change page occurs
		public static const POPUP_CLOSE_REQUEST		:String = "popup_close_request";	// event dispatched when a popup is about to be closed
		public static const POPUP_OPENED			:String = "popup_opened";			// event dispatched when a popup is opened
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var pageId						:String;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function PageEvent(__type:String, __id:String)
		{
			super(__type, false, false)
			pageId = __id;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new PageEvent(type, pageId);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}