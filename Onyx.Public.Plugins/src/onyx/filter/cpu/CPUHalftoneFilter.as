package onyx.filter.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.getTimer;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Halftone::CPU',
		name		= 'CPU Style::Halftone',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	[Parameter(type='int',				id='amount',		target='tone/size',		reset='20',	clamp='10,100')]
	[Parameter(type='colorTransform',	id='blendAmount',	target='blendAmount',	channels='rgba')]
	[Parameter(type='int',				id='delay',			target='delay',		 	reset='100',	clamp='1,1000')]
	[Parameter(type='boolean',			id='flicker', 		target='flicker',		reset='false')]
	
	final public class CPUHalftoneFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var amount:int					= 20;
		/**
		 * 	@parameter
		 */
		parameter var delay:int						= 100;
		/**
		 * 	@parameter
		 */
		parameter var flicker:Boolean				= false;
		/**
		 * 	@private
		 */
		private var time:int						= getTimer();
		
		private var matrix_:Matrix;
		private var smooth:Smooth;  
		
		parameter const tone:HalftoneColor			= new HalftoneColor();
		
		private var buffer:DisplaySurface;
		
		/**
		 * 	@parameter
		 */
		private var blend:IPluginBlendCPU			= Onyx.CreateInstance('Onyx.Display.Blend.Overlay::CPU') as IPluginBlendCPU;
		
		// blend amount?
		parameter var blendAmount:ColorTransform	= new ColorTransform();
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			this.context		= context;
			this.owner			= owner;
			
			smooth				= new Smooth();       
			smooth.strength 	= 2;
   
			tone.size			= amount;
			matrix_				= new Matrix( 1, 0, 0, 1, 0, 0);
			
			buffer				= new DisplaySurface( context.width, context.height, true, 0x00);
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			var rtn:Boolean = false;
			if (getTimer() - time >= delay) {
								
				// copy the previous over
				buffer.copyPixels(context.surface, context.rect, CONST_IDENTITY);
				
				// apply everything to the buffer
				smooth.applyEffect(buffer);
	
				// apply the effect
				tone.applyEffect(buffer);
				
				// target, base, blend, amount
				
				// swap buffer
				rtn = blend.render(context.target, context.surface, buffer, blendAmount);

				time			= getTimer();
			}
			// swap buffer
			if (!flicker) rtn = blend.render(context.target, context.surface, buffer, blendAmount);
			return rtn;
		}			
		/**
		 * 	@public
		 */
		override public function dispose():void {

			// dispose
			super.dispose();
			
			// dispose
			buffer.dispose();
			
		}
	}
}
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.geom.Rectangle;

/**
 * @author YOSHIDA, Akio (Aquioux)
 */
class HalftoneColor 
{
	public function set size(value:uint):void 
	{
		_size = value;
		
		wNum_ = Math.ceil(width_  / _size);    
		hNum_ = Math.ceil(height_ / _size);    
		
		if (blockBmd_) blockBmd_.dispose();
		blockBmd_ = new BitmapData(_size, _size);
		
		blockRect_.width = blockRect_.height = _size;
		
		blockPixels_ = _size * _size;
	}
	
	public function get size():uint {
		return _size;
	}
	
	private var _size:uint = 16;               
	private var width_:Number;           
	private var height_:Number;           
	
	private var wNum_:uint;               
	private var hNum_:uint;               
	
	private var blockBmd_:BitmapData;    
	private var blockRect_:Rectangle;
	private var blockPixels_:uint;       
	
	static private var rBmd_:BitmapData;    // for RED Channel
	static private var gBmd_:BitmapData;    // for GREEN Channel
	static private var bBmd_:BitmapData;    // for BLUE Channel
	static private var bufferBmds_:Array;
	
	static private var totalRect_:Rectangle;
	static public const ZERO_POINT:Point = new Point(0, 0);
	
	public function HalftoneColor(width:Number = 0.0, height:Number = 0.0)
	{
		width_  = width;   
		height_ = height;   
		blockRect_ = new Rectangle();
		if (width_ != 0.0 && height_ != 0.0) init(width, height);
	}
	
	public function applyEffect(value:BitmapData):BitmapData 
	{
		
		if (rBmd_){
			rBmd_.fillRect(totalRect_, 0x00000000);
			gBmd_.fillRect(totalRect_, 0x00000000);
			bBmd_.fillRect(totalRect_, 0x00000000);
		}
		
		if (width_ == 0.0 || height_ == 0.0) init(value.width, value.height);
		
		var saveBmd:BitmapData = value.clone();   
		value.fillRect(value.rect, 0xFF000000);    
		
		value.lock();
		for (var i:int = 0; i < hNum_; i++) 
		{
			for (var j:int = 0; j < wNum_; j++)
			{
				var px:Number = j * _size;
				var py:Number = i * _size;
				
				blockRect_.x = px;
				blockRect_.y = py;
				blockRect_.width  = blockRect_.height = _size;
				
				blockBmd_.copyPixels(saveBmd, blockRect_, ZERO_POINT);
				
				var brightness:Vector.<uint> = getAverageBrightness(blockBmd_.histogram());
				for (var k:int = 0; k < 3; k++)
				{
					
					var blockSize:Number = _size * (brightness[k] / 255) * 0.9;    // 90% 
					
					var offset:Number = (_size - blockSize) / 2;
					
					blockRect_.x = px + offset + Math.random() - 0.5;
					blockRect_.y = py + offset + Math.random() - 0.5;
					blockRect_.width = blockRect_.height = blockSize;
					
					bufferBmds_[k].fillRect(blockRect_, 0xFFFFFFFF);
				}
			}
		}
		value.copyChannel(rBmd_, totalRect_, ZERO_POINT, BitmapDataChannel.RED, BitmapDataChannel.RED);
		value.copyChannel(gBmd_, totalRect_, ZERO_POINT, BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
		value.copyChannel(bBmd_, totalRect_, ZERO_POINT, BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
		value.unlock();
		return value;
	}
	
	
	private function init(width:Number, height:Number):void
	{
		width_  = width;    
		height_ = height;   
		size    = _size;    
		
		rBmd_ = new BitmapData(width_, height_, true, 0x00000000);
		gBmd_ = rBmd_.clone();
		bBmd_ = rBmd_.clone();
		bufferBmds_ = [rBmd_, gBmd_, bBmd_];
		totalRect_ = new Rectangle(0, 0, width_, height_);
	}
	
	private function getAverageBrightness(hist:Vector.<Vector.<Number>>):Vector.<uint>
	{
		var rSum:uint = 0;
		var gSum:uint = 0;
		var bSum:uint = 0;
		for (var i:int = 0; i < 256; i++) 
		{
			rSum += i * hist[0][i];
			gSum += i * hist[1][i];
			bSum += i * hist[2][i];
		}
		var r:uint = rSum / blockPixels_ >> 0;
		var g:uint = gSum / blockPixels_ >> 0;
		var b:uint = bSum / blockPixels_ >> 0;
		
		return Vector.<uint>([r, g, b]);
	}
}


import flash.display.BitmapData;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.geom.Point;

/**
 * BlurFilter
 * @author YOSHIDA, Akio (Aquioux)
 */
class Smooth
{
	static public const ZERO_POINT:Point = new Point(0, 0);
	public function set strength(value:Number):void 
	{
		blurFilter_.blurX = blurFilter_.blurY = value;
	}
	
	public function set quality(value:int):void
	{
		blurFilter_.quality = value;
	}
	
	private var blurFilter_:BlurFilter;
	
	public function Smooth()
	{
		blurFilter_ = new BlurFilter(2, 2, BitmapFilterQuality.MEDIUM);
	}
	
	public function applyEffect(value:BitmapData):BitmapData 
	{
		value.applyFilter(value, value.rect, ZERO_POINT, blurFilter_);
		return value;
	}
}
