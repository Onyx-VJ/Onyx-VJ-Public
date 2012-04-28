package onyx.filter.cpu {
	
	import com.quasimondo.geom.ColorMatrix;
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Filter.Gamma::CPU',
		name		= 'Color::Gamma',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='amount',	 	clamp='0,2',	reset='1')]
	
	public final class GammaFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 * 	Brightness
		 */
		parameter var amount:Number		= 1.0;
		
		/**
		 * 	@private
		 */
		private var RLUT:Array			= new Array(256);
		
		/**
		 * 	@private
		 */
		private var GLUT:Array			= new Array(256);
		
		/**
		 * 	@private
		 */
		private var BLUT:Array			= new Array(256);
		
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
		override public function validate():void {
			
			if (amount !== 1) {
				for (var v:int = 0; v < 256; v++) {
					BLUT[v] = int(Math.pow(v / 256.0, 2.00000001 - amount) * 256);
					GLUT[v] = BLUT[v] << 8;
					RLUT[v] = GLUT[v] << 8;
				}
			}
			
			// we're done
			super.validate();

		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			if (amount !== 1) {
				context.paletteMap(RLUT, GLUT, BLUT, null, context.surface);
				return true;
			}
			
			return false;
		}
	}
}