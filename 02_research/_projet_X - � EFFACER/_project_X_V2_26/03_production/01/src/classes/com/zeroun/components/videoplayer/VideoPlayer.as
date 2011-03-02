/* :TODO:
 * - stop current loading of a stream when a new video is loading
 * - remove all listener in reset function
 * 
 * ********************************/

package com.zeroun.components.videoplayer
{
	import flash.display.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	
	import gs.TweenLite;
	
	import com.zeroun.components.videoplayer.*;
	
	
	public class VideoPlayer extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		protected const PLAYER_DEFAULT_SCALE		:String = PlayerScaleMode.NO_RESIZE;
		protected const VIDEO_DEFAULT_SCALE			:String = VideoScaleMode.EXACT_FIT;
		protected const LOOP_PLAYLIST				:Boolean = false;
		protected const AUTO_NEXT					:Boolean = true;
		protected const AUTO_START					:Boolean = true;
		protected const SCREEN_CLICKABLE			:Boolean = false;						// enables play/pause when click on screen
		protected const INIT_VOLUME					:Number = 1;							// valid values goes from 0 to 1
		protected const DEBUG_MODE					:Boolean = false;						// enables traces when set to true
		
		protected const DEFAULT_BUFFER				:Number = 2;							// default buffer time in seconds
		protected const USE_CUSTOM_BUFFER			:Boolean = true;						// evaluates when playback can start regarding the bandwith
		protected const VOLUME_TWEEN_DURATION		:Number = .2;
		protected const CHECK_BUFFER_INTERVAL		:Number = 500;							// interval each time the buffer is checked.
		protected const DETECT_BANDWITH_DELAY		:int = 1;								// delay in seconds before start checking bandwith
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		// has to declare variables on stage
		public var mcScreen							:MovieClip; 
		public var mcControls						:Controls; 
		public var mcBuffering						:MovieClip; 
		public var mcBigPlay						:MovieClip; 
		
		protected var _videoPath					:*;
		protected var _imagePath					:*;
		protected var _playerWidth					:int = -1;
		protected var _playerHeight					:int = -1;
		protected var _playerSpaceforControls		:int = -1;								// space used by the controls
		
		protected var _autoStart					:Boolean = AUTO_START;
		protected var _playerScaleMode				:String = PLAYER_DEFAULT_SCALE;
		protected var _videoScaleMode				:String = VIDEO_DEFAULT_SCALE;
		protected var _debugMode					:Boolean = DEBUG_MODE;
		protected var _screenClickable				:Boolean = SCREEN_CLICKABLE;
		protected var _loopPlaylist					:Boolean = LOOP_PLAYLIST;
		protected var _autoNext						:Boolean = AUTO_NEXT;
		protected var _videoVolume					:Number = INIT_VOLUME;
		
		protected var _savedVideoVolume				:Number;
		protected var _savedPlayerScaleMode			:String;
		protected var _savedVideoIndex				:int = -1;
		protected var _savedPlayerPosition			:Point;
		protected var _savedStageAlign				:String;
		protected var _savedStageScaleMode			:String;
		
		protected var _isPlaying					:Boolean = false;
		protected var _isPaused						:Boolean = false;
		protected var _isAtEnd						:Boolean = false;
		protected var _isMute						:Boolean = false;
		protected var _isLoaded						:Boolean = false;
		protected var _isBuffering					:Boolean = false;
		protected var _isFullScreen					:Boolean = false;
		protected var _useBigPlayButton				:Boolean = false;
		protected var _useControls					:Boolean = false;
		protected var _isInitializable				:Boolean = false;
		protected var _isInitialized				:Boolean = false;
		protected var _imageisLoaded				:Boolean = false;
		
		protected var _startLoadingVideo			:Boolean = false;
		protected var _metaDataReceived				:Boolean = false;
		protected var _waitingNetConnection			:Boolean = false;
		protected var _netConnectionIsOpen			:Boolean = false;
		protected var _dispatchStartEvent			:Boolean = false;
		
		protected var _startLoadedTime				:Number;
		protected var _useCustomBuffer				:Boolean = USE_CUSTOM_BUFFER;
		protected var _bufferingcheckTimer			:Timer;
		
		protected var _video						:Video;
		protected var _netConnection				:NetConnection;
		protected var _netStream					:NetStream;
		protected var _screen						:MovieClip;
		protected var _buffering					:MovieClip;
		protected var _bigPlay						:MovieClip;
		protected var _videoMask					:Shape;
		protected var _controls						:Controls;
		protected var _playList						:PlayList;
		protected var _imageLoader					:Loader;
		protected var _playerNativeWidth			:int;
		protected var _playerNativeHeight			:int;
		protected var _cuePointsByName				:Array;
		
		protected var _netStreamClientForMetaData	:Object = new Object();		// object that receive native events from the netStream object
		protected var _netStreamClient				:Object = new Object();		// empty object that receive native events from the netStream object
		protected var _videoMetaData				:Object;
		
		public var tweenVideoVolume					:Number = INIT_VOLUME;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function VideoPlayer(__videoPath:String = undefined, __imagePath:String = undefined)
		{
			if (_containsInstance("mcBuffering"))
			{
				_buffering = this["mcBuffering"];
				_buffering.stop();
				_buffering.visible = false;
			}
			
			if (_containsInstance("mcBigPlay"))
			{
				_useBigPlayButton = true;
				_bigPlay = this["mcBigPlay"];
				_bigPlay.buttonMode = true;
				_bigPlay.mouseChildren = false;
				_bigPlay.useHandCursor = true;
				_bigPlay.stop();
				_bigPlay.visible = false;
			}
			
			if (_containsInstance("mcControls")) _controls = this["mcControls"];
			
			// the videoplayer must be composed by those three movieClip : mcScreen & mcControls
			if (_containsInstance("mcScreen")) _screen = this["mcScreen"];
			else
			{
				_screen = new MovieClip();
				var shape:Shape = new Shape();
				shape.graphics.beginFill(0x000000, 0);
				shape.graphics.lineStyle();
				shape.graphics.drawRect(0, 0, 1, 1);
				shape.graphics.endFill();
				_screen.addChild(shape);
				
				_playerScaleMode = PlayerScaleMode.FIT_VIDEO;
			}
			
			// already on stage
			if (stage != null) 
			{
				// :NOTE: has to wait for the component to be initialized
				addEventListener("frameConstructed", _onInitializable);
			}
			// dynamically created
			else
			{
				_isInitializable = true;
				if (__videoPath != null)
				{
					if (__imagePath != null) 
					{
						_screenClickable = true;
						_autoStart = false;
					}
					initialize(__videoPath, __imagePath);
				}
			}
		}
		
		
		/************************************************************
		 * getter / setter
		 ************************************************************/
		
		// :NOTES: components variable
		[Inspectable(name = "1 - video")]
		public function get videoPath():* { return _videoPath; }
		public function set videoPath(__value:*):void { _videoPath = __value; }
		
		[Inspectable(name = "2 - image")]
		public function get imagePath():* { return _imagePath; }
		public function set imagePath(__value:*):void { _imagePath = __value; }
		
		[Inspectable(name = "3 - width", defaultValue = -1)]
		public function get playerWidth():int {return _playerWidth;}
		public function set playerWidth(__value:int):void {_playerWidth = __value;}
		
		[Inspectable(name = "4 - height", defaultValue = -1)]
		public function get playerHeight():int {return _playerHeight;}
		public function set playerHeight(__value:int):void { _playerHeight = __value; }
		
		[Inspectable(name = "5 - space for controls", defaultValue = 0)]
		public function get playerSpaceforControls():int
		{
			if (_controls != null) return _playerSpaceforControls;
			else return 0;
		}
		public function set playerSpaceforControls(__value:int):void { _playerSpaceforControls = __value; }
		
		[Inspectable(name = "6 - auto start")]
		public function get autoStart():Boolean { return _autoStart; }
		public function set autoStart(__value:Boolean):void { _autoStart = __value; }
		
		public function get screen():Sprite { return _screen; }
		public function get video():Video { return _video; }
		public function get controls():Controls { return _controls; }
		public function get playList():PlayList { return _playList; }
		public function get netStream():NetStream { return _netStream; }
		public function get videoIndex():Number{ return _playList.index; }
		public function get videoPosition():Number{ return _netStream.time; }
		public function get videoDuration():Number
		{
			if (_videoMetaData == null)
			{
				_throwError(12);
				return -1;
			}
			else return _videoMetaData["duration"];
		}
		public function get videoWidth():int { return _video.width; }
		public function get videoHeight():int { return _video.height; }
		public function get videoNativeWidth():int
		{ 
			if (_videoMetaData == null)
			{
				_throwError(12);
				return -1;
			}
			else return _videoMetaData["width"];
		}
		public function get videoNativeHeight():int
		{ 
			if (_videoMetaData == null)
			{
				_throwError(12);
				return -1;
			}
			else return _videoMetaData["height"];
		}
		public function get isPlaying():Boolean{ return _isPlaying; }
		public function get isLoaded():Boolean{ return _isLoaded; }
		public function get isInitialized():Boolean{ return _isInitialized; }
		public function get isInitializable():Boolean{ return _isInitializable; }
		public function get cuePointsByName():Array{ return _cuePointsByName; }
		public function get isMute():Boolean { return _isMute; }
		public function get netConnectionIsOpen():Boolean { return _netConnectionIsOpen; }
		
		public function get videoVolume():Number{ return _videoVolume; }
		public function set videoVolume(__value:Number):void 
		{
			var volume:Number;
			if (__value <= 0) volume = 0;
			else 
			{
				_isMute = false;
				if (__value > 1) volume = 1;
				else volume = __value;
			}
			tweenVideoVolume = _videoVolume;
			TweenLite.killTweensOf(this, false);
			TweenLite.to(this, VOLUME_TWEEN_DURATION, { tweenVideoVolume:volume, onUpdate:_onUpdateVolume } );
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_UNMUTE));
		}
		
		public function get loopPlaylist():Boolean { return _loopPlaylist; }
		public function set loopPlaylist(__value:Boolean):void 
		{
			_loopPlaylist = __value;
			if (_controls != null) _controls.loopPlaylist = __value;
			if (__value) autoNext = true;
		}
		
		public function get autoNext():Boolean { return _autoNext; }
		public function set autoNext(__value:Boolean):void 
		{
			_autoNext = __value;
			if (_controls != null) _controls.autoNext = __value;
		}
		
		public function get debugMode():Boolean { return _debugMode; }
		public function set debugMode(__value:Boolean):void { _debugMode = __value; }
		
		public function get useCustomBuffer():Boolean { return _useCustomBuffer; }
		public function set useCustomBuffer(__value:Boolean):void { _useCustomBuffer = __value; }
		
		public function get fullScreen():Boolean{ return _isFullScreen; }
		public function set fullScreen(__value:Boolean):void
		{
			if (!_isFullScreen) _savedPlayerScaleMode = _playerScaleMode;
			_isFullScreen = __value;
			if (_controls != null) _controls.fullScreen = __value;
			if (_isFullScreen) 
			{
				if (stage == null) 
				{
					_throwError(1);
					return;
				}
				else
				{
					_playerScaleMode = PlayerScaleMode.FULL_SIZE;
					stage.displayState = StageDisplayState.FULL_SCREEN;
					_savedStageAlign = stage.align;
					_savedStageScaleMode = stage.scaleMode;
					stage.align = StageAlign.TOP_LEFT;
					stage.scaleMode = StageScaleMode.NO_SCALE;
					_savedPlayerPosition = new Point(x, y);
					resize();
					x = 0;
					y = 0;
					dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.ENTER_FULLSCREEN));
				}
			}
			else 
			{
				if (stage == null) 
				{
					_throwError(1);
					return;
				}
				else
				{
					_playerScaleMode = _savedPlayerScaleMode;
					stage.displayState = StageDisplayState.NORMAL;
					stage.align = _savedStageAlign;
					stage.scaleMode = _savedStageScaleMode;
					resize();
					x = _savedPlayerPosition.x;
					y = _savedPlayerPosition.y;
					dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.EXIT_FULLSCREEN));
				}
			}
		}
		
		public function get defaultBuffer():int { return _netStream.bufferTime; }
		public function set defaultBuffer(__value:int):void 
		{
			// :NOTES: if the bufferTimer is used with USE_CUSTOM_BUFFER it makes some video play twice the regular speed
			if (!USE_CUSTOM_BUFFER) _netStream.bufferTime = __value;
		}
		
		public function get videoScaleMode():String{ return _videoScaleMode; }
		public function set videoScaleMode(__value:String):void 
		{
			var tmpWidth:int;
			var tmpHeight:int;
			switch (__value)
			{
				case VideoScaleMode.NO_RESIZE:
					if (_controls != null) _controls.zoom = Controls.NO_RESIZE;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						tmpWidth = _videoMetaData["width"];
						tmpHeight = _videoMetaData["height"];
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.ZOOM_X05:
					if (_controls != null) _controls.zoom = Controls.ZOOM_X05;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						tmpWidth = _videoMetaData["width"]/2;
						tmpHeight = _videoMetaData["height"]/2;
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.ZOOM_X2:
					if (_controls != null) _controls.zoom = Controls.ZOOM_X2;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						tmpWidth = _videoMetaData["width"]*2;
						tmpHeight = _videoMetaData["height"]*2;
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.ZOOM_X3:
					if (_controls != null) _controls.zoom = Controls.ZOOM_X3;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						tmpWidth = _videoMetaData["width"]*3;
						tmpHeight = _videoMetaData["height"]*3;
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.ZOOM_X4:
					if (_controls != null) _controls.zoom = Controls.ZOOM_X4;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						tmpWidth = _videoMetaData["width"]*4;
						tmpHeight = _videoMetaData["height"]*4;
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.FIT:
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						if (_playerScaleMode == PlayerScaleMode.NO_RESIZE)
						{
							tmpWidth = _video.width;
							tmpHeight = _video.height;
						}
						else if (_playerScaleMode == PlayerScaleMode.FIT_VIDEO)
						{
							tmpHeight = videoNativeHeight;
							tmpWidth = videoNativeWidth;
						}
						else if (_playerScaleMode == PlayerScaleMode.CUSTOM_SIZE)
						{
							tmpWidth = _playerWidth;
							tmpHeight = (_playerHeight - playerSpaceforControls);
						}
						else
						{
							if (stage == null) 
							{
								_throwError(1);
								return;
							}
							else
							{
								tmpWidth = stage.stageWidth;
								tmpHeight = (stage.stageHeight - playerSpaceforControls);
							}
						}
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.NO_BORDER:
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						if (_playerScaleMode == PlayerScaleMode.NO_RESIZE)
						{
							if (_videoMetaData["width"] > _playerNativeWidth && _videoMetaData["height"] > _playerNativeHeight)
							{
								if ((_playerNativeWidth / _videoMetaData["width"]) < (_playerNativeHeight / _videoMetaData["height"]))
								{
									
									tmpWidth = _videoMetaData["width"] * (_playerNativeHeight / _videoMetaData["height"]);
									tmpHeight = _playerNativeHeight;
								}
								else
								{
									tmpWidth = _playerNativeWidth;
									tmpHeight = _videoMetaData["height"] * (_playerNativeWidth / _videoMetaData["width"]);
								}
							}
							else if (_videoMetaData["width"] > _playerNativeWidth)
							{
								tmpWidth = _videoMetaData["width"] * (_playerNativeHeight / _videoMetaData["height"]);
								tmpHeight = _playerNativeHeight;
							}
							else if (_videoMetaData["height"] > _playerNativeHeight)
							{
								
								tmpWidth = _playerNativeWidth;
								tmpHeight = _videoMetaData["height"] * (_playerNativeWidth / _videoMetaData["width"]);
							}
							else
							{
								tmpWidth = _videoMetaData["width"];
								tmpHeight = _videoMetaData["height"];
							}
						}
						else if (_playerScaleMode == PlayerScaleMode.FIT_VIDEO)
						{
							tmpWidth = videoNativeWidth;
							tmpHeight = videoNativeHeight;
						}
						else if (_playerScaleMode == PlayerScaleMode.CUSTOM_SIZE)
						{
							if (_videoMetaData["width"] > _playerWidth && _videoMetaData["height"] > (_playerHeight -  playerSpaceforControls))
							{
								if ((_playerWidth / _videoMetaData["width"]) < ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]))
								{
									tmpWidth = _videoMetaData["width"] * ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]);
									tmpHeight = (_playerHeight -  playerSpaceforControls);
								}
								else
								{
									tmpWidth = _playerWidth;
									tmpHeight = _videoMetaData["height"] * (_playerWidth / _videoMetaData["width"]);
								}
							}
							else if (_videoMetaData["width"] > _playerWidth)
							{
								tmpWidth = _videoMetaData["width"] * ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]);
								tmpHeight = (_playerHeight -  playerSpaceforControls);
							}
							else if (_videoMetaData["height"] > (_playerHeight -  playerSpaceforControls))
							{
								tmpWidth = _playerWidth;
								tmpHeight = _videoMetaData["height"] * (_playerWidth / _videoMetaData["width"]);
							}
							else
							{
								if ((_playerWidth / _videoMetaData["width"]) < ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]))
								{
									tmpWidth = _videoMetaData["width"] * ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]);
									tmpHeight = (_playerHeight -  playerSpaceforControls);
								}
								else
								{
									tmpWidth = _playerWidth;
									tmpHeight = _videoMetaData["height"] * (_playerWidth / _videoMetaData["width"]);
								}
							}
						}
						else
						{
							if (stage == null) 
							{
								_throwError(1);
								return;
							}
							else
							{
								if (_videoMetaData["width"] > stage.stageWidth && _videoMetaData["height"] > (stage.stageHeight -  playerSpaceforControls))
								{
									if ((stage.stageWidth / _videoMetaData["width"]) < ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]))
									{
										tmpWidth = _videoMetaData["width"] * ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]);
										tmpHeight = (stage.stageHeight -  playerSpaceforControls);
									}
									else
									{
										tmpWidth = stage.stageWidth;
										tmpHeight = _videoMetaData["height"] * (stage.stageWidth / _videoMetaData["width"]);
									}
								}
								else if (_videoMetaData["width"] > stage.stageWidth)
								{
									tmpWidth = _videoMetaData["width"] * ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]);
									tmpHeight = (stage.stageHeight -  playerSpaceforControls);
								}
								else if (_videoMetaData["height"] > (stage.stageHeight -  playerSpaceforControls))
								{
									tmpWidth = stage.stageWidth;
									tmpHeight = _videoMetaData["height"] * (stage.stageWidth / _videoMetaData["width"]);
								}
								else
								{
									if ((stage.stageWidth / _videoMetaData["width"]) < ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]))
									{
										tmpWidth = _videoMetaData["width"] * ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]);
										tmpHeight = (stage.stageHeight -  playerSpaceforControls);
									}
									else
									{
										tmpWidth = stage.stageWidth;
										tmpHeight = _videoMetaData["height"] * (stage.stageWidth / _videoMetaData["width"]);
									}
								}
							}
						}
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.FIT_WIDTH:
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						if (_playerScaleMode == PlayerScaleMode.NO_RESIZE)
						{
							tmpWidth = _playerNativeWidth;
							tmpHeight = _videoMetaData["height"] * (_playerNativeWidth / _videoMetaData["width"]);
						}
						else if (_playerScaleMode == PlayerScaleMode.FIT_VIDEO)
						{
							tmpWidth = videoNativeWidth;
							tmpHeight = videoNativeHeight;
						}
						else if (_playerScaleMode == PlayerScaleMode.CUSTOM_SIZE)
						{
							tmpWidth = _playerWidth;
							tmpHeight = _videoMetaData["height"] * (_playerWidth / _videoMetaData["width"]);
						}
						else
						{
							if (stage == null) 
							{
								_throwError(1);
								return;
							}
							else
							{
								tmpWidth = stage.stageWidth;
								tmpHeight = _videoMetaData["height"] * (stage.stageWidth / _videoMetaData["width"]);
							}
						}
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.FIT_HEIGHT:
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						if (_playerScaleMode == PlayerScaleMode.NO_RESIZE)
						{
							tmpWidth = _videoMetaData["width"] * (_playerNativeHeight / _videoMetaData["height"]);
							tmpHeight = _playerNativeHeight;
						}
						else if (_playerScaleMode == PlayerScaleMode.FIT_VIDEO)
						{
							tmpWidth = videoNativeWidth;
							tmpHeight = videoNativeHeight;
						}
						else if (_playerScaleMode == PlayerScaleMode.CUSTOM_SIZE)
						{
							tmpWidth = _videoMetaData["width"] * ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]);
							tmpHeight = (_playerHeight -  playerSpaceforControls);
						}
						else
						{
							if (stage == null) 
							{
								_throwError(1);
								return;
							}
							else
							{
								tmpWidth = _videoMetaData["width"] * ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]);
								tmpHeight = (stage.stageHeight -  playerSpaceforControls);
							}
						}
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				case VideoScaleMode.EXACT_FIT:
					if (_controls != null) _controls.zoom = Controls.ZOOM_FIT;
					_videoScaleMode = __value;
					if (_metaDataReceived)
					{
						if (_playerScaleMode == PlayerScaleMode.NO_RESIZE)
						{
							if ((_videoMetaData["width"] / _videoMetaData["height"]) >= (_playerNativeWidth / _playerNativeHeight ))
							{
								tmpWidth = _playerNativeWidth;
								tmpHeight = _videoMetaData["height"] * (_playerNativeWidth / _videoMetaData["width"]);
							}
							else
							{
								tmpWidth = _videoMetaData["width"] * (_playerNativeHeight / _videoMetaData["height"]);
								tmpHeight = _playerNativeHeight;
							}
						}
						else if (_playerScaleMode == PlayerScaleMode.FIT_VIDEO)
						{
							tmpWidth = videoNativeWidth;
							tmpHeight = videoNativeHeight;
						}
						else if (_playerScaleMode == PlayerScaleMode.CUSTOM_SIZE)
						{
							if ((_videoMetaData["width"] / _videoMetaData["height"]) >= (_playerWidth / (_playerHeight -  playerSpaceforControls) ))
							{
								tmpWidth = _playerWidth;
								tmpHeight = _videoMetaData["height"] * (_playerWidth / _videoMetaData["width"]);
							}
							else
							{
								tmpWidth = _videoMetaData["width"] * ((_playerHeight -  playerSpaceforControls) / _videoMetaData["height"]);
								tmpHeight = (_playerHeight -  playerSpaceforControls);
							}
						}
						else
						{
							if (stage == null) 
							{
								_throwError(1);
								return;
							}
							else
							{
								if ((_videoMetaData["width"] / _videoMetaData["height"]) >= (stage.stageWidth / (stage.stageHeight -  playerSpaceforControls) ))
								{
									tmpWidth = stage.stageWidth;
									tmpHeight = _videoMetaData["height"] * (stage.stageWidth / _videoMetaData["width"]);
								}
								else
								{
									tmpWidth = _videoMetaData["width"] * ((stage.stageHeight -  playerSpaceforControls) / _videoMetaData["height"]);
									tmpHeight = (stage.stageHeight -  playerSpaceforControls);
								}
							}
						}
						_resizeScreenTo(tmpWidth, tmpHeight);
					}
					break;
				default:
					_throwError(3);
					break;
			}
		}
		
		public function get playerScaleMode():String{ return _playerScaleMode; }
		public function set playerScaleMode(__value:String):void 
		{
			switch (__value) 
			{
				case PlayerScaleMode.NO_RESIZE:
				case PlayerScaleMode.FIT_VIDEO:
				case PlayerScaleMode.CUSTOM_SIZE:
				case PlayerScaleMode.FULL_SIZE:
					_playerScaleMode = __value;
					break;
				default:
					_throwError(4);
					break;
			}
			_resizePlayer();
		}
		
		public function get useControls():Boolean{ return _useControls; }
		public function set useControls(__value:Boolean):void
		{
			_useControls = __value;
			if (!_useControls) hideControls();
		}
		
		public function set screenClickable(__value:Boolean):void
		{
			_screenClickable = __value;
			if (_screenClickable)
			{
				_screen.buttonMode = true;
				_screen.useHandCursor = true;
				_screen.addEventListener(MouseEvent.CLICK, _onClickScreen);
				if (_bigPlay != null) _bigPlay.addEventListener(MouseEvent.CLICK, _onClickScreen);
			}
			else
			{
				_screen.buttonMode = false;
				_screen.useHandCursor = false;
				if (_screen.hasEventListener(MouseEvent.CLICK)) _screen.removeEventListener(MouseEvent.CLICK, _onClickScreen);
				if (_bigPlay != null && _bigPlay.hasEventListener(MouseEvent.CLICK)) _bigPlay.removeEventListener(MouseEvent.CLICK, _onClickScreen);
			}
		}
		public function set smoothing(__value:Boolean):void{ if (_video != null) _video.smoothing = __value;}
		public function set useBigPlayButton(__value:Boolean):void { _useBigPlayButton = __value; }
		public function set options(__value:Object):void
		{
			for (var option:* in __value)
			{
				switch(option)
				{
					case "videoPath":
					case "imagePath":
					case "playerWidth":
					case "playerHeight":
					case "autoStart":
					case "playerSpaceforControls":
					case "debugMode":
					case "screenClickable":
					case "playerScaleMode":
					case "videoScaleMode":
					case "loopPlaylist":
					case "autoNext":
					case "videoVolume":
					case "useBigPlayButton":
					case "useCustomBuffer":
					case "useControls":
						this[option] = __value[option];
						break;
					default:
						"VideoPlayer set option ERROR : unknow " + option;
				}
			}
			if (!_isInitialized) initialize(_videoPath, _imagePath);
		}
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		// :NOTES: path can either be a String or a Array
		public function initialize(__videoPaths:* = undefined, __imagePaths:* = undefined):void
		{
			if (_isInitializable)
			{
				if (_playerWidth > -1) _screen.width = _playerWidth;
				else _playerWidth = _screen.width;
				
				if (_playerHeight > -1) _screen.height = _playerHeight;
				else _playerHeight = _screen.height;
				
				if (_playerSpaceforControls == -1)
				{
					if (_controls != null) _playerSpaceforControls = _controls.y - _playerHeight;
					else _playerSpaceforControls = 0;
				}
				
				_playerNativeWidth = _screen.width;
				_playerNativeHeight = _screen.height;
				
				screenClickable = _screenClickable;
				
				_videoMask = new Shape();
				_videoMask.graphics.beginFill(0xFF0000, 0);
				_videoMask.graphics.lineStyle();
				_videoMask.graphics.drawRect(0, 0, _playerWidth, _playerHeight);
				_videoMask.graphics.endFill();
				addChild(_videoMask);
				
				_bufferingcheckTimer = new Timer(CHECK_BUFFER_INTERVAL);
				_bufferingcheckTimer.addEventListener(TimerEvent.TIMER, _onCheckBuffer);
				
				var videos:* = (__videoPaths == undefined) ? _videoPath : __videoPaths;
				var images:* = (__imagePaths == undefined) ? _imagePath : __imagePaths;
				
				_playList = new PlayList();
				if (videos != null) setPlaylist(videos, images);
				
				if (_controls != null) _controls.initialize(this);
				resize();
				
				_isInitialized = true;
				dispatchEvent( new VideoPlayerEvent(VideoPlayerEvent.ON_INITIALIZED));
			}
			else _throwError(-1);
		}
		
		// :NOTES: path can either be a String or a Array os Strings
		public function setPlaylist(__videoPaths:*, __imagePaths:* = undefined):void 
		{
			if (_video != null) 
			{
				_video.visible = false;
				_video.clear();
			}
			if (debugMode) traceDebug ("setPlaylist>> __videoPaths:" +  __videoPaths + " __imagePaths:" + __imagePaths + "!");
			_playList.removeAllItems();
			
			// reset all the playlist;
			if (_isBuffering) _stopBuffering(false);
			
			if (_netConnectionIsOpen) _netStream.pause();
			
			_isPlaying = false;
			_isPaused = false
			_isLoaded = false;
			_startLoadingVideo = false;
			_metaDataReceived = false;
			_isAtEnd = false;
			
			// single video
			if (typeof(__videoPaths) == "string")
			{
				if (__imagePaths == null) _playList.addItem([__videoPaths,""]);
				else if (__imagePaths != null && typeof(__imagePaths) == "string") _playList.addItem([__videoPaths, __imagePaths]);
				else
				{
					_throwError(13);
					return;
				}
			}
			// list of videos
			else if (typeof(__videoPaths) == "object")
			{
				if (__imagePaths == null)
				{
					for (var i:int = 0 ; i < __videoPaths.length; i++ ) _playList.addItem([__videoPaths[i],""]);
				}
				else if (__imagePaths != null && typeof(__imagePaths) == "object" && __videoPaths.length == __imagePaths.length)
				{
					for (var j:int = 0 ; j < __videoPaths.length; j++ ) _playList.addItem([__videoPaths[j], __imagePaths[j]]);
				}
				else
				{
					_throwError(13);
					return;
				}
			}
			else
			{
				_throwError(2);
				return;
			}
			
			if (__imagePaths != null) 
			{
				_autoStart = false;
				_showImage(_playList.getImagePath());
			}
			else if (_autoStart) if (!_netConnectionIsOpen && !_waitingNetConnection) _openNetConnection();
		}
		
		public function reset():void
		{
			if (debugMode) traceDebug ("reset>>");
			if (_netConnectionIsOpen)
			{
				pause();
				if (_controls != null) _controls.reset();
				_netStream.close();
				_netConnection.close();
				_netConnectionIsOpen = false;
				_waitingNetConnection = false;
				this.removeEventListener(Event.ENTER_FRAME, _onVideoUpdated);
				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.PLAYER_RESET));
			}
		}
		
		public function loadNextVideo():Boolean 
		{
			if (debugMode) traceDebug ("loadNextVideo>>");
			if (_startLoadingVideo)
			{
				var index:int = _playList.getNextIndex();
				if (index != -1) return loadVideoIndex(index)
				else return false;
			}
			else return false
		}
		
		public function loadPreviousVideo():Boolean 
		{
			if (debugMode) traceDebug ("loadPreviousVideo>>");
			if (_startLoadingVideo)
			{
				var index:int = _playList.getPreviousIndex();
				if (index != -1) return loadVideoIndex(index)
				else return false;
			}
			else return false
		}
		
		public function loadVideoIndex(__index:int = 0):Boolean
		{
			if (debugMode) traceDebug ("loadVideoIndex>> __index:" + __index);
			var video:String;
			if (_playList.items.length > 0)
			{
				if (__index >= _playList.items.length) _throwError(5);
				else if (_netConnectionIsOpen)
				{
					_savedVideoIndex = -1;
					video = _playList.setToIndex(__index)[0];
					if (video != null) _loadVideo(video);
					else  _throwError(6);
				}
				else _savedVideoIndex = __index;
			}
			else _throwError(7);
			return (video != null);
		}
		
		public function play(__position:Number = -1, __play:Boolean = true):void 
		{
			if (debugMode) traceDebug ("play>> __position:" +  __position + ", __play:" + __play);
			if (_netConnectionIsOpen) 
			{
				if (!_startLoadingVideo) loadVideoIndex();
				else
				{
					// user decided to start playing before the end of the custom buffer
					if (_isBuffering && _useCustomBuffer)
					{
						_useCustomBuffer = false;
						_netStream.bufferTime = DEFAULT_BUFFER;
						_stopBuffering();
					}
					//else if (!_isLoaded && !_isBuffering && (_netStream.bufferLength < _netStream.bufferTime))
					// :NOTES: this line was causing :Il s'est produit un débordement de pile.
					else if (!_isLoaded && !_isBuffering && (_netStream.bufferLength < _netStream.bufferTime) && !_useCustomBuffer) _startBuffering();
					else
					{
						if (_isBuffering) _stopBuffering(false);
						
						if (_isPaused)
						{
							if (_isAtEnd)
							{
								_isAtEnd = false;
								if (__position == -1) _netStream.seek(0);
								else _netStream.seek(__position);
							}
							else if (__position != -1) _netStream.seek(__position);
							_netStream.resume();
						}
						else if (__play)
						{
							if (__position == -1)  _netStream.play(_netStream.time);
							else
							{
								_netStream.seek(__position);
								_netStream.play(__position);
							}
						}
						
						_isPlaying = true;
						_isPaused = false;
						if (_controls != null) _controls.status = "Playing";
						_hideBigPlayButton();
						
						if (_dispatchStartEvent)
						{
							_dispatchStartEvent = false;
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_STARTED));
						}
						dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_PLAYED));
					}
					if (!_isLoaded)
					{
						_onCheckBuffer();
						_bufferingcheckTimer.start();
					}
				}
			}
			else if (_playList.items.length > 0) _startPlayBack(null);
			else _throwError(0);
		}
		
		public function pause(__position:int = -1):void 
		{
			if (debugMode) traceDebug ("pause>> __position:" +  __position);
			if (_netConnectionIsOpen) 
			{
				if (__position == -1) _netStream.pause();
				else 
				{
					_netStream.seek(__position);
					_netStream.pause();
				}
				_isPlaying = false;
				_isPaused = true;
				if (!_isBuffering) 
				{
					if (_controls != null) _controls.status = "Paused";
					_showBigPlayButton();
				}
				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_PAUSED));
			}
		}
		
		public function stop():void 
		{
			if (debugMode) traceDebug ("stop>>");
			if (_netConnectionIsOpen)  pause(0);
		}
		
		public function seek(__position:int):void 
		{
			if (debugMode) traceDebug ("seek>> __position:" + __position);
			if (_netConnectionIsOpen) 
			{
				_isAtEnd = false;
				_netStream.seek(__position);
			}
			else _throwError(0);
		}
		
		public function mute():void
		{
			if (debugMode) traceDebug ("mute>>");
			_savedVideoVolume = _videoVolume;
			videoVolume = 0;
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_MUTE));
			_isMute = true;
		}
		
		public function unmute(__value:Number = -1):void
		{
			var volume:Number = __value == -1 ? _savedVideoVolume : __value;
			if (debugMode) traceDebug ("unmute>>");
			videoVolume = volume;
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_UNMUTE));
		}
		
		public function resize(__width:int = -1, __height:int = -1):void
		{
			if (debugMode) traceDebug ("resize>>" + _metaDataReceived);
			if (__width > -1 && __height > -1)
			{
				_playerScaleMode = PlayerScaleMode.CUSTOM_SIZE;
				_playerWidth = __width;
				_playerHeight = __height;
			}
			
			if (_metaDataReceived) 
			{
				playerScaleMode = _playerScaleMode;
				videoScaleMode = _videoScaleMode;
			}
			else
			{
				_resizePlayer();
				_resizeScreenTo(_screen.width, _screen.height);
			}
			
			if (_controls != null)
			{
				_controls.y = _screen.height + playerSpaceforControls;
				_controls.resize();
			}
			
			_resizeImage();
			if (_bigPlay != null && _bigPlay.visible)
			{
				_bigPlay.x = _playerWidth / 2;
				_bigPlay.y = _playerHeight / 2;
			}
		}
		
		public function showControls(__resize:Boolean = true):void
		{
			if (debugMode) traceDebug ("showControls>> resize:" + __resize);
			if (_controls != null && _useControls) _controls.visible = true;
			if (_netConnectionIsOpen) 
			{
				if (__resize)  resize();
			}
		}
		
		public function hideControls(__resize:Boolean = true):void
		{
			if (debugMode) traceDebug ("hideControls>> resize:" + __resize);
			if (_controls != null) _controls.visible = false;
			if (_netConnectionIsOpen) 
			{
				if (__resize)  resize();
			}
		}
		
		/************************************************************
		 * protected methods
		 ************************************************************/
		
		protected function _containsInstance(__instance:String, __object:* = null):Boolean
		{
			if (_debugMode) traceDebug ("_containsInstance>> __instance:" + __instance);
			var object:*;
			if (__object == null ) object = this;
			else object = __object;
			return (object.getChildByName(__instance) != null);
		}
		
		protected function _openNetConnection():void
		{
			if (_debugMode) traceDebug ("_openNetConnection>> " + _savedVideoIndex);
			_waitingNetConnection = true;
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
            _netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
			_netConnection.connect(null);
		}
		
		protected function _initializeNetStream():void
		{
			if (_debugMode) traceDebug ("_initializeNetStream>> " + _savedVideoIndex);
			_netStream = new NetStream(_netConnection);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _asyncErrorHandler);
			_netStream.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler);
			_netStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);
			
			defaultBuffer = DEFAULT_BUFFER;
			
			//_netStreamClient.onXMPData = _onXMPDataReceived;
			//_netStreamClient.onMetaData = _onMetaDataReceived;
			//_netStreamClient.onCuePoint = _onCuePointReached;
			//_netStreamClient.onPlayStatus = _onPlayStatusModified;
			
			_netStreamClientForMetaData.onMetaData = _onMetaDataReceived;
			
			//_netStreamClient.onXMPData = _onXMPDataReceived;
			_netStreamClient.onMetaData = undefined;
			_netStreamClient.onCuePoint = _onCuePointReached;
			_netStreamClient.onPlayStatus = _onPlayStatusModified;
			
			_video = new Video();
			_video.attachNetStream(_netStream);
			_video.visible = false;
			_video.mask = _videoMask;
			addChild(_video);
			if (_controls != null) addChild(_controls);
			
			_waitingNetConnection = false;
			_netConnectionIsOpen = true;
			
			// playback is pending
			if (_savedVideoIndex != -1)
			{
				loadVideoIndex(_savedVideoIndex);
				_savedVideoIndex = -1;
			}
			else loadVideoIndex();
		}
		
		protected function _netStatusHandler(__event:NetStatusEvent):void
		{
			if (_debugMode) traceDebug ("_netStatusHandler> " + __event.info.code);
            switch (__event.info.code) {
                case "NetConnection.Connect.Success":
                    _initializeNetStream();
                    break;
                case "NetStream.Play.StreamNotFound":
                    _throwError(8, _playList.getVideoPath());
                    break;
				case "NetStream.Play.Start":
					// :NOTE: sound is temporarely mute to prevent a glitch at the beginning
					_savedVideoVolume = _videoVolume;
					_videoVolume = 0;
					_setVolume(_videoVolume);
					
					this.addEventListener(Event.ENTER_FRAME, _checkMetadataReceived);
					break;
				case "NetStream.Play.Stop":
					if (_debugMode) traceDebug ("NetStream.Play.Stop>>" + _loopPlaylist);
					// :NOTES: prevents video to go to the end and load next video if ther is no key frames
					if (_controls != null && _controls.hasProgressBar() && _controls.progressBar.isDragging) seek(0);
					else
					{
						if (_isBuffering) _stopBuffering();
						_isAtEnd = true;
						if (!_autoNext) 
						{
							// :TODO: show image
							pause();
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_COMPLETE));
						}
						else if (_loopPlaylist && _playList.items.length <= 1)
						{
							play(0);
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_COMPLETE));
						}
						else if (_loopPlaylist && videoIndex >= _playList.items.length - 1)
						{
							loadVideoIndex(0);
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_COMPLETE));
						}
						else if (_autoNext && videoIndex < _playList.items.length - 1)
						{
							loadNextVideo();
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_COMPLETE));
						}
						else
						{
							pause();
							dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_COMPLETE));
						}
					}
					break;
				case "NetStream.Buffer.Empty":
					if (!_isLoaded && !_isBuffering && _isPlaying)
					{
						_startBuffering();
						pause();
					}
					break;
				case "NetStream.Seek.InvalidTime":
					// :NOTES: at the end if there is no key frame, the seeked timed might throw an exeption. the info.details contains the last right position. attention if can be an infinite loop ?
					seek(Math.floor(Number(__event.info.details)));
					break;
				case "NetStream.Buffer.Flush":
				case "NetStream.Buffer.Full":
					if (_isBuffering) _stopBuffering();
					break;
				case "NetStream.Seek.Notify":
					break;
				default:
					if (_debugMode) traceDebug ("_netStatusHandler> " + __event.info.code);
					break;
            }
        }
		
		protected function _securityErrorHandler(__event:SecurityErrorEvent):void
		{
            _throwError(9, __event);
        }
		
		protected function _asyncErrorHandler(__event:AsyncErrorEvent):void
		{
           _throwError(10, __event);
        }
		
		protected function _ioErrorHandler(__event:IOErrorEvent):void
		{
           _throwError(11, __event);
        }
		
		protected function _onMetaDataReceived(__object:Object):void
		{
			var data:*;
			if (_videoMetaData == null) _videoMetaData = new Object();
			// :KLUDGE: this is to prevent the metada to be catch if the loading wasn't wanted (case when the user is playing with the cursor and the video has no key frames)
			if (!_metaDataReceived)
			{
				for (data in _videoMetaData)  _videoMetaData[data] = null;
				_cuePointsByName = null;
				var hasCuePoints:Boolean = false;
				for (data in __object) 
				{
					_videoMetaData[data] = __object[data];
					if (_debugMode) traceDebug ("_onMetaDataReceived>> " + data + ":" + __object[data])
					if (data == "cuePoints") hasCuePoints = true;
				}
				if (hasCuePoints)
				{
					_cuePointsByName = new Array();
					for (var i:int = 0 ; i < _videoMetaData["cuePoints"].length; i++) _cuePointsByName[_videoMetaData["cuePoints"][i].name] = _videoMetaData["cuePoints"][i].time;
				}
				_metaDataReceived = true;
				_netStream.client = _netStreamClient;
			//	_netStream.client = _netStreamClientEmpty;
				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.ON_METADATA_RECEIVED));
				resize();
			}
		}
		
		//protected function _onXMPDataReceived(__object:Object):void
		//{
			//for (var data:* in __object) 
			//{
				//if (_debugMode) traceDebug ("_onXMPDataReceived>> " + data + ":" + __object[data])
			//}
		//}
		
		protected function _onCuePointReached(__object:Object):void
		{
			if (_debugMode) traceDebug ("_onCuePointReached>> __object:" + __object);
			for (var data:* in __object) 
			{
				if (_debugMode) traceDebug ("_onCuePointReached>> " + data + ":" + __object[data])
			}
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.ON_CUE_POINT, __object["name"]));
			/*
			Property 	Description 
			-----------------------
			name 		The name given to the cue point when it was embedded in the video file. 
			parameters 	A associative array of name/value pair strings specified for this cue point. Any valid string can be used for the parameter name or value. 
			time 		The time in seconds at which the cue point occurred in the video file during playback. 
			type 		The type of cue point that was reached, either navigation or event. 
			*/
		}
		
		protected function _onPlayStatusModified(__object:Object):void
		{
			if (_debugMode) traceDebug ("_onPlayStatusModified>> __object:" + __object);
			for (var data:* in __object) 
			{
				if (_debugMode) traceDebug ("_onPlayStatus>> " + data + ":" + __object[data])
			}
			/*
			Code property			Level property	Meaning 
			-----------------------------------------------
			NetStream.Play.Switch	"status" 		The subscriber is switching from one stream to another in a playlist. 
			NetStream.Play.Complete "status" 		Playback has completed. 
 
			*/
		}
		
		protected function _onUpdateVolume():void
		{
			if (_debugMode) traceDebug ("_onUpdateVolume>>" );
			_videoVolume = tweenVideoVolume;
			_setVolume(_videoVolume);
			if (_controls != null) _controls.volume = tweenVideoVolume;
		}
		
		protected function _setVolume(__volume:Number):void
		{
			if (_debugMode) traceDebug ("_setVolume>>" );
			var soundTransform:SoundTransform =  new SoundTransform();
            soundTransform.volume = __volume;
			if (_netStream != null)  _netStream.soundTransform = soundTransform;
		}
		
		protected function _onClickScreen(__event:MouseEvent):void
		{
			if (_debugMode) traceDebug ("_onClickScreen>>");
			if (_isPlaying)
			{
				_showBigPlayButton();
				pause();
			}
			else
			{
				_hideBigPlayButton();
				play();
			}
		}
		
		protected function _showBigPlayButton():void
		{
			if (_bigPlay != null && _useBigPlayButton)
			{
				_bigPlay.visible = true;
				_bigPlay.x = _playerWidth / 2;
				_bigPlay.y = _playerHeight / 2;
				addChild(_bigPlay);
			}
		}
		
		protected function _hideBigPlayButton():void
		{
			if (_bigPlay != null && _useBigPlayButton) _bigPlay.visible = false;
		} 
		
		protected function _startPlayBack(__event:MouseEvent):void
		{
			if (_debugMode) traceDebug ("_startPlayBack>>" + _videoVolume);
			if (!_screenClickable)
			{
				_screen.buttonMode = false;
				_screen.removeEventListener(MouseEvent.CLICK, _startPlayBack);
			}
			
			if (_imageLoader != null && contains(_imageLoader)) removeChild(_imageLoader);
			
			if (!_netConnectionIsOpen && !_waitingNetConnection)
			{
				_openNetConnection();
				_autoStart = true;
				_setVolume(_videoVolume);
			}
		}
		
		protected function _onVideoUpdated(__event:Event):void
		{
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_UPDATED, _netStream.time));
		}
		
		protected function _resizePlayer():void
		{
			if (_debugMode) traceDebug ("_resizePlayer>> _playerScaleMode:" + _playerScaleMode);
			switch (_playerScaleMode) 
			{
				case PlayerScaleMode.NO_RESIZE:
					_screen.width = _playerNativeWidth;
					_screen.height = _playerNativeHeight;
					break;
				case PlayerScaleMode.FIT_VIDEO:
					if (_video != null)
					{
						_screen.width = _videoMask.width;
						_screen.height = _videoMask.height;
					}
					break;
				case PlayerScaleMode.FULL_SIZE:
					if (stage == null) 
					{
						_throwError(1);
						return;
					}
					else
					{
						_screen.width = stage.stageWidth;
						_screen.height = stage.stageHeight - playerSpaceforControls;
					}
					break;
				case PlayerScaleMode.CUSTOM_SIZE:
					_screen.width = _playerWidth;
					_screen.height = _playerHeight;
					break;
				default:
					break;
			}
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.PLAYER_RESIZED));
		}
		
		protected function _resizeScreenTo(__width:Number, __height:Number):void 
		{
			if (_debugMode) traceDebug ("_resizeScreenTo>> _playerScaleMode:" + _playerScaleMode + " __width :" + __width + " __height:" +__height);
			
			if (_video != null)
			{
				_video.width = __width;
				_video.height = __height;
			}
			
			switch (_playerScaleMode) 
			{
				case PlayerScaleMode.NO_RESIZE:
					if (_video != null)
					{
						_video.x = (_playerNativeWidth - __width) / 2;
						_video.y = (_playerNativeHeight - __height) / 2;
					}
					_videoMask.width = _playerNativeWidth;
					_videoMask.height = _playerNativeHeight;
					_videoMask.x = 0;
					_videoMask.y = 0;
					break;
				case PlayerScaleMode.FIT_VIDEO:
					if (_video != null)
					{
						if (_video.width < _playerNativeWidth) _video.x = (_playerNativeWidth - __width) / 2;
						else _video.x = 0;
						_video.y = 0;
					}
					_videoMask.width = Math.max(__width, _playerNativeWidth);
					_videoMask.height = __height;
					_videoMask.x = 0;
					_videoMask.y = 0;
					break;
				case PlayerScaleMode.FULL_SIZE:
					if (stage == null) 
					{
						_throwError(1);
						return;
					}
				case PlayerScaleMode.CUSTOM_SIZE:
					if (_video != null)
					{
						_video.x = (_screen.width - __width) / 2;
						_video.y = (_screen.height - __height) / 2;
					}
					_videoMask.width = Math.min(__width, _screen.width);
					_videoMask.height = Math.min(__height, _screen.height);
					if (_video != null)
					{
						if (_video.x < 0) _videoMask.x = 0;
						else _videoMask.x = _video.x;
						if (_video.y < 0) _videoMask.y = 0;
						else _videoMask.y = _video.y;
					}
					break;
				default:
					break;
			}
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_RESIZED));
		}
		
		// start playing a video
		protected function _loadVideo(__video:String):void
		{
			if (_debugMode) traceDebug ("_loadVideo> __video:" + __video);
			_metaDataReceived = false;
			_videoMetaData = null;
			if (_isBuffering) _stopBuffering(false);
			_isLoaded = false;
			_startLoadingVideo = true;
			_useCustomBuffer = USE_CUSTOM_BUFFER;
			_startLoadedTime = getTimer();
			if (_controls != null)
			{
				_controls.status = "Loading";
				if (_controls.hasProgressBar()) _controls.progressBar.reset();
			}
			//the video has not to be updated anymore
			this.removeEventListener(Event.ENTER_FRAME, _onVideoUpdated);
			this.addEventListener(Event.ENTER_FRAME, _onCheckLoading);
			// connect the object that recevives the metadata
			_netStream.client = _netStreamClientForMetaData;
			//load the video
			_netStream.play(__video);
			_hideBigPlayButton();
			
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_START_LOADING));
		}
		
		protected function _showImage(__imagePath:String):void
		{
			if (_debugMode) traceDebug ("_showImage>> " + __imagePath);
			_screen.buttonMode = true;
			_screen.useHandCursor = true;
			_screen.addEventListener(MouseEvent.CLICK, _startPlayBack);
			// ::
			_showBigPlayButton();
			
			if (__imagePath != null && __imagePath.length > 0)
			{
				_imageisLoaded = false;
				_imageLoader = new Loader();
				_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageLoaded);
				_imageLoader.load(new URLRequest(__imagePath));
			}
		}
		
		protected function _resizeImage():void
		{
			if (_debugMode) traceDebug ("_resizeImage>> " + _imageLoader);
			if (_imageisLoaded)
			{
				// fit on width
				if ((_imageLoader.width / _imageLoader.height) > (_playerWidth / _playerHeight))
				{
					_imageLoader.height = _imageLoader.height * (_playerWidth / _imageLoader.width);
					_imageLoader.width = _playerWidth;
					_imageLoader.x = 0;
					_imageLoader.y = (_playerHeight - _imageLoader.height) / 2;
					//traceDebug (_imageLoader.width + " x " + _imageLoader.height + " : " + (_imageLoader.width / _imageLoader.height));
				}
				else
				{
					_imageLoader.width = _imageLoader.width * (_playerHeight / _imageLoader.height);
					_imageLoader.height = _playerHeight;
					_imageLoader.x = (_playerWidth - _imageLoader.width) / 2;
					_imageLoader.y = 0;
				}
			}
		}
		
		protected function _onImageLoaded(__event:Event):void
		{
			_imageisLoaded = true;
			_imageLoader.mouseEnabled = false;
			addChild(_imageLoader);
			_resizeImage();
			if (_controls != null) addChild(_controls);
			// ::
			_showBigPlayButton();
		}
		
		protected function _checkMetadataReceived(__event:Event):void
		{
			if (_debugMode) traceDebug ("_checkMetadataReceived ?? >> ");
			if (_metaDataReceived)
			{
				_dispatchStartEvent = true;
				this.removeEventListener(Event.ENTER_FRAME, _checkMetadataReceived);
				this.addEventListener(Event.ENTER_FRAME, _onVideoUpdated);
				if (_debugMode) traceDebug ("_checkMetadataReceived !! >>" + _loopPlaylist + ":" + _isPaused + "=>" + _metaDataReceived);
				
				// :NOTE: sound is restored
				_videoVolume = _savedVideoVolume;
				_setVolume(_videoVolume);
				_video.visible = true;
				_video.clear();
				if (_isPaused) pause(0);
				else
				{
					pause(0);
					play(0, false);
				}
			}
		}
		
		protected function _onCheckLoading(__event:Event):void
		{
			if (_debugMode) traceDebug ("_onCheckLoading>> _netStream.bytesLoaded:" + _netStream.bytesLoaded + " _netStream.bytesTotal:" + _netStream.bytesTotal);
			var percentLoaded:Number;
			if (_netStream.bytesTotal > 1000) percentLoaded = (_netStream.bytesLoaded / _netStream.bytesTotal);
			else percentLoaded = 0;
			if (percentLoaded == 1) 
			{
				_isLoaded = true;
				_bufferingcheckTimer.reset();
				if (_isBuffering) _stopBuffering();
				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_LOADED));
				this.removeEventListener(Event.ENTER_FRAME, _onCheckLoading);
			}
		}
		
		protected function _onCheckBuffer(__event:TimerEvent = null):void
		{
			if (_debugMode) traceDebug ("_onCheckBuffer>> _useCustomBuffer:" + _useCustomBuffer + " _isBuffering:" + _isBuffering + " _isPlaying:" + _isPlaying + " _hasEnoughBufferToPlay:" + _hasEnoughBufferToPlay(true));
			// check the buffer with the custom buffer
			if (_useCustomBuffer)
			{
				if (!_hasEnoughBufferToPlay() && !_isBuffering && _isPlaying) _startBuffering();
				else if (_hasEnoughBufferToPlay() && _isBuffering)
				{
					_stopBuffering();
					// when the movie starts with the custom buffer in theory it doesn't have to check it anymore. the default buffer is then used instead
					_useCustomBuffer = false;
					_netStream.bufferTime = DEFAULT_BUFFER;
				}
			}
			// check the buffer with the default buffer
			else if (_isBuffering)
			{
				if (_netStream.bufferLength >= _netStream.bufferTime && _isBuffering) _stopBuffering();
			}
		}
		
		protected function _startBuffering():void
		{
			_isBuffering = true;
			if (_controls != null) _controls.status = "Buffering";
			_hideBigPlayButton();
			
			if (_buffering != null)
			{
				_buffering.x = _playerWidth / 2;
				_buffering.y = _playerHeight / 2;
				_buffering.gotoAndPlay(1);
				_buffering.visible = true;
				addChild(_buffering);
			}
			
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_START_BUFFERING));
			if (_debugMode) traceDebug ("VIDEO_START_BUFFERING>> CustomBuffer:" + _useCustomBuffer);
			if (_useCustomBuffer) pause();			
		}
		
		protected function _stopBuffering(__forcePlay:Boolean = true):void
		{
			_isBuffering = false;
			if (_buffering != null)
			{
				_buffering.gotoAndStop(1);
				_buffering.visible = false;
			}
			
			dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_END_BUFFERING));
			if (_debugMode) traceDebug ("VIDEO_END_BUFFERING>> forcePlay:" + __forcePlay);
			if (__forcePlay) play();
		}
		
		protected function _hasEnoughBufferToPlay(__trace:Boolean = false):Boolean
		{
			var elapsedSeconds:Number = (getTimer() - _startLoadedTime) / 1000;
			var estimatedSecondsLeft:Number = ((_netStream.bytesTotal - _netStream.bytesLoaded) * (elapsedSeconds / _netStream.bytesLoaded));
			// already in cache
			if (__trace) traceDebug ("_hasEnoughBufferToPlay>> elapsedSeconds:" + elapsedSeconds + " estimatedSecondsLeft:" + estimatedSecondsLeft + " _netStream.bytesLoaded:" + _netStream.bytesLoaded + " _netStream.bytesTotal:" + _netStream.bytesTotal);
			if (estimatedSecondsLeft == 0 && _netStream.bytesLoaded > 1000) return true
			// delay of seconds before bandwith is checked
			else if (elapsedSeconds >= DETECT_BANDWITH_DELAY)
			{
				// has enough buffer to play the video without interruption
				// :NOTES: a 10% of buffer is added to the estimatedSecondsLeft to be safe
				if (_metaDataReceived)
				{
					if ((estimatedSecondsLeft * 1.1) <= (_videoMetaData["duration"] - _netStream.time))  return true;
					else return false;
				}
				else return false;
			}
			else return false;
		}
		
		protected function _onInitializable(__event:Event):void
		{
			removeEventListener("frameConstructed", _onInitializable);
			_isInitializable = true;
			dispatchEvent( new VideoPlayerEvent(VideoPlayerEvent.ON_INITIALIZABLE));
		}
		
		protected function _throwError(__index:int, __description:* = null)
		{
			var description:*;
			if (__description != null) description = __description.toString();
			else description = new String();
			
			switch (__index)
			{
				case -1:
					traceDebug ("VideoPlayer Error > video player is not initialized. wait for event VideoPlayerEvent.ON_INITIALIZED");
					break;
				case 0:
					traceDebug ("VideoPlayer Error > playlist is empty");
					break;
				case 1:
					traceDebug ("VideoPlayer Error > instance has to be on stage in order to use the stage property ");
					break;
				case 2:
					traceDebug("VideoPlayer Error @ setPlaylist > valid parameters are a single String or an array of Strings ");
					break;
				case 3:
					traceDebug ("VideoPlayer Error @ set videoScaleMode > invalid parameters ");
					break;
				case 4:
					traceDebug ("VideoPlayer Error @ set playerScaleMode > invalid parameters ");
					break;
				case 5:
					traceDebug ("VideoPlayer Error @ loadVideoIndex > no video at this index");
					break;
				case 6:
					traceDebug ("VideoPlayer Error @ loadVideoIndex > invalid videoIndex");
					break;
				case 7:
					traceDebug ("VideoPlayer Error @ loadVideoIndex > no video in the playlist. use setPlaylist first");
					break;
				case 8:
					traceDebug("VideoPlayer Error @ _netStatusHandler > Unable to locate video: " + description);
					break;
				case 9:
					traceDebug("VideoPlayer Error @ _securityErrorHandler > " + description);
					break;
				case 10:
					traceDebug("VideoPlayer Error @ _asyncErrorHandler > " + description);
					break
				case 11:
					traceDebug("VideoPlayer Error @ _ioErrorHandler > " + description);
					break
				case 12:
					traceDebug("VideoPlayer Error > metadata are not defined yet. use ON_METADATA_RECEIVED event");
					break
				case 13:
					traceDebug("VideoPlayer Error @ setPlaylist > parameters video(s) and image(s) must be the same type");
					break
				case 13:
					traceDebug("VideoPlayer Error @ setPlaylist > parameters video(s) and image(s) must contains the same number of items");
					break
				default:
					traceDebug ("VideoPlayer Error > undefined " + description);
					break;
			}
		}
	}
}