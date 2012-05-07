package onyx.filter.cpu {
	
	import flash.display.IBitmapDrawable;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Mirror::CPU',
		name		= 'CPU Style::Mirror',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='offset',	 	target='offset',		clamp='0,1', reset='0.5')]
	[Parameter(type='boolean',		id='horizontal', 	target='horizontal',	reset='true')]
	[Parameter(type='enum',			id='order',	 		target='order',			values='auto,1h,2h', reset='auto')]
	public final class CPUMirrorFilter extends PluginFilterCPU implements IPluginFilterCPU {

		/**
		 * 	@parameter
		 */
		parameter var horizontal:Boolean	= true;
		
		/**
		 * 	@parameter
		 */
		parameter var offset:Number			= 0.5;
		
		/**
		 * 	@parameter
		 */
		parameter var order:String			= 'auto';
		
		/**
		 * 	@private
		 */
		private var clipRect:Rectangle;
		
		/**
		 * 	@private
		 */
		private var copyRect:Rectangle;
		
		/**
		 * 	@private
		 */
		private var matrix:Matrix;
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			this.owner		= owner;
			
			// return ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			var firstField:Boolean;
			switch (order) {
				case 'auto':
					firstField = (offset <= .5);
					break;
				case '1h':
					firstField = true;
					break;
				case '2h':
					firstField = false;
					break;
			}
			
			if (horizontal) {

				if (firstField) {
					clipRect	= new Rectangle(0, 0, offset * context.width, context.height);
					matrix		= new Matrix(-1, 0, 0, 1, context.width * offset * 2);
				} else {
					clipRect	= new Rectangle(offset * context.width, 0, context.width, context.height);
					matrix		= new Matrix(-1, 0, 0, 1, context.width * offset * 2);
				}
			} else {
				
				if (firstField) {
					clipRect	= new Rectangle(0, 0, context.width, offset * context.height);
					matrix		= new Matrix(1, 0, 0, -1, 0, context.height * offset * 2);
				} else {
					clipRect	= new Rectangle(0, offset * context.height, context.width, context.height);
					matrix		= new Matrix(1, 0, 0, -1, 0, context.height * offset * 2);
				}
			}
			
			// validate -- sets invalid to false, invalid parameters to null
			super.validate();
			
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
			
			// copy itself, since target !== surface
			// TODO: Optimize this, since we have a smaller rectangle to copy (don't have to copy the whole thing
			context.copyPixels(context.surface);
			
			// now we're going to re-draw the surface again
			context.draw(context.surface, matrix, null, null, clipRect);

			// return true -- we've rendered something, so we need swap the buffers eh?
			return true;
		}
	}
}