/**
 * Copyright ile ( http://wonderfl.net/user/ile )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/h4en
 */

package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;	
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='colorTransform',	id='colorTransform',	target='colorTransform',	channels='argb')]
	final public class ForceField extends PluginPatchCPU {
		
		/**
		 * 	@private
		 */
		parameter var colorTransform:ColorTransform	= new ColorTransform(1,0.33,0.12,1);
		
		private var mx:int = 320;
		private var my:int = 240;
		
		private static const ZERO_POINT:Point = new Point();
		
		private static const MAP_SCALE:Number = 0.25;
		private static const TRAIL_SCALE:Number = 2;
		private static const DRAW_SCALE:Number = 0.5;
		
		private var _timer:Timer;
		private var _seed:Number = Math.random();
		private var _offsets:Array = [new Point(), new Point()];
		private var _forcemap:BitmapData;
		private var _count:int = 0;
		
		private var _particles:Vector.<Particle>;
		private var _canvas:Shape;
		private var _fade:BitmapData;
		private var _darken:ColorMatrixFilter = new ColorMatrixFilter([
			1, 0, 0, 0, -2,
			0, 1, 0, 0, -2,
			0, 0, 1, 0, -2,
			0, 0, 0, 1, 0
		]);
		private var _blur:BlurFilter = new BlurFilter(2, 2, 1);
		
		private var _drawMatrix:Matrix = new Matrix(DRAW_SCALE, 0, 0, DRAW_SCALE, 0, 0);
		private var _drawColor:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		private var sprite:Sprite;
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			sprite = new Sprite();
			_timer = new Timer(500, 0);
			_timer.addEventListener(TimerEvent.TIMER, _onTimer);
			_timer.start();
			_forcemap = new BitmapData(context.width * MAP_SCALE, context.height * MAP_SCALE, true, 0x0);
			//addChild(new Bitmap(_forcemap));
			
			_particles = new Vector.<Particle>();
			
			_fade = new BitmapData(context.width * DRAW_SCALE, context.height * DRAW_SCALE, true, 0x0);
			var bm:Bitmap = sprite.addChild(new Bitmap(_fade, PixelSnapping.AUTO, true)) as Bitmap;
			bm.scaleX = bm.scaleY = 1 / DRAW_SCALE;
			
			_canvas = addChild(new Shape()) as Shape;
			_canvas.blendMode = BlendMode.ADD;			
			// add a listener for mouse events
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.MOUSE_MOVE, 	handleInteraction);

			// success
			return super.initialize(context, channel, path, content);
		}
		private function _onTimer(e:TimerEvent = null):void
		{
			var t:int = getTimer();
			_offsets[0].x = t / 20;
			_offsets[1].y = t / 35;
			_forcemap.perlinNoise(150, 150, 2, _seed, true, true, 3, false, _offsets);
		}
		/**
		 * 	@private
		 */
		private function handleInteraction(e:InteractionEvent):void {
			
			switch (e.type) {
				case InteractionEvent.MOUSE_DOWN:
					
					// move graphics
					mx = e.x;
					my = e.y;
					
					break;
				case InteractionEvent.MOUSE_MOVE:
					
					// move graphics
					mx = e.x;
					my = e.y;
					
					break;
			}
			
			invalid = true;
			
		}		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			for (var i:String in invalidParameters) {
				switch (i) {
					
					case 'colorTransform':
						
						//trace( colorTransform.redMultiplier);
						
						break;
				}
			}			
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
			
			var n:int = 10;
			while (n--) {
				var a:Number = getTimer() / 1000 + Math.random() * Math.PI;
				//color.h = (getTimer() / 20000) * 360;
				var p:Particle = new Particle(mx, my, Math.cos(a), Math.sin(a), 0xFFFFFF);
				_particles.push(p);
			}
			
			var g:Graphics = _canvas.graphics;
			g.clear();
			
			n = _particles.length;
			while (n--) {
				p = _particles[n];
				var c:uint = _forcemap.getPixel(p.x * MAP_SCALE, p.y * MAP_SCALE);
				p.vx += (((c >> 16) & 0xff) - 0x80) / 0x80 * 0.3;
				p.vy += (((c >> 8) & 0xff) - 0x80) / 0x80 * 0.3;
				p.x += p.vx;
				p.y += p.vy;
				p.life -= 0.005;
				if (p.life < 0 || p.x < -10 || p.x > context.width || p.y < -10 || p.y > context.height) {
					_particles.splice(n, 1);
				} else {
					g.lineStyle(0, p.color, 0.5 * p.life);
					g.moveTo(p.x, p.y);
					g.lineTo(p.x - (p.x - p.px) * TRAIL_SCALE, p.y - (p.y - p.py) * TRAIL_SCALE);
					p.px = p.x;
					p.py = p.y;
				}
			}
			
			if (_count & 1) {
				_fade.lock();
				_fade.draw(_canvas, _drawMatrix, _drawColor, BlendMode.ADD);
				_fade.applyFilter(_fade, _fade.rect, ZERO_POINT, _blur);
				_fade.unlock();
			}
			if (_count & 0x4) {
				_onTimer();
			}
			_count++;		
			// draw the sprite
			context.draw( sprite, null, colorTransform );

			// return
			return true;
		}

		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			context.removeEventListener(InteractionEvent.MOUSE_DOWN,	handleInteraction);
			context.removeEventListener(InteractionEvent.MOUSE_MOVE,	handleInteraction);
		
			// dispose
			super.dispose();
			
		}
	}
}

class Particle {
	public var x:Number = 0;
	public var y:Number = 0;
	public var px:Number = 0;
	public var py:Number = 0;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var life:Number = 1;
	public var color:uint = 0xffffff;
	public function Particle(x:Number = 0, y:Number = 0, vx:Number = 0, vy:Number = 0, color:uint = 0xffffff) {
		this.x = this.px = x;
		this.y = this.py = y;
		this.vx = vx;
		this.vy = vy;
		this.color = color;
	}
}