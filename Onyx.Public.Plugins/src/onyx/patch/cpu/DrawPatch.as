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
	
	[Parameter(type='color',		id='color',			target='color')]
	[Parameter(type='number',		id='lineAlpha',		target='lineAlpha')]
	[Parameter(type='number',		id='thickness',		target='thickness', clamp='1,100')]
	[Parameter(type='function',		id='clear',			target='clear')]
	[Parameter(target='quality',	id='quality',		type='stageQuality',	name='quality', reset='8x8')]	
	
	final public class DrawPatch extends PluginPatchCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var quality:String			= StageQuality.HIGH_8X8;
		
		/**
		 * 	@private
		 */
		parameter var color:uint				= 0xFFFFFF;
		
		/**
		 * 	@private
		 */
		parameter var lineAlpha:Number			= 1.0;
		
		/**
		 * 	@private
		 */
		parameter var thickness:Number			= 5.0;
		
		/**
		 * 	@private
		 */
		private var hasStuffToDraw:Boolean;
		
		/**
		 * 	@private
		 */
		private var buffer:BitmapData;
		
		/**
		 * 	@private
		 */
		private var shape:Shape				= new Shape();
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// buffer!
			buffer					= new DisplaySurface(context.width, context.height, true, 0x00);
			
			// add a listener for mouse down
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.RIGHT_CLICK,	handleInteraction);
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@private
		 */
		parameter function clear():void {
			
			// clear
			var graphics:Graphics	= shape.graphics;
			graphics.clear();
			graphics.lineStyle(thickness, color, alpha);
			
			// clear!
			buffer.fillRect(buffer.rect, 0x00);
			
			// set invalid to true, so that we'll redraw
			invalid = true;
		}
		
		/**
		 * 	@private
		 */
		private function handleInteraction(e:InteractionEvent):void {
			var graphics:Graphics	= shape.graphics;
			
			trace('xx', e);
			
			switch (e.type) {
				case InteractionEvent.RIGHT_CLICK:
					
					clear();
					
					break;
				case InteractionEvent.MOUSE_DOWN:
					
					context.addEventListener(InteractionEvent.MOUSE_MOVE, 		handleInteraction);
					context.addEventListener(InteractionEvent.MOUSE_UP,			handleInteraction);
					
					// move graphics
					graphics.moveTo(e.x, e.y );
					
					break;
				case InteractionEvent.MOUSE_MOVE:
					
					// move graphics
					graphics.lineTo(e.x, e.y);
					
					break;
				case InteractionEvent.MOUSE_UP:
					
					// draw the buffer
					buffer.drawWithQuality(shape, null, null, null, null, true, StageQuality.HIGH_8X8);
					
					// clear
					graphics.clear();
					graphics.lineStyle(thickness, color, lineAlpha);
					
					context.removeEventListener(InteractionEvent.MOUSE_MOVE,	handleInteraction);
					context.removeEventListener(InteractionEvent.MOUSE_UP,		handleInteraction);
					
					break;
			}
			
			invalid = true;
			
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			var graphics:Graphics	= shape.graphics;
			
			// set line style
			graphics.lineStyle(thickness, color, lineAlpha);
			
			// validate
			super.validate();
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {

			// only say we should be rendered if invalid
			return invalid;
		}

		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			// this is the same as a clear pretty much
			context.copyPixels(buffer);
			
			// draw the shape
			context.draw(shape, null, null, null, null, true, StageQuality.HIGH_8X8);
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			context.removeEventListener(InteractionEvent.RIGHT_CLICK,	handleInteraction);
			context.removeEventListener(InteractionEvent.MOUSE_DOWN,	handleInteraction);
			context.removeEventListener(InteractionEvent.MOUSE_MOVE,	handleInteraction);
			context.removeEventListener(InteractionEvent.MOUSE_UP,		handleInteraction);
			
			// dispose
			super.dispose();
			
		}
	}
}