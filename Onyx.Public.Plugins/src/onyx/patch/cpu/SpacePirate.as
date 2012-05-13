package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	final public class SpacePirate extends PluginPatchCPU {
		
		private var _shape : Shape;
		private var _theta : Number;
		private var _color : uint;
		private var _radius : Number;
		private var _cx : int;
		private var _cy : int;
			
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			_shape = new Shape();
			_shape.filters = [new BlurFilter(0.0, 128.0, BitmapFilterQuality.MEDIUM)];
			
			_color = 0xFFFFAA;
			_theta = 0.0;
			_cx = context.width >> 1;
			_cy = context.height >> 1;
			
			_radius = Math.sqrt(((_cx * _cx) + (_cy * _cy)) >> 2);
			
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			context.clear();
			
			_theta += Math.PI / 222;
			Console.Log(3, '_theta', _theta);
			
			draw(graphics, _radius / 12, _theta);
			draw(_shape.graphics, _radius / 10, _theta);
			
			// draw the shape
			context.draw(_shape, null, null, null, null, true, StageQuality.HIGH_8X8);
			//context.draw(_shape);
			
			// return
			return true;
		}
		private function draw(g : Graphics, thickness : Number, theta : Number) : void {
			g.clear();
			g.lineStyle(thickness, _color, 0.28);
			
			/* head */
			g.drawCircle(_cx, _cy, _radius / 2);
			
			/* bones */
			var ampX : Number = _radius * Math.cos(theta);
			var ampY : Number = _radius * Math.sin(theta);
			g.moveTo(_cx + ampX, _cy + ampY);
			g.lineTo(_cx - ampX, _cy - ampY);
			g.moveTo(_cx + ampX, _cy - ampY);
			g.lineTo(_cx - ampX, _cy + ampY);
		}
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// dispose
			super.dispose();		
		}
	}
}