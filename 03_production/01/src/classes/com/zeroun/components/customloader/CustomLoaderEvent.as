package com.zeroun.components.customloader
{
	import flash.events.*;
	
	public class CustomLoaderEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const START					:String = "start";
		public static const LOADED					:String = "loaded";
		public static const COMPLETE				:String = "complete";
		public static const PROGRESS				:String = "progress";
		public static const CUSTOM_EVENT			:String = "custom_event";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var itemURL							:String;
		public var percentLoaded					:Number;
		public var customEventLabel					:String;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function CustomLoaderEvent(__type:String, __itemURL:String = "", __percentLoaded:Number = -1, __customEventLabel:String = "")
		{
			super(__type, false, false)
			itemURL = __itemURL;
			percentLoaded = __percentLoaded;
			customEventLabel = __customEventLabel;
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		
		public override function clone():Event
		{
			return new CustomLoaderEvent(type, itemURL, percentLoaded, customEventLabel);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}