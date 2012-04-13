package onyx.filter.cpu {
	
	import flash.display.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.DisplaySurfaceProxy;
	import onyx.parameter.IParameter;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.CPU.Noise',
		name		= 'Filter::Noise',
		depends		= 'Onyx.Display.CPU',
		vendor		= 'Daniel Hai',
		version		= '1.0'
	)]
	
	[Parameter(type='colorTransform',	id='colorTransform',	target='colorTransform',	channels='argb')]
	[Parameter(type='boolean',			id='greyScale',	 	 	target='greyScale')]
	[Parameter(type='blendMode',		id='blendMode',	 	 	target='blendMode')]

	public final class NoiseFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		/**
		 * 	@private
		 */
		parameter var colorTransform:ColorTransform	= new ColorTransform(1,1,1,0.20);
		
		/**
		 * 	@private
		 */
		parameter var blendMode:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Blend.CPU.Normal') as IPluginBlendCPU;

		/**
		 * 	@private
		 */
		parameter var greyScale:Boolean				= true;
		
		/**
		 * 	@private
		 */
		private var buffer:BitmapData;
		
		/**
		 * 	@private
		 */
		private var rect:Rectangle;

		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU):PluginStatus {
			
			this.context	= context;
			this.buffer		= new BitmapData(context.width, context.height, false, 0);
			this.rect		= context.rect;
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			for each (var parameter:IParameter in invalidParameters) {
				
				switch (parameter.id) {
					case 'blendMode':
						
						blendMode.initialize(context);
						
						break;
					case 'greyScale':
						
						// renoise
						buffer.noise(Math.random() * 255, 0, 255, 7, greyScale);
						
						break;
				}
				
			}
			
			super.validate();

		}
		
		/**
		 * 	@public
		 */
		public function render(surface:IDisplaySurface):void {
			
			if (invalid) {
				validate();
			}
			
			var position:int		= Math.random() * rect.width;
			var bitmap:BitmapData	= surface.nativeSurface;
			
			blendMode.render(surface, new DisplaySurfaceProxy(buffer), colorTransform, new Matrix(1,0,0,1, -rect.width + position), new Rectangle(0,0,position,rect.height));
			blendMode.render(surface, new DisplaySurfaceProxy(buffer), colorTransform, new Matrix(1,0,0,1, position), new Rectangle(position,0,rect.width - position,rect.height));

		}
	}
}