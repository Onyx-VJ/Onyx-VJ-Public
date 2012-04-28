package onyx.filter.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Repeater',
		name		= 'Filter::Repeat',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',	id='amount',	 	target='amount',		clamp='2,24', reset='2')]

	public final class RepeaterFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		private static const POINT:Point	= new Point();
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var matrix:Matrix;
		
		/**
		 * 	@private
		 */
		parameter var amount:int			= 2;
		
		/**
		 * 	@private
		 */
		private var rect:Rectangle;

		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			this.owner		= owner;
			this.context	= context;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			var square:int		= amount * amount;
			
			matrix				= new Matrix(1 / amount, 0, 0, 1 / amount);
			buffer				= new DisplaySurface(matrix.a * context.width, matrix.d * context.height, true, 0x00);
			rect				= buffer.rect;
			
			super.validate();
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {

			// copy the previous into our buffer
			buffer.fillRect(rect, 0x00);
			buffer.draw(context.surface, matrix);
			
			var square:int			= amount * amount;
			var segmentX:Number		= context.width / amount;
			var segmentY:Number		= context.height / amount;
			
			// make sure we wipe everything -- as items may have alpha
			context.clear();
			
			for (var count:int = 0; count < square; ++count) {
				POINT.x = (count % amount) * segmentX;
				POINT.y = int(count / amount) * segmentY;
				context.copyPixels(buffer, false, rect, POINT);
			}
			
			return true;
		}
	}
}