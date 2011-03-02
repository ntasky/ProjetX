package com.zeroun.components.dropdown
{
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	
	import gs.TweenLite;
	
	import com.zeroun.components.scrollbar.Scrollbar;
	
	
	public class Dropdown extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const DIRECTION_DOWN	:String = "down";
		public static const DIRECTION_UP	:String = "up";
		 
		private const TEXT_OVER_COLOR		:Number = 0xFFFFFF;
		private const TEXT_SELECT_COLOR		:Number = 0xFFFFFF;
		private const TEXT_DEFAULT_COLOR	:Number = 0xB7B7B7;
		private const TWEEN_DURATION		:Number = .2;
		private const OPEN_DURATION			:Number = .3;
		private const CLOSE_DURATION		:Number = .1;
		private const DEFAULT_TIME_OUT		:int = 100;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var tfLabel					:TextField;
		public var mcButton					:MovieClip;
		public var mcMask					:MovieClip;
		public var mcTop					:MovieClip;
		public var mcBottom					:MovieClip;
		 
		private var _data					:Array;
		private var _size					:int;
		private var _selectedIndex			:int;
		private var _selectedID				:String;
		private var _numVisibleItems		:int;
		private var _direction				:String = DIRECTION_DOWN;
		private var _label					:String;
		private var _selectable				:Boolean = false;
		private var _itemsTotalHeight		:Number;
		private var _isOpen					:Boolean = false;
		private var _customItem				:Class;
		private var _items					:Array = new Array();
		private var _itemsHolder			:Sprite = new Sprite();
		private var _skinHolder				:Sprite = new Sprite();
		private var _maskedContent			:Sprite = new Sprite();
		private var _scroll					:Scrollbar;
		private var _button					:MovieClip;
		private var _skinTop				:MovieClip;
		private var _skinBottom				:MovieClip;
		private var _scrollHolder			:Sprite = new Sprite();
		private var _firstVisibleIndex		:int;
		private var _timer					:Timer;
	
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Dropdown()
		{
			// call initialize to use the dropdown
		};
		

		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initialize(	__data:Array,
									__selectedIndex:Number = -1,
									__numVisibleItems:Number = -1,
									__direction:String = DIRECTION_DOWN,
									__timeOut:int = DEFAULT_TIME_OUT):void
		{
			
			for (var i:int = 0; i < this.numChildren; i++)
			{
				if (describeType(this.getChildAt(i)).@base.toString().split("::")[1] == "Scrollbar")
				{
					_scroll = this.getChildAt(i) as Scrollbar;
					break;
				}
			}
			
			for (var j:int = 0; j < this.numChildren; j++)
			{
				if (describeType(this.getChildAt(j)).@base.toString().split("::")[1] == "DropdownItem")
				{
					_customItem = flash.utils.getDefinitionByName(describeType(this.getChildAt(j)).@name.toString()) as Class;
					(this.getChildAt(j) as MovieClip).visible = false;
					(this.getChildAt(j) as MovieClip).mcBackground.stop();
				}
			}

			// :NOTES: a button should be always defined on stage
			_button = this["mcButton"];
			if (_containsInstance("mcTop")) _skinTop = this["mcTop"];
			else _skinTop = new MovieClip();
			if (_containsInstance("mcBottom")) _skinBottom = this["mcBottom"];
			else _skinBottom = new MovieClip();
			
			_data = __data;
				
			_selectedIndex = __selectedIndex;
			if (_selectedIndex > -1 && _selectedIndex < _data.length)
			{
				label = getLabelFromIndex(_selectedIndex);
			}
			
			if (__numVisibleItems < 0)
			{
				_numVisibleItems = _data.length;
			}
			else
			{
				_numVisibleItems = __numVisibleItems;
			}
			
			_button.tfLabel.autoSize = TextFieldAutoSize.LEFT;
			_button.tfLabel.mouseEnabled = false;
			
			
			selectable = _selectable;
			
			_direction = __direction;
			
			mcMask.mouseEnabled = false;
			
			_itemsHolder.x = _scrollHolder.x =  _button.x;
			_itemsHolder.y = _scrollHolder.y = _button.y + _button.mcBackground.height;
			_maskedContent.addChild(_itemsHolder);
			
			size = _button.mcBackground.width;
			
			_button.mcBackground.stop();
			_button.mcBackground.buttonMode = true;
			_button.mcBackground.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownButton);
			_button.mcBackground.addEventListener(MouseEvent.MOUSE_OVER, _onOverButton);
			_button.mcBackground.addEventListener(MouseEvent.MOUSE_OUT, _onOutButton);
			
			_skinHolder.addChild(_skinTop);
			_skinHolder.addChild(_skinBottom);
			_maskedContent.addChild(_skinHolder);
			
			if (_scroll != null) 
			{
				_scroll.initialize({ target:this, totalItems:_data.length, visibleItems:_numVisibleItems, currentItem:_selectedIndex }, _itemsHolder, "array", false);
				_scroll.visible = false;
				_scrollHolder.addChild(_scroll);
			}
			_maskedContent.addChild(_scrollHolder);
			
			_maskedContent.mask = mcMask;
			
			enable = true;
			
			_timer = new Timer(__timeOut, 1)
			_timer.addEventListener(TimerEvent.TIMER, _onTimeOut);
		}
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		public function set selectedIndex(__index:int):void
		{
			_selectedIndex = __index;
			_button.tfLabel.text = getLabelFromIndex(_selectedIndex);
		}
		
		public function get selectedID():String
		{
			return _selectedID;
		}
		
		public function set selectedID(__ID:String):void
		{
			_selectedID = __ID;
			_button.tfLabel.text = getLabelFromID(__ID);
		}
		
		public function get size():int
		{
			return _size;
		}
		
		public function set size(__value:int):void
		{
			_size = __value;
			_button.mcBackground.width = _size;
			_skinTop.width = _size;
			_skinBottom.width = _size;
			mcMask.width = _size;
		}
		
		public function get selectable():Boolean
		{
			return _selectable;
		}
		
		public function set selectable(__value:Boolean):void
		{
			_selectable = __value;
			if (_selectable)
			{
				_button.tfLabel.selectable = true;
				_button.tfLabel.mouseEnabled = true;
			}
			else
			{
				_button.tfLabel.selectable = false;
				_button.tfLabel.mouseEnabled = false;
			}
		}
		
		public function get label():String
		{
			return _label;
		}
		
		public function set label(__label:String):void
		{
			_label = __label;
			_button.tfLabel.text = _label;
		}
		
		public function get isOpen():Boolean
		{
			return _isOpen;
		}
		
		public function set enable(__enable:Boolean):void
		{
			var __frame:String = (__enable)? "_up" : "_disable";
			_button.mcBackground.enabled = __enable;
			_button.mcBackground.gotoAndStop(__frame);
			if (!__enable)
			{
				_button.mcBackground.buttonMode = false;
				_button.mcBackground.useHandCursor = false;
				_button.mcBackground.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownButton);
			}
			else
			{
				_button.mcBackground.buttonMode = true;
				_button.mcBackground.useHandCursor = true;
				_button.mcBackground.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownButton);
			}
		}

		public function open():void
		{
			this.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			_showItems(_selectedIndex);
			if (!this.contains(_itemsHolder))
			{
				addChild(_maskedContent);
				
				_skinTop.x = _itemsHolder.x;
				_skinBottom.x = _itemsHolder.x;
				_skinTop.y = _itemsHolder.y;
				_skinBottom.y = _itemsHolder.y + _itemsTotalHeight;
				
				if (_direction == DIRECTION_UP)
				{
					mcMask.rotation = 180;
					mcMask.y = _button.mcBackground.height;
					mcMask.x = _size;
					_itemsHolder.y = _button.y - _itemsTotalHeight;
					_skinBottom.scaleY = -1;
					_skinBottom.y = _itemsHolder.y;
					_skinTop.scaleY = -1;
					_skinTop.y = _itemsHolder.y + _itemsTotalHeight;
				}
				else
				{
					mcMask.rotation = 0;
					mcMask.y = 0;
					mcMask.x = 0;
				}
				
			}
			if (_numVisibleItems < _data.length)
			{
				if (_scroll != null)
				{
					_scroll.initialize({ target:this, totalItems:_data.length, visibleItems:_numVisibleItems, currentItem:_selectedIndex }, _itemsHolder, "array", false);
					_scroll.addEventListener(Scrollbar.ON_SCROLL_PLUS, _onScrollPlus);
					_scroll.addEventListener(Scrollbar.ON_SCROLL_MINUS, _onScrollMinus);
					_scroll.addEventListener(Scrollbar.ON_SCROLL, _onScroll);
					_scroll.visible = true;
				}
				_maskedContent.addChild(_scrollHolder);
				if (_direction == DIRECTION_UP)
				{
					_scrollHolder.y = _button.y - _itemsTotalHeight;
				}
			}
			_isOpen = true;
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_OPEN));
			if (_direction == DIRECTION_DOWN) TweenLite.to(mcMask, OPEN_DURATION, { height:_skinBottom.y - mcMask.y + _skinBottom.height } );
			else TweenLite.to(mcMask, OPEN_DURATION, { height:Math.abs(mcMask.y - _skinBottom.y) + _skinBottom.height } );
			TweenLite.to(_button.tfLabel, 0 , { tint : TEXT_OVER_COLOR } );
		}
		
		public function close():void
		{
			this.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
			this.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
			_isOpen = false;
			TweenLite.to(mcMask, CLOSE_DURATION, { height:1, onComplete:_onClosed } );
			TweenLite.to(_button.tfLabel, TWEEN_DURATION , { tint : TEXT_DEFAULT_COLOR } );
		}
		
		public function getIndexFromID(__ID:String):int
		{
			var index:int = -1;
			for (var i:int = 0 ; i < _data.length ; i++)
			{
				if (_data[i].id == __ID) 
				{
					index = i;
					break;
				}
			}
			return index;
		}
		
		public function getIDFromIndex(__index:int):String
		{
			return _data[__index].id;
		}
		
		public function getLabelFromID(__ID:String):String
		{
			var label:String = "";
			for (var i:int = 0 ; i < _data.length ; i++)
			{
				if (_data[i].id == __ID) 
				{
					label = _data[i].label;
					break;
				}
			}
			return label; 
		}
		
		public function getLabelFromIndex(__index:int):String
		{
			return _data[__index].label;
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _containsInstance(__instance:String, __object:* = null):Boolean
		{
			var object:*;
			if (__object == null ) object = this;
			else object = __object;
			return (object.getChildByName(__instance) != null);
		} 
		
		private function _onClosed():void
		{
			if (this.contains(_itemsHolder))
			{
				while (_items.length > 0)
				{
					_itemsHolder.removeChild(_items.pop())
				}
				removeChild(_maskedContent);
			}
			if (_maskedContent.contains(_scrollHolder))
			{
				if (_scroll != null)
				{
					_scroll.removeEventListener(Scrollbar.ON_SCROLL_PLUS, _onScrollPlus);
					_scroll.removeEventListener(Scrollbar.ON_SCROLL_MINUS, _onScrollMinus);
					_scroll.removeEventListener(Scrollbar.ON_SCROLL, _onScroll);
					_scroll.visible = false;
				}
				_maskedContent.removeChild(_scrollHolder);
			}
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_CLOSE));
		}
		
		private function _showItems(__startIndex:Number):void
		{
			var endIndex:Number;
			var startIndex:Number;
			if (__startIndex < 0 || _data.length < _numVisibleItems)
			{
				startIndex = 0
			}
			else if (_data.length - __startIndex < _numVisibleItems)
			{
				startIndex = _data.length - _numVisibleItems;
			}
			else
			{
				startIndex = __startIndex
			}
			
			endIndex = Math.min(_data.length, startIndex + _numVisibleItems)
			
			while (_items.length > 0)
			{
				_itemsHolder.removeChild(_items.pop())
			}
			_itemsTotalHeight = 0;
			for (var i:int = startIndex ; i < endIndex ; i++)
			{
				//var item:Item = new Item();
				var item:DropdownItem = new _customItem();
				item.initialize(i, getIDFromIndex(i), getLabelFromIndex(i), _selectedIndex == i);
				item.addEventListener(DropdownEvent.ON_OVER_ITEM, _onMouseOverItem);
				item.addEventListener(DropdownEvent.ON_OUT_ITEM, _onMouseOutItem);
				item.addEventListener(DropdownEvent.ON_CLICK_ITEM, _onMouseDownItem);
				item.y = _itemsTotalHeight;
				item.mcBackground.width = _size;
				_items.push(item)
				_itemsHolder.addChild(item)
				_itemsTotalHeight += item.mcBackground.height;
			}
			_firstVisibleIndex = startIndex;
		}
		 
		private function _onMouseDownButton(__event:MouseEvent):void
		{
			if (!this.contains(_itemsHolder))
			{
				open();
			}
			else
			{
				close();
			}
		}
		
		private function _onOverButton(__event:MouseEvent):void
		{
			if (!_isOpen)
			{
				TweenLite.to(_button.tfLabel, TWEEN_DURATION , { tint : TEXT_OVER_COLOR } );
			}
		}
		
		private function _onOutButton(__event:MouseEvent):void
		{
			if (!_isOpen)
			{
				TweenLite.to(_button.tfLabel, TWEEN_DURATION , { tint : TEXT_DEFAULT_COLOR } );
			}
		}
		
		private function _onMouseDownItem(__event:DropdownEvent):void
		{
			var item:DropdownItem = (__event.target as DropdownItem)
			_selectedIndex = item.index;
			_button.tfLabel.text = getLabelFromIndex(_selectedIndex);
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_CLICK_ITEM, __event.index, __event.id));
			_timer.stop();
			close();
		}
		
		private function _onMouseOverItem(__event:DropdownEvent):void
		{
			(__event.target as DropdownItem).status = DropdownItem.STATUS_OVER
			_timer.reset();
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_OVER_ITEM, __event.index, __event.id));
		}
		
		private function _onMouseOutItem(__event:DropdownEvent):void
		{
			var item:DropdownItem = (__event.target as DropdownItem)
			if (item.index != _selectedIndex)
			{
				item.status = DropdownItem.STATUS_DEFAULT;
			}
			if(_isOpen)
			{
				_timer.start();
			}
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_OUT_ITEM, __event.index, __event.id));
		}
		
		private function _onScrollPlus(__event:Event):void
		{
			var index:Number = Math.min((_firstVisibleIndex + 1), _data.length)
			_showItems(index);
			_scroll.setScrollValue(index);
		}
		
		private function _onScrollMinus(__event:Event):void
		{
			var index:Number = Math.max(0,(_firstVisibleIndex - 1))
			_showItems(index);
			_scroll.setScrollValue(index);
		}
		
		private function _onScroll(__event:Event):void
		{
			_showItems(__event.target.firstVisibleItem);
		}
		
		private function _onTimeOut(__event:TimerEvent):void
		{
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_TIME_OUT));
		}
		
		private function _onMouseOver(__event:MouseEvent):void
		{
			if(_isOpen)
			{
				_timer.reset();
			}
		}
		
		private function _onMouseOut(__event:MouseEvent):void
		{
			if(_isOpen)
			{
				_timer.start();
			}
		}
	}
}