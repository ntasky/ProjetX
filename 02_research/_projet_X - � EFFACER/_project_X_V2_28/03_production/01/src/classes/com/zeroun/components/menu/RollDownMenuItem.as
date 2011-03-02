package com.zeroun.components.menu
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
	
	
	public class RollDownMenuItem extends MovieClip implements IMenuItem
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		protected const MASK_INSTANCE_NAME			:String = "mcMask";
		protected const SUB_MENU_ITEM_INSTANCE_NAME	:String = "mcSubMenuItem";
		
		protected const TWEEN_DURATION				:Number = .2;
		protected const OPEN_DURATION				:Number = .3;
		protected const CLOSE_DURATION				:Number = .1;
		protected const DEFAULT_TIMED_OUT			:int = 100;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcMenuItem						:*;
		public var mcMask							:MovieClip;
		public var mcSubMenuItem					:MovieClip;
		
		protected var _itemsHolder					:Sprite;
		protected var _timer						:Timer;
		protected var _itemsTotalHeight				:Number;
		protected var _isOpen						:Boolean;
		protected var _hasSubItems					:Boolean;
		protected var _subMenuItem					:Class;
		protected var _subItems						:Array;
		protected var _subItemsById					:Array;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function RollDownMenuItem(){};
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function setProperties(__id:String, __label:String, ... args):void
		{
			mcMenuItem.setProperties(__id, __label, args);
			
			if (!_containsInstance(MASK_INSTANCE_NAME)) mcMask = new MovieClip();
			else mcMask.visible = false;
			if (!_containsInstance(SUB_MENU_ITEM_INSTANCE_NAME)) mcSubMenuItem = new MovieClip();
			else
			{
				_subMenuItem = flash.utils.getDefinitionByName((describeType(mcSubMenuItem).@name)) as Class;
				mcSubMenuItem.visible = false;
			}
			
			if (args[0] != null && args[0].length() > 0)
			{
				_hasSubItems = true;
				_subItems = new Array();
				_subItemsById = new Array();
				_itemsHolder = new Sprite();
				_itemsTotalHeight = 0;
				
				for (var i:int = 0; i < args[0].length(); i++ )
				{
					var item:* = new _subMenuItem();
					item.setProperties(args[0][i].@id, (parent as Menu).getLabel(args[0][i].label));
					item.addEventListener(MenuEvent.ON_OVER_ITEM, _onOverSubMenuItem);
					item.addEventListener(MenuEvent.ON_OUT_ITEM, _onOutSubMenuItem);
					item.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickSubMenuItem);
					item.y = _itemsTotalHeight;
					_subItems.push(item);
					_subItemsById[args[0][i].@id] = item;
					_itemsHolder.addChild(item);
					_itemsTotalHeight += item.mcBackground.height;
					
					// link by id the submenuitem to the menuItem
					(parent as Menu).addSubItemsById(args[0][i].@id, item);
					(parent as Menu).addItemsById(args[0][i].@id, this);
				}
				_itemsTotalHeight += mcMenuItem.mcBackground.height;
				
				mcMask.mouseEnabled = false;
				_itemsHolder.x = mcMenuItem.x;
				_itemsHolder.y = mcMenuItem.y + mcMenuItem.mcBackground.height;
				_itemsHolder.mask = mcMask;
				addChild(_itemsHolder);
				
				_timer = new Timer(DEFAULT_TIMED_OUT, 1);
				_timer.addEventListener(TimerEvent.TIMER, _timedOut);
				
				_isOpen = false;
				
			}
			else _hasSubItems = false;
			
			mcMenuItem.addEventListener(MenuEvent.ON_OVER_ITEM, _onOverMenuItem);
			mcMenuItem.addEventListener(MenuEvent.ON_OUT_ITEM, _onOutMenuItem);
			mcMenuItem.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickMenuItem);
		}
		
		public function open():void
		{
			if (_hasSubItems)
			{
				this.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
				this.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
				
				_isOpen = true;
				dispatchEvent(new MenuEvent(MenuEvent.ON_OPEN));
				TweenLite.to(mcMask, OPEN_DURATION, { height:_itemsTotalHeight } );
			}
		}
		
		public function close():void
		{
			if (_hasSubItems)
			{
				this.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOut);
				this.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOver);
				_isOpen = false;
				TweenLite.to(mcMask, CLOSE_DURATION, { height:1 } );
			}
		}
		
		public function enable():void
		{
			mcMenuItem.enable();
		}
		
		public function disable():void
		{
			mcMenuItem.disable();
		}
		
		public function select():void
		{
			mcMenuItem.select();
		}
		
		public function deselect():void
		{
			mcMenuItem.deselect();
		}
		
		public function highlight():void
		{
			mcMenuItem.highlight();
		}
		
		public function dehighlight():void
		{
			mcMenuItem.dehighlight();
		}
		
		public function get id():String
		{
			return mcMenuItem.id;
		}
		
		public function get label():String
		{
			return mcMenuItem.label;
		}
		
		public function set label(__value:String):void
		{
			mcMenuItem.label = __value;
			mcMenuItem.tfLabel.text = __value;
		}
		
		public function get isSelected():Boolean
		{
			return mcMenuItem.isSelected;
		}
		
		public function get subItems():Array
		{
			return _subItems;
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		protected function _containsInstance(__instance:String, __object:* = null):Boolean
		{
			var object:*;
			if (__object == null ) object = this;
			else object = __object;
			return (object.getChildByName(__instance) != null);
		} 
		
		protected function _onMouseOver(__event:MouseEvent):void
		{
			if(_isOpen) _timer.reset();
		}
		
		protected function _onMouseOut(__event:MouseEvent):void
		{
			if(_isOpen) _timer.start();
		}
		
		protected function _timedOut(__event:TimerEvent):void
		{
			close();
		}
		
		protected function _onOverMenuItem(__event:MenuEvent):void
		{
			if (!_isOpen) open();
			if (!isSelected) mcMenuItem.highlight();
		}
		
		protected function _onOutMenuItem(__event:MenuEvent):void
		{
			if (!isSelected) mcMenuItem.dehighlight();
		}
		
		protected function _onClickMenuItem(__event:MenuEvent):void
		{
			if (_isOpen) close();
			else open();
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_ITEM, __event.itemId));
		}
		
		protected function _onOverSubMenuItem(__event:MenuEvent):void
		{
			if (!_subItemsById[__event.itemId].isSelected) _subItemsById[__event.itemId].highlight();
		}
		
		protected function _onOutSubMenuItem(__event:MenuEvent):void
		{
			if (!_subItemsById[__event.itemId].isSelected) _subItemsById[__event.itemId].dehighlight();
		}
		
		protected function _onClickSubMenuItem(__event:MenuEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_SUB_ITEM, __event.itemId));
			_timer.stop();
			close();
		}
	}
}