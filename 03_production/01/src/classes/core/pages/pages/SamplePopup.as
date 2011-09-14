package core.pages.pages
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	// third-party classes
	import com.greensock.TweenMax;
	import com.zeroun.utils.Numbers
	
	// project classes
	import core.events.PageEvent;
	
	
	public class SamplePopup extends SamplePage
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		// elements on stage
		// ...
		
		// other variables
		// ...
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SamplePopup(__id:String, __args:* = null)
		{
			super(__id, __args);
			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
		}
		
		
		/************************************************************
		 * Getters / setters
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// ...


		/************************************************************
		 * Protected / private methods
		 ************************************************************/
		
		private function _onMouseDown(__event:MouseEvent):void
		{
			dispatchEvent(new PageEvent(PageEvent.POPUP_CLOSE_REQUEST, _id));
		}
	}
	
}