package com.zeroun.components.slider
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import com.zeroun.utils.Numbers;
	
	
	public class SliderH extends Slider
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
				
		//...
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SliderH()
		{
			super();
		};
		

		/************************************************************
		 * Public methods
		 ************************************************************/
		
		override public function getCursorPosition():Number
		{
			return _cursor.x;
		}
		
		
		/************************************************************
		 * Protected methods
		 ************************************************************/
		
		override protected function _initialize():void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_INITIALIZED));
			_minCursorPosition = _background.x;
			_maxCursorPosition = _background.x + _background.width - _cursor.width;
			setSliderValue(_sliderValue, false);
			_cursor.visible = true;
		}
		
		override protected function _process(__value:Number):void
		{
			var cursorPosition:Number =	_cursor.x - __value;
			
			if (cursorPosition < _minCursorPosition)
			{
				cursorPosition = _minCursorPosition;
			}
			else if (cursorPosition > _maxCursorPosition)
			{
				cursorPosition = _maxCursorPosition;
			}
			
			setCursorPosition(cursorPosition);
		}
		
		override protected function _updateCursorPosition(__value:Number, __animate:Boolean):void
		{
			var duration:Number;
			//if (__animate)
			if (false)
			{
				duration = Numbers.getRelative(.1, SCROLL_DURATION, 0, _maxCursorPosition - _minCursorPosition, Math.abs(_cursor.x - __value));
				TweenLite.to(_cursor, duration, { x:__value, onUpdate:_updateSliderValue} );
			}
			else
			{
				_cursor.x = __value;
				_updateSliderValue();
			}
		}

		override protected function _updateSliderValue(__event:MouseEvent = null):void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_UPDATED, Numbers.getRelative(0, 1, _minCursorPosition, _maxCursorPosition, _cursor.x)));
		}
		
		// BACKGROUND
		
		override protected function _onMouseDownBackground(__event:MouseEvent):void
		{
			setCursorPosition(_slider.mouseX - _cursor.width / 2);
		}
		
		// CURSOR
		
		override protected function _onMouseDownCursor(__event:MouseEvent):void
		{
			_startDragging = true;
			_cursor.startDrag(false, new Rectangle(_minCursorPosition, _cursor.y, _maxCursorPosition - _minCursorPosition, 0));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _updateSliderValue);
		}
		
	}
}