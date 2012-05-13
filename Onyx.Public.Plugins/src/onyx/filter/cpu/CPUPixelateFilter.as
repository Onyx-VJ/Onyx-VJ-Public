package onyx.filter.cpu {
	
	import flash.display.BitmapData;
	import flash.filters.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Pixelate::CPU',
		name		= 'CPU Style::Pixelate',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	[Parameter(type='integer',		id='amount', 	target='amount', clamp='2,200')]
	[Parameter(type='number',		id='alpha', 	target='alpha', clamp='0,1')]
	public final class CPUPixelateFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface				= new DisplaySurface(40, 30, true, 0x00);	
		
		private var _blendTransform:ColorTransform	= new ColorTransform(1,1,1,1);
		
		parameter function get alpha():Number {
			return _blendTransform.alphaMultiplier;
		}
		
		parameter function set alpha(value:Number):void {
			_blendTransform.alphaMultiplier = value;
		}
		parameter function get amount():int {
			return context.width / buffer.width;
		}
		
		parameter function set amount(value:int):void {
			if (buffer) {
				buffer.dispose();
			}
			if (value > 0) {
				buffer = new DisplaySurface(context.width / value, context.height / value, true, 0x00);
			}
		}
		
		private var _matrix:Matrix					= new Matrix();
		
		/**
		 * 	@parameter
		 */
		private var blend:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Display.Blend.Overlay::CPU') as IPluginBlendCPU;
		

		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			this.owner		= owner;
			this.buffer		= context.requestSurface(true);		
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			var matrix:Matrix = new Matrix();
			matrix.scale(buffer.width / context.width, buffer.height / context.height);
			
			buffer.draw(context.surface, matrix);
			
			matrix.invert();
			matrix.concat(_matrix);	
			
			//return blend.render(context.target, context.surface, buffer, _blendTransform, matrix);
			return blend.render(context.target, context.target, buffer, _blendTransform, matrix);
		}
		
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
			// release
			context.releaseSurface(buffer);
			
		}
	}
}