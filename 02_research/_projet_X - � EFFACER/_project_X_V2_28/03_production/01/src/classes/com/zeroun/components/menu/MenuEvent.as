package com.zeroun.components.menu
{
	import flash.events.*;
	
	public class MenuEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ON_OVER_ITEM		:String = "on_over_item";
		public static const ON_OUT_ITEM			:String = "on_out_item";
		public static const ON_OPEN				:String	= "on_open";
		public static const ON_CLOSE			:String	= "on_close";
		public static const ON_CLICK_SUB_ITEM	:String	= "on_click_sub_item";
		public static const ON_CLICK_ITEM		:String	= "on_click_item";
		public static const ON_TIME_OUT			:String	= "on_time_out";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var itemId					:String;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function MenuEvent(__type:String, __itemId:String = "")
		{
			super(__type, false, false)
			itemId = __itemId;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new MenuEvent(type, itemId);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}