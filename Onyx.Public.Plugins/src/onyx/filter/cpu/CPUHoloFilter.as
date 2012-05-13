/**
 * Contains code from: http://wonderfl.net/c/f4H9
 */
package onyx.filter.cpu {
	
	import flash.display.IBitmapDrawable;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Holo::CPU',
		name		= 'CPU Style::Holo',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	public final class CPUHoloFilter extends PluginFilterCPU implements IPluginFilterCPU {

		private var _matrix : Matrix;
		private var _sourceRect : Rectangle;
		private var _destPoint : Point;
		private var _zero : Point;
		private var _theta : Number;
		private var _scanLine : int;
		
		private var buffer:DisplaySurface;
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			this.owner		= owner;
			this.buffer		= context.requestSurface(true);
			
			_sourceRect = new Rectangle(0, 0, 0, 1);
			_destPoint = new Point();
			_zero = new Point();
			_theta = 0.0;
			_scanLine = 0;
			
			
			_matrix = new Matrix();
						
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			buffer.fillRect(context.rect, 0x0);

			buffer.draw(context.surface, _matrix);
			
			_scanLine = ++_scanLine & 127;
			
			var offset : Number;
			var n : uint = context.height;
			while (n-- != 0) {
				_theta = (_theta + (Math.PI / (64 + _scanLine))) % (Math.PI * 2);
				offset = Math.tan(_theta * n / context.height);
				offset = offset < -(context.width >> 1) ? -(context.width >> 1) : offset > (context.width >> 1) ? context.width >> 1 : offset;
				
				_sourceRect.x = offset;
				_sourceRect.width = context.width - offset;
				_sourceRect.y = n;
				
				_destPoint.y = n;
				
				context.copyPixels(buffer, false, _sourceRect, _destPoint);
			}
			return true;
		}
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
			// dispose
			context.releaseSurface(buffer);
			
		}
	}
}
