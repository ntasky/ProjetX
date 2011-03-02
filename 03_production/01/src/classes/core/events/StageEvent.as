package core.events
{
	import flash.events.*;
	
	public class StageEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const RESIZE					:String = "resize";			// event dispatched when a page is revealed
		public static const EXIT					:String = "exit";			// event dispatched when a mouse is off the stage
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var availableWitdh					:int;
		public var availableHeight					:int;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function StageEvent(__type:String, __availableWitdh:int = -1, __availableHeight:int = -1)
		{
			super(__type, false, false);
			switch(__type)
			{
				case RESIZE:
					availableWitdh = __availableWitdh;
					availableHeight = __availableHeight
					break;
			}
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			return new StageEvent(type, availableWitdh, availableHeight);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}