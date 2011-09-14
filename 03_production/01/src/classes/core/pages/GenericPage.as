package core.pages
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	// third-party classes
	import com.greensock.TweenMax;
	
	// project classes
	import core.Main;
	import core.Config;
	import core.events.PageEvent;
	import core.events.StageEvent;
	
	
	public class GenericPage extends Sprite implements IPage
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
		protected var _id			:String;
		protected var _isActive		:Boolean;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function GenericPage(__id:String, __args:* = null)
		{
			_id = __id;
			
			visible = false;
			alpha = 0;
			
			Main.instance.addEventListener(StageEvent.RESIZE, _onResize);
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
		
		public function reveal():void
		{
			TweenMax.to(this, .5, { autoAlpha:1, onComplete:_onRevealed } );
			_isActive = true;
			Main.instance.resizeLayout();
		}
		
		public function hide():void
		{
			_isActive = false;
			TweenMax.to(this, .5, { autoAlpha:0, onComplete:_onHidden} );
		}
		
		public function reload():void
		{
			reveal();
		}
		
		public function resize(__width:int = -1 , __height:int = -1):void
		{
			if (Config.DEBUG_MODE) traceDebug("resize> " + __width + ", " + __height);
		}
		
		/************************************************************
		 * Protected / private methods
		 ************************************************************/
		
		protected function _onResize(__event:StageEvent):void
		{
			if (_isActive) resize(__event.availableWitdh, __event.availableHeight);
		}
		
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