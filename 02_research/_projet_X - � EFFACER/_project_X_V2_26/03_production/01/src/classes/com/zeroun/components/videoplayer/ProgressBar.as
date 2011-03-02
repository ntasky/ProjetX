package com.zeroun.components.videoplayer
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import com.zeroun.utils.Numbers;
	
	
	public class ProgressBar extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _videoPlayer			:VideoPlayer;
		private var _isDragging				:Boolean = false;
		private var _playPending			:Boolean = false;
		private var _cursorType				:int;	// 1: cursor is middle centered
													// 2: cursor is left centered
		
		private var _cursor					:MovieClip;
		private var _hitArea				:MovieClip;
		private var _background				:MovieClip;
		private var _toBeLoaded				:MovieClip;
		private var _loaded					:MovieClip;
		private var _played					:MovieClip;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function ProgressBar()
		{
			if (getChildByName("mcCursorType1") != null && getChildByName("mcCursorType2") != null)
			{
				_throwError(0);
			}
			else if (getChildByName("mcCursorType1") != null)
			{
				_cursor = this["mcCursorType1"];
				_cursorType = 1;
			}
			else if (getChildByName("mcCursorType2") != null)
			{
				_cursor = this["mcCursorType2"];
				_cursorType = 2;
			}
			else
			{
				_throwError(1);
				return;
			}
			
			if (_cursor == null) _cursor = new MovieClip();
			_cursor.buttonMode = true;
			_cursor.useHandCursor = true;
			_cursor.stop();
			_cursor.visible = false;
			_cursor.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownCursor);
			
			if (getChildByName("mcHitArea") != null)
			{
				_hitArea = this["mcHitArea"];
				_hitArea.buttonMode = true;
				_hitArea.useHandCursor = true;
				_hitArea.visible = false;
				_hitArea.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownProgressBar);
			}
			
			if (getChildByName("mcToBeLoaded") != null)
			{
				_toBeLoaded = this["mcToBeLoaded"];
				_toBeLoaded.visible = false;
			}
			
			if (getChildByName("mcLoaded") != null)
			{
				_loaded = this["mcLoaded"];
				_loaded.visible = false;
			}
			
			if (getChildByName("mcPlayed") != null)
			{
				_played = this["mcPlayed"];
				_played.visible = false;
			}
			
			if (getChildByName("mcBackground") != null)
			{
				_background = this["mcBackground"];
			}
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function initialize(__videoPlayer:VideoPlayer):void
		{
			_videoPlayer = __videoPlayer;
			reset(false);
		}
		
		public function update():void
		{
			if (!_isDragging)
			{
				var cursorPosition:int;
				switch (_cursorType)
				{
					case 1:
						cursorPosition = Math.min(Numbers.getRelative(0, _background.width, 0, _videoPlayer.videoDuration, _videoPlayer.netStream.time), _background.width);
						break;
					case 2:
						cursorPosition = Math.min(Numbers.getRelative(0, _background.width - _cursor.width, 0, _videoPlayer.videoDuration, _videoPlayer.netStream.time), _background.width - _cursor.width);
						break;
				}
				_cursor.x = cursorPosition;
			}
			
			var percentLoaded:Number = _videoPlayer.netStream.bytesTotal > 1000 ? (_videoPlayer.netStream.bytesLoaded / _videoPlayer.netStream.bytesTotal) : 0;
			
			if (percentLoaded == 1) dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.VIDEO_LOADED));
			
			_updateVisualElements(Numbers.getRelative(0, _background.width, 0, 1, percentLoaded));
		}
		
		public function reset(__showCursor:Boolean = true):void
		{
			_cursor.x = 0;
			_cursor.visible = __showCursor;
			_hitArea.visible = true;
			_toBeLoaded.visible = true;
			_loaded.visible = true;
			_played.visible = true;
			
			_updateVisualElements();
		}
		
		public function resizeTo(__width:int):void
		{
			_background.width = __width;
			_updateVisualElements();
		}
		
		public function get isDragging():Boolean
		{
			return _isDragging;
		}
		
		public function get cursorPosition():int
		{
			return _cursor.x;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _updateVisualElements(__loadedWidth:Number = 0):void
		{
			_loaded.width = __loadedWidth;
			_hitArea.width = _loaded.width;
			_toBeLoaded.width = _background.width - _loaded.width;
			_toBeLoaded.x = _loaded.width;
			_played.width = _cursor.x;
		}
		
		private function _onMouseDownCursor(__event:MouseEvent):void
		{
			_startDragging();
		}
		
		private function _onMouseDownProgressBar(__event:MouseEvent):void
		{
			_cursor.x = __event.target.mouseX * __event.target.scaleX;
			_updateTargetPosition(null);
			_startDragging();
		}
		
		private function _startDragging():void
		{
			if (_videoPlayer.isPlaying)
			{
				_playPending = true;
				_videoPlayer.pause();
			}
			
			_isDragging = true;
			switch (_cursorType)
			{
				case 1:
					_cursor.startDrag(false, new Rectangle(0, _cursor.y, _loaded.width));
					break;
				case 2:
					_cursor.startDrag(false, new Rectangle(0, _cursor.y, _loaded.width - _cursor.width));
					break;
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _stopDragging);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _updateTargetPosition);
		}
		
		private function _stopDragging(__event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDragging);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _updateTargetPosition);
			
			_cursor.stopDrag();
			_isDragging = false;
			
			if (_playPending)
			{
				_playPending = false;
				_videoPlayer.play();
			}
		}
		
		private function _updateTargetPosition(__event:MouseEvent):void
		{
			if (_videoPlayer.netConnectionIsOpen)
			{
				var position:Number;
				switch (_cursorType)
				{
					case 1:
						position = Numbers.getRelative(0, _videoPlayer.videoDuration, 0, _background.width, _cursor.x)
						break;
					case 2:
						position = Numbers.getRelative(0, _videoPlayer.videoDuration, 0, _background.width - _cursor.width, _cursor.x)
						break;
				}
				
				_videoPlayer.seek(Math.floor(position));
			}
		}
		
		private function _throwError(__index:int, __description:* = null)
		{
			var description:*;
			description = __description != null ? __description.toString() : new String();
			
			switch (__index)
			{
				case 0:
					traceDebug ("ProgressBar Error @ constructor > there must be only one instance called mcCursorType1 or mcCursorType2 ");
					break;
				case 1:
					traceDebug ("ProgressBar Error @ constructor > there must be one instance called mcCursorType1 or mcCursorType2 ");
					break;
				default:
					traceDebug ("Playlist Error: undefined " + description);
					break;
			}
		}
	}
}