package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='channelCPU',	id='channel', target='channel')]
	
	final public class ChannelCopy extends PluginPatchCPU {
		
		/**
		 * 	@private
		 */
		parameter var channel:IChannel;
		
		/**
		 * 	@private
		 */
		private var listenChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var updated:Boolean;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// create
			buffer					= new DisplaySurface(context.width, context.height, true, 0x00);
			
			// success
			return super.initialize(context, path, content);
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			// the channel has changed!
			if (invalidParameters.channel) {
				
				if (listenChannel) {
					listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER, handleRender);	
				}
				
				listenChannel = channel as IChannelCPU;
				if (listenChannel) {
					listenChannel.addEventListener(OnyxEvent.CHANNEL_RENDER, handleRender);	
				}
				
				updated = false;

			}
			
			// validate
			super.validate();
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(event:OnyxEvent):void {
			
			var target:BitmapData = listenChannel.surface;
			buffer.copyPixels(target, target.rect, CONST_IDENTITY);
			
			updated = true;
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return invalid || updated;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			if (updated) {
				updated = false;
				context.copyPixels(buffer);
				return true;
			}
			
			return false;
		}
				
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (listenChannel) {
				listenChannel.addEventListener(OnyxEvent.CHANNEL_RENDER, handleRender);
				listenChannel = null;
			}
						
			// dispose
			super.dispose();
			
		}
	}
}