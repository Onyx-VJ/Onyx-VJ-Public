package onyx.filter.gpu {
	
	import com.adobe.utils.*;
	import com.quasimondo.geom.*;
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.ColorFilter::GPU',
		name		= 'GPU Color::Adjust',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='brightness',	name='Brightness', 	clamp='-1,1',	reset='0')]
	[Parameter(type='number',		id='contrast',		name='Contrast',	clamp='-1,2',	reset='0')]
	[Parameter(type='number',		id='saturation',	name='Saturation',	clamp='0,2',	reset='1')]
	[Parameter(type='number',		id='hue',	 		name='Hue',			clamp='-1,1',	reset='0')]
	[Parameter(type='number',		id='threshold',		name='Threshold', 	clamp='0,1',	reset='0')]
	
	// TODO, FIX OFFSETS brightness, etc
	
	public final class GPUColorFilter extends PluginFilterGPU implements IPluginFilterGPU {
		
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
		parameter var colors:Vector.<Number>;
		parameter var offset:Vector.<Number>;
		
		/**
		 * 	@public
		 */
		override public function initialize(owner:IChannelGPU, context:IDisplayContextGPU):PluginStatus {
			
			// compile
			return super.compile(context,
				
				// vertex
				'mov op, va0\n' +
				'mov v0, va1',
				
				//fragment
				'tex ft0,	v0, fs0 <2d,nearest,nomip>\n' +
				'm44 oc,	ft0,		fc0'// + 
				//'add oc,	ft1,		fc1\n'

			) || super.initialize(owner, context);
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			// if everything is default, we shouldn't render anything
			if (threshold === 0 && hue === 0 && contrast === 0 && brightness === 0 && saturation === 1) {
				colors = null;
				return super.validate();
			}
			
			// reset
			this.matrix.reset();
			if (threshold !== 0) {
				this.matrix.threshold(threshold);
			}
			
			if (saturation !== 1.0) {
				this.matrix.adjustSaturation(saturation);
			}
			this.matrix.adjustHue(hue * 360);
			this.matrix.adjustContrast(contrast);
			this.matrix.adjustBrightness(brightness);
			
			var matrix:Array = this.matrix.filter.matrix;
			
			// store the colors to draw
			colors		= new Vector.<Number>(16, true);
//			offset		= new Vector.<Number>(4, true);
			colors[0]	= matrix[0];
			colors[1]	= matrix[1];
			colors[2]	= matrix[2];
			colors[3]	= matrix[3];
//			offset[0]	= matrix[4];
			colors[4]	= matrix[5];
			colors[5]	= matrix[6];
			colors[6]	= matrix[7];
			colors[7]	= matrix[8];
//			offset[1]	= matrix[9];
			colors[8]	= matrix[10];
			colors[9]	= matrix[11];
			colors[10]	= matrix[12];
			colors[11]	= matrix[13];
//			offset[2]	= matrix[14];
			colors[12]	= matrix[15];
			colors[13]	= matrix[16];
			colors[14]	= matrix[17];
			colors[15]	= matrix[18];
			
//			offset[3]	= matrix[19];
			
			// we're done
			super.validate();
			
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextGPU):Boolean {
			
			// run!
			if (colors) {
				
				// bind program
				context.bindProgram(program);
			
				// set program constants
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colors, 4);
				//context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, offset, 1);
				
				// basic draw
				context.drawProgram();

				// draw the previous texture
				return true;
			}
			
			// return false, buffers aren't going to get switched
			return false;
		}
	}
}