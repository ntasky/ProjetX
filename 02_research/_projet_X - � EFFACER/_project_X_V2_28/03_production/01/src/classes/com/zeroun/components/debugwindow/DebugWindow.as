package com.zeroun.components.debugwindow
{
	import flash.display.*;
	import flash.errors.IllegalOperationError;
    import flash.events.*;
    import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
	
	import com.zeroun.components.scrollbar.Scrollbar;
	import core.Config;
	
	
    public class DebugWindow extends Sprite
	{		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ARGS_DELIMITER	:String = "|#|";
		
		private const DEBUG_WINDOW_LABEL	:String = "Zéro Un debugger";
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
		private static var _this			:DebugWindow;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		function DebugWindow(__root:*, __version:String = "")
		{	
			if (_isOnDebugServer(__root.root.loaderInfo.url))
			{
				_this = this;
				_root = __root;
				var customContextMenu:ContextMenu = new ContextMenu();
				var label:String = __version == "" ? DEBUG_WINDOW_LABEL :  DEBUG_WINDOW_LABEL + " ("  + __version + ")";
				var customContextMenuItem:ContextMenuItem = new ContextMenuItem(label);
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
			else return;
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
		
		public static function getInstance():DebugWindow
		{
			return _this;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _isOnDebugServer(__url:String):Boolean
		{
			for (var i:int = 0 ; i < Config.DEBUG_ALLOWED_URLS.length; i ++)
			{
				if (__url.indexOf(Config.DEBUG_ALLOWED_URLS[i]) > -1) return true;
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