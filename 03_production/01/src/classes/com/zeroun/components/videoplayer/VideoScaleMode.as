package com.zeroun.components.videoplayer
{
	public class VideoScaleMode
	{
		/************************************************************
		 * Constants
		 ************************************************************/
		
		public static const NO_RESIZE		: String = "no_resize";			// the video keeps its native size
		public static const ZOOM_X05		: String = "zoom_x05";			// the video is half sized
		public static const ZOOM_X2			: String = "zoom_x2";			// the video size is doubled
		public static const ZOOM_X3			: String = "zoom_x3";			// the video size is tripled
		public static const ZOOM_X4			: String = "zoom_x4";			// the video size is quadrupled
		public static const FIT				: String = "fit";				// the video is resized to the player size (no cropping, streching may occur)
		public static const FIT_WIDTH		: String = "fit_width";			// the video fits the player size in width and keeps its ratio (cropping may occur, borders may appear at top/bottom)
		public static const FIT_HEIGHT		: String = "fit_height";		// the video fits the player size in height and keeps its ratio (cropping may occur, borders may appear on the sides)
		public static const NO_BORDER		: String = "no_border";			// the video is resized to the player size, keeping a constant width/height ratio, until there is no border (cropping may occur)
		public static const EXACT_FIT		: String = "exact_fit";			// the video fits the player's height or width while keeping its ratio, allowing borders if necessary (no streching, no cropping, borders may appear)
		
		
		/************************************************************
		 * Variables
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Constructor
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Public methods
		 ************************************************************/
		
		//...
		
		
		/************************************************************
		 * Private methods
		 ************************************************************/
		
		//...
		
	}
}