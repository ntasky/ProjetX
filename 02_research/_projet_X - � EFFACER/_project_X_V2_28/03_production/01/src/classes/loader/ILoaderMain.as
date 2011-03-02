package loader
{
	import flash.events.*;
	
	public interface ILoaderMain extends IEventDispatcher
	{		
		function getAsset(__path:String):*
		function getXML(__path:String):XML
		function getFlashVar(__var:String):String
		function getDownloadSpeed():Number
	}	
}