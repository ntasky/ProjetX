package com.zeroun.components.videoplayer
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	
	// third-party classes
	import com.greensock.TweenMax;
	import com.greensock.easing.Quint;
	
	// project classes
	//...
	
	
	public class Buffering extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		private const TIME_TO_REVEAL_A_FOLLOWER					:Number = 0.3;
		private const TIME_TO_HIDE_A_FOLLOWER					:Number = 2;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _rotation	:int = 0;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Buffering()
		{}
		
		
		/************************************************************
		 * Getter & Setter methods
		 ************************************************************/
		
		//***
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function startBuffering():void
		{
			alpha = 1;
			addEventListener(Event.ENTER_FRAME, _update);
		}
		
		public function stopBuffering():void
		{
			alpha = 0;
			removeEventListener(Event.ENTER_FRAME, _update);
		}
		
		public function reveal():void
		{
			visible = true;
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		 
		protected function _update(__event:Event):void
		{
			_rotation += 6;
			
			var follower:Shape = new Shape();
			follower.graphics.beginFill(0x000000);
			follower.graphics.drawRect(-1,-10, 2, 20);
			follower.graphics.endFill();
			follower.rotation = _rotation;
			follower.alpha = 0;
			addChild(follower);
			
			TweenMax.to(follower, TIME_TO_REVEAL_A_FOLLOWER, { overwrite:1, alpha:0.8, ease:Quint.easeOut, onComplete:function()
			{
				TweenMax.to(follower, TIME_TO_HIDE_A_FOLLOWER, { overwrite:1, alpha:0, ease:Quint.easeOut, onComplete:function() 
				{
					removeChild(follower);
					follower = null;
				}} );
			}});
		}
	}
}