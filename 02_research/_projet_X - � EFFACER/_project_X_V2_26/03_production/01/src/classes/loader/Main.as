package loader
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.media.Sound;
		
	import loader.*;
	import loader.animation.*;

	
	public class Main extends MovieClip implements ILoaderMain
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		// ...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _coreLoader						:Loader;
		private var _xmlLoader						:URLLoader;
		private var _displayAssetLoader				:Loader;
		private var _audioAssetLoader				:Sound;
		private var _filesToLoad					:Array;
		private var _nbFilesLoading					:uint;
		private var _xmlFiles						:Array;
		private var _assetsFiles					:Array;
		private var _flashVars						:Object;
		private var _timeStartLoading				:int;
		private var _timeLastAssetLoaded			:int;
		private var _bytesLoaded					:int;
		private var _core							:ILoadable;
		private var _loadingAnimation				:LoadingAnimation;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function Main()
		{
			// loader has been loaded from core.swf because core.Main has detected that the loader hadn't been loaded
			// (this happens when you double-click on core.swf or publish + test core.fla in the Flash IDE)
			if (stage == null)
			{
				addEventListener(Event.ENTER_FRAME, _initWhenLoaded);
			}
			// loader has been loaded as expected
			// (happens when you double-click on loader.swf, publish + test loader.fla or open the html page)
			else
			{
				_init();
			}
		}
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function showLoadingAnimation():void
		{
			_loadingAnimation.show();
		}
		
		public function hideLoadingAnimation():void
		{
			_loadingAnimation.hide();
		}
		
		public function getXML(__path:String):XML
		{
			return _xmlFiles[__path];
		}
		
		public function getAsset(__path:String):*
		{
			return _assetsFiles[__path];
		}
		
		public function getFlashVar(__var:String):String
		{
			var result:String;
			try
			{
				result =  _flashVars[__var];
			}
			catch(__e:Error)
			{
				traceDebug("loader.Main getFlashVar: variable not found");
				result = "";
			}
			
			return result;
		}
		
		// returns the download speed in bytes/s, based on the assets that have been fully up to this point
		public function getDownloadSpeed():Number
		{
			var t:Number = (_timeLastAssetLoaded - _timeStartLoading) / 1000;
			return (t == 0) ? -1 : _bytesLoaded / t;
		}
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _onResize(__event:Event):void
		{
			if (contains(_loadingAnimation))
			{
				_loadingAnimation.resizeLayout();
			}
			if (_core != null)
			{
				_core.resizeLayout();
			}
		}
		 
		private function _initWhenLoaded(__event:Event):void
		{
			// this function is only used when the loader is loaded through core.swf
			if (loaderInfo.loader.parent != null)
			{
				removeEventListener(Event.ENTER_FRAME, _initWhenLoaded);
				loaderInfo.loader.parent.addChild(this);
				_init();
			}
		}
		
		private function _init():void
		{
			// setup the stage
			stage.scaleMode = Config.STAGE_SCALE_MODE;
			stage.align = Config.STAGE_SCALE_ALIGN;
			stage.addEventListener(Event.RESIZE, _onResize);
			
			// init variables
			_coreLoader = new Loader();
			_xmlLoader = new URLLoader();
			_displayAssetLoader = new Loader();
			_audioAssetLoader = new Sound();
			_filesToLoad = new Array();
			_xmlFiles = new Array();
			_assetsFiles = new Array();
			_flashVars = LoaderInfo(this.root.loaderInfo).parameters;
			
			_loadingAnimation = new LoadingAnimation();
			_loadingAnimation.addEventListener(Event.ADDED_TO_STAGE, _loadingAnimation.resizeLayout);
			
			_loadingAnimation.show();
			addChild(_loadingAnimation);
			
			// start loading main swf file
			_loadCore();
		}
		 
		private function _loadCore():void
		{
			_coreLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onCoreProgress);
			_coreLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onCoreComplete);
			_coreLoader.load(new URLRequest(Config.CORE_SWF_URL));
		}
		
		private function _onCoreProgress(event:ProgressEvent):void
		{
			_loadingAnimation.update(Config.CORE_SWF_PERCENTAGE * event.bytesLoaded / event.bytesTotal);
		}
		
		private function _onCoreComplete(event:Event):void
		{
			// update download statistics
			_bytesLoaded += _coreLoader.contentLoaderInfo.bytesLoaded;
			_timeLastAssetLoaded = getTimer();
			
			_coreLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onCoreProgress);
			_coreLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onCoreComplete);
			
			addChild(_coreLoader);
			swapChildren(_loadingAnimation, _coreLoader);
			
			_core = _coreLoader.content as ILoadable;
			_core.resizeLayout();
			
			_loadXMLFiles();
		}
		
		private function _loadXMLFiles():void
		{
			_filesToLoad = _core.getXMLFilesToLoad();
			_nbFilesLoading = _filesToLoad.length;
			
			_xmlLoader.addEventListener(ProgressEvent.PROGRESS, _onXMLProgress);
			_xmlLoader.addEventListener(Event.COMPLETE, _onXMLComplete);
			_xmlLoader.addEventListener(IOErrorEvent.IO_ERROR , _onIOError);

			_loadNextXMLFile();			
		}
		
		private function _loadNextXMLFile():void
		{
			if (_filesToLoad.length > 0)
			{
				_xmlLoader.load(new URLRequest(_filesToLoad[0]));
			}
			else
			{
				// all XML have been loaded
				_xmlLoader.removeEventListener(ProgressEvent.PROGRESS, _onXMLProgress);
				_xmlLoader.removeEventListener(Event.COMPLETE, _onXMLComplete);
				_xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR , _onIOError);
				_loadAssetsFiles();
			}
		}
		
		private function _onXMLProgress(event:ProgressEvent):void
		{
			var n:Number = (_nbFilesLoading - _filesToLoad.length + event.bytesLoaded / event.bytesTotal) / _nbFilesLoading;
			_loadingAnimation.update(Config.CORE_SWF_PERCENTAGE + Config.CORE_XML_PERCENTAGE * n);
		}
		
		private function _onXMLComplete(event:Event):void
		{
			// update download statistics
			_bytesLoaded += _xmlLoader.bytesLoaded;
			_timeLastAssetLoaded = getTimer();

			// store loaded XML into _xmlFiles
			var file_path:String = _filesToLoad.shift();
			_xmlFiles[file_path] = new XML(event.target.data);
			
			// move on to the next file
			_loadNextXMLFile();
		}
		
		private function _loadAssetsFiles():void
		{
			_core = _coreLoader.content as ILoadable;
			_filesToLoad = _core.getOtherFilesToLoad();
			_nbFilesLoading = _filesToLoad.length;
			
			_displayAssetLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onAssetProgress);
			_displayAssetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onAssetComplete);
			_displayAssetLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR , _onIOError);
			
			_loadNextAssetFile();
		}
		
		private function _loadNextAssetFile():void
		{
			if (_filesToLoad.length > 0)
			{
				var file_path:String = _filesToLoad[0];
				if (file_path.substr(0, 6) == "event:")
				{
					dispatchEvent(new Event(file_path.substr(6)));
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
						_audioAssetLoader.addEventListener(ProgressEvent.PROGRESS, _onAssetProgress);
						_audioAssetLoader.addEventListener(Event.COMPLETE, _onAssetComplete);
						_audioAssetLoader.load(new URLRequest(file_path));
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
				_displayAssetLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onAssetProgress);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onAssetComplete);
				_displayAssetLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR , _onIOError);
				
				// we don't need to call a function or dispatch an event because the core swf is expected to (a) add a "event:complete" at the end of the array returned
				// by getOtherFilesToLoad() and (b) add a listener for this event, in order to be notified that the loading has finished
				_loadingAnimation.hide();

			}
		}
		
		private function _onAssetProgress(event:ProgressEvent):void
		{
			var n:Number = (_nbFilesLoading - _filesToLoad.length + event.bytesLoaded / event.bytesTotal) / _nbFilesLoading;
			_loadingAnimation.update(Config.CORE_SWF_PERCENTAGE + Config.CORE_XML_PERCENTAGE + (100 - Config.CORE_SWF_PERCENTAGE - Config.CORE_XML_PERCENTAGE) * n);
		}
		
		private function _onAssetComplete(event:Event = null):void
		{
			// update download statistics
			if (event != null)
			{
				_bytesLoaded += event.target.bytesLoaded;
				_timeLastAssetLoaded = getTimer();
			}
			
			// store loaded asset into _assetsFiles
			var file_path:String = _filesToLoad.shift();
			if (file_path.substr(0, 6) != "event:")
			{
				if (_isSoundFile(file_path))
				{
					_audioAssetLoader.removeEventListener(ProgressEvent.PROGRESS, _onAssetProgress);
					_audioAssetLoader.removeEventListener(Event.COMPLETE, _onAssetComplete);
					_assetsFiles[file_path] = _audioAssetLoader;
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
			}
			
			// move on to the next file
			_loadNextAssetFile();
		}
		
		private function _isSoundFile(__filename:String):Boolean
		{
			return (__filename.substr(-4) == ".mp3");
		}
		
		private function _isSWFFile(__filename:String):Boolean
		{
			return (__filename.substr(-4) == ".swf");
		}
		
		private function _onIOError(event:IOErrorEvent):void
		{
			traceDebug("loader.Main._onIOError: " + event.text);
		}
		
	}
}