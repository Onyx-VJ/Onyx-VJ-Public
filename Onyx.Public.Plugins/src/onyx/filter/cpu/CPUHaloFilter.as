package onyx.filter.cpu {
	
	import flash.display.BitmapData;
	import flash.filters.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Halo::CPU',
		name		= 'CPU Style::Halo',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='quality', 	target='filter/quality', clamp='1,3')]
	[Parameter(type='blendMode',	id='blendMode',	target='blendMode')]
	[Parameter(type='integer',		id='blurX', 	target='filter/blurX', clamp='0,40')]
	[Parameter(type='integer',		id='blurY', 	target='filter/blurY', clamp='0,40')]
	
	public final class CPUHaloFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@parameter
		 */
		parameter const filter:BlurFilter		= new BlurFilter(20, 20);
		
		/**
		 * 	@parameter
		 */
		private var blend:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Display.Blend.Overlay::CPU') as IPluginBlendCPU;
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			if (!blend || blend.initialize(context) !== PluginStatus.OK) {
				return new PluginStatus('Error Initializing blend');
			}
			
			this.owner		= owner;
			this.buffer		= context.requestSurface(true);
			this.context	= context;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		parameter function set blendMode(value:IPlugin):void {
			blend = (value as IPluginBlendCPU) || Onyx.CreateInstance('Onyx.Display.Blend.Overlay::CPU') as IPluginBlendCPU;
			blend.initialize(context);
		}
		
		/**
		 * 	@private
		 */
		parameter function get blendMode():IPlugin {
			return blend;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// context.surface is the previous render
			buffer.applyFilter(context.surface, context.rect, CONST_IDENTITY, filter);
			
			// render the blend mode
			// where to render, base, blend
			return blend.render(context.target, context.surface, buffer);
		}
		
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
			// dispose
			context.releaseSurface(buffer);
			
		}
	}
}