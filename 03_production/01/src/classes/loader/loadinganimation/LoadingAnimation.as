package loader.loadinganimation
{
	import flash.display.MovieClip;
	import flash.events.*;
	
	
	public class LoadingAnimation extends MovieClip implements ILoadingAnimation
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcLabel						:MovieClip;
		
		private var _isInitialized				:Boolean = false;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function LoadingAnimation()
		{
			alpha = 0;
			visible = false;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function show():void
		{
			if (!_isInitialized)
			{
				visible = true;
				_updateProcess(0);
				_isInitialized = true;
			}
			if (hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, _hideProcess);
			}
			addEventListener(Event.ENTER_FRAME, _revealProcess);
		}
		
		public function hide():void
		{
			_isInitialized = false;
			if (hasEventListener(Event.ENTER_FRAME))
			{
				removeEventListener(Event.ENTER_FRAME, _revealProcess);
			}
			addEventListener(Event.ENTER_FRAME, _hideProcess);
		}
		
		public function update(__value:Number):void
		{
			_updateProcess(__value);
		}
		
		public function resizeLayout(__event:Event = null):void
		{
			x = Math.round(stage.stageWidth / 2);
			y = Math.round(stage.stageHeight / 2);
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _updateProcess(__value:Number):void
		{
			// update the progress bar
			var n:uint = Math.round(__value);
			mcLabel.tfLabel.text = n + "%";
			var f:uint = 1 + Math.round((totalFrames - 1) * __value / 100);
			gotoAndStop(f);
		}
		
		private function _revealProcess(__event:Event):void
		{
			alpha += 0.1;

			if (alpha >= 1)
			{
				removeEventListener(Event.ENTER_FRAME, _revealProcess);
			}
		}
		
		private function _hideProcess(__event:Event):void
		{
			alpha -= 0.1;

			if (alpha <= 0)
			{
				visible = false;
				removeEventListener(Event.ENTER_FRAME, _hideProcess);
				if (parent.contains(this))
				{
					parent.removeChild(this);
				}
			}
		}
		
	}
	
}