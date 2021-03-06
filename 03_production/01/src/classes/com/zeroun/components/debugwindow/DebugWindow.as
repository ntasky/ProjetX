﻿package com.zeroun.components.debugwindow
{
	import flash.display.*;
	import flash.errors.IllegalOperationError;
    import flash.events.*;
    import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
	
	import com.zeroun.components.scrollbar.Scrollbar;
	
	
    public class DebugWindow extends Sprite
	{		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ARGS_DELIMITER	:String = "|#|";
		
		private const DEBUG_WINDOW_LABEL	:String = "Zéro Un debugger";
		private const DEBUG_ALLOWED_URLS	:Array = ["file:///","http://127.0.0.1/", "http://dev.zero-un.com/", "http://client.zero-un.com/", "http://test.zero-un.lan/"];
		private const DEBUG_TEXT_COLOR		:Number = 0xFF0000;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcDrag					:MovieClip;
		public var mcClose					:MovieClip;
		public var mcFPS					:MovieClip;
		public var tfTrace					:TextField;
		public var mcScroll					:Scrollbar;
		public var mcAction1				:MovieClip;
		public var mcAction2				:MovieClip;
		public var mcAction3				:MovieClip;
		public var mcAction4				:MovieClip;
		public var mcAction5				:MovieClip;
		
        private var _root					:*;
		private var _debugAllowedURLs		:Array = DEBUG_ALLOWED_URLS;
		private static var _this			:DebugWindow;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		function DebugWindow(__root:*, __debugAllowedURLs:Array = null, __version:int = -1)
		{	
			_this = this;
			if (__debugAllowedURLs != null)
			{
				debugAllowedURLs = __debugAllowedURLs;
			}
			
			var customContextMenu:ContextMenu = new ContextMenu();
			var customContextMenuItem:ContextMenuItem;
			var customContextMenuLabel:String;
			
			if (_isOnDebugServer(__root.root.loaderInfo.url))
			{
				_this = this;
				_root = __root;
				customContextMenuLabel = __version == -1 ? DEBUG_WINDOW_LABEL :  DEBUG_WINDOW_LABEL + " ( V."  + __version + ")";
				customContextMenuItem = new ContextMenuItem(customContextMenuLabel);
				customContextMenuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _open);
				customContextMenu.customItems.push(customContextMenuItem);
				_root.contextMenu = customContextMenu;
				
				mcClose.buttonMode = true;
				mcClose.addEventListener(MouseEvent.MOUSE_DOWN, _onClose);
				
				mcDrag.buttonMode = true;
				mcDrag.addEventListener(MouseEvent.MOUSE_DOWN, _onStartDrag);
				mcDrag.addEventListener(MouseEvent.MOUSE_UP, _onStopDrag);
				
				for (var i:int = 1 ; i <= 5 ; i++)
				{
					this["mcAction" + i].buttonMode = true;
					this["mcAction" + i].useHandCursor = true;
					this["mcAction" + i].tf.text = i;
					this["mcAction" + i].mouseChildren = false;
					this["mcAction" + i].addEventListener(MouseEvent.MOUSE_DOWN, _onCallAction);
				}
				
				mcScroll.initializeForTextField(tfTrace);
				
				_this.tfTrace.htmlText = "";
				
				mcFPS.mouseEnabled = false;
				mcFPS.mouseChildren = false;
				
				traceDebug ("TraceWindow is initialized! ", DEBUG_TEXT_COLOR);
			}
			else
			{
				customContextMenuItem = new ContextMenuItem("V." + __version);
				customContextMenu.customItems.push(customContextMenuItem);
				__root.contextMenu = customContextMenu;
			}
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public static function traceToDebugWindow(... args)	// if 2 parameters then the second one should be a color
		{
			var params:Array = args.toString().split(ARGS_DELIMITER);
			trace (args[0]);
			if (_this != null) 
			{
				var autoScroll:Boolean = _this.tfTrace.scrollV == _this.tfTrace.maxScrollV ? true : false;
				if (params.length == 1 || params.length > 2) _this.tfTrace.htmlText += _htmlEncode(params.toString());
				else _this.tfTrace.htmlText += "<FONT COLOR=\"#" + int(params[1]).toString(16) + "\">" + _htmlEncode(params[0].toString()) + "</FONT>";
				if (autoScroll) _this.tfTrace.scrollV = _this.tfTrace.maxScrollV;
			}
		}
		
		public static function get instance():DebugWindow
		{
			return _this;
		}
		
		public static function set debugAllowedURLs(__URLs:Array):void
		{
			for (var i:int = 0 ; i < __URLs.length; i ++)
			{
				if (!_this._isOnDebugServer(__URLs[i]))
				{
					_this._debugAllowedURLs.push(__URLs[i]);
				}
			}
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _isOnDebugServer(__url:String):Boolean
		{
			for (var i:int = 0 ; i < _debugAllowedURLs.length; i ++)
			{
				if (__url.indexOf(_debugAllowedURLs[i]) > -1) return true;
			}
			return false;
		}
		
		private function _open(__event:ContextMenuEvent):void
        {
            _root.addChild(this);
			x = _root.mouseX;
			y = _root.mouseY;
        }
		
		private function _onStartDrag(__event:MouseEvent):void
        {
			 _root.addChild(this);
            this.startDrag();
        }
		
		private function _onStopDrag(__event:MouseEvent):void
        {
           this.stopDrag();
        }
		
		private function _onClose(__event:MouseEvent):void
        {
           _root.removeChild(this);
        }
		
		private function _onCallAction(__event:MouseEvent):void
		{
			var target:String = __event.target.name;
			var index:int = int(target.substring(target.length - 1));
			traceDebug("_onCallAction >>" + index, DEBUG_TEXT_COLOR);
			dispatchEvent(new DebugWindowEvent(DebugWindowEvent.CALL_ACTION, index));
		}
		
		private static function _htmlEncode(__source:String):String
		{
			var s:String = __source;
			s = s.split("<").join("&lt;");
			s = s.split(">").join("&gt;");
			return s;
		}
		
	}	
}