package onyx.filter.cpu {
	
	import flash.display.BitmapData;
	import flash.filters.*;
	import flash.geom.ColorTransform;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.EdgeBlend::CPU',
		name		= 'CPU Style::EdgeBlend',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
		
	[Parameter(type='integer',		id='width', 	target='width', clamp='1,100')]
	public final class CPUEdgeBlendFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		private var matrix:Array				= [0, -2, 0, -2, 8, -2, 0, -2, 0];
		private var transform:ColorTransform = new ColorTransform();
		private var filter:ConvolutionFilter	= new ConvolutionFilter(3, 3, matrix, 1);
		
		parameter function get width():int {
			return matrix[1] * -1;
		}
		
		parameter function set width(value:int):void {
			matrix[1] = matrix[3] = matrix[5] = matrix[7] = value * -1;
			matrix[4] = value * 4;
			
			/*if (sharpen) {
				matrix[7] = matrix[7] / 2;
			}*/
			
			filter.matrix = matrix;
		}
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
					
			this.owner		= owner;
			this.buffer		= new DisplaySurface(context.width, context.height, true, 0x00);
			this.context	= context;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// context.surface is the previous render
			buffer.applyFilter(context.surface, context.rect, CONST_IDENTITY, filter);		
			
			return blend.render(context.target, context.surface, buffer, transform);
		}
		
		override public function dispose():void {
			
			super.dispose();
			buffer.dispose();
			
		}
	}
}