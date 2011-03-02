package loader.animation
{
	import flash.events.*;
	import flash.display.*;
	
	public interface ILoadingAnimation extends IEventDispatcher
	{		
		function show():void
		function hide():void
		function update(__value:Number):void
		function resizeLayout(__event:Event = null):void
	}	
}