package com.zeroun.components.videoplayer
{
	import flash.events.*;
	
	public class VideoPlayerEvent extends Event
	{

		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ON_CUE_POINT			:String = "on_cue_point";			// event dispatched when a cuepoint is reached
		public static const ON_INITIALIZED			:String = "on_initialized";			// event dispatched when the player is intialized
		public static const ON_INITIALIZABLE		:String = "on_initializable";			// event dispatched when the player is intialized
		public static const VIDEO_UPDATED			:String = "video_updated";			// event dispatched every frame when the video is playing
		public static const VIDEO_START_LOADING		:String = "video_start_loading";
		public static const VIDEO_LOADED			:String = "video_loaded";
		public static const VIDEO_RESIZED			:String = "video_resized";
		public static const VIDEO_STARTED			:String = "video_started";
		public static const VIDEO_PAUSED			:String = "video_paused";
		public static const VIDEO_PLAYED			:String = "video_played";
		public static const VIDEO_MUTE				:String = "video_mute";
		public static const VIDEO_UNMUTE			:String = "video_unmute";
		public static const VIDEO_COMPLETE			:String = "video_complete";
		public static const VIDEO_START_BUFFERING	:String = "video_start_buffering";
		public static const VIDEO_END_BUFFERING		:String = "video_end_buffering";
		public static const PLAYER_RESIZED			:String = "player_resized";
		public static const PLAYER_RESET			:String = "player_reset";
		public static const PROGRESS_BAR_UPDATED	:String = "progress_bar_updated";
		public static const ENTER_FULLSCREEN		:String = "enter_fullscreen";
		public static const EXIT_FULLSCREEN			:String = "exit_fullscreen";
		public static const ON_METADATA_RECEIVED	:String = "on_metadata_received";
		
		public static const VIDEO_REALLY_STARTED	:String = "video_really_started";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var cuePointName						:String;
		public var position							:Number;
		public var datas							:Object;


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function VideoPlayerEvent(__type:String, __data:* = undefined)
		{
			super(__type, false, false)
			switch(__type)
			{
				case ON_CUE_POINT:
					cuePointName = String(__data);
					break;
				case VIDEO_UPDATED:
					position = Number(__data);
					break;
				case PROGRESS_BAR_UPDATED:
					datas = Object(__data);
					break;
				default:
					break;
			}
			
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public override function clone():Event
		{
			switch(type)
			{
				case ON_CUE_POINT:
					return new VideoPlayerEvent(type, cuePointName);
				case VIDEO_UPDATED:
					return new VideoPlayerEvent(type, position);
				default:
					return new VideoPlayerEvent(type);
			}
			return new VideoPlayerEvent(type);
		}


		/************************************************************
		 * Private methods
		 ************************************************************/
		
		// ...
		
	}
	
}