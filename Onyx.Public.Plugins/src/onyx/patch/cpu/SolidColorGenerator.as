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
	
	[Parameter(type='color', id='color', target='color')]
	
	final public class SolidColorGenerator extends PluginPatchCPU {
		
		/**
		 * 	@private
		 */
		parameter const contentTransform:ContentTransform		= new ContentTransform();
		
		/**
		 * 	@private
		 */
		parameter var color:uint;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// success
			return super.initialize(context, path, content);
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
			
			// clear!
			context.clear(0xFF << 24 | color);
			
			// return
			return true;
		}
	}
}