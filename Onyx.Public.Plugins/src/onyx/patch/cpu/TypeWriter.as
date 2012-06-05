
package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;

	
	use namespace parameter;
	
	[Parameter(type='color',		id='color', 		target='format/color')]
	[Parameter(type='number',		id='size', 			target='format/size',	clamp='6,350')]
	[Parameter(type='font',			id='font', 			target='format/font')]
	[Parameter(type='boolean',		id='embedFonts', 	target='label/embedFonts')]
	[Parameter(type='text',			id='text', 			target='text')]
	[Parameter(type='function',		id='start',			target='start')]
	final public class TypeWriter extends PluginPatchTransformCPU {
		
		/**
		 * 	@private
		 */
		parameter var size:int			= 40;
				
		/**
		 * 	@private
		 */
		parameter var text:String		= '';
		
		/**
		 * 	@private
		 */
		parameter const label:TextField		= new TextField();
		
		/**
		 * 	@private
		 */
		parameter const format:TextFormat	= new TextFormat(null, 28, 0xFFFFFF);
		
		/**
		 * 	@private
		 */
		private var timer:Timer		= new Timer(120);
		
		/**
		 * 	@private
		 */
		private var typeIndex:int			= 0;
		
		/**
		 * 	@private
		 */
		private var container : Sprite;
		

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			container = new Sprite();
		
			container.addChild(label);
			
			label.autoSize			= TextFieldAutoSize.LEFT;
			label.antiAliasType		= AntiAliasType.ADVANCED;
			label.text				= '';
			label.defaultTextFormat	= format;
			label.embedFonts		= true;
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			label.setTextFormat(format);
			label.defaultTextFormat = format;
				
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
			
			// draw the shape
			context.clear();
			context.draw(label, renderMatrix, null, null, null, true, StageQuality.HIGH_8X8);
			
			// return
			return true;
		}

		
		/**
		 * 	@private
		 */
		parameter function start():void {
			
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			typeIndex = 0;
			
			// set invalid to true, so that we'll redraw
			invalid = true;
		}	
		
		/**
		 * 	@private
		 */		
		private function onTimer(event:TimerEvent):void {
			
			label.text = text.substr(0, ++typeIndex);
			
			// set invalid to true, so that we'll redraw
			invalid = true;
			
			if (typeIndex >= text.length) {
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.stop();
			}
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			
			// dispose
			super.dispose();
			
		}
	}
}