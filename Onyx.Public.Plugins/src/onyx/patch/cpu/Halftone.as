package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='channelCPU',	id='channel',	target='boundChannel')]
	[Parameter(type='int',			id='delay',		target='delay', reset='96',	clamp='8,250')]
	[Parameter(type='int',			id='amount',	target='amount', reset='20',	clamp='1,100')]
	
	final public class Halftone extends PluginPatchCPU {
		
		/**
		 * 	@public
		 */
		parameter var status:String;
		
		/**
		 * 	@parameter
		 */
		parameter var amount:int				= 20;
		
		/**
		 * 	@parameter
		 */
		parameter var delay:int				= 96;
		
		/**
		 * 	@private
		 */
		parameter var listenChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		parameter var boundChannel:IChannel;
		
		/**
		 * 	@private
		 */
		private var frames:Array	= [];
		
		private var matrix_:Matrix;
		private var smooth:Smooth;  
		private var tone:HalftoneColor; 
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			smooth = new Smooth();       
			smooth.strength = 2;
			tone = new HalftoneColor();    
			tone.size = amount;
			matrix_ = new Matrix( 1, 0, 0, 1, 0, 0); 
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override public function getTotalTime():int {
			return 0;
		}
		
		/**
		 * 	@private
		 */
		private function handleChannel(e:OnyxEvent):void {
			
			// push
			if (frames.push(listenChannel.surface.clone()) > delay) {
				
				frames.splice(0, frames.length - delay);
				
			}
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			// we are rendering to this
			var target:DisplaySurface = context.target;
			
			// no matter what we should clear, otherwise we might get crap from some other place
			if (frames.length === delay) {
				
				var frame:DisplaySurface = frames[0];
			
				smooth.applyEffect(frame);   
				tone.applyEffect(frame);
				context.copyPixels(frame);

			} else {
				context.clear();
			}

			// clear
			return true;
		}
				
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			/*if (listenChannel) {
				listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER, handleChannel);
			}*/

			// dispose
			super.dispose();
			
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
