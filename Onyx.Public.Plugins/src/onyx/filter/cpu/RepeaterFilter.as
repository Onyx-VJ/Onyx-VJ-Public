package onyx.filter.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	import onyx.display.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Repeater',
		name		= 'Filter::Repeat',
		depends		= 'Onyx.Display.CPU',
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
			
			var square:int		= amount * amount;
			
			matrix				= new Matrix(1 / amount, 0, 0, 1 / amount);
			buffer				= new DisplaySurface(matrix.a * context.width, matrix.d * context.height, true, 0x00);
			
			super.validate();
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):void {

			// draw
			buffer.draw(context.surface, matrix);
			
			var square:int			= amount * amount;
			var segmentX:Number		= context.width / amount;
			var segmentY:Number		= context.height / amount;
			
			context.clear();
			
			for (var count:int = 0; count < square; ++count) {
				POINT.x = (count % amount) * segmentX;
				POINT.y = int(count / amount) * segmentY;
				context.copyPixels(buffer, false, buffer.rect, POINT);
			}
		}
	}
}