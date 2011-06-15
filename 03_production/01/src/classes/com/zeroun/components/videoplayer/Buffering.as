package com.zeroun.components.videoplayer
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	
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
		
		public var tfPrct	:TextField;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Buffering()
		{
			alpha = 0;
			visible = false;
			stop();
		}
		
		
		/************************************************************
		 * Getter & Setter methods
		 ************************************************************/
		
		//***
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function startBuffering():void
		{
			try { removeEventListener(Event.ENTER_FRAME, _update); } catch (e:Error) { };
			addEventListener(Event.ENTER_FRAME, _update);
		}
		
		public function stopBuffering():void
		{
			try { removeEventListener(Event.ENTER_FRAME, _update); } catch (e:Error) { };
		}
		
		public function reveal():void
		{
			TweenMax.to(this, .5, { autoAlpha:1 } );
		}
		
		public function hide():void
		{
			TweenMax.to(this, .5, { autoAlpha:0 } );
		}
		
		public function update(__prct:int):void
		{
			tfPrct.text = __prct + "%";
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		 
		protected function _update(__event:Event):void
		{
			play();
		}
	}
}