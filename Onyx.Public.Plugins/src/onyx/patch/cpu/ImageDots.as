/**
 * Copyright bradsedito ( http://wonderfl.net/user/bradsedito )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/vr0s
 */

// forked from bongiovi015's flash on 2011-9-8

package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	import onyx.util.tween.*;
	
	use namespace parameter;
	
	[Parameter(type='text',				id='dotstext',		target='dotstext')]
	[Parameter(type='integer',			id='mx', 			target='mx', 	clamp='0,2000', 	reset='320')]
	[Parameter(type='integer',			id='my', 			target='my', 	clamp='0,2000', 	reset='240')]
	final public class ImageDots extends PluginPatchCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var mx:int = 320;
		
		/**
		 * 	@parameter
		 */
		parameter var my:int = 240;
		
		/**
		 * 	@parameter
		 */
		parameter var dotstext:String = "Batchass";	
		
		public const CIRCLE_SIZE : int = 4;
		public const MAX_DISPLACE : int = 800;
		public var W:int;
		public var H:int;
		//public var loaderImage : Loader = new Loader;
		private var bmpdText:BitmapData;
		private var bmpdPerlin:BitmapData;
		private var spMask:Sprite = new Sprite;
		private var particles:Array = [];
		private var isOpen:Boolean = true;
		private var bmp:Bitmap;
		
		public var seed:int = Math.floor(Math.random() * 0xFFFF);
		public var offset:Array = [new Point, new Point];
		public var perlinOffset : Number = MAX_DISPLACE;
		private var bmpd:BitmapData;
		private var sprite:Sprite;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			Console.Log(Console.MESSAGE,'ImageDots v 0.0.1');
			Console.Log(Console.MESSAGE,'Adapted by Bruce LANE (http://www.batchass.fr)');
			
			sprite = new Sprite();

			var mtx:Matrix = new Matrix;
			mtx.createGradientBox(context.width, context.height);
			graphics.beginGradientFill(GradientType.RADIAL, [0x333333, 0x111111], [1, 1], [0, 255], mtx);
			graphics.drawRect(0, 0, context.width, context.height);
			graphics.endFill();
			
			bmpd = new AssetForImageDots();
			
			bmp = new Bitmap(bmpd);
			sprite.addChild(bmp);
			_createText();
			W = bmpdText.width;
			H = bmpdText.height;
			spMask.x = (context.width - W) * .5;
			spMask.y = (context.height - H) * .5;
			bmpdPerlin = new BitmapData(W/2, H/2, false);
			_createParticles();
			
			sprite.addChild(spMask);
			bmp.mask = spMask;
			
			// add a listener for mouse events
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);

			// success
			return super.initialize(context, channel, path, content);
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
					sprite.x = mx;
					sprite.y = my;
					
					
					const duration : Number = 3;
					if(isOpen) {
						perlinOffset = 1;
						//Tweener.addTween(this, {time:duration, transition:"easeOutCubic", perlinOffset:1});
						/*Tween.Create(duration, function(ratio:Number, currentTime:int, length:int):void {
							
							var data:Object					= this.data;
							var generator:IPluginGenerator	= data.generator;
							
							for (var i:String in data.end) {
								var endValue:Number		= data.end[i];
								var startValue:Number	= data.start[i];
								var easing:Function		= Easing.sine.easeIn;
								generator.setParameterValue(i, easing(currentTime, startValue, (endValue - startValue), length));
							}
						}, {
							'generator':	generator,
							'start':		{
								'perlinOffset':		perlinOffset
							},
							'end':	{
								'perlinOffset':		1
							}
						});*/
					}
					else {
						perlinOffset = MAX_DISPLACE;
						//Tweener.addTween(this, {time:duration/2, transition:"easeInCubic", perlinOffset:MAX_DISPLACE});
					}
					
					isOpen = !isOpen;

					
					break;
			}
			
			invalid = true;
			
		}			
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			sprite.x = mx;
			sprite.y = my;
			_createText();
			_createParticles();	
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
			
			bmpdPerlin.perlinNoise(W/2, H/2, 4, seed, false, true, 7, false, offset);
			spMask.graphics.clear();
			
			for each(var p:Particle in particles) {
				spMask.graphics.beginFill(0xFFFFFF, 1);
				var tx:Number = p.x;
				var ty:Number = p.y;
				var color:uint = bmpdPerlin.getPixel(tx/2, ty/2);
				var r:Number = ((color >> 16 & 0xFF) / 0xFF - .5) * perlinOffset;
				var g:Number = ((color >> 8 & 0xFF) / 0xFF - .5) * perlinOffset;
				var b:Number = Math.floor((color & 0xFF) / 0xFF * 100) / 100;
				b = Math.pow(b, 2);
				tx += r*2;
				ty += g*3;
				spMask.graphics.drawCircle(tx, ty, CIRCLE_SIZE * b * (1 - perlinOffset / MAX_DISPLACE) * 2);                    
				spMask.graphics.endFill();
			}
			
			
			const SPEED:int = 2;
			offset[0].x += SPEED;
			offset[1].y += SPEED;
			
			// draw the shape
			context.draw(sprite);
			
			// return
			return true;
		}
		private function _createParticles():void 
		{
			var i:int;
			var j:int;
			particles = [];
			
			for(j=0;j<H; j+=CIRCLE_SIZE/2) 
			{
				for(i=0;i<W; i+=CIRCLE_SIZE/2) 
				{
					var color:uint = bmpdText.getPixel32(i, j);
					if( (color >> 24 & 0xFF) > 0x1F) {
						var p:Particle = new Particle;
						p.x = i;
						p.y = j;
						//p.z = k;
						particles.push(p);
					} 					
				}                
			}
		}
		
		private function _createText():void {
			var tf:TextField = new TextField;
			var format:TextFormat = new TextFormat("Arial Black", 60, 0xFFFFFF);
			tf.defaultTextFormat = format;
			tf.text = dotstext;
			tf.autoSize = "left";
			bmpdText = new BitmapData(tf.width + 20, tf.height + 20, true, 0);
			bmpdText.draw(tf);
		}		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			context.removeEventListener(InteractionEvent.MOUSE_DOWN,	handleInteraction);

			// dispose
			super.dispose();
			
		}
	}
}

class Particle 
{
	public var x : Number = 0;
	public var y : Number = 0;
	public var z : Number = 0;
	
	public function Particle():void 
	{ 
		
	}
}
