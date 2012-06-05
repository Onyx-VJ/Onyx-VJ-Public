package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	final public class SpacePirate extends PluginPatchCPU {
		
		private var _shape1 : Shape;
		private var _shape2 : Shape;
		private var _container : Sprite;
		private var _theta : Number;
		private var _color : uint;
		private var _radius : Number;
		private var _cx : int;
		private var _cy : int;
			
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			Console.Log(Console.MESSAGE, 'Space Pirate Transmission from: http://wonderfl.net/c/f4H9');
			_shape1 = new Shape();
			_shape2 = new Shape();
			_container = new Sprite();
			_container.addChild(new Background());
			_container.addChild(_shape1);
			_container.addChild(_shape2);
			_container.filters = [new BlurFilter(0.0, 128.0, BitmapFilterQuality.MEDIUM), new GlowFilter(0xFF8040)];
			
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
			
			draw(_shape1.graphics, _radius / 12, _theta);
			draw(_shape2.graphics, _radius / 10, _theta);
			
			// draw the shape
			context.draw(_container, null, null, null, null, true, StageQuality.HIGH_8X8);
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
import flash.display.*;
import flash.events.Event;
import flash.geom.Matrix;

internal final class Background extends Shape {
	private const _colors : Array = [0x999999, 0x000000];
	private const _alphas : Array = [1.0, 1.0];
	private const _ratios : Array = [0, 255];
	private var _matrix : Matrix;
	
	public function Background() {
		_matrix = new Matrix();
		
	}
	
	public function onResize(e : Event) : void {
		var sw : Number = 640;
		var sh : Number = 480;
		
		_matrix.createGradientBox(sw, sh, Math.PI);
		graphics.clear();
		graphics.beginGradientFill(GradientType.RADIAL, _colors, _alphas, _ratios, _matrix);
		graphics.drawRect(0, 0, sw, sh);
		graphics.endFill();
	}
}