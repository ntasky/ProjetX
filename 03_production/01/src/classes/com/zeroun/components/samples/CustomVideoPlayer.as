package com.zeroun.components.samples
{
	import flash.display.*;
	import flash.events.MouseEvent;
	
	import com.zeroun.components.videoplayer.*;
	
	
	public class CustomVideoPlayer extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var bt1					:MovieClip;
		public var bt2					:MovieClip;
		public var bt3					:MovieClip;
		public var bt4					:MovieClip;
		public var mcVideoPlayer		:VideoPlayer;
		
		private var _videoPlayer		:VideoPlayer;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function CustomVideoPlayer()
		{
			//*
			// create a VideoPlayer
			
			var _videoPlayerOptions:Object = new Object();
			//_videoPlayerOptions.debugMode = true;
			//_videoPlayerOptions.autoStart = false;
			//_videoPlayerOptions.playerWidth = 100;
			//_videoPlayerOptions.playerHeight = 200;
			//_videoPlayerOptions.playerSpaceforControls = 34;
			//_videoPlayerOptions.playerScaleMode = PlayerScaleMode.FIT_VIDEO;
			//_videoPlayerOptions.autoNext = false;
			//_videoPlayerOptions.screenClickable = false;
			//_videoPlayerOptions.useControls = false;
			_videoPlayerOptions.videoPath = "sample1.flv";
			_videoPlayerOptions.imagePath = "sample1.jpg";
			//_videoPlayerOptions.videoPath = ["sample1.flv", "sample2.flv", "sample3.flv"];
			
			//_videoPlayer = new VideoPlayer("sample2.flv");
			//_videoPlayer = new VideoPlayer("sample2.flv", "sample1.jpg");
			_videoPlayer = new VideoPlayer();
			
			_videoPlayer.options = _videoPlayerOptions;
			_videoPlayer.x = 250;
			_videoPlayer.y = 200;
			addChild(_videoPlayer);
			//*/
			
			/*
			// VideoPlayer is on Timeline
			_videoPlayer = mcVideoPlayer;
			_videoPlayer.addEventListener(VideoPlayerEvent.ON_INITIALIZABLE, _onVideoPlayerInitializable);
			//TweenLite.to(_videoPlayer, 5, { scaleX:1.5, scaleY:1.5 } );
			//*/
			
			bt1.buttonMode = true;
			bt2.buttonMode = true;
			bt3.buttonMode = true;
			bt4.buttonMode = true;
			
			bt1.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt1);
			bt2.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt2);
			bt3.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt3);
			bt4.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt4);
			//*/
		};

		
		/************************************************************
		 * Public methods
		 ************************************************************/
		 
		 //...
		 
			
		/************************************************************
		 * Private methods
		 ************************************************************/
			
		private function _onVideoPlayerInitializable(__event:VideoPlayerEvent = null):void
		{
			_videoPlayer.debugMode = true;
			_videoPlayer.autoStart = false;
			_videoPlayer.playerWidth = 100;
			_videoPlayer.playerHeight = 150;
			_videoPlayer.playerSpaceforControls = 34;
			//_videoPlayer.videoScaleMode = VideoScaleMode.NO_BORDER;
			_videoPlayer.autoNext = false;
           // _videoPlayer.screenClickable = true;
			//_videoPlayer.useControls = false;
			//_videoPlayer.videoPath = "sample1.flv";
			_videoPlayer.videoPath = ["sample1.flv", "sample2.flv", "sample3.flv"];
			
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_COMPLETE, _onVideoComplete);
            _videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_STARTED, _onVideoStart);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_COMPLETE, _onVideoComplete);
            _videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_STARTED, _onVideoStart);
			
			_videoPlayer.initialize();
		}
		
		
		private function _onMouseDownBt1(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("sample1.flv");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt2(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("sample2.flv");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt3(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist(["sample3.flv", "sample2.flv", "sample1.flv"]);
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt4(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("http://www.zeroun.com/video/reel2008.flv");
			_videoPlayer.play();
		}
		
		private function _onVideoComplete(__event:VideoPlayerEvent):void
		{
			traceDebug ("_onVideoComplete>> ");
		}
		
		private function _onVideoStart(__event:VideoPlayerEvent):void
		{
			traceDebug ("_onVideoStart>> ");
		}
	}
}