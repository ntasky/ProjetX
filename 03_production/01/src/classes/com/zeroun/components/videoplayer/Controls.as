package com.zeroun.components.videoplayer
{
	// flashes classes
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	// third-party classes
	//...
	
	// project classes
	import com.zeroun.utils.Numbers;
	
	
	public class Controls extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const ZOOM_FIT			:String = "zoom_fit";
		public static const NO_RESIZE			:String = "no_resize";
		public static const ZOOM_X05			:String = "zoom_x05";
		public static const ZOOM_X2				:String = "zoom_x2";
		public static const ZOOM_X3				:String = "zoom_x3";
		public static const ZOOM_X4				:String = "zoom_x4";

		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		protected var _videoPlayer				:VideoPlayer;
		protected var _currentSelectedZoom		:MovieClip;
		protected var _progressBar				:ProgressBar;
		protected var _background				:MovieClip;
		protected var _progressBarExtraSpace	:int;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Controls()
		{
		}
		
		
		/************************************************************
		 * Getter & Setter methods
		 ************************************************************/
		
		public function get progressBar():ProgressBar
		{
			return _progressBar;
		}
		
		public function set loopPlaylist(__flag:Boolean):void
		{
			if (_containsInstance("mcLoop"))
			{
				if (__flag)
				{
					this["mcLoop"].mcLoopOff.visible = false;
					this["mcLoop"].mcLoopOn.visible = true;
				}
				else
				{
					this["mcLoop"].mcLoopOff.visible = true;
					this["mcLoop"].mcLoopOn.visible = false;
				}
			}
		}
		
		public function set autoNext(__flag:Boolean):void
		{
			if (_containsInstance("mcAutoNext"))
			{
				if (__flag)
				{
					this["mcAutoNext"].mcAutoNextOff.visible = false;
					this["mcAutoNext"].mcAutoNextOn.visible = true;
				}
				else
				{
					this["mcAutoNext"].mcAutoNextOff.visible = true;
					this["mcAutoNext"].mcAutoNextOn.visible = false;
				}
			}
		}
		
		public function set fullScreen(__flag:Boolean):void
		{
			if (_containsInstance("mcFullScreen"))
			{
				if (__flag)
				{
					this["mcFullScreen"].mcFullScreenOff.visible = false;
					this["mcFullScreen"].mcFullScreenOn.visible = true;
				}
				else
				{
					this["mcFullScreen"].mcFullScreenOff.visible = true;
					this["mcFullScreen"].mcFullScreenOn.visible = false;
				}
			}
		}
		
		public function set status(__value:String):void
		{
			if (_containsInstance("tfStatus"))
			{
				this["tfStatus"].text = __value;
			}
			switch(__value)
			{
				case VideoPlayer.STATUS_LOADING:
					break;
				case VideoPlayer.STATUS_BUFFERING:
					_canPlayPause = false;
					break;
				case VideoPlayer.STATUS_PLAYING:
					_canPlayPause = true;
					break;
				case VideoPlayer.STATUS_PAUSED:
					_canPlayPause = true;
					break;
			}
		}
		
		public function set title(__value:String):void
		{
			if (_containsInstance("tfTitle"))
			{
				this["tfTitle"].text = __value;
			}
		}
		
		public function set volume(__value:Number):void
		{
			if (_containsInstance("mcVolume"))
			{
				this["mcVolume"].mcVolumeBar.width = Numbers.getRelative(0, this["mcVolume"].mcHitArea.width, 0, 1, __value);
			}
		}
		
		public function set zoom(__value:String):void
		{
			if (_containsInstance("mcZoom"))
			{
				if (_currentSelectedZoom != null)
				{
					_currentSelectedZoom.gotoAndStop("_up");
					_currentSelectedZoom.buttonMode = true;
				}
				switch(__value)
				{
					case ZOOM_FIT:
						_currentSelectedZoom = this["mcZoom"].mcZoomFit;
						break;
					case ZOOM_X05:
						_currentSelectedZoom = this["mcZoom"].mcZoomX05;
						break;
					case NO_RESIZE:
						_currentSelectedZoom = this["mcZoom"].mcZoomNoResize;
						break;
					case ZOOM_X2:
						_currentSelectedZoom = this["mcZoom"].mcZoomX2;
						break;
					case ZOOM_X3:
						_currentSelectedZoom = this["mcZoom"].mcZoomX3;
						break;
					case ZOOM_X4:
						_currentSelectedZoom = this["mcZoom"].mcZoomX4;
						break;
					default:
						break;
				}
				if (_currentSelectedZoom != null)
				{
					_currentSelectedZoom.gotoAndStop("_down");
					_currentSelectedZoom.buttonMode = false;
				}
			}
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		 
		public function initialize(__videoPlayer:VideoPlayer):void
		{
			_videoPlayer = __videoPlayer;
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_PLAYED, _onVideoPlayed);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_PAUSED, _onVideoPaused);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_START_BUFFERING, _onVideoPaused);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_END_BUFFERING, _onVideoPlayed);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_MUTE, _onMute);
			_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_UNMUTE, _onUnmute);
			
			if (_containsInstance("mcBackground"))
			{
				_background = this["mcBackground"];
			}
			
			if (_containsInstance("mcPlayPause"))
			{
				this["mcPlayPause"].mcPlay.buttonMode = true;
				this["mcPlayPause"].mcPlay.useHandCursor = true;
				this["mcPlayPause"].mcPlay.stop();
				this["mcPlayPause"].mcPlay.addEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
				
				this["mcPlayPause"].mcPause.buttonMode = true;
				this["mcPlayPause"].mcPause.useHandCursor = true;
				this["mcPlayPause"].mcPause.stop();
				this["mcPlayPause"].mcPause.addEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
				
				this["mcPlayPause"].mcPlay.visible = true;
				this["mcPlayPause"].mcPause.visible = false;
			}
			
			if (_containsInstance("mcPlay"))
			{
				this["mcPlay"].buttonMode = true;
				this["mcPlay"].useHandCursor = true;
				this["mcPlay"].stop();
				this["mcPlay"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
			}
			
			if (_containsInstance("mcPause"))
			{
				this["mcPause"].buttonMode = true;
				this["mcPause"].useHandCursor = true;
				this["mcPause"].stop();
				this["mcPause"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
			}
			
			if (_containsInstance("mcStop"))
			{
				this["mcStop"].buttonMode = true;
				this["mcStop"].useHandCursor = true;
				this["mcStop"].stop();
				this["mcStop"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickStop);
			}
			
			if (_containsInstance("mcSound"))
			{
				this["mcSound"].mcSoundOff.visible = false;
				this["mcSound"].mcSoundOff.buttonMode = true;
				this["mcSound"].mcSoundOff.useHandCursor = true;
				this["mcSound"].mcSoundOff.stop();
				this["mcSound"].mcSoundOff.addEventListener(MouseEvent.MOUSE_DOWN, _onClickSoundOff);
				
				this["mcSound"].mcSoundOn.visible = true;
				this["mcSound"].mcSoundOn.buttonMode = true;
				this["mcSound"].mcSoundOn.useHandCursor = true;
				this["mcSound"].mcSoundOn.stop();
				this["mcSound"].mcSoundOn.addEventListener(MouseEvent.MOUSE_DOWN, _onClickSoundOn);
			}
			
			if (_containsInstance("mcTime"))
			{
				this["mcTime"].mouseChildren = false;
				this["mcTime"].mouseEnabled = false;
			}
			
			if (_containsInstance("mcRestart"))
			{
				this["mcRestart"].buttonMode = true;
				this["mcRestart"].useHandCursor = true;
				this["mcRestart"].stop();
				this["mcRestart"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickRestart);
			}
			
			if (_containsInstance("mcPrevious"))
			{
				this["mcPrevious"].buttonMode = true;
				this["mcPrevious"].useHandCursor = true;
				this["mcPrevious"].stop();
				this["mcPrevious"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickPrevious);
			}
			
			if (_containsInstance("mcNext"))
			{
				this["mcNext"].buttonMode = true;
				this["mcNext"].useHandCursor = true;
				this["mcNext"].stop();
				this["mcNext"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickNext);
			}
			
			if (_containsInstance("mcLoop"))
			{
				this["mcLoop"].mcLoopOff.buttonMode = true;
				this["mcLoop"].mcLoopOff.useHandCursor = true;
				this["mcNext"].mcLoopOff.stop();
				this["mcLoop"].mcLoopOff.addEventListener(MouseEvent.MOUSE_DOWN, _onClickLoopOff);
				
				this["mcLoop"].mcLoopOn.buttonMode = true;
				this["mcLoop"].mcLoopOn.useHandCursor = true;
				this["mcLoop"].mcLoopOff.stop();
				this["mcLoop"].mcLoopOn.addEventListener(MouseEvent.MOUSE_DOWN, _onClickLoopOn);
			}
			
			if (_containsInstance("mcAutoNext"))
			{
				this["mcAutoNext"].mcAutoNextOff.buttonMode = true;
				this["mcAutoNext"].mcAutoNextOff.useHandCursor = true;
				this["mcAutoNext"].mcAutoNextOff.stop();
				this["mcAutoNext"].mcAutoNextOff.addEventListener(MouseEvent.MOUSE_DOWN, _onClickAutoNextOff);

				this["mcAutoNext"].mcAutoNextOn.buttonMode = true;
				this["mcAutoNext"].mcAutoNextOn.useHandCursor = true;
				this["mcAutoNext"].mcAutoNextOn.stop();
				this["mcAutoNext"].mcAutoNextOn.addEventListener(MouseEvent.MOUSE_DOWN, _onClickAutoNextOn);
			}
			
			if (_containsInstance("mcFullScreen"))
			{
				this["mcFullScreen"].mcFullScreenOff.buttonMode = true;
				this["mcFullScreen"].mcFullScreenOff.useHandCursor = true;
				this["mcFullScreen"].mcFullScreenOff.stop();
				this["mcFullScreen"].mcFullScreenOff.addEventListener(MouseEvent.MOUSE_DOWN, _onClickFullScreenOff);
				
				this["mcFullScreen"].mcFullScreenOn.buttonMode = true;
				this["mcFullScreen"].mcFullScreenOn.useHandCursor = true;
				this["mcFullScreen"].mcFullScreenOn.stop();
				this["mcFullScreen"].mcFullScreenOn.addEventListener(MouseEvent.MOUSE_DOWN, _onClickFullScreenOn);
			}
			
			if (_containsInstance("mcVolume"))
			{
				if (_containsInstance("mcVolumeMinus", this["mcVolume"]))
				{
					this["mcVolume"].mcVolumeMinus.buttonMode = true;
					this["mcVolume"].mcVolumeMinus.useHandCursor = true;
					this["mcVolume"].mcVolumeMinus.stop();
					this["mcVolume"].mcVolumeMinus.addEventListener(MouseEvent.MOUSE_DOWN, _onClickLessVolume);
				}
				
				if (_containsInstance("mcVolumePlus", this["mcVolume"]))
				{
					this["mcVolume"].mcVolumePlus.buttonMode = true;
					this["mcVolume"].mcVolumePlus.useHandCursor = true;
					this["mcVolume"].mcVolumePlus.stop();
					this["mcVolume"].mcVolumePlus.addEventListener(MouseEvent.MOUSE_DOWN, _onClickMoreVolume);
				}
				
				if (_containsInstance("mcHitArea", this["mcVolume"]))
				{
					this["mcVolume"].mcHitArea.buttonMode = true;
					this["mcVolume"].mcHitArea.useHandCursor = true;
					this["mcVolume"].mcHitArea.stop();
					this["mcVolume"].mcHitArea.addEventListener(MouseEvent.MOUSE_DOWN, _onClickVolume);
				}
				
				if (_containsInstance("mcVolumeMute", this["mcVolume"]))
				{
					this["mcVolume"].mcVolumeMute.buttonMode = true;
					this["mcVolume"].mcVolumeMute.useHandCursor = true;
					this["mcVolume"].mcVolumeMute.stop();
					this["mcVolume"].mcVolumeMute.addEventListener(MouseEvent.MOUSE_DOWN, _onClickMute);
				}
			}
			
			if (_containsInstance("mcZoom"))
			{
				if (_containsInstance("mcZoomFit", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomFit.buttonMode = true;
					this["mcZoom"].mcZoomFit.useHandCursor = true;
					this["mcZoom"].mcZoomFit.stop();
					this["mcZoom"].mcZoomFit.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
				
				if (_containsInstance("mcZoomX05", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomX05.buttonMode = true;
					this["mcZoom"].mcZoomX05.useHandCursor = true;
					this["mcZoom"].mcZoomX05.stop();
					this["mcZoom"].mcZoomX05.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
				
				if (_containsInstance("mcZoomNoResize", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomNoResize.buttonMode = true;
					this["mcZoom"].mcZoomNoResize.useHandCursor = true;
					this["mcZoom"].mcZoomNoResize.stop();
					this["mcZoom"].mcZoomNoResize.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
				
				if (_containsInstance("mcZoomX2", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomX2.buttonMode = true;
					this["mcZoom"].mcZoomX2.useHandCursor = true;
					this["mcZoom"].mcZoomX2.stop();
					this["mcZoom"].mcZoomX2.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
				
				if (_containsInstance("mcZoomX3", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomX3.buttonMode = true;
					this["mcZoom"].mcZoomX3.useHandCursor = true;
					this["mcZoom"].mcZoomX3.stop();
					this["mcZoom"].mcZoomX3.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
				
				if (_containsInstance("mcZoomX4", this["mcZoom"]))
				{
					this["mcZoom"].mcZoomX4.buttonMode = true;
					this["mcZoom"].mcZoomX4.useHandCursor = true;
					this["mcZoom"].mcZoomX4.stop();
					this["mcZoom"].mcZoomX4.addEventListener(MouseEvent.MOUSE_DOWN, _onClickZoom);
				}
			}
			
			if (_containsInstance("mcProgressBar"))
			{
				_progressBar = this["mcProgressBar"];
				_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_UPDATED, updateTime);
				_videoPlayer.addEventListener(VideoPlayerEvent.VIDEO_UPDATED, _updateProgressBar);
				this["mcProgressBar"].initialize(_videoPlayer);
				_progressBarExtraSpace = (_background.width - (_progressBar.width + _progressBar.x)) + _progressBar.x;
			}
			
			reset();
		}
		
		public function reset():void
		{
			status = "";
			title = "";
			loopPlaylist = _videoPlayer.loopPlaylist;
			autoNext = _videoPlayer.autoNext;
			fullScreen = _videoPlayer.fullScreen;
		}
		
		public function hasProgressBar():Boolean
		{
			return (_progressBar != null);
		}
		
		public function updateTime(__event:VideoPlayerEvent = null, __time:String = ""):void
		{
			if (_containsInstance("mcTime"))
			{
				this["mcTime"].tfCurrentTime.text = Numbers.StoMMSS(int(_videoPlayer.netStream.time));
				this["mcTime"].tfTotalTime.text = Numbers.StoMMSS(int(_videoPlayer.videoDuration));
			}
			
		}
		
		public function resize(__width:int =  -1):void
		{
			//...
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		 
		protected function _updateProgressBar(__event:VideoPlayerEvent):void
		{
			if (_progressBar != null) _progressBar.update();
		}
		
		protected function _containsInstance(__instance:String, __object:* = null):Boolean
		{
			var object:*;
			if (__object == null ) object = this;
			else object = __object;
			return (object.getChildByName(__instance) != null);
		}
		
		protected function _onClickPlay(__event:MouseEvent):void
		{
			_videoPlayer.play();
		}
		
		protected function _onClickPause(__event:MouseEvent):void
		{
			_videoPlayer.pause();
		}
		
		protected function _onClickStop(__event:MouseEvent):void
		{
			_videoPlayer.stop();
		}
		
		protected function _onClickRestart(__event:MouseEvent):void
		{
			_videoPlayer.seek(0);
		}
		
		protected function _onClickPrevious(__event:MouseEvent):void
		{
			_videoPlayer.loadPreviousVideo();
		}
		
		protected function _onClickNext(__event:MouseEvent):void
		{
			_videoPlayer.loadNextVideo();
		}
		
		protected function _onClickSoundOff(__event:MouseEvent):void
		{
			_videoPlayer.unmute();
		}
		
		protected function _onClickSoundOn(__event:MouseEvent):void
		{
			_videoPlayer.mute();
		}
		
		protected function _onClickLoopOff(__event:MouseEvent):void
		{
			_videoPlayer.loopPlaylist = true;
		}
		
		protected function _onClickLoopOn(__event:MouseEvent):void
		{
			_videoPlayer.loopPlaylist = false;
		}
		
		protected function _onClickAutoNextOff(__event:MouseEvent):void
		{
			_videoPlayer.autoNext = true;
		}
		
		protected function _onClickAutoNextOn(__event:MouseEvent):void
		{
			_videoPlayer.autoNext = false;
		}
		
		protected function _onClickLessVolume(__event:*):void
		{
			_videoPlayer.videoVolume = Math.max(0, _videoPlayer.videoVolume - 0.1);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp2);
			stage.addEventListener(Event.ENTER_FRAME, _onClickLessVolume);
			if (_containsInstance("mcVolumeMute", this["mcVolume"]))
			{
				this["mcVolume"].mcVolumeMute.gotoAndStop(1);
			}
		}
		
		protected function _onClickMoreVolume(__event:*):void
		{
			_videoPlayer.videoVolume = Math.min(1, _videoPlayer.videoVolume + 0.1);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp3);
			stage.addEventListener(Event.ENTER_FRAME, _onClickMoreVolume);
			if (_containsInstance("mcVolumeMute", this["mcVolume"]))
			{
				this["mcVolume"].mcVolumeMute.gotoAndStop(1);
			}
		}
		
		protected function _onClickFullScreenOff(__event:MouseEvent):void
		{
			_videoPlayer.fullScreen = true;
		}
		
		protected function _onClickFullScreenOn(__event:MouseEvent):void
		{
			_videoPlayer.fullScreen = false;
		}
		
		protected function _onClickVolume(__event:MouseEvent):void
		{
			if (_containsInstance("mcVolume"))
			{
				if (stage != null)
				{
					stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
					stage.addEventListener(Event.ENTER_FRAME, _onSetVolume);
				}
			}
		}
		
		protected function _onMouseUp(__event:Event):void
		{
			if (stage != null)
			{
				try { stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp); } catch (__e:Error) { };
				try { stage.removeEventListener(Event.ENTER_FRAME, _onSetVolume); } catch (__e:Error) { };
			}
		}
		
		protected function _onMouseUp2(__event:Event):void
		{
			if (stage != null)
			{
				try { stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp2); } catch (__e:Error) { };
				try { stage.removeEventListener(Event.ENTER_FRAME, _onClickLessVolume); } catch (__e:Error) { };
			}
		}
		
		protected function _onMouseUp3(__event:Event):void
		{
			if (stage != null)
			{
				try { stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp2); } catch (__e:Error) { };
				try { stage.removeEventListener(Event.ENTER_FRAME, _onClickMoreVolume); } catch (__e:Error) { };
			}
		}
		
		protected function _onSetVolume(__event:Event = null ):void
		{
			if (_containsInstance("mcVolume"))
			{
				_videoPlayer.videoVolume = Numbers.getRelative(0, 1, 0, this["mcVolume"].mcHitArea.width, this["mcVolume"].mouseX);
				if (_containsInstance("mcVolumeMute", this["mcVolume"]))
				{
					this["mcVolume"].mcVolumeMute.gotoAndStop(1);
				}
			}
		}
		
		protected function _onClickZoom(__event:MouseEvent):void
		{
			if (_containsInstance("mcZoom"))
			{
				switch(__event.target.name)
				{
					case "mcZoomFit":
						_videoPlayer.videoScaleMode = VideoScaleMode.EXACT_FIT;
						break;
					case "mcZoomX05":
						_videoPlayer.videoScaleMode = VideoScaleMode.ZOOM_X05;
						break;
					case "mcZoomNoResize":
						_videoPlayer.videoScaleMode = VideoScaleMode.NO_RESIZE;
						break;
					case "mcZoomX2":
						_videoPlayer.videoScaleMode = VideoScaleMode.ZOOM_X2;
						break;
					case "mcZoomX3":
						_videoPlayer.videoScaleMode = VideoScaleMode.ZOOM_X3;
						break;
					case "mcZoomX4":
						_videoPlayer.videoScaleMode = VideoScaleMode.ZOOM_X4;
						break;
					default:
						break;
				}
				// :NOTES: forces the player to resize itself;
				_videoPlayer.playerScaleMode = _videoPlayer.playerScaleMode;
			}
		}
		
		protected function _onVideoPlayed(__event:Event):void
		{
			if (_containsInstance("mcPlayPause"))
			{
				this["mcPlayPause"].mcPlay.visible = false;
				this["mcPlayPause"].mcPause.visible = true;
			}
		}
		
		protected function _onVideoPaused(__event:Event):void
		{
			if (_containsInstance("mcPlayPause"))
			{
				this["mcPlayPause"].mcPlay.visible = true;
				this["mcPlayPause"].mcPause.visible = false;
			}
		}
		
		protected function _onMute(__event:Event):void
		{
			if (_containsInstance("mcSound"))
			{
				this["mcSound"].mcSoundOff.visible = true;
				this["mcSound"].mcSoundOn.visible = false;
			}
			if (_containsInstance("mcVolumeMute", this["mcVolume"]))
			{
				this["mcVolume"].mcVolumeMute.gotoAndStop(2);
			}
		}
		
		protected function _onUnmute(__event:Event):void
		{
			if (_containsInstance("mcSound"))
			{
				this["mcSound"].mcSoundOff.visible = false;
				this["mcSound"].mcSoundOn.visible = true;
			}
			if (_containsInstance("mcVolumeMute", this["mcVolume"]))
			{
				this["mcVolume"].mcVolumeMute.gotoAndStop(1);
			}
		}
		
		protected function _onClickMute(__event:MouseEvent):void
		{
			if (_videoPlayer.isMute) 
			{
				_videoPlayer.unmute();
				this["mcVolume"].mcVolumeMute.gotoAndStop(1);
			}
			else if (!_videoPlayer.isMute)
			{
				_videoPlayer.mute();
				this["mcVolume"].mcVolumeMute.gotoAndStop(2);
			}
		}
		
		protected function set _canPlayPause(__value:Boolean):void
		{
			if (_containsInstance("mcPlayPause"))
			{
				this["mcPlayPause"].mcPlay.buttonMode = __value;
				this["mcPlayPause"].mcPlay.useHandCursor = __value;
				if (__value) this["mcPlayPause"].mcPlay.addEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
				else this["mcPlayPause"].mcPlay.removeEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
				
				this["mcPlayPause"].mcPause.buttonMode = __value;
				this["mcPlayPause"].mcPause.useHandCursor = __value;
				if (__value) this["mcPlayPause"].mcPause.addEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
				else this["mcPlayPause"].mcPause.removeEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
			}
			
			if (_containsInstance("mcPlay"))
			{
				this["mcPlay"].buttonMode = __value;
				this["mcPlay"].useHandCursor = __value;
				if (__value) this["mcPlay"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
				else this["mcPlay"].removeEventListener(MouseEvent.MOUSE_DOWN, _onClickPlay);
			}
			
			if (_containsInstance("mcPause"))
			{
				this["mcPause"].buttonMode = __value;
				this["mcPause"].useHandCursor = __value;
				if (__value) this["mcPause"].addEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
				else this["mcPause"].removeEventListener(MouseEvent.MOUSE_DOWN, _onClickPause);
			}
		}
	}
}