package com.zeroun.components.scrollbar
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	import com.zeroun.utils.Numbers;
	
	
	public class ScrollbarH extends Scrollbar
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _w						:int;
		private var _cursorWidth			:Number;
		private var _backgroundWidth		:Number;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function ScrollbarH()
		{
			super();
		};
		

		/************************************************************
		 * Public methods
		 ************************************************************/

		// ...
		
		/************************************************************
		 * Protected methods
		 ************************************************************/
		
		override protected function _setProperties(__x:Number, __y:Number, __w:Number = Number.MAX_VALUE):void
		{
			if (_autoPosition)
			{
				if (__w == Number.MAX_VALUE)
				{
					switch(_scrollType)
					{
						case OBJECT_TYPE:
							__w = _mask.width;
							break;
						default:
							traceDebug ("ERROR");
							break;
					}
				}
				x = __x;
				y = __y;
			}
			else
			{
				x = _x;
				y = _y;
				__w = _w;
			}
			_arrow1.x = 0;
			_arrow1.y = 0;
			_arrow2.x = _arrow1.x + __w - _arrow2.width;
			_arrow2.y = _arrow1.y;
			_background.x = _arrow1.x + _arrow1.width;
			_background.y = _arrow1.y;
			_background.width = _arrow2.x - _background.x;
			_backgroundWidth = _arrow2.x - _background.x;
			_cursor.y = _arrow1.y;
			_updateCursorPosition();
		}
		 
		override protected function _setListenners(__value:Boolean = true ):void
		{
			if (__value)
			{
				_arrow1.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownUpArrow);
				_arrow1.addEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_arrow1.addEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_arrow2.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDownArrow);
				_arrow2.addEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_arrow2.addEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_background.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBackground);
				_background.addEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_background.addEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_cursor.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor);
				_cursor.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpCursor);
				_cursor.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutCursor);
			}
			else
			{
				_arrow1.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownUpArrow);
				_arrow1.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_arrow1.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_arrow2.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDownArrow);
				_arrow2.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_arrow2.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_background.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBackground);
				_background.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess);
				_background.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess);
				_cursor.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor);
				_cursor.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpCursor);
				_cursor.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOutCursor);
			}
		}
		
		override protected function _selectArrows():void
		{
			if (_containsInstance("mcArrowLeft")) _arrow1 = this["mcArrowLeft"];
			else _arrow1 = new MovieClip();
			if (_containsInstance("mcArrowRight")) _arrow2 = this["mcArrowRight"];
			else _arrow2 = new MovieClip();
			if (_containsInstance("mcCursorH")) _cursor = this["mcCursorH"];
			else _cursor = new MovieClip();
			if (_containsInstance("mcBackgroundH")) _background = this["mcBackgroundH"];
			else _background = new MovieClip();
			
			// get the native (minimum) cursor height
			if (isNaN(_cursorWidth)) _cursorWidth = _cursor.width;
		}
		
		override protected function _initialize(__event:TimerEvent = null):void
		{
			switch (_scrollType)
			{
				case OBJECT_TYPE:
					_setProperties(_mask.x, (_mask.y + _mask.height));
					_checkScrollValue();
					break;
				default:
					traceDebug ("ERROR : type " + _scrollType + " is not valid. Use 'object' or 'text'");
					break;
			}
		}
		 
		override protected function _scrollProcess1(__value:Number):void
		{
			switch(_scrollType)
			{
				case OBJECT_TYPE:
					var targetPosition:Number = _target.x + (__value * -1)
					if (targetPosition < _minTargetPosition)
					{
						targetPosition = _minTargetPosition
					}
					else if (targetPosition > _maxTargetPosition)
					{
						targetPosition = _maxTargetPosition
					}
					_target.x = targetPosition;
					_updateCursorPosition();
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
			
		}
		
		override protected function _scrollProcess2(__value:Number):void
		{
			var cursorPosition:Number =	_cursor.x - __value;
			if ((__value < 0 && cursorPosition > _scroll.mouseX) || (__value > 0 && cursorPosition < _scroll.mouseX))
			{
				_scrollTimer.stop();
			}
			if (cursorPosition < _maxCursorPosition)
			{
				cursorPosition = _maxCursorPosition
			}
			else if (cursorPosition > _minCursorPosition)
			{
				cursorPosition = _minCursorPosition
			}
			_cursor.x = cursorPosition;
			_updateTargetPosition();
		}
		
		override protected function _updateCursorPosition():void
		{
			if (!_startDragging)
			{
				switch (_scrollType)
				{
					case OBJECT_TYPE:
						if (_target.width > _mask.width)
						{
							_cursor.x = _arrow1.x + _arrow1.width;
							_cursor.visible = true;
							if (!_fixedCursorSize) {
								_cursor.width = Math.max(_cursorWidth, Math.round(_backgroundWidth / (_target.width / _backgroundWidth)));
							}
						}
						else
						{
							_cursor.visible = false;
						}
						_maxCursorPosition = _background.x;
						_minCursorPosition = _background.x + _backgroundWidth - _cursor.width;
						_maxTargetPosition = _mask.x;
						_minTargetPosition = Math.round(_mask.x - _target.width + _mask.width);
						_cursor.x = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxCursorPosition, _minCursorPosition, _maxTargetPosition, _minTargetPosition, _target.x)), _maxCursorPosition, _minCursorPosition);
						break;
					default:
						traceDebug ("ERROR");
						break;
						
				}
			}
		}

		override protected function _updateTargetPosition(__event:Event = null):void
		{
			switch(_scrollType)
			{
				case OBJECT_TYPE:
					_target.x = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxTargetPosition, _minTargetPosition, _maxCursorPosition, _minCursorPosition, _cursor.x)), _minTargetPosition, _maxTargetPosition);
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
		}
		
		override protected function _checkScrollValue(__event:TimerEvent = null):void
		{
			if (!_startDragging)
			{
				switch (_scrollType)
				{
					case OBJECT_TYPE:
						if (_target.width <= _mask.width)
						{
							enable = false;
							if (_visible)
							{
								_cursor.visible = false;
								_show();
							}
							else
							{
								_hide();
							}
						}
						else
						{
							_cursor.visible = true;
							enable = true;
							_show()
						}
						break;
					default:
						traceDebug ("ERROR");
						break;
				}
			}
		}
		
		// BACKGROUND
		
		override protected function _onMouseDownBackground(__event:MouseEvent):void
		{
			_scrollTimer = new Timer(500, 1);
			if (_scroll.mouseX < _cursor.x)
			{
				_scrollProcess2(_cursor.width)
				_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollUpProcess2);
			}
			else
			{
				_scrollProcess2(-_cursor.width)
				_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollDownProcess2);
			}
			_scrollTimer.start();
		}
		
		// CURSOR
		
		override protected function _onMouseDownCursor(__event:MouseEvent):void
		{
			_startDragging = true;
			_cursor.startDrag(false, new Rectangle(_maxCursorPosition, _background.y, _minCursorPosition - _maxCursorPosition, 0));
			this.addEventListener(Event.ENTER_FRAME, _updateTargetPosition);
		}
	}
}