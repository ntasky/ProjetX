package loader
{
	import flash.events.*;
	import flash.display.*;
	
	public interface ILoadable extends IEventDispatcher
	{		
		function getXMLFilesToLoad():Array
		function getOtherFilesToLoad():Array
		function resizeLayout(__width:int = -1, __height:int = -1):void
		function contentIsInitializable():Boolean
	}	
}