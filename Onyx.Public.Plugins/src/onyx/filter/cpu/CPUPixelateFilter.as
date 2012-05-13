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
	
	[Parameter(type='integer',				id='amount', 	target='amount', clamp='2,200', reset='2')]
	[Parameter(type='colorTransform',		id='alpha', 	target='blendTransform', channels='a')]
	[Parameter(type='blendMode',			id='blend', 	target='blendMode', allowNull='true')]
	public final class CPUPixelateFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;	
		
		/**
		 * 	@parameter
		 */
		parameter const blendTransform:ColorTransform		= new ColorTransform(1,1,1,1);
		
		/**
		 * 	@parameter
		 */
		parameter var amount:int				= 2;
		
		/**
		 * 	@parameter
		 */
		parameter var blendMode:IPluginBlendCPU	= null;
		
		/**
		 * 	@private
		 */
		private const pMatrix:Matrix			= new Matrix();
		private const iMatrix:Matrix			= new Matrix();
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			this.owner		= owner;		
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			for (var i:String in invalidParameters) {
				switch (i) {
					case 'amount':
						
						if (buffer) {
							buffer.dispose();
						}
						buffer = new DisplaySurface(context.width / amount, context.height / amount, false, 0x00);
						
						pMatrix.identity();
						pMatrix.scale(buffer.width / context.width, buffer.height / context.height);
						
						// identity
						iMatrix.identity();
						iMatrix.copyFrom(pMatrix);
						iMatrix.invert();
						
						break;
					case 'blendMode':
						
						if (blendMode.initialize(context) !== PluginStatus.OK) {
							trace('error!');
							blendMode = null;
						}
						
						break;
					case 'alpha':
						break;
				}
				
			}
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// draw
			buffer.draw(context.surface, pMatrix);
			
			// return the blend value, since sometimes it doesn't swap the buffer
			if (blendMode) {
				return blendMode.render(context.target, context.surface, buffer, blendTransform, iMatrix);
			}
			
			// no blend, draw directly
				
			context.clear();
			context.draw(buffer, iMatrix, blendTransform, null, null, false);
			
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release
			if (buffer) {
				buffer.dispose();
			}
			
			// dispose
			super.dispose();
			
		}
	}
}