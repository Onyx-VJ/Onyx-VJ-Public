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
		id			= 'Onyx.Filter.Infinite::CPU',
		name		= 'CPU Style::Infinite',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	[Parameter(type='integer',				id='amount', 	target='amount', clamp='2,200', reset='2')]
	[Parameter(type='colorTransform',		id='alpha', 	target='blendTransform', channels='a')]
	[Parameter(type='blendMode',			id='blend', 	target='blendMode', allowNull='true')]
	[Parameter(type='function',				id='execute',	target='execute')]
	public final class CPUInfiniteFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
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
		parameter var blendMode:IPluginBlendCPU	= Onyx.CreateInstance('Onyx.Blend.CPU.Normal') as IPluginBlendCPU;
		
		/**
		 * 	@private
		 */
		private var pMatrix:Matrix			= new Matrix();
		private var iMatrix:Matrix			= new Matrix();
		
		private var iterations:int 				= 10; 
		
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
		 * 	@private
		 */
		parameter function execute():void {
			
			iterations = 10;
			pMatrix = null;
			pMatrix = new Matrix();
			
			// set invalid to true, so that we'll redraw
			invalid = true;
		}		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			for (var i:String in invalidParameters) {
				switch (i) {
					case 'amount':
						
						
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
			
			if (iterations-- > 0) {
				
				pMatrix.translate(-70, -71);
				pMatrix.scale(0.8, 0.8);
				pMatrix.rotate(-0.1);
				pMatrix.translate(70, 71);
				pMatrix.translate(-24, -26);
				
				
				// identity
				iMatrix.identity();
				iMatrix.copyFrom(pMatrix);
				iMatrix.invert();
				
			}
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