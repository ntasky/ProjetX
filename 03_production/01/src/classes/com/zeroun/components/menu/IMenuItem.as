package com.zeroun.components.menu
{
	import flash.events.*;
	import flash.display.*;
	
	public interface IMenuItem extends IEventDispatcher
	{	
		function get id():String
		function get label():String
		function set label(__value:String):void
		function get isSelected():Boolean
		function get visibleHeight():int
		function get visibleWidth():int
		function setProperties(__id:String, __label:String, ... args):void
		function enable():void
		function disable():void
		function select():void
		function deselect():void
		function highlight():void
		function dehighlight():void
	}
}