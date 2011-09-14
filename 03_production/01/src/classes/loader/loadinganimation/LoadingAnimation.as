package loader.loadinganimation
{
	import flash.display.MovieClip;
	import flash.events.*;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import loader.LoaderConfig;
	
	
	public class LoadingAnimation extends MovieClip implements ILoadingAnimation
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcLabel				:MovieClip;
		public var tweenLoadingPrct		:Number = 0;
		
		private var _isInitialized		:Boolean = false;
		
		
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
		
		public function reveal():void
		{
			if (!_isInitialized)
			{
				visible = true;
				_onLoadingProgress();
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
			// :NOTES: Tween duration must be > 0 because of initialization
			TweenLite.to(this, 1, { tweenLoadingPrct:__value, onUpdate:_onLoadingProgress, ease:Linear.easeNone } );
			if (__value == 100) 
			{
				TweenLite.killDelayedCallsTo(_onLoadingComplete);
				TweenLite.delayedCall(1, _onLoadingComplete);
			}
		}
		
		public function resizeLayout(__event:Event = null):void
		{
			x = Math.round(stage.stageWidth / 2);
			y = Math.round(stage.stageHeight / 2);
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _onLoadingProgress():void
		{
			// update the progress bar
			var n:uint = Math.round(tweenLoadingPrct);
			mcLabel.tfLabel.text = n + "%";
			var f:uint = 1 + Math.round((totalFrames - 1) * tweenLoadingPrct / 100);
			gotoAndStop(f);
		}
		
		private function _onLoadingComplete():void
		{
			dispatchEvent(new Event(LoaderConfig.LOADING_ANIMATION_COMPLETED));
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