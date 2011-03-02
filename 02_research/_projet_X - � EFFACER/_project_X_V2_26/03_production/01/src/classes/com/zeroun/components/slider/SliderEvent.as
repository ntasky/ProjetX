package com.zeroun.components.slider
{
	import flash.events.*;
	
	public class SliderEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ON_INITIALIZED		:String = "on_initialized";
		public static const ON_UPDATED			:String = "on_updated";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var value						:Number;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SliderEvent(__type:String, __value:Number = -1)
		{
			super(__type, false, false)
			value = __value;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new SliderEvent(type, value);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}