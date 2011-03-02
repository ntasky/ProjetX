package com.zeroun.components.customloader
{
	import flash.errors.IllegalOperationError;
	import flash.display.Loader;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.media.Sound;
	
	
	public class CustomLoader
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const XML_LOADED				:String = "xml_loaded";
		public static const ASSETS_LOADED			:String = "assets_loaded";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private static var _XMLLoader					:URLLoader = new URLLoader();
		private static var _displayAssetLoader			:Loader = new Loader();
		private static var _audioAssetLoader			:Sound = new Sound();
		private static var _assetsToLoad				:Array = new Array();
		private static var _savedAssetsToLoad			:String;
		private static var _totalAssetsToLoad			:int;
		private static var _XMLFiles					:Array = new Array();
		private static var _assetsFiles					:Array = new Array();
		private static var _dispatcher					:EventDispatcher = new EventDispatcher();
		private static var _timeStartLoading			:int;
		private static var _timeLastAssetLoaded			:int;
		private static var _bytesLoaded					:int;
		private static var _XMLLoaderIsLoading			:Boolean = false;
		private static var _displayAssetLoaderIsLoading	:Boolean = false;
		private static var _audioAssetLoaderIsLoading	:Boolean = false;
		private static var _isLoading					:Boolean = false;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function CustomLoader()
		{
			throw new IllegalOperationError("Loader cannot be instantiated.");
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public static function getXML(__path:String):XML
		{
			return _XMLFiles[__path];
		}
		
		public static function getAsset(__path:String):*
		{
			return _assetsFiles[__path];
		}
		
		public static function getIsLoading():Boolean
		{
			return (_XMLLoaderIsLoading || _displayAssetLoaderIsLoading || _audioAssetLoaderIsLoading);
		}
		
		// :TODO: check that it works
		// returns the download speed in bytes/s, based on the assets that have been fully up to this point
		public static function getDownloadSpeed():Number
		{
			var t:Number = (_timeLastAssetLoaded - _timeStartLoading) / 1000;
			return (t == 0) ? -1 : _bytesLoaded / t;
		}
		
		public static function addXMLFilesToLoad(__files:*, __queued:Boolean = true):void
		{
			if (_XMLLoaderIsLoading)
			{
				stopAllLoadings();
				
				var i:int;
				var currentFiles:Array = _assetsToLoad;
				
				var files:Array = new Array();
				if (typeof(__files) == "string")
				{
					files.push(__files);
				}
				// list of videos
				else if (typeof(__files) == "object")
				{
					files = __files;
				}
				
				if (__queued)
				{
					for (i = 0; i < files.length; i++ )
					{
						currentFiles.push(files[i]);
					}
				}
				else
				{
					for (i = 0; i < files.length; i++)
					{
						currentFiles.splice(0,0, files[i]);
					}
				}
				
				loadXMLFiles(currentFiles, false);
			}
			else
			{
				loadXMLFiles(__files);
			}
		}
		
		public static function loadXMLFiles(__files:*, __stopAllLoadings:Boolean = true ):void
		{
			if (__stopAllLoadings)
			{
				stopAllLoadings();
			}
			
			var files:Array = new Array();
			if (typeof(__files) == "string")
			{
				files.push(__files);
			}
			// list of videos
			else if (typeof(__files) == "object")
			{
				files = __files;
			}
			
			_assetsToLoad = files;
			_savedAssetsToLoad = files.toString();
			_totalAssetsToLoad = _assetsToLoad.length;
			
			_XMLLoader.addEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
			_XMLLoader.addEventListener(Event.COMPLETE, _onXMLComplete);
			_XMLLoader.addEventListener(IOErrorEvent.IO_ERROR , _onXMLIOError);
			
			_XMLLoaderIsLoading = true;
			_loadNextXMLFile();
		}
		
		public static function addAssetsFilesToLoad(__files:Array, __queued:Boolean = true):void
		{
			if (__files.length == 0) { return; }

			if (_displayAssetLoaderIsLoading)
			{
				stopAllLoadings();
				
				var i:int;
				var currentFiles:Array = _assetsToLoad;
				
				if (__queued)
				{
					for (i = 0; i < __files.length; i++)
					{
						currentFiles.push(__files[i]);
					}
				}
				else
				{
					for (i = 0; i < __files.length; i++)
					{
						currentFiles.splice(0, 0, __files[i]);
					}
				}
				
				loadAssetsFiles(currentFiles, false);
			}
			else
			{
				loadAssetsFiles(__files);
			}
		}
		
		public static function loadAssetsFiles(__files:Array, __stopAllLoadings:Boolean = true ):void
		{
			if (__stopAllLoadings)
			{
				stopAllLoadings();
			}
			
			_assetsToLoad = __files;
			_savedAssetsToLoad = __files.toString();
			_totalAssetsToLoad = _assetsToLoad.length;
			
			_displayAssetLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
			_displayAssetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onAssetComplete);
			_displayAssetLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR , _onIOError);
			
			_displayAssetLoaderIsLoading = true;
			_loadNextAssetFile();
		}
		
		public static function getLoadingQueue():Array
		{
			return _savedAssetsToLoad.split(",");
		}
		
		public static function addEventListener(__type:String, __listener:Function, __useCapture:Boolean = false, __priority:int = 0, 
            __useWeakReference:Boolean = false):void
		{
            _dispatcher.addEventListener(__type, __listener, __useCapture, __priority, __useWeakReference);
        }

        public static function removeEventListener(__type:String, __listener:Function):void
		{
            _dispatcher.removeEventListener(__type, __listener, false);
        }
		
		public static function dispatchEvent(__event:Event):Boolean
		{
            return _dispatcher.dispatchEvent(__event);
        }

        public static function hasEventListener(__type:String):Boolean
		{
            return _dispatcher.hasEventListener(__type);
        }
		
		public static function stopAllLoadings():void
		{
			if (_displayAssetLoaderIsLoading)
			{
				try { _displayAssetLoader.close(); } catch(__error:Error) { };
				try { _displayAssetLoader.unload(); } catch(__error:Error) { };
				_displayAssetLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onAssetComplete);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR , _onIOError);
				_displayAssetLoader = null;
				_displayAssetLoader	= new Loader();
				_displayAssetLoaderIsLoading = false;
			}
			
			if (_XMLLoaderIsLoading)
			{
				try { _XMLLoader.close(); } catch(__error:Error) { };
				_XMLLoader.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
				_XMLLoader.removeEventListener(Event.COMPLETE, _onXMLComplete);
				_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR , _onXMLIOError);
				_XMLLoader	= null;
				_XMLLoader	= new URLLoader();
				_XMLLoaderIsLoading = false;
			}
			
			if (_audioAssetLoaderIsLoading)
			{
				try { _audioAssetLoader.close(); } catch(__error:Error) { };
				_audioAssetLoader.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
				_audioAssetLoader.removeEventListener(Event.COMPLETE, _onAssetComplete);
				_audioAssetLoader = null;
				_audioAssetLoader = new Sound();
				_audioAssetLoaderIsLoading = false;
			}
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private static function _loadNextXMLFile():void
		{
			if (_assetsToLoad.length > 0)
			{
				_XMLLoader.load(new URLRequest(_assetsToLoad[0]));
				dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.START, _assetsToLoad[0]));
			}
			else
			{
				// all XML have been loaded
				_XMLLoader.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
				_XMLLoader.removeEventListener(Event.COMPLETE, _onXMLComplete);
				_XMLLoader.removeEventListener(IOErrorEvent.IO_ERROR , _onXMLIOError);
				_XMLLoaderIsLoading = false;
				dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.COMPLETE, _savedAssetsToLoad.toString()));
			}
		}
		
		private static function _onLoadingProgress(event:ProgressEvent):void
		{
			var n:Number;
			
			if (getLoadingQueue().length == 1)
			{
				n = 100 * event.bytesLoaded / event.bytesTotal;
			}
			else
			{
				n = 100 * (_totalAssetsToLoad - _assetsToLoad.length + event.bytesLoaded / event.bytesTotal ) / _totalAssetsToLoad;
			}
			dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.PROGRESS, _assetsToLoad[0], Math.floor(n)));
		}
		
		private static function _onXMLComplete(event:Event):void
		{
			// update download statistics
			_bytesLoaded += _XMLLoader.bytesLoaded;
			_timeLastAssetLoaded = getTimer();

			// store loaded XML into _xmlFiles
			var file_path:String = _assetsToLoad.shift();
			_XMLFiles[file_path] = new XML(event.target.data);
			dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.LOADED, file_path));
			
			// move on to the next file
			_loadNextXMLFile();
		}
		
		private static function _loadNextAssetFile():void
		{
			if (_assetsToLoad.length > 0)
			{
				var file_path:String = _assetsToLoad[0];
				if (file_path.substr(0, 6) == "event:")
				{
					dispatchEvent(new CustomLoaderEvent(CustomLoaderEvent.CUSTOM_EVENT, "", -1, file_path.substring(6)));
					_onAssetComplete();
				}
				else
				{
					if (_isSoundFile(file_path))
					{
						// because the sound object and the loaded sound cannot be separated (as opposed to the Loader class
						// where the loaded object is in the 'content' propery of the class), we must reset _audioAssetLoader
						// each time we use it
						_audioAssetLoader = new Sound();
						_audioAssetLoader.addEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
						_audioAssetLoader.addEventListener(Event.COMPLETE, _onAssetComplete);
						_audioAssetLoader.load(new URLRequest(file_path));
						_audioAssetLoaderIsLoading = true;
					}
					else
					{
						_displayAssetLoader.load(new URLRequest(file_path));
					}
				}
			}
			else
			{
				// all assets have been loaded
				_displayAssetLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onAssetComplete);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR , _onIOError);
				_displayAssetLoaderIsLoading = false;
				dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.COMPLETE, _savedAssetsToLoad.toString()));
			}
		}
		
		private static function _onAssetComplete(event:Event = null):void
		{
			// update download statistics
			if (event != null)
			{
				_bytesLoaded += event.target.bytesLoaded;
				_timeLastAssetLoaded = getTimer();
			}
			
			// store loaded asset into _assetsFiles
			var file_path:String = _assetsToLoad.shift();
			if (file_path.substr(0, 6) != "event:")
			{
				if (_isSoundFile(file_path))
				{
					_audioAssetLoader.removeEventListener(ProgressEvent.PROGRESS, _onLoadingProgress);
					_audioAssetLoader.removeEventListener(Event.COMPLETE, _onAssetComplete);
					_assetsFiles[file_path] = _audioAssetLoader;
					_audioAssetLoaderIsLoading = false;
				}
				else
				{
					_assetsFiles[file_path] = _displayAssetLoader.content;
					if (_isSWFFile(file_path))
					{
						_assetsFiles[file_path].gotoAndStop(1);
					}
					// :TRICKY: we *must* unload, otherwise using addChild with the last asset loaded before the next asset is loaded will trigger error #2025
					_displayAssetLoader.unload();
				}
				dispatchEvent (new CustomLoaderEvent(CustomLoaderEvent.LOADED, file_path));
			}
			
			// move on to the next file
			_loadNextAssetFile();
		}
		
		private static function _isSoundFile(__filename:String):Boolean
		{
			return (__filename.substr(-4) == ".mp3");
		}
		
		private static function _isSWFFile(__filename:String):Boolean
		{
			return (__filename.substr(-4) == ".swf");
		}
		
		private static function _onIOError(event:IOErrorEvent):void
		{
			// there were an error, but loading has to continue
			traceDebug("CustomLoader._onIOError: " + event.text);
			
			// update download statistics
			_timeLastAssetLoaded = getTimer();
			
			// store loaded asset into _assetsFiles
			var file_path:String = _assetsToLoad.shift();

			// move on to the next file
			_loadNextAssetFile();
		}
		
		private static function _onXMLIOError(event:IOErrorEvent):void
		{
			traceDebug("CustomLoader._onXMLIOError: " + event.text);
		}
		
	}
}