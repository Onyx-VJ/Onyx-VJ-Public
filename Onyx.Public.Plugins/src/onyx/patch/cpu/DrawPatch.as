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
	
	[Parameter(type='color',	id='color',			target='color')]
	[Parameter(type='number',	id='alpha',			target='alpha')]
	[Parameter(type='number',	id='thickness',		target='thickness', clamp='1,100')]
	[Parameter(type='function',	id='clear',			target='clear')]
	
	final public class DrawPatch extends PluginPatch {
		
		/**
		 * 	@private
		 */
		parameter var color:uint			= 0xFFFFFF;
		
		/**
		 * 	@private
		 */
		parameter var alpha:Number			= 1.0;
		
		/**
		 * 	@private
		 */
		parameter var thickness:Number		= 5.0;
		
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
		override public function initialize(context:IDisplayContext, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// buffer!
			// buffer					= new BitmapData(context.width, context.height, true, 0x00);
			
			// add a listener for mouse down
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.RIGHT_CLICK,	handleInteraction);
			
			// success
			return super.initialize(context, path, content);
		}
		
		/**
		 * 	@private
		 */
		parameter function clear():void {
			
			// clear
			var graphics:Graphics	= shape.graphics;
			graphics.clear();
			graphics.lineStyle(thickness, color, alpha);
			
			// set invalid to true, so that we'll redraw
			invalid = true;
		}
		
		/**
		 * 	@private
		 */
		private function handleInteraction(e:InteractionEvent):void {
			var graphics:Graphics	= shape.graphics;
			
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
			graphics.lineStyle(thickness, color, alpha);
			
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
		override public function render(surface:IDisplaySurface):Boolean {
			
			// invalid?
			if (invalid) {
				
				// validate the everything
				validate();

			}
			
			// draw this!
			surface.fillRect(surface.rect, 0x00);
			
			// draw
			surface.draw(shape, null, null, null, null, true);
			
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