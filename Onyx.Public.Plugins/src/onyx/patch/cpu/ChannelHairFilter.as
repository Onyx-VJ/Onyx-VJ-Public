package onyx.patch.cpu {
	
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
	
	[Parameter(type='channelCPU',			id='targetChannel', target='targetChannel')]
	[Parameter(type='integer',				id='amount', 		target='amount', 	clamp='1,200', 	reset='1')]
	[Parameter(type='colorTransform',		id='alpha', 		target='transform', channels='argb')]
	[Parameter(type='int',					id='delay',			target='delay',		reset='1000',	clamp='1,1000')]
		public final class ChannelHairFilter extends PluginPatchTransformCPU {
			
			private var walkerNum:int = 0;
			private var walkers:Vector.<Function>;
			/**
			 * 	@private
			 */
			private var buffer:DisplaySurface;	
			
			/**
			 * 	@private
			 */
			parameter var targetChannel:IChannel;
			
			/**
			 * 	@private
			 */
			private var listenChannel:IChannelCPU;
			
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
			private var updated:Boolean;
			
			/**
			 * 	@private
			 */
			private const pMatrix:Matrix			= new Matrix();
			private const iMatrix:Matrix			= new Matrix();
			
			/**
			 * 	@public
			 */
			override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
				
				// set our size to the context size
				dimensions.width 		= context.width;
				dimensions.height		= context.height;
				
				// create
				buffer					= new DisplaySurface(context.width, context.height, true, 0x00);
				
				walkerNum = 50000;
				walkers = null;
				walkers = new Vector.<Function>(walkerNum, true);
				makeWalkers();				
				// success
				return super.initialize(context, channel, path, content);
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
						case 'targetChannel':
							// the channel has changed!						
							if (listenChannel) {
								listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);	
							}
							
							listenChannel = targetChannel as IChannelCPU;
							if (listenChannel) {
								listenChannel.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);	
								
								
							}
							
							updated = false;
							break;
					}
					
				}
			}
			
			/**
			 * 	@private
			 */
			private function handleRender(event:OnyxEvent):void {
				
				var target:BitmapData = listenChannel.surface;
				buffer.copyPixels(target, target.rect, CONST_IDENTITY);
				if (!walkers) {
					walkerNum = 50000;
					walkers = null;
					walkers = new Vector.<Function>(walkerNum, true);
					makeWalkers();
				}
				
				buffer.lock ();
				for (var i:int = 0; i<walkerNum; i++){
					walkers[i]();
				}
				buffer.unlock ();
				updated = false;
			}
			/**
			 * 	@public
			 */
			override public function render(context:IDisplayContextCPU):Boolean {
				if (updated) {
					updated	= false;
					
					context.draw(buffer, renderMatrix);
					return true;
					
				}
				
				return false;
				
			}
			
			/**
			 * 	@public
			 */
			override public function update(time:Number):Boolean {
				return invalid || updated;
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