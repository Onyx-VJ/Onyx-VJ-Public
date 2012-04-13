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
		id			= 'Onyx.Filter.CPU.Gamma',
		name		= 'Color::Gamma',
		depends		= 'Onyx.Display.CPU',
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
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			this.context	= context;
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
		public function render(surface:IDisplaySurface):void {
			
			if (invalid) {
				validate();
			}
			
			if (amount !== 1) {
				var bitmap:BitmapData = surface.nativeSurface;
				bitmap.paletteMap(bitmap, bitmap.rect, CONST_IDENTITY, RLUT, GLUT, BLUT, null);
			}
		}
	}
}