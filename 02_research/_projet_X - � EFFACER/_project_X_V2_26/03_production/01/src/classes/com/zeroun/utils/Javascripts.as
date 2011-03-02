package com.zeroun.utils 
{
	//http://skovalyov.blogspot.com/2007/01/how-to-prevent-pop-up-blocking-in.html
    import flash.external.ExternalInterface;

    public class Javascripts
	{
		// opens a new window as it would be done from javascript. this is to prevent popup-blockers
		// :NOTE: has to use MouseEvent.CLICK to call this function otherwise the event is catch bye IE7 popupBlocker
        public static function openWindow(__url:String, __window:String = "_blank", __features:String = "") : void
		{
            ExternalInterface.call("window.open", __url, __window, __features);
        }
    }
}