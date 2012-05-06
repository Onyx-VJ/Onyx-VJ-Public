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
		id			= 'Onyx.Filter.Test::GPU',
		name		= 'GPU Test',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	public final class GPUTestFilter extends PluginFilterGPU implements IPluginFilterGPU {
		
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
				'mov oc, v0\n'

			) || super.initialize(owner, context);
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextGPU):Boolean {
		
			// bind program
			context.bindProgram(program);
			
			// basic draw
			context.drawProgram();
			
			// return false, buffers aren't going to get switched
			return true;
		}
	}
}