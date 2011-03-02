package com.zeroun.components.menu
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	
	public class Menu extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		protected const ITEM_SPACING_X		:int = 0;
		protected const ITEM_SPACING_Y		:int = 25;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		protected var _data					:XMLList;
		protected var _language				:String;
		protected var _items				:Array;
		protected var _itemsById			:Array;
		protected var _selectedItemId		:String;
		protected var _subItemsById			:Array;
		protected var _selectedSubItemId	:String;
		protected var _itemClass			:Class;
		protected var _itemSpacingX			:int;
		protected var _itemSpacingY			:int;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Menu(	__data:XMLList,
								__itemClass:Class,						// this class should implement IMenuItem
								__language:String = "",
								__itemSpacingX:int = ITEM_SPACING_X,
								__itemSpacingY:int = ITEM_SPACING_Y)
		{
			_data				= __data;
			_language			= __language;
			_items				= new Array();
			_itemsById			= new Array();
			_selectedItemId		= null;
			_subItemsById		= new Array();
			_selectedSubItemId	= null;
			_itemClass			= __itemClass;
			_itemSpacingX		= __itemSpacingX;
			_itemSpacingY		= __itemSpacingY;
			
			for each (var data:XML in __data)
			{
				if (data.@id.split("/").length == 3 && data.@show_in_menu == "1") _addItem(data, _data.(@id.search(data.@id) == 0 && @id != data.@id && @show_in_menu == "1"));
			}
			
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function select(__id:String):void
		{
			var item:* = _itemsById[__id];
			var subItem:* = _subItemsById[__id];
			
			// deselect the old current item
			if (_selectedItemId != __id && _selectedItemId != null)
			{
				_itemsById[_selectedItemId].deselect();
			}
			
			// deselect the old current subitem
			if (_selectedSubItemId != __id && _selectedSubItemId != null)
			{
				_subItemsById[_selectedItemId].deselect();
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
			
			// select the new current subitem
			if (subItem != null)
			{
				_selectedSubItemId = __id;
				subItem.select();
			}
			else
			{
				_selectedSubItemId = null;
			}
		}
		
		public function addSubItemsById(__id:String, __item:*):void
		{
			_subItemsById[__id] = __item;
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
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		protected function _addItem(__page:XML, __subPages:XMLList):void
		{
			var item:* = new _itemClass();
			var index:int = _items.length;
			
			// initialize the item
			addChild(item);
			item.setProperties(__page.@id, getLabel(__page.label), __subPages);
			item.x = index * _itemSpacingX;
			item.y = index * _itemSpacingY;
			item.addEventListener(MenuEvent.ON_CLICK_SUB_ITEM, _onClickSubItem);
			item.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickItem);
			
			// add the item both to _items and _itemsById so that items can be looked up by index and by id
			_items.push(item);
			addItemsById(__page.@id, item);
		}
		
		protected function _onClickItem(__event:MenuEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_ITEM, __event.itemId));
		}
		
		protected function _onClickSubItem(__event:MenuEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_SUB_ITEM, __event.itemId));
		}
		
	}
	
}