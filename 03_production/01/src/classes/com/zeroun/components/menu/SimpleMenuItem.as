package com.zeroun.components.menu
{
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	
	import com.greensock.TweenLite;
	
	
	public class SimpleMenuItem extends MovieClip implements IMenuItem
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var tfLabel							:TextField;
		public var mcBackground						:MovieClip;
		
		protected var _id							:String;
		protected var _label						:String;
		protected var _isSelected					:Boolean;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SimpleMenuItem(){};
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function setProperties(__id:String, __label:String, ... args):void
		{
			_id = __id;
			_label = __label;
			_isSelected = false;
			
			tfLabel.mouseEnabled = false;
			label = __label;
			
			mcBackground.stop();
			mcBackground.buttonMode = true;
			enable();
		}
		
		public function enable():void
		{
			mcBackground.enabled = true;
			mcBackground.gotoAndStop("_up");
			mcBackground.addEventListener(MouseEvent.MOUSE_OVER, _onMouseOverButton);
			mcBackground.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutButton);
			mcBackground.addEventListener(MouseEvent.CLICK, _onMouseDownButton);
		}
		
		public function disable():void
		{
			mcBackground.enabled = false;
			mcBackground.gotoAndStop("_disable");
			if (mcBackground.hasEventListener(MouseEvent.MOUSE_OVER)) mcBackground.removeEventListener(MouseEvent.MOUSE_OVER, _onMouseOverButton);
			if (mcBackground.hasEventListener(MouseEvent.MOUSE_OUT)) mcBackground.removeEventListener(MouseEvent.MOUSE_OUT, _onMouseOutButton);
			if (mcBackground.hasEventListener(MouseEvent.MOUSE_DOWN)) mcBackground.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownButton);
		}
		
		public function select():void
		{
			highlight();
			mcBackground.gotoAndStop("_selected");
			mcBackground.enabled = false;
			_isSelected = true;
		}
		
		public function deselect():void
		{
			dehighlight();
			mcBackground.gotoAndStop("_up");
			mcBackground.enabled = true;
			_isSelected = false;
		}
		
		public function highlight():void
		{
			//...
		}
		
		public function dehighlight():void
		{
			//...
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get label():String
		{
			return _label;
		}
		
		public function set label(__value:String):void
		{
			tfLabel.autoSize = TextFieldAutoSize.LEFT;
			_label = __value;
			tfLabel.text = _label;
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		
		public function get visibleHeight():int
		{
			return mcBackground.heigth;
		}
		
		public function get visibleWidth():int
		{
			return mcBackground.width;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		protected function _onMouseOverButton(__event:MouseEvent):void
		{
			if (!_isSelected)
			{
				highlight();
			}
			dispatchEvent(new MenuEvent(MenuEvent.ON_OVER_ITEM, _id));
		}
		
		protected function _onMouseOutButton(__event:MouseEvent):void
		{
			if (!_isSelected)
			{
				dehighlight();
			}
			dispatchEvent(new MenuEvent(MenuEvent.ON_OUT_ITEM, _id));
		}
		 
		protected function _onMouseDownButton(__event:MouseEvent):void
		{
			dispatchEvent(new MenuEvent(MenuEvent.ON_CLICK_ITEM, _id));
		}
	}
}