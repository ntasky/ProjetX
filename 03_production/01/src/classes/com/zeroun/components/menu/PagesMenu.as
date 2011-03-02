package com.zeroun.components.menu
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	
	public class PagesMenu extends SimpleMenu
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		protected var _subItemsById			:Array;
		protected var _selectedSubItemId	:String;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function PagesMenu(	__data:XMLList,
									__itemClass:Class,						// this class should implement IMenuItem
									__language:String = "",
									__type:String = HORIZONTAL,
									__itemSpacingX:Number = Number.MAX_VALUE,
									__itemSpacingY:Number = Number.MAX_VALUE)
		{
			_subItemsById		= new Array();
			_selectedSubItemId	= null;
			
			super(__data, __itemClass, __language, __type, __itemSpacingX, __itemSpacingY);
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		override public function select(__id:String):void
		{
			var subItem:* = _subItemsById[__id];
			
			 //deselect the old current subitem
			if (_selectedSubItemId != __id && _selectedSubItemId != null)
			{
				_subItemsById[_selectedItemId].deselect();
			}
			
			 //select the new current subitem
			if (subItem != null)
			{
				_selectedSubItemId = __id;
				subItem.select();
			}
			else
			{
				_selectedSubItemId = null;
			}
			
			super.select(__id);
		}
		
		public function addSubItemsById(__id:String, __item:*):void
		{
			_subItemsById[__id] = __item;
		}
		
			
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		override protected function _populate():void
		{
			var posX:int = 0;
			var posY:int = 0;
			var item:*;
			var isTopLevel:Boolean;
			var showInMenu:Boolean;
			var subpagesData:XMLList;
			
			for each (var data:XML in _data)
			{
				isTopLevel = (data.@id == "" || data.@id == "/" || data.@id.split("/").length == 3);
				showInMenu = (data.@show_in_menu == undefined || data.@show_in_menu == "1");
				if (isTopLevel && showInMenu)
				{
					subpagesData = (data.@id == "" || data.@id == "/") ? null : _data.(@id.search(data.@id) == 0 && @id != data.@id && (@show_in_menu == undefined || @show_in_menu == "1"));
					_addItem(data, subpagesData);
					
					item = _items[_items.length - 1];
					item.x = posX;
					item.y = posY;
					
					if (_type == HORIZONTAL)
					{
						posX += item.visibleWidth + _itemSpacingX;
						posY += _itemSpacingY;
					}
					else
					{
						posX += _itemSpacingX;
						posY += item.visibleHeight + _itemSpacingY;
					}
				}
			}
		}
		
		override protected function _addItem(__page:XML, __subPages:XMLList = null):void
		{
			super._addItem(__page, __subPages);
			_items[_items.length - 1].addEventListener(MenuEvent.ON_CLICK_SUB_ITEM, _onClickSubItem);
		}
		
		protected function _onClickSubItem(__event:MenuEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_SUB_ITEM, __event.itemId));
		}
		
	}
	
}