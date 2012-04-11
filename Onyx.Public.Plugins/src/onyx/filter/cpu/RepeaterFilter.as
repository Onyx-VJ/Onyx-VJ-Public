package onyx.filter.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Repeater',
		name		= 'Filter::Repeat',
		depends		= 'Onyx.Display.CPU',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		name='amount',	 	target='amount',		clamp='2,24', reset='2')]
	
	public final class RepeaterFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		private static const POINT:Point	= new Point();
		
		/**
		 * 	@private
		 */
		private var buffer:BitmapData;
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
			buffer				= new BitmapData(matrix.a * context.width, matrix.d * context.height, true, 0x00);
//			buffer = new BitmapData();
			
			super.validate();
		}
		
		public function render(surface:IDisplaySurface):void {
			if (invalid) {
				validate();
			}
			
			buffer.draw(surface.nativeSurface, matrix);
			
			var square:int			= amount * amount;
			var segmentX:Number		= context.width / amount;
			var segmentY:Number		= context.height / amount;
			var target:BitmapData	= surface.nativeSurface;
			target.fillRect(target.rect, 0);
			
			for (var count:int = 0; count < square; ++count) {
				POINT.x = (count % amount) * segmentX;
				POINT.y = int(count / amount) * segmentY;
				target.copyPixels(buffer, buffer.rect, POINT);
			}
		}
	}
}