package com.zeroun.components.debugwindow
{
	import flash.events.*;
	
	public class DebugWindowEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const CALL_ACTION			:String = "call_action";			// event dispatched when a menu item is clicked
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var buttonIndex					:int;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function DebugWindowEvent(__type:String, __buttonIndex:int = -1)
		{
			super(__type, false, false)
			buttonIndex = __buttonIndex;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new DebugWindowEvent(type, buttonIndex);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}