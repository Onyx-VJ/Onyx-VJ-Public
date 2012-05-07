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
		id			= 'Onyx.Filter.ColorFilter::CPU',
		name		= 'CPU Color::Adjust',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='brightness',	name='Brightness', 	clamp='-1,1',	reset='0')]
	[Parameter(type='number',		id='contrast',		name='Contrast',	clamp='-1,2',	reset='0')]
	[Parameter(type='number',		id='saturation',	name='Saturation',	clamp='0,2',	reset='1')]
	[Parameter(type='number',		id='hue',	 		name='Hue',			clamp='-1,1',	reset='0')]
	[Parameter(type='number',		id='threshold',		name='Threshold', 	clamp='0,1',	reset='0')]
	
	public final class CPUColorFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		private const matrix:ColorMatrix	= new ColorMatrix();
		
		/**
		 * 	@private
		 * 	Contrast
		 */
		parameter var saturation:Number		= 1.0;
		
		/**
		 * 	@private
		 * 	Brightness
		 */
		parameter var brightness:Number		= 0.0;
		
		/**
		 * 	@private
		 * 	Brightness
		 */
		parameter var contrast:Number		= 0.0;
		
		/**
		 * 	@private
		 * 	Brightness
		 */
		parameter var hue:Number			= 0.0;
		
		/**
		 * 	@private
		 * 	Brightness
		 */
		parameter var threshold:Number		= 0.0;
		
		/**
		 * 	@private	
		 */
		parameter var filter:ColorMatrixFilter;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, channel:IDisplayContextCPU):PluginStatus {
			this.context	= channel;
			this.owner		= owner;
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			if (threshold === 0 && hue === 0 && contrast === 0 && brightness === 0 && saturation === 1) {
				filter = null;
				return super.validate();
			}
			
			matrix.reset();
			if (threshold !== 0) {
				matrix.threshold(threshold * 255);
			}
			
			if (saturation !== 1.0) {
				matrix.adjustSaturation(saturation);
			}
			matrix.adjustHue(hue * 360);
			matrix.adjustContrast(contrast);
			matrix.adjustBrightness(brightness * 255);
			
			// store the filter
			filter = matrix.filter;
			
			// we're done
			super.validate();
			
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// run!
			if (filter) {
				context.applyFilter(matrix.filter, context.surface);
				return true;
			}
			
			// return false, buffers aren't going to get switched
			return false;
		}
	}
}