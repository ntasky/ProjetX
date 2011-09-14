package core
{
	import flash.display.*;
	import flash.events.*;
	
	import com.greensock.TweenMax;
	
	import core.events.StageEvent;
	import core.pages.PagesManager;
	import loader.LoaderConfig;
	
	public class LayersManager extends Sprite
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const POPUP_CONTENT_TYPE					:String = "popup_content_type";
		public static const DEFAULT_CONTENT_TYPE				:String = "default_content_type";
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcOpaqueBackground			:MovieClip;	// for opaque background
		 
		private var _contentLayer				:Sprite;
		private var _opaqueLayer				:Sprite;
		private var _popupLayer					:Sprite;
		private var _menuLayer					:Sprite;
		private var _fullscreenLayer			:Sprite;
		private var _cursorLayer				:Sprite;
		
		private var _popupIsOpen				:Boolean;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function LayersManager()
		{	
			alpha = 0;
			visible = false;
			
			_contentLayer = new Sprite();
			addChild(_contentLayer);
			_menuLayer = new Sprite();
			addChild(_menuLayer);
			
			_opaqueLayer = new Sprite();
			addChild(_opaqueLayer);
			_opaqueLayer.visible = false;
			_opaqueLayer.alpha = 0;
			_opaqueLayer.addChild(mcOpaqueBackground);
			
			_popupLayer = new Sprite();
			addChild(_popupLayer);
			
			_fullscreenLayer = new Sprite();
			addChild(_fullscreenLayer);
			
			_cursorLayer = new Sprite();
			_cursorLayer.mouseEnabled = false;
			_cursorLayer.mouseChildren= false;
			addChild(_cursorLayer);
			
			Main.instance.addEventListener(StageEvent.RESIZE, _onResize);
			Main.instance.stage.addEventListener(Event.MOUSE_LEAVE, _onMouseLeave);
		}
		
		
		/************************************************************
		 * getter setter
		 ************************************************************/
		
		public function get fullscreenLayer():Sprite
		{
			return _fullscreenLayer;
		}
		 
		public function get menuLayer():Sprite
		{
			return _menuLayer;
		}
		
		public function get contentLayer():Sprite
		{
			return _contentLayer;
		}
		
		public function get popupLayer():Sprite
		{
			return _popupLayer;
		}
		
		public function get cursorLayer():Sprite
		{
			return _cursorLayer;
		}
		 
		public function get popupIsOpen():Boolean
		{
			return _popupIsOpen;
		}
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function reveal(__width:int = -1 , __height:int = -1):void
		{
			TweenMax.to(this, .5, { autoAlpha:1 } );
		}
		
		public function showOpaqueBackground(__contentType:String = DEFAULT_CONTENT_TYPE):void
		{
			TweenMax.to(_opaqueLayer, .5, { autoAlpha:1 } );
			
			switch(__contentType)
			{
				case POPUP_CONTENT_TYPE:
					_popupIsOpen = true;
					break;
				case DEFAULT_CONTENT_TYPE:
					break;
			}
			center();
		}
		
		public function hideOpaqueBackground(__contentType:String = DEFAULT_CONTENT_TYPE):void
		{
			// don't hide background if passing from a popup to an other
			if ((!_popupIsOpen || (_popupIsOpen && __contentType == POPUP_CONTENT_TYPE)))
			{
				TweenMax.to(_opaqueLayer, .5, { autoAlpha:0 } );
			}

			switch(__contentType)
			{
				case POPUP_CONTENT_TYPE:
					_popupIsOpen = false;
					break;
				case DEFAULT_CONTENT_TYPE:
					break;
			}
		}
		
		public function center():void
		{
			_onResize(null);
		}
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		 
		private function _onResize(__event:StageEvent):void
		{
			var availableWitdh:int;
			var availableHeight:int;
			
			if (__event != null && __event.availableHeight == -1)
			{
				availableHeight = __event.availableHeight;
			}
			else
			{
				availableHeight = stage.stageHeight;
			}
			
			if (__event != null && __event.availableWitdh == -1)
			{
				availableWitdh = __event.availableWitdh;
			}
			else
			{
				availableWitdh = stage.stageWidth;
			}
			
			mcOpaqueBackground.width = availableWitdh;
			mcOpaqueBackground.height = availableHeight;
			
			if (LoaderConfig.STAGE_SCALE_ALIGN == StageAlign.TOP)
			{
				mcOpaqueBackground.x = (Config.SITE_WIDTH -  mcOpaqueBackground.width) / 2;
			}
		}

		private function _onMouseLeave(__event:Event):void
		{
			dispatchEvent(new StageEvent(StageEvent.EXIT));
		}
	}
}