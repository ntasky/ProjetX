package com.zeroun.components.dropdown
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.*;
	
	import gs.TweenLite;

	
	public class DropdownItem extends MovieClip{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const STATUS_DEFAULT	:String = "status_default";
		public static const STATUS_OVER		:String = "status_over";
		public static const STATUS_SELECT	:String = "status_select";
		
		private const TEXT_OVER_COLOR		:Number = 0xFFFFFF;
		private const TEXT_SELECT_COLOR		:Number = 0xFFFFFF;
		private const TEXT_DEFAULT_COLOR	:Number = 0x999999;
		
		private static const TWEEN_DURATION	:Number = .2;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var tfLabel					:TextField;
		public var mcBackground				:MovieClip;
		
		private var _id						:String;
		private var _index					:int;
		private var _label					:String;
		private var _textDefaultColor		:Number;
		private var _textOverColor			:Number;
		private var _textSelectColor		:Number;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function DropdownItem()
		{
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
									__textOverColor:Number = TEXT_OVER_COLOR,
									__textSelectColor:Number = TEXT_SELECT_COLOR,
									__textDefaultColor:Number = TEXT_DEFAULT_COLOR)
		{
			_index = __index;
			_id = __id;
			_label = __label;
			_textDefaultColor = __textDefaultColor;
			_textOverColor = __textOverColor;
			_textSelectColor = __textSelectColor;
			
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			tfLabel.mouseEnabled = false;
			tfLabel.text = _label;
			
			if (__selected) TweenLite.to(tfLabel, 0 , { tint : _textSelectColor } );
			else TweenLite.to(tfLabel, 0 , { tint : _textDefaultColor } );
						
			mcBackground.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOverItem);
			mcBackground.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutItem);
			mcBackground.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownItem);
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
			switch (__status)
			{
				case STATUS_OVER:
					color = _textOverColor;
					break;
				case STATUS_DEFAULT:
					color = _textDefaultColor;
					break;
				case STATUS_SELECT:
					color = _textSelectColor;
					break;
				default:
					color = _textDefaultColor;
					break;
			}
			TweenLite.to(tfLabel, TWEEN_DURATION , { tint : color } );
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