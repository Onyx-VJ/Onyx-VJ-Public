package onyx.filter.cpu {
	
	import flash.display.IBitmapDrawable;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Mirror',
		name		= 'Filter::Mirror',
		depends		= 'Onyx.Display.CPU,Onyx.Display.CPU.Blend.Overlay',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='number',		id='offset',	 	target='offset',		clamp='0,1', reset='0.5')]
	[Parameter(type='boolean',		id='horizontal', 	target='horizontal',	reset='true')]
	[Parameter(type='array',		id='order',	 	target='order',			values='auto,1h,2h', reset='auto')]
	public final class MirrorFilter extends PluginFilterCPU implements IPluginFilterCPU {

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
		private var matrix:Matrix;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			
			// context
			this.context	= context;
			
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
		public function render(surface:IDisplaySurface):void {
			
			if (invalid) {
				validate();
			}
			
//			var buffer:IBitmapDrawable = surface.nativeSurface.clone();
//			surface.fillRect(surface.rect, 0);
//			surface.draw(buffer, null, new ColorTransform(1,1,1,.4));
			
			// draw
			surface.draw(surface.nativeSurface, matrix, null, null, clipRect);
		}
	}
}