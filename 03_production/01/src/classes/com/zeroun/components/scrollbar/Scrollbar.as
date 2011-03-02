package com.zeroun.components.scrollbar
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	
	import com.zeroun.utils.Numbers;
	
	
	public class Scrollbar extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ON_INITIALIZED	:String = "on_initialized";
		public static const ON_SCROLL		:String = "on_scroll";
		public static const ON_SCROLL_PLUS	:String = "on_scroll_plus";
		public static const ON_SCROLL_MINUS	:String = "on_scroll_minus";
		
		public static const TEXT_TYPE		:String = "text";
		public static const OBJECT_TYPE		:String = "object";
		public static const ARRAY_TYPE		:String = "array";
		
		public static const MAX				:String = "max";
		public static const MIN				:String = "min";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var  mcArrowUp				:MovieClip;
		public var  mcArrowDown				:MovieClip;
		public var  mcCursorV				:MovieClip;
		public var  mcBackgroundV			:MovieClip;
		
		protected var _scroll				:Sprite = new Sprite();		// sprite containing all the elements of the scrollbar
		protected var _scrollType			:String;
		protected var _target				:Object;					// scrolled object
		protected var _enabled				:Boolean;					// scrolled object
		protected var _mask					:Sprite;					// mask
		protected var _visible				:Boolean					// visible when disbaled
		protected var _fixedCursorSize		:Boolean;					// allow cursor to resize depending of the scroll values
		protected var _scrollValue			:Number;					// scroll value when click on buttons
		protected var _maxCursorPosition	:Number;					
		protected var _minCursorPosition	:Number;
		protected var _maxTargetPosition	:Number;					
		protected var _minTargetPosition	:Number;
		protected var _startDragging		:Boolean = false;			// indicates if the central cursor is dragging
		protected var _scrollTimer			:Timer = new Timer(1);
		protected var _arrow1				:MovieClip;
		protected var _arrow2				:MovieClip;
		protected var _cursor				:MovieClip;
		protected var _background			:MovieClip;
		protected var _x					:int;
		protected var _y					:int;
		protected var _h					:int;
		protected var _autoPosition			:Boolean = true;
		
		private var _cursorHeight			:Number;
		private var _backgroundHeight		:Number;
		private var _isInitialized			:Boolean = false;
		
		// :TODO: include this in a custom event (used only with the 'array' type)
		public var firstVisibleItem			:Number;
	
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Scrollbar()
		{
			// call initialize to use the scrollbar
		}
		

		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initializeForTextField(	__target:Object,
												__alwaysVisible:Boolean = false,
												__fixedCursorSize:Boolean = false,
												__scrollValue:Number = 1)
		{
			_preInitialize(__target, null, TEXT_TYPE, __alwaysVisible, __fixedCursorSize, __scrollValue);
		}
		
		public function initializeForDisplayObject(	__target:Object,
													__mask:Sprite,
													__alwaysVisible:Boolean = false,
													__fixedCursorSize:Boolean = false,
													__scrollValue:Number = 1)
		{
			_preInitialize(__target, __mask, OBJECT_TYPE, __alwaysVisible, __fixedCursorSize, __scrollValue);
		}
		
		public function initializeForDropDown(	__target:Object,
												__mask:Sprite,
												__alwaysVisible:Boolean = false,
												__fixedCursorSize:Boolean = false,
												__scrollValue:Number = 1)
		{
			_preInitialize(__target, __mask, ARRAY_TYPE, __alwaysVisible, __fixedCursorSize, __scrollValue);
		}
		
		public function setCursorPosition(__value:Number):void
		{
			var position:Number = __value;
			if (position < 0) 
			{
				position = 0;
			}
			else if (position > 1) 
			{
				position = 1;
			}
			_cursor.y = Numbers.getRelative(_maxCursorPosition, _minCursorPosition, 0, 1,position);
			_updateTargetPosition();
		}
		
		public function setScrollValue(__value:Number):void
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					var targetScroll:int = __value;
					if (targetScroll < 1 ) targetScroll = 1;
					else if (targetScroll > (_target as TextField).maxScrollV) targetScroll = (_target as TextField).maxScrollV;
					(_target as TextField).scrollV = targetScroll;
					break;
				case OBJECT_TYPE:
					var targetPosition:Number = __value;
					if (targetPosition < _minTargetPosition)
					{
						targetPosition = _minTargetPosition
					}
					else if (targetPosition > _maxTargetPosition)
					{
						targetPosition = _maxTargetPosition
					}
					_target.y = targetPosition;
					break;
				case ARRAY_TYPE:
					var targetIndex:int = __value;
					if (targetIndex < 0 ) targetIndex = 0;
					// :NOTES: can't check if index is out of range
					_target.currentItem = targetIndex;
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
			_updateCursorPosition();
		}
		
		public function get maxScrollValue():int
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					return (_target as TextField).maxScrollV;
					break;
				case OBJECT_TYPE:
					return _maxTargetPosition;
					break;
				case ARRAY_TYPE:
					// TODO:
					traceDebug ("TODO");
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
			return 0;
		}
		
		public function get minScrollValue():int
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					return 1;
					break;
				case OBJECT_TYPE:
					return _minTargetPosition;
					break;
				case ARRAY_TYPE:
					// TODO:
					traceDebug ("TODO");
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
			return 0;
		}
		
		public function get alwaysVisible():Boolean
		{
			return _visible;
		}
		
		public function set alwaysVisible(__flag:Boolean):void
		{
			_visible = __flag;
		}
		
		public function get fixedCursorSize():Boolean
		{
			return _fixedCursorSize;
		}
		
		public function set fixedCursorSize(__flag:Boolean):void
		{
			_fixedCursorSize = __flag;
		}
		
		public function get enable():Boolean
		{
			return _enabled;
		}
		
		public function set enable(__flag:Boolean):void
		{
			_enabled = __flag;
			var __frame:String = (__flag)?"_up":"_disable"
			_arrow1.enabled = __flag;
			_arrow1.gotoAndStop(__frame);
			_arrow2.enabled = __flag;
			_arrow2.gotoAndStop(__frame);
			_background.enabled = __flag;
			_background.gotoAndStop(__frame);
			_cursor.enabled = __flag;
			_cursor.gotoAndStop(__frame);
			
			_setListenners(__flag);
		}
		
		public function setProperties(__x:Number = Number.MIN_VALUE, __y:Number = Number.MIN_VALUE, __h:Number = Number.MIN_VALUE):void
		{
			if (_isInitialized)
			{
				__x = (__x == Number.MIN_VALUE ) ? x : __x;
				__y = (__y == Number.MIN_VALUE ) ? y : __y;
				
				if (__h == Number.MIN_VALUE )
				{
					switch(_scrollType)
					{
						case TEXT_TYPE:
							__h = getTargetHeight();
							break;
						case OBJECT_TYPE:
						case ARRAY_TYPE:
							__h = _mask.height;
							break;
						default:
							traceDebug ("ERROR");
							break;
					}
				}
				
				_autoPosition = false;
				_x = __x;
				_y = __y;
				_h = __h;
				
				_setProperties(__x, __y, __h);
				_checkScrollValue();
				_updateTargetPosition();
			}
			else
			{
				traceDebug ("WARNING in setProperties : scrollbar is not initialized !");
			}
		}
		
		public function update():void
		{
			if (_isInitialized)
			{
				_checkScrollValue();
				_updateCursorPosition();
				_updateTargetPosition();
			}
			else
			{
				traceDebug ("WARNING in update : scrollbar is not initialized !");
			}
		}
		
		public override function toString():String
		{
			return ("com.zeroun.components.Scrollbar");
		}
		
		/************************************************************
		 * Protected methods
		 ************************************************************/
		
		private function _preInitialize(	__target:Object,
											__mask:Sprite = null,
											__type:String = TEXT_TYPE,
											__alwaysVisible:Boolean = false,
											__fixedCursorSize:Boolean = false,
											__scrollValue:Number = 1)
		{
			_maxCursorPosition = 0;
			_minCursorPosition = 0;
			_maxTargetPosition = 0;
			_minTargetPosition = 0;
			_startDragging = false;
			
			_target = __target;
			_mask = __mask;
			_scrollType = __type;
			_visible = __alwaysVisible;
			_fixedCursorSize = __fixedCursorSize;
			_scrollValue = __scrollValue;
			
			if (!_isInitialized)
			{
				_selectArrows();
				_initializeArrows();
				_isInitialized = true;
				_scrollTimer = new Timer(100, 1);
				_scrollTimer.addEventListener(TimerEvent.TIMER, _initialize);
				_scrollTimer.start();
			}
			else
			{
				_initialize();
			}
			
		} 
		
		protected function _setProperties(__x:Number, __y:Number, __h:Number = Number.MAX_VALUE):void
		{
			if (_autoPosition)
			{
				if (__h == Number.MAX_VALUE)
				{
					switch(_scrollType)
					{
						case TEXT_TYPE:
							__h = getTargetHeight();
							break;
						case OBJECT_TYPE:
						case ARRAY_TYPE:
							__h = _mask.height;
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
				__h = _h;
			}
			_arrow1.x = 0;
			_arrow1.y = 0;
			_arrow2.x = 0;
			_arrow2.y = _arrow1.y + __h - _arrow2.height;
			_background.x = _arrow1.x;
			_background.y = _arrow1.y + _arrow1.height;
			_background.height = _arrow2.y - _background.y;
			_backgroundHeight = _arrow2.y - _background.y;
			_cursor.x = _arrow1.x;
			_updateCursorPosition();
		}
		 
		protected function _selectArrows():void
		{
			if (_containsInstance("mcArrowUp")) _arrow1 = this["mcArrowUp"];
			else _arrow1 = new MovieClip();
			if (_containsInstance("mcArrowDown")) _arrow2 = this["mcArrowDown"];
			else _arrow2 = new MovieClip();
			if (_containsInstance("mcCursorV")) _cursor = this["mcCursorV"];
			else _cursor = new MovieClip();
			if (_containsInstance("mcBackgroundV")) _background = this["mcBackgroundV"];
			else _background = new MovieClip();
			
			// get the native (minimum) cursor height
			if (isNaN(_cursorHeight)) _cursorHeight = _cursor.height;
		}
		
		protected function _initializeArrows():void
		{
			_arrow1.stop();
			_arrow2.stop();
			_cursor.stop();
			_background.stop();
			
			_arrow1.buttonMode = true;
			_arrow1.useHandCursor = true;

			_arrow2.buttonMode = true;
			_arrow2.useHandCursor = true;
			
			_cursor.buttonMode = true;
			_cursor.useHandCursor = true;
			
			_background.buttonMode = true;
			_background.useHandCursor = true;
			
			_scroll.addChild(_arrow1);
			_scroll.addChild(_arrow2);
			_scroll.addChild(_background);
			_scroll.addChild(_cursor);
		}
		
		protected function _setListenners(__value:Boolean = true ):void
		{
			if (__value)
			{
				_setListenners(false);
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
				
				switch (_scrollType)
				{
					case TEXT_TYPE:
						_target.addEventListener(Event.SCROLL,_onScrolled);
						_target.addEventListener(Event.CHANGE, _onTextChanged);
						break;
					case OBJECT_TYPE:
						_mask.mouseEnabled = false;
						if (stage != null)
						{
							stage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheeled);
						}
						break;
					case ARRAY_TYPE:
						_mask.addEventListener(MouseEvent.MOUSE_WHEEL,_onMouseWheeled);
						break;
				}
			}
			else
			{
				try { _arrow1.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownUpArrow); } catch (e:Error) { };
				try { _arrow1.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess); } catch (e:Error) { };
				try { _arrow1.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess); } catch (e:Error) { };
				try { _arrow2.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownDownArrow); } catch (e:Error) { };
				try { _arrow2.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess); } catch (e:Error) { };
				try { _arrow2.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess); } catch (e:Error) { };
				try { _background.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBackground); } catch (e:Error) { };
				try { _background.removeEventListener(MouseEvent.MOUSE_UP, _stopScrollProcess); } catch (e:Error) { };
				try { _background.removeEventListener(MouseEvent.MOUSE_OUT, _stopScrollProcess); } catch (e:Error) { };
				try { _cursor.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor); } catch (e:Error) { };
				try { _cursor.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpCursor); } catch (e:Error) { };
				try { _cursor.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOutCursor); } catch (e:Error) { };
				try { _target.removeEventListener(Event.SCROLL,_onScrolled); } catch (e:Error) { };
				try { _target.removeEventListener(Event.CHANGE, _onTextChanged); } catch (e:Error) { };
				try { stage.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheeled); } catch (e:Error) { };
				try { _mask.removeEventListener(MouseEvent.MOUSE_WHEEL,_onMouseWheeled); } catch (e:Error) { };
			}
		}
		 
		protected function _initialize(__event:TimerEvent = null):void
		{
			switch (_scrollType)
			{
				case TEXT_TYPE:
					_setProperties((_target.x + _target.width), _target.y);
					_checkScrollValue();
					break;
				case OBJECT_TYPE:
					_setProperties((_mask.x + _mask.width), _mask.y);
					_checkScrollValue();
					break;
				case ARRAY_TYPE:
					_setProperties((_mask.x + _mask.width) - _scroll.width, 0);
					_checkScrollValue();
					break;
				default:
					traceDebug ("ERROR : type " + _scrollType + " is not valid. Use 'object', 'array' or 'text'");
					break;
			}
			enable = true;
			dispatchEvent(new Event(ON_INITIALIZED));
		}
		 
		protected function _scrollProcess1(__value:Number):void
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					(_target as TextField).scrollV += __value
					break;
				case OBJECT_TYPE:
					var targetPosition:Number = _target.y + (__value * -1)
					if (targetPosition < _minTargetPosition)
					{
						targetPosition = _minTargetPosition
					}
					else if (targetPosition > _maxTargetPosition)
					{
						targetPosition = _maxTargetPosition
					}
					_target.y = targetPosition;
					_updateCursorPosition();
					break;
				case ARRAY_TYPE:
					if (__value > 0)
					{
						dispatchEvent(new Event(ON_SCROLL_PLUS));
					}
					else
					{
						dispatchEvent(new Event(ON_SCROLL_MINUS));
					}
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
			
		}
		
		protected function _scrollProcess2(__value:Number):void
		{
			var cursorPosition:Number =	_cursor.y - __value;
			if ((__value < 0 && cursorPosition > _scroll.mouseY) || (__value > 0 && cursorPosition < _scroll.mouseY))
			{
				_scrollTimer.stop();
			}
			if (cursorPosition < _maxCursorPosition)
			{
				cursorPosition = _maxCursorPosition;
			}
			else if (cursorPosition > _minCursorPosition)
			{
				cursorPosition = _minCursorPosition;
			}
			_cursor.y = cursorPosition;
			_updateTargetPosition();
		}
		 
		protected function _scrollUpProcess1(__event:TimerEvent):void
		{
			_scrollProcess1(-_scrollValue);
		}
		
		protected function _scrollDownProcess1(__event:TimerEvent):void
		{
			_scrollProcess1(_scrollValue);
		}
		
		protected function _scrollUpProcess2(__event:TimerEvent):void
		{
			_scrollProcess2(_cursor.height)
		}
		
		protected function _scrollDownProcess2(__event:TimerEvent):void
		{
			_scrollProcess2(-_cursor.height)
		}
		
		protected function _stopDragging():void
		{
			this.removeEventListener(Event.ENTER_FRAME, _updateTargetPosition);
			_cursor.stopDrag();
			_startDragging = false;
		}
		
		protected function _stopScrollProcess(__event:MouseEvent):void
		{
			_scrollTimer.stop();
		}

		protected function _startScrollUpProcess1(__event:TimerEvent):void
		{
			_scrollTimer.stop();
			_scrollTimer = new Timer(10);
            _scrollTimer.addEventListener(TimerEvent.TIMER, _scrollUpProcess1);
            _scrollTimer.start();
		}
		
		protected function _startScrollDownProcess1(__event:TimerEvent):void
		{
			_scrollTimer.stop();
			_scrollTimer = new Timer(10);
            _scrollTimer.addEventListener(TimerEvent.TIMER, _scrollDownProcess1);
            _scrollTimer.start();
		}
		
		protected function _startScrollUpProcess2(__event:TimerEvent):void
		{
			_scrollTimer.stop();
			_scrollTimer = new Timer(10);
            _scrollTimer.addEventListener(TimerEvent.TIMER, _scrollUpProcess2);
            _scrollTimer.start();
		}
		
		protected function _startScrollDownProcess2(__event:TimerEvent):void
		{
			_scrollTimer.stop();
			_scrollTimer = new Timer(10);
            _scrollTimer.addEventListener(TimerEvent.TIMER, _scrollDownProcess2);
            _scrollTimer.start();
		}
		
		protected function _show():void
		{
			if (!this.contains(_scroll))
			{
				addChild(_scroll);
			}
			_cursor.visible = true;
		}
		
		protected function _hide():void
		{
			if (_visible)
			{
				_cursor.visible = false;
			}
			else
			{
				if (this.contains(_scroll))
				{
					removeChild(_scroll);
				}
			}
		}
		
		protected function _updateCursorPosition():void
		{
			if (!_startDragging)
			{
				switch (_scrollType)
				{
					case TEXT_TYPE:
						var target:TextField = (_target as TextField)
						if (target.maxScrollV > 1)
						{
							_cursor.y = _arrow1.y + _arrow1.height;
							_show();
							if (!_fixedCursorSize)
							{
								_cursor.height = Math.max(_cursorHeight, Math.round(_backgroundHeight / (target.textHeight / _backgroundHeight)));
							}
						}
						else
						{
							_hide();
						}
						_maxCursorPosition = _background.y;
						_minCursorPosition = _background.y + _backgroundHeight - _cursor.height;
						_maxTargetPosition = 1;
						_minTargetPosition = target.maxScrollV;
						_cursor.y = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxCursorPosition, _minCursorPosition, _maxTargetPosition, _minTargetPosition, target.scrollV)), _maxCursorPosition, _minCursorPosition)
						break;
					case OBJECT_TYPE:
						if (getTargetHeight() > _mask.height)
						{
							_cursor.y = _arrow1.y + _arrow1.height;
							_show();
							if (!_fixedCursorSize)
							{
								_cursor.height = Math.max(_cursorHeight, Math.round(_backgroundHeight / (getTargetHeight() / _backgroundHeight)));
							}
						}
						else
						{
							_hide();
						}
						_maxCursorPosition = _background.y;
						_minCursorPosition = _background.y + _backgroundHeight - _cursor.height;
						_maxTargetPosition = _mask.y
						_minTargetPosition = Math.round(_mask.y - getTargetHeight() + _mask.height)
						_cursor.y = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxCursorPosition, _minCursorPosition, _maxTargetPosition, _minTargetPosition, _target.y)), _maxCursorPosition, _minCursorPosition)
						break;
					case ARRAY_TYPE:
						if (_target.totalItems > _target.visibleItems)
						{
							_cursor.y = _arrow1.y + _arrow1.height;
							_show();
							if (!_fixedCursorSize)
							{
								_cursor.height = Math.max(_cursorHeight, Math.round(_backgroundHeight / (getTargetHeight() / _backgroundHeight)));
							}
						}
						else
						{
							_hide();
						}
						_minCursorPosition = _background.y + _backgroundHeight - _cursor.height;
						_maxCursorPosition = _background.y;
						_minTargetPosition = (_target.totalItems) - _target.visibleItems;
						_maxTargetPosition = 0
						if (_target.currentItem >= 0)
						{
						_cursor.y = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxCursorPosition, _minCursorPosition, _maxTargetPosition, _minTargetPosition, _target.currentItem)), _maxCursorPosition, _minCursorPosition)
						}
						else
						{
							_cursor.y = _maxCursorPosition
						}
						break;
					default:
						traceDebug ("ERROR");
						break;
						
				}
			}
		}
		
		protected function _resetTargetPosition(__event:Event = null):void
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					(_target as TextField).scrollV = 1;
					break;
				case OBJECT_TYPE:
					_target.y = 0;
					break;
				case ARRAY_TYPE:
					firstVisibleItem = 0;
					dispatchEvent(new Event(ON_SCROLL));
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
		}
		
		protected function _updateTargetPosition(__event:Event = null):void
		{
			switch(_scrollType)
			{
				case TEXT_TYPE:
					(_target as TextField).scrollV = Math.round(Numbers.getRelative(1, (_target as TextField).maxScrollV, _maxCursorPosition, _minCursorPosition, _cursor.y))
					break;
				case OBJECT_TYPE:
					_target.y = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxTargetPosition, _minTargetPosition, _maxCursorPosition, _minCursorPosition, _cursor.y)), _minTargetPosition, _maxTargetPosition);
					break;
				case ARRAY_TYPE:
					firstVisibleItem = Numbers.forceBetween(Math.round(Numbers.getRelative(_maxTargetPosition, _minTargetPosition, _maxCursorPosition, _minCursorPosition, _cursor.y)), _maxTargetPosition, _minTargetPosition);
					dispatchEvent(new Event(ON_SCROLL));
					break;
				default:
					traceDebug ("ERROR");
					break;
			}
		}
		
		protected function _checkScrollValue(__event:TimerEvent = null):void
		{
			if (!_startDragging)
			{
				switch (_scrollType)
				{
					case TEXT_TYPE:
						if ((_target as TextField).maxScrollV == 1)
						{
							_hide();
						}
						else
						{
							// :KLUDGE: this is a bug of flash. even if the height of the field is greater than the textHeight value maxScrollV > 1 expecially when leading is high
							if ((_target as TextField).textHeight < (_target as TextField).height)
							{
								traceDebug("Scrollbar.as: special case. see kludge at l. 648");
								(_target as TextField).height += 5;	// 5 is a given value it might not work with every values
								_hide();
							}
							else
							{
								_show();
							}
						}
						break;
					case OBJECT_TYPE:
						if (getTargetHeight() <= _mask.height)
						{
							_hide();
						}
						else
						{
							_show();
						}
						break;
					case ARRAY_TYPE:
						if (_target.totalItems <= _target.visibleItems)
						{
							_hide();
						}
						else
						{
							_show();
						}
						break;
					default:
						traceDebug ("ERROR");
						break;
				}
			}
		}
		
		protected function getTargetHeight():Number
		{
			return _target.height;
		}
		
		protected function _onTextChanged(__event:Event):void
		{
			_checkScrollValue();
		}
		
		protected function _onScrolled(__event:Event):void
		{
			_updateCursorPosition();
		}
		
		// UP ARROW
		
		protected function _onMouseDownUpArrow(__event:MouseEvent):void
		{
			_scrollProcess1(-_scrollValue);
			_scrollTimer = new Timer(500, 1);
			_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollUpProcess1);
			_scrollTimer.start();
		}
		
		// DOWN ARROW
		
		protected function _onMouseDownDownArrow(__event:MouseEvent):void
		{
			_scrollProcess1(_scrollValue)
			_scrollTimer = new Timer(500, 1);
			_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollDownProcess1);
			_scrollTimer.start();
		}

		// BACKGROUND
		
		protected function _onMouseDownBackground(__event:MouseEvent):void
		{
			_scrollTimer = new Timer(500, 1);
			if (_scroll.mouseY < _cursor.y)
			{
				_scrollProcess2(_cursor.height)
				_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollUpProcess2);
			}
			else
			{
				_scrollProcess2(-_cursor.height)
				_scrollTimer.addEventListener(TimerEvent.TIMER, _startScrollDownProcess2);
			}
			_scrollTimer.start();
		}
		
		// CURSOR
		
		protected function _onMouseDownCursor(__event:MouseEvent):void
		{
			_startDragging = true;
			_cursor.startDrag(false, new Rectangle(_arrow1.x, _maxCursorPosition, 0, _minCursorPosition - _maxCursorPosition));
			this.addEventListener(Event.ENTER_FRAME, _updateTargetPosition);
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
		
		// WHEEL
		
		protected function _onMouseWheeled(__event:MouseEvent):void
		{
			if (_scroll != null && this.contains(_scroll))
			{
				if (_scrollType != OBJECT_TYPE || (stage != null && _mask.hitTestPoint(_mask.stage.mouseX, _mask.stage.mouseY)))
				{
					if (__event.delta > 0)
					{
						//_scrollProcess2(_cursor.height / 2);
						_scrollProcess2(_scrollValue * 10);
					}
					else
					{
						//_scrollProcess2( -_cursor.height / 2);
						_scrollProcess2( -_scrollValue * 10);
					}
				}
			}
		}
		
		protected function _containsInstance(__instance:String, __object:* = null):Boolean
		{
			var object:*;
			if (__object == null ) object = this;
			else object = __object;
			return (object.getChildByName(__instance) != null);
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		//...
		
		
	}
}