package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
		
	import com.zeroun.components.scrollbar.Scrollbar;
	import com.zeroun.components.loadinganimation.LoadingAnimationRoundStyle;
	import com.zeroun.components.debugwindow.DebugWindow;
	import com.zeroun.components.dropdown.DropdownEvent;
	import com.zeroun.components.menu.*;
	
	
	public class ComponentsSamples extends MovieClip
	{
		
		/************************************************************
		 * Constants
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		public var mcScroll1			:CustomScrollbar2;
		public var tfSample1			:TextField;
		public var tfSample2			:TextField;
		
		public var mcMask				:MovieClip;
		public var mcAsset				:MovieClip;
		
		public var mcMask2				:MovieClip;
		public var mcAsset2				:MovieClip;
		
		public var mcDropdown1			:CustomDropdown1;
		public var mcDropdown2			:CustomDropdown1;
		
		private var _scroll2			:CustomScrollbar1;
		private var _scroll3			:CustomScrollbar2;
		private var _scroll4			:CustomScrollbar1;
		private var _scroll5			:CustomScrollbarH1;
		
		private var _dropdown3			:CustomDropdown1;
		private var _dropdown4			:CustomDropdown2;
		
		private var _menu				:PagesMenu;
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function ComponentsSamples()
		{
			// DEBUG WINDOW
			new DebugWindow(this);
			
			// SCROLLBAR
			tfSample1.text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Curabitur nibh. Quisque viverra. Mauris ornare, justo ac viverra varius, mi neque sagittis pede, vel accumsan justo neque in ipsum. Nulla cursus ligula. Quisque nec sem. Mauris facilisis lorem ut odio faucibus gravida. Pellentesque ultricies magna in ante. Aenean velit. Aenean ante. Integer et neque eu mauris varius convallis. "
			tfSample2.text = tfSample1.text;
			
			mcScroll1.initializeForTextField(tfSample1);
			mcScroll1.setProperties(200,60,100);
			
			_scroll2 = new CustomScrollbar1();
			_scroll2.addEventListener(Scrollbar.ON_INITIALIZED, _onScroll1Initialized);
			_scroll2.initializeForTextField(tfSample2);
			addChild(_scroll2);
			
			_scroll3 = new CustomScrollbar2();
			_scroll3.initializeForDisplayObject(mcAsset, mcMask);
			addChild(_scroll3);
			
			mcAsset2.buttonMode = true;
			
			_scroll4 = new CustomScrollbar1();
			_scroll4.initializeForDisplayObject(mcAsset2, mcMask2);
			addChild(_scroll4);
			
			_scroll5 = new CustomScrollbarH1();
			_scroll5.initializeForDisplayObject(mcAsset2, mcMask2);
			addChild(_scroll5);
			
			// DROPDOWN
			var items:Array = [
				{ id:"/", 			label:"zero" },
				{ id:"/un/",		label:"un" },
				{ id:"/deux/",		label:"deux" },
				{ id:"/trois/",		label:"trois" },
				{ id:"/quatre/",	label:"quatre" }
			];
			
			mcDropdown1.initialize(items);
			mcDropdown1.label = "please";
			mcDropdown1.selectedIndex = 1;
			//mcDropdown1.enable = false;
			
			mcDropdown1.addEventListener (DropdownEvent.ON_CLICK_ITEM, _onDropDownEvent);
			mcDropdown1.addEventListener (DropdownEvent.ON_CLOSE, _onDropDownEvent);
			mcDropdown1.addEventListener (DropdownEvent.ON_OPEN, _onDropDownEvent);
			mcDropdown1.addEventListener (DropdownEvent.ON_OVER_ITEM, _onDropDownEvent);
			mcDropdown1.addEventListener (DropdownEvent.ON_OUT_ITEM, _onDropDownEvent);
			mcDropdown1.addEventListener (DropdownEvent.ON_TIME_OUT, _onDropDownEvent);
			
			mcDropdown2.initialize(items, 0, -1, "up");
			
			_dropdown3 = new CustomDropdown1();
			_dropdown3.initialize(items, 2, 4);
			_dropdown3.x = 375;
			_dropdown3.y = 250;
			addChild(_dropdown3);
			
			_dropdown4 = new CustomDropdown2();
			_dropdown4.initialize(items, 2, 4);
			_dropdown4.selectable = true;
			_dropdown4.size = 100;
			_dropdown4.x = 555;
			_dropdown4.y = 250;
			addChild(_dropdown4);
			
			// MENU
			var dataXML:XML = new XML("<pages><page id='/section1/' show_in_menu='1'><label>section 1</label></page><page id='/section2/' show_in_menu='1'><label>section 2</label></page><page id='/section2/1/' show_in_menu='1'><label>section 2 - 1</label></page><page id='/section2/2/' show_in_menu='1'><label>section 2 - 2</label></page><page id='/section3/' show_in_menu='1'><label>section 3</label></page><page id='/section3/1/' show_in_menu='1'><label>section 3 - 1</label></page></pages>");
			_menu = new PagesMenu(dataXML.page, PagesMenuItem);
			_menu.x = 10;
			_menu.y = 10;
			_menu.addEventListener(MenuEvent.ON_CLICK_ITEM, _onClickMenuItem);
			addChild(_menu);
		};

		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		//...
		
			
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		private function _onScroll1Initialized(__event:Event):void
		{
			_scroll2.setCursorPosition(1);
			_scroll2.setScrollValue(20);
		}
		
		private function _onDropDownEvent(__event:DropdownEvent):void
		{
			traceDebug ("_onDropDownEvent >" + __event.type + " : id> " + __event.id + " index>" + __event.index);
		}
		
		private function _onClickMenuItem(__event:MenuEvent):void
		{
			traceDebug ("_onClickMenu >" + __event.type + " : itemId> " + __event.itemId);
			_menu.select(__event.itemId);
		}
	}
}