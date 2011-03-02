package com.zeroun.components.slider
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import com.zeroun.utils.Numbers;
	
	
	
	public class Slider extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const SCROLL_DURATION		:Number = .5;
		public static const REVEAL_DURATION		:Number = .4;
		public static const HIDE_DURATION		:Number = .2;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
				
		protected var _slider				:Sprite = new Sprite();		// sprite containing all the elements of the slider
		//protected var _target				:Object;					// object affected by the slider
		protected var _scrollStep			:Number;					// scroll value when click on buttons
		protected var _sliderValue			:Number;					// slider value
		protected var _roundValues			:Boolean;					// should be always at true
		protected var _minCursorPosition	:Number;
		protected var _maxCursorPosition	:Number;					
		protected var _startDragging		:Boolean = false;			// indicates if the central cursor is dragging
		protected var _cursor				:MovieClip;
		protected var _background			:MovieClip;
		
		private var _isInitialized			:Boolean = false;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Slider()
		{
			_cursor = this["mcCursor"];
			_background = this["mcBackground"];
			_cursor.visible = false;
			
			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		}
		

		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initialize( __sliderValue:Number = 0,
									__scrollStep:Number = 1,
									__roundValues:Boolean = true)
		{
			_startDragging = false;
			
			_sliderValue = __sliderValue;
			setScrollStep(__scrollStep);
			_roundValues = __roundValues;
			
			_initializeAssets();
			_isInitialized = true;
			_initialize();
		}
		
		// value between 0 and 1
		public function setSliderValue(__value:Number, __animate:Boolean = true ):void
		{
			if (_isInitialized)
			{
				_sliderValue = __value;
				if (_sliderValue < 0)
				{
					_sliderValue = 0;
				}
				else if (_sliderValue > 1)
				{
					_sliderValue = 1;
				}
				
				_updateCursorPosition(Numbers.getRelative(_minCursorPosition, _maxCursorPosition, 0, 1, _sliderValue), __animate);
			}
		}
		
		// value in pixel
		public function setScrollStep(__value:int):void
		{
			_scrollStep = __value;
		}
		
		// in pixel
		public function setCursorPosition(__value:Number, __animate:Boolean = true ):void
		{
			if (_isInitialized)
			{
				var _cursorPosition:Number = __value;
				if (_cursorPosition < _minCursorPosition)
				{
					_cursorPosition = _minCursorPosition;
				}
				else if (_cursorPosition > _maxCursorPosition)
				{
					_cursorPosition = _maxCursorPosition;
				}
				
				_updateCursorPosition(_cursorPosition, __animate);
			}
		}
		
		public function getCursorPosition():Number
		{
			return _cursor.y;
		}
		
		public function get scrollStep():Number
		{
			return _scrollStep;
		}
		
		public override function toString():String
		{
			return ("com.zeroun.components.slider");
		}
		
		/************************************************************
		 * Protected methods
		 ************************************************************/
		
		protected function _initializeAssets():void
		{
			_cursor.stop();
			_background.stop();
			
			_cursor.buttonMode = true;
			_cursor.useHandCursor = true;
			
			_background.buttonMode = true;
			_background.useHandCursor = true;
			
			_slider.addChild(_background);
			_slider.addChild(_cursor);
			
			addChild(_slider);
		}
		
		protected function _onAddedToStage(__event:Event):void
		{
			_background.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBackground);
			_cursor.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor);
			_cursor.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpCursor);
			_cursor.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutCursor);
		}
		
		protected function _onRemovedFromStage(__event:Event):void
		{
			_background.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBackground);
			_cursor.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor);
			_cursor.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpCursor);
			_cursor.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOutCursor);
		}
		 
		protected function _initialize():void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_INITIALIZED));
			_minCursorPosition = _background.y;
			_maxCursorPosition = _background.y + _background.height - _cursor.height;
			setSliderValue(_sliderValue, false);
			_cursor.visible = true;
		}
		
		protected function _process(__value:Number):void
		{
			var cursorPosition:Number =	_cursor.y - __value;
			
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
		
		protected function _stopDragging():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _updateSliderValue);
			_cursor.stopDrag();
			_startDragging = false;
		}
		
		protected function _updateCursorPosition(__value:Number, __animate:Boolean):void
		{
			var duration:Number;
			//if (__animate)
			if (false)
			{
				// :TODO: make duration proportional to distance
				duration = Numbers.getRelative(.1, SCROLL_DURATION, 0, _maxCursorPosition - _minCursorPosition, Math.abs(_cursor.y - __value));
				TweenLite.to(_cursor, duration, { y:__value, onUpdate:_updateSliderValue} );
			}
			else
			{
				_cursor.y = __value;
				_updateSliderValue();
			}
		}
		
		protected function _updateSliderValue(__event:MouseEvent = null):void
		{
			dispatchEvent(new SliderEvent(SliderEvent.ON_UPDATED, Numbers.getRelative(0, 1, _minCursorPosition, _maxCursorPosition, _cursor.y)));
		}
		
		// BACKGROUND
		
		protected function _onMouseDownBackground(__event:MouseEvent):void
		{
			setCursorPosition(_slider.mouseY - _cursor.height / 2);
		}
		
		// CURSOR
		
		protected function _onMouseDownCursor(__event:MouseEvent):void
		{
			_startDragging = true;
			_cursor.startDrag(false, new Rectangle(_minCursorPosition, _cursor.y, 0, _maxCursorPosition - _minCursorPosition));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _updateSliderValue);
		}
		
		protected function _onMouseUpCursor(__event:MouseEvent):void
		{
			_stopDragging();
		}
		
		protected function _onMouseOutCursor(__event:MouseEvent):void
		{
			if (_startDragging)
			{
				stage.addEventListener(MouseEvent.MOUSE_UP, _checkReleaseOutside);
			}
		}
		
		protected function _checkReleaseOutside(__event:Event):void
		{
			if (_startDragging)
			{
				_stopDragging();
				stage.removeEventListener(MouseEvent.MOUSE_UP, _checkReleaseOutside);
			}
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		//...
		
		
	}
}