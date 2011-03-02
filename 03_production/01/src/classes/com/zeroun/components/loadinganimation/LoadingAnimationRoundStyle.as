package com.zeroun.components.loadinganimation
{
	import flash.display.*;
	import flash.events.*;
	
	import com.zeroun.utils.Numbers;
	
	
	public class LoadingAnimationRoundStyle extends Sprite
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		private const MAX_ELEMENTS			:Number = 8;
		private const MAX_VISIBLE_ELEMENTS	:Number = 8;
		private const RADIUS				:Number = 7;
		private const SPEED					:Number = 3;
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		private var _maxElements			:Number;
		private var _maxVisibleElements		:Number;
		private var _radius					:Number;
		private var _speed					:Number;
		private var _index					:Number = 0;
		private var _counter				:Number = 0;
		private var _items					:Array = new Array();


		/************************************************************
		 * Constructor
		 ************************************************************/
		
		public function LoadingAnimationRoundStyle(	__elementClass:Class,
													__maxElements:Number = MAX_ELEMENTS,
													__maxVisibleElements:Number = MAX_VISIBLE_ELEMENTS,
													__radius:Number = RADIUS,
													__speed:Number = SPEED)
		{
			_maxElements = __maxElements;
			_maxVisibleElements = __maxVisibleElements;
			_radius = __radius;
			_speed = __speed;
			
			var item:DisplayObject;
			var angle:Number;
			
			for (var i:int = 0 ; i < _maxElements ; i++)
			{
				item = new __elementClass();
				angle = i * 360 / _maxElements;
				item.x = _radius * Math.cos(Numbers.degreeToRadian(angle));
				item.y = _radius * Math.sin(Numbers.degreeToRadian(angle));
				item.rotation = angle + 90;
				item.alpha = 1;
				_items.push(item);
				addChild(item);
			}
		}


		/************************************************************
		 * Public methods
		 ************************************************************/
		
		public function start() :void
		{
			this.addEventListener(Event.ENTER_FRAME, _animate); 
		}
		 
		public function stop() :void
		{
			if (this.hasEventListener(Event.ENTER_FRAME))
			{
				this.removeEventListener(Event.ENTER_FRAME, _animate); 
			}
		}


		/************************************************************
		 * Private methods
		 ************************************************************/

		private function _animate(__evt:Event): void
		{
			_counter++;
			if (_counter % _speed == 0)
			{
				_counter = 0;
				for (var i:int = 0 ; i < _maxVisibleElements ; i++)
				{
					_items[(i + _index) % _maxElements].alpha = (i / _maxVisibleElements);
				}
				_index = (_index + 1) % _maxElements;
			}
		}
		
	}
}