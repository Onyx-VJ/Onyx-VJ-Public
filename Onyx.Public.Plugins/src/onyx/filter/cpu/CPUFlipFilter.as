package onyx.filter.cpu {
	
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.FlipFilter::CPU',
		name		= 'CPU Style::Flip',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='boolean',		id='flipV',			name='Flip V',	reset='false')]
	[Parameter(type='boolean',		id='flipH',			name='Flip H',	reset='false')]
	
	public final class CPUFlipFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		parameter var flipH:Boolean;
		parameter var flipV:Boolean;
		
		private var matrix:Matrix;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			this.context	= context;
			this.owner		= owner;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			if (flipV || flipH) {
				
				matrix = new Matrix();
				
				matrix.scale(flipH ? -1 : 1, flipV ? -1 : 1);
				matrix.translate(flipH ? context.width : 0, flipV ? context.height : 0);
				
				return;
			}
			
			matrix = null;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			if (matrix) {
				context.clear();
				context.draw(context.surface, matrix);
				return true;
			}
			
			// return false, buffers aren't going to get switched
			return false;
		}
	}
}