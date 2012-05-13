package onyx.filter.cpu {
	
	import flash.display.IBitmapDrawable;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.PassThrough::CPU',
		name		= 'CPU Style::PassThrough',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]

	[Parameter(type='integer',		id='amount', 	target='amount', 	clamp='0,255')]
	[Parameter(type='integer',		id='postBlur', 	target='postBlur', 	clamp='0,10')]
	[Parameter(type='enum',			id='mode',	 	target='mode',		values='low pass,high pass', reset='low pass')]
	public final class CPUPassThroughFilter extends PluginFilterCPU implements IPluginFilterCPU {
			
		/**
		 * 	@parameter
		 */
		parameter var amount:int			= 150;
		
		/**
		 * 	@parameter
		 */
		parameter var mode:String			= 'low pass';
		
		parameter function set postBlur(value:int):void {
			blur.blurX = blur.blurY = value;
		}
		parameter function get postBlur():int {
			return blur.blurX;
		}
		public const blur:BlurFilter	= new BlurFilter(2, 2);
		
		private var buffer:DisplaySurface;
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			this.owner		= owner;
			this.buffer		= context.requestSurface(true);
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			var thresh:uint = (amount << 16 | amount << 8 | amount);
			

			
			buffer.copyPixels(context.surface,context.rect, CONST_IDENTITY);
			buffer.threshold(buffer, buffer.rect, CONST_IDENTITY, mode === 'high pass' ? '<=' : '>=', thresh, 0x00FFFFFF, 0x00FFFFFF);
			
			if (blur.blurX) buffer.applyFilter(buffer, context.rect, CONST_IDENTITY, blur);
			context.copyPixels(buffer, false, context.rect, CONST_IDENTITY);
			
			return true;
		}
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
			// dispose
			context.releaseSurface(buffer);
			
		}
	}
}