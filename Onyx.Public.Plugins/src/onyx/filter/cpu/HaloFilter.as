package onyx.filter.cpu {
	
	import flash.display.BitmapData;
	import flash.filters.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Halo',
		name		= 'Filter::Halo',
		depends		= 'Onyx.Display.CPU,Onyx.Display.CPU.Blend.Overlay',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		name='quality', 	target='filter/quality', clamp='1,3')]
	[Parameter(type='blendMode',	name='blendMode',	target='blendMode')]
	[Parameter(type='number',		name='blurX', 		target='filter/blurX', clamp='0,40')]
	[Parameter(type='number',		name='blurY', 		target='filter/blurY', clamp='0,40')]
	public final class HaloFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@parameter
		 */
		parameter const filter:BlurFilter		= new BlurFilter(20, 20);
		
		/**
		 * 	@parameter
		 */
		private var blend:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Display.CPU.Blend.Overlay') as IPluginBlendCPU;
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;//		= new BitmapData();
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			
			if (!blend || blend.initialize(context) !== PluginStatus.OK) {
				return new PluginStatus('Error Initializing HaloFilter');
			}
			
			this.buffer		= new DisplaySurface(context.width, context.height, true, 0x00);
			this.context	= context;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@private
		 */
		parameter function set blendMode(value:IPlugin):void {
			blend = (value as IPluginBlendCPU) || Onyx.CreateInstance('Onyx.Display.CPU.Blend.Overlay') as IPluginBlendCPU;
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
		public function render(source:IDisplaySurface):void {
			buffer.fillRect(source.rect, 0);
			buffer.applyFilter(source.nativeSurface, source.rect, CONST_IDENTITY, filter);
			blend.render(source, buffer);
			
//			source.fillRect(source.rect
		}
	}
}