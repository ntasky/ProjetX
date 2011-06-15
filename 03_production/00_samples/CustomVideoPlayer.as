package
{
	import flash.display.*;
	import flash.events.MouseEvent;
	
	import com.zeroun.components.videoplayer.*;
	import com.zeroun.components.debugwindow.DebugWindow;
	
	
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
		public var bt5					:MovieClip;
		public var bt6					:MovieClip;
		public var mcVideoPlayer		:VideoPlayer;
		
		private var _videoPlayer		:VideoPlayer;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function CustomVideoPlayer()
		{
			/* VideoPlayer is on Timeline
			_videoPlayer = mcVideoPlayer;
			_videoPlayer.addEventListener(VideoPlayerEvent.ON_INITIALIZABLE, _onVideoPlayerInitializable);
			//*/
			
			//* VideoPlayer is dynamically created
			createDynamicVideoPlayer();
			//*/
			
			// set listenners
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_COMPLETE, _onVideoComplete);
            _videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_STARTED, _onVideoStart);
			
			bt1.buttonMode = true;
			bt2.buttonMode = true;
			bt3.buttonMode = true;
			bt4.buttonMode = true;
			bt5.buttonMode = true;
			bt6.buttonMode = true;
			
			bt1.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt1);
			bt2.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt2);
			bt3.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt3);
			bt4.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt4);
			bt5.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt5);
			bt6.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownBt6);
			
			new DebugWindow(this);
		};

		
		/************************************************************
		 * Public methods
		 ************************************************************/
		 
		public function createDynamicVideoPlayer()
		{
			//_videoPlayer = new VideoPlayer("sample2.flv");
			//_videoPlayer = new VideoPlayer("sample2.flv", "sample1.jpg");
			_videoPlayer = new VideoPlayer();
			
			// set options
			var _videoPlayerOptions:Object = new Object();
			_videoPlayerOptions.debugMode = true;
			_videoPlayerOptions.autoStart = false;
			//_videoPlayerOptions.playerWidth = 100;
			//_videoPlayerOptions.playerHeight = 200;
			//_videoPlayerOptions.playerSpaceforControls = 34;
			//_videoPlayerOptions.playerScaleMode = PlayerScaleMode.FIT_VIDEO;
			//_videoPlayerOptions.autoNext = false;
			//_videoPlayerOptions.screenClickable = false;
			//_videoPlayerOptions.useControls = false;
			
			/* single video
			_videoPlayerOptions.imagePath = "sample1.jpg";
			_videoPlayerOptions.videoPath = "sample1.flv";
			//*/
			
			/* multiple videos
			_videoPlayerOptions.imagePath = "sample1.jpg";
			_videoPlayerOptions.videoPath = ["sample1.flv", "sample2.flv", "sample3.flv"];
			//*/
			
			//* streaming video
			_videoPlayerOptions.imagePath = "sample1.jpg";
			_videoPlayerOptions.serverPath = "rtmp://fms.zero-un.lan/vod/" ;
			_videoPlayerOptions.videoPath = "mp4:sample1_1500kbps.f4v";
			//*/
			
			// initialize player
			_videoPlayer.options = _videoPlayerOptions;
			_videoPlayer.x = 390;
			_videoPlayer.y = 200;
			addChild(_videoPlayer);
			//*/
		}
		 
			
		/************************************************************
		 * Private methods
		 ************************************************************/
			
		private function _onVideoPlayerInitializable(__event:VideoPlayerEvent = null):void
		{
			// set options
			_videoPlayer.debugMode = true;
			_videoPlayer.autoStart = false;
			_videoPlayer.playerWidth = 100;
			_videoPlayer.playerHeight = 200;
			_videoPlayer.playerSpaceforControls = 34;
			//_videoPlayer.videoScaleMode = PlayerScaleMode.FIT_VIDEO;
			//_videoPlayer.autoNext = false;
			//_videoPlayer.screenClickable = true;
			//_videoPlayer.useControls = false;
			
			//* single video
			_videoPlayer.imagePath = "sample1.jpg";
			_videoPlayer.videoPath = "sample1.flv";
			//*/
			
			/* multiple videos
			_videoPlayer.imagePath = "sample1.jpg";
			_videoPlayer.videoPath = ["sample1.flv", "sample2.flv", "sample3.flv"];
			//*/
			
			/* streaming video
			_videoPlayer.imagePath = "sample1.jpg";
			_videoPlayer.serverPath = "rtmp://fms.zero-un.lan/vod/" ;
			_videoPlayer.videoPath = "mp4:sample1_1500kbps.f4v";
			//*/
			
			// initialize player
			_videoPlayer.initialize();
		}
		
		
		private function _onMouseDownBt1(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("sample1.flv");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt2(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("reel2009.flv");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt3(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist(["sample3.flv", "sample2.flv", "sample1.flv"]);
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt4(__event:MouseEvent):void
		{
			_videoPlayer.setPlaylist("http://www.zero-un.com/video/reel2008.flv");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt5(__event:MouseEvent):void
		{
			_videoPlayer.setStreamingPlaylist("rtmp://fms.zero-un.lan/vod/", "mp4:sample1_1500kbps.f4v");
			_videoPlayer.play();
		}
		
		private function _onMouseDownBt6(__event:MouseEvent):void
		{
			_videoPlayer.setStreamingPlaylist("rtmp://medias-flash.radio-canada.ca/ondemand/diffusion/75eme/concours/", "mp4:1986-05-24_SoireeHockey_0000_1200.mp4");
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