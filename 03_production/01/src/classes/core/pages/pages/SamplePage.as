package core.pages.pages
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	
	// third-party classes
	import com.greensock.TweenMax;
	import com.zeroun.utils.Numbers
	
	// project classes
	import core.events.PageEvent;
	import core.pages.GenericPage;
	import core.TextStyles;
	
	
	public class SamplePage extends GenericPage
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		// elements on stage
		// ...
		
		// other variables
		// ...
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function SamplePage(__id:String, __args:* = null)
		{
			var child:Shape = new Shape();
            child.graphics.beginFill(Numbers.getRandomIntBetween(0,16777215));
            child.graphics.lineStyle(Numbers.getRandomIntBetween(0,10), Numbers.getRandomIntBetween(0,16777215));
            child.graphics.drawRoundRect(50, 50, Numbers.getRandomIntBetween(20,300), Numbers.getRandomIntBetween(20,20), Numbers.getRandomIntBetween(0,10));
            child.graphics.endFill();
            addChild(child);
			
			super(__id, __args);
		}
		
		
		/************************************************************
		 * Getters / setters
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// ...

		/************************************************************
		 * Protected / private methods
		 ************************************************************/
		
		// ...
	}
	
}