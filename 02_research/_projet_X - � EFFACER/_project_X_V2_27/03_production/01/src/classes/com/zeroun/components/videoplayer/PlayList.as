package com.zeroun.components.videoplayer
{
	
	public class PlayList
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		protected var _items		:Array;		// array of [video, image]
		protected var _index		:int;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function PlayList()
		{
			_items = new Array();
			_index = -1;
		}
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function get items():Array
		{
			return _items;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function getVideoPath(__index:int = -1):String
		{
			var index:int;
			if (__index == -1 && _index > -1) index = _index;
			else if (__index == -1 && _index == -1) index = 0;
			return _items[index][0];
		}
		
		public function getImagePath(__index:int = -1):String
		{
			var index:int;
			if (__index == -1 && _index > -1) index = _index;
			else if (__index == -1 && _index == -1) index = 0;
			return _items[index][1];
		}
		
		public function setToIndex(__index:int = -1):Array
		{
			var index:int;
			if (__index == -1) index = _index;
			else _index = __index;
			return _items[_index];
		}
		
		public function getNextIndex():int
		{
			if (_index < _items.length - 1) return (_index + 1)
			else return -1;
		}
		
		public function getPreviousIndex():int
		{
			if (_index > 0) return (_index - 1);
			else return -1;
		}
		
		public function addItem(__item:Array, __index = -1):void
		{
			if (__index < -1 || __index > _items.length)
			{
				_throwError(2, __index);
				return;
			}
			else if (__index == -1)
			{
				_items.push(__item);
			}
			else
			{
				_items.splice(__index);
			}
		}
		
		public function removeItemAt(__index:int):void
		{
			_items.splice(__index, 0);
		}
		
		public function removeAllItems():void
		{
			_items = null;
			_items = new Array();
		}
		

		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _throwError(__index:int, __description:* = null)
		{
			var description:*;
			if (__description != null)
			{
				description = __description.toString();
			}
			else
			{
				description = new String();
			}
			
			switch (__index)
			{
				case 0:
					traceDebug ("Playlist Error @ addVideos > invalid index " + description);
					break;
				case 1:
					traceDebug ("Playlist Error @ addVideo > invalid index " + description);
					break;
				case 2:
					traceDebug ("Playlist Error @ addImage > invalid index " + description);
					break;
				case 3:
					traceDebug ("Playlist Error @ addImages > invalid index " + description);
					break;
				default:
					traceDebug ("Playlist Error: undefined " + description);
					break;
			}
		}
		
	}
}