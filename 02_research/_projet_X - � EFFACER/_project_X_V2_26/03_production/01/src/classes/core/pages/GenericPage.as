package core.pages
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	// third-party classes
	import gs.TweenLite;
	import gs.easing.*;
	import com.zeroun.utils.Numbers
	
	// project classes
	// ...
	
	
	public class GenericPage extends Sprite implements IPageable
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
		protected var _id		:String;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function GenericPage(__id:String)
		{
			_id = __id;
			
			var child:Shape = new Shape();
            child.graphics.beginFill(Numbers.getRandomIntBetween(0,16777215));
            child.graphics.lineStyle(Numbers.getRandomIntBetween(0,10), Numbers.getRandomIntBetween(0,16777215));
            child.graphics.drawRoundRect(50, 50, Numbers.getRandomIntBetween(20,300), Numbers.getRandomIntBetween(20,300), Numbers.getRandomIntBetween(0,10));
            child.graphics.endFill();
            addChild(child);

		}
		
		
		/************************************************************
		 * Getters / setters
		 ************************************************************/
		
		public function get id():String
		{
			return _id;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function reveal(... args):void
		{
			// add here motion ...
			_onRevealed();
		}
		
		public function hide(... args):void
		{
			// add here motion ...
			_onHidden();
		}
		
		public function resize(... args):void
		{
			// add here logic ...
		}


		/************************************************************
		 * Protected / private methods
		 ************************************************************/
		
		protected function _onRevealed():void
		{
			dispatchEvent(new PageEvent(PageEvent.PAGE_REVEALED, _id));
		}
		
		protected function _onHidden():void
		{
			// :NOTE: don't forget to erase all unused data
			dispatchEvent(new PageEvent(PageEvent.PAGE_HIDDEN, _id));
		}
	}
	
}