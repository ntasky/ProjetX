package com.zeroun.components.dropdown
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.Capabilities;
	
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;

	
	public class DropdownItem extends MovieClip{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const STATUS_DEFAULT	:String = "status_default";
		public static const STATUS_OVER		:String = "status_over";
		public static const STATUS_SELECT	:String = "status_select";
		
		private const OVER_TEXT_COLOR		:Number = 0xFD2416;
		private const SELECTED_TEXT_COLOR	:Number = 0xFD2416;
		
		private static const TWEEN_DURATION	:Number = .2;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcLabel					:MovieClip;
		public var mcBackground				:MovieClip;
		
		private var _id						:String;
		private var _index					:int;
		private var _label					:String;
		private var _overTextColor			:Number;
		private var _selectedTextColor		:Number;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function DropdownItem()
		{
			TweenPlugin.activate([TintPlugin]);
			mcBackground.stop();
			mcBackground.buttonMode = true;
		}


		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initialize(	__index:int,
									__id:String,
									__label:String,
									__selected:Boolean = false,
									__overTextColor:Number = OVER_TEXT_COLOR,
									__selectedTextColor:Number = SELECTED_TEXT_COLOR)
		{
			_index = __index;
			_id = __id;
			_label = __label;
			_overTextColor = __overTextColor;
			_selectedTextColor = __selectedTextColor;
			
			mcLabel.tfLabel.autoSize = TextFieldAutoSize.LEFT;
			mcLabel.mouseEnabled = false;
			mcLabel.tfLabel.mouseEnabled = false;
			mcLabel.tfLabel.text = _label;
			
			if (__selected) TweenLite.to(mcLabel, 0 , { tint : _selectedTextColor } );
			else TweenLite.to(mcLabel, 0 , { tint : null } );
						
			mcBackground.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOverItem);
			mcBackground.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutItem);
			mcBackground.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownItem);
			// :KLUDGE: on MAC mcButton catches the mouseDown
			if (Capabilities.manufacturer == "Adobe Macintosh") this.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownItem);
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get index():Number
		{
			return _index;
		}
		
		public function set status(__status:String):void
		{
			var color:Number;
			if (__status == STATUS_DEFAULT)
			{
				TweenLite.to(mcLabel, TWEEN_DURATION , { tint : null } );
			}
			else
			{
				switch (__status)
				{
					case STATUS_OVER:
						color = _overTextColor;
						break;
					case STATUS_SELECT:
						color = _selectedTextColor;
						break;
				}
				TweenLite.to(mcLabel, TWEEN_DURATION , { tint : color } );
			}
		}

		/************************************************************
		 * Private methods
		 ************************************************************/
		 
		private function _onMouseOverItem(__event:MouseEvent):void
		{
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_OVER_ITEM, _index, _id));
		}
		
		private function _onMouseOutItem(__event:MouseEvent):void
		{
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_OUT_ITEM, _index, _id));
		}
		
		private function _onMouseDownItem(__event:MouseEvent):void
		{
			dispatchEvent(new DropdownEvent(DropdownEvent.ON_CLICK_ITEM, _index, _id));
		}
	}
}