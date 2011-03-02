package com.zeroun.components.menu
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	
	public class SimpleMenu extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const HORIZONTAL			:String = "horizontal";
		public static const VERTICAL			:String = "vertical";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		protected var _data					:XMLList;
		protected var _language				:String;
		protected var _type					:String;
		protected var _items				:Array;
		protected var _itemsById			:Array;
		protected var _selectedItemId		:String;
		protected var _itemClass			:Class;
		protected var _itemSpacingX			:int;
		protected var _itemSpacingY			:int;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SimpleMenu(	__data:XMLList,
									__itemClass:Class,						// this class should implement IMenuItem
									__language:String = "",
									__type:String = HORIZONTAL,
									__itemSpacingX:Number = Number.MAX_VALUE,
									__itemSpacingY:Number = Number.MAX_VALUE)
		{
			_data				= __data;
			_language			= __language;
			_type				= __type;
			_items				= new Array();
			_itemsById			= new Array();
			_selectedItemId		= null;
			_itemClass			= __itemClass;
			_itemSpacingX 		= (__itemSpacingX == Number.MAX_VALUE) ? 0 : __itemSpacingX;
			_itemSpacingY 		= (__itemSpacingY == Number.MAX_VALUE) ? 0 : __itemSpacingY;
			
			_populate();
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function select(__id:String):void
		{
			var item:* = _itemsById[__id];
			
			// deselect the old current item
			if (_selectedItemId != __id && _selectedItemId != null)
			{
				_itemsById[_selectedItemId].deselect();
			}
			
			// select the new current item
			if (item != null)
			{
				_selectedItemId = __id;
				item.select();
			}
			else
			{
				_selectedItemId = null;
			}
			
		}
		
		public function addItemsById(__id:String, __item:*):void
		{
			_itemsById[__id] = __item;
		}
		
		public function getLabel(__data:XMLList):String
		{
			var result:String;
			// no languages tag are specified
			if (__data.hasSimpleContent())
			{
				result = __data.toString();
			}
			else if (_language == "") result = "";
			else result = __data[_language].toString();
			
			result = result.length > 0 ? result : "undefined language";
			return result;
		}
		
		public function get items():Array
		{
			return _items;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		protected function _populate():void
		{
			var posX:int = 0;
			var posY:int = 0;
			
			for each (var data:XML in _data)
			{
				if (data.@show_in_menu == undefined || data.@show_in_menu == "1")
				{
					_addItem(data);
					var item:* = _items[_items.length - 1];
					item.x = posX;
					item.y = posY;
					if (_type == HORIZONTAL)
					{
						posX += item.width + _itemSpacingX;
						posY += _itemSpacingY;
					}
					else
					{
						posX += _itemSpacingX;
						posY += item.height + _itemSpacingY;
					}
				}
			}
		}
		
		protected function _addItem(__page:XML, __subPages:XMLList = null):void
		{
			var item:* = new _itemClass();
			var index:int = _items.length;
			
			// initialize the item
			addChild(item);
			item.setProperties(__page.@id, getLabel(__page.label), __subPages);
			item.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickItem);
			
			// add the item both to _items and _itemsById so that items can be looked up by index and by id
			_items.push(item);
			addItemsById(__page.@id, item);
		}
		
		protected function _onClickItem(__event:MenuEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_ITEM, __event.itemId));
		}
		
	}
	
}