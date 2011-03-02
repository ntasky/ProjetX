package com.zeroun.components.dropdown
{
	import flash.events.*;
	
	public class DropdownEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ON_OVER_ITEM	:String = "on_over_item";
		public static const ON_OUT_ITEM		:String = "on_out_item";
		public static const ON_OPEN			:String	= "on_open";
		public static const ON_CLOSE		:String	= "on_close";
		public static const ON_CLICK_ITEM	:String	= "on_click_item";
		public static const ON_TIME_OUT		:String	= "on_time_out";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var index					:int;
		public var id						:String;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function DropdownEvent(__type:String, __index:int = -1, __id:String = "")
		{
			super(__type, false, false)
			index = __index;
			id = __id;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new DropdownEvent(type, index, id);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}