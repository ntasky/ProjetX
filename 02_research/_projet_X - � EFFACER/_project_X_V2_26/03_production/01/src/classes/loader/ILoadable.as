package loader
{
	import flash.events.*;
	import flash.display.*;
	
	public interface ILoadable extends IEventDispatcher
	{		
		function getXMLFilesToLoad():Array
		function getOtherFilesToLoad():Array
		function resizeLayout():void
	}	
}