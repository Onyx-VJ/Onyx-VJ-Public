package onyx.filter.cpu {
	
	import flash.display.BitmapData;
	import flash.filters.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.OnyxEvent;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Hair::CPU',
		name		= 'CPU Style::Hair',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	[Parameter(type='integer',				id='amount', 		target='amount', 	clamp='1,200', 	reset='1')]
	[Parameter(type='colorTransform',		id='alpha', 		target='transform', channels='argb')]
	[Parameter(type='int',					id='delay',			target='delay',		reset='1000',	clamp='1,1000')]
	public final class CPUHairFilter extends PluginFilterCPU implements IPluginFilterCPU {
		
		private var walkerNum:int = 0;
		private var walkers:Vector.<Function>;
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;	

		/**
		 * 	@parameter
		 */
		parameter const transform:ColorTransform		= new ColorTransform(1,1,1,1);
		
		/**
		 * 	@parameter
		 */
		parameter var amount:int				= 1;

		/**
		 * 	@parameter
		 */
		parameter var delay:int						= 1000;
		
		/**
		 * 	@private
		 */
		private var time:int						= getTimer();				

		/**
		 * 	@private
		 */
		private var created:Boolean;

		/**
		 * 	@private
		 */
		private const pMatrix:Matrix			= new Matrix();
		private const iMatrix:Matrix			= new Matrix();
		
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, context:IDisplayContextCPU):PluginStatus {
			
			this.context		= context;
			this.owner			= owner;
			
			// create
			buffer					= new DisplaySurface(context.width, context.height, true, 0x00);

			//makeWalkers();				
			// success
			return PluginStatus.OK;
		}

		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			for (var i:String in invalidParameters) {
				switch (i) {
					case 'amount':
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
			
			var rtn:Boolean = false;
			if (getTimer() - time >= delay) {
			if (!created) {
				created = true;
				makeWalkers();	
			}
			buffer.lock ();
			for (var i:int = 0; i<walkerNum; i++){
			walkers[i]();
			}
			buffer.unlock ();
			
			//context.clear();
			context.draw(buffer, iMatrix, transform, null, null, false);
			time			= getTimer();
			}
			return true;
		}
				
		private function makeWalkers():void{
			// draw
			//buffer.copyPixels(context.surface, context.rect, CONST_IDENTITY);
			for (var i:int = 0; i < walkerNum; i++) {
				var ix:int = buffer.width * Math.random ();
				var iy:int = buffer.height * Math.random ();
				walkers[i] = makeWalker(ix, iy,
					(buffer.getPixel (
						ix,
						iy)
						& 0xFF00) >> 10);
			}
		}
		private function makeWalker(xp:Number=200, yp:Number=200, dieAt:int=500):Function{
			var age:int = dieAt;
			var x:Number = xp, y:Number = yp;
			var rad:Number = Math.random();
			var theta:Number = Math.random() * Math.PI * 2;
			var speed:Number = 0.01 * Math.random() * 2;
			if (int(Math.random() * 2) == 1){
				speed *= -1;
			}
			return function():void{
				if (age --< 1) return;
				x += rad * Math.cos(theta);
				y += rad * Math.sin(theta);
				theta += speed
				if (int(Math.random() * 100) == 1){
					theta = Math.random() * Math.PI * 2;
				}
				if (!(x > buffer.width || x < 0 || y > buffer.height || y < 0)){
					buffer.setPixel(x, y, Math.max (0x40404*age, buffer.getPixel (x, y)));
				}
			}
		}

		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// release
			if (buffer) {
				context.releaseSurface(buffer);
				buffer.dispose();
			}
			
			// dispose
			super.dispose();
			
		}
	}
}