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
	
	[Parameter(type='integer',			id='mx', 			target='mx', 	clamp='0,2000', 	reset='320')]
	[Parameter(type='integer',			id='my', 			target='my', 	clamp='0,2000', 	reset='240')]
	final public class Imagination extends PluginPatchCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var mx:int = 320;
		
		/**
		 * 	@parameter
		 */
		parameter var my:int = 240;
		

		
		// Main constants
		private const RED_STEP:Number = 0.02;
		private const GREEN_STEP:Number = 0.015;
		private const BLUE_STEP:Number = 0.025;
		private const MAX_LENGTH:int = 80;
		private const SPREAD_MIN:int = 1;
		private const SPREAD_MAX:int = 40;
		
		// Main variables
		
		private var list:Array;
		private var px:Number;
		private var py:Number;
		private var size:Number;
		private var spread:int;
		private var paused:Boolean;
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		private var lines:Shape;                
		private var bmp:Bitmap;
		private var blackBitmap:BitmapData;
		private var m:Matrix;
		private var p:Point;
		private var blur:BlurFilter;
		//private var _sourceBD:BitmapData = createDefaultBitmap();
		private var sprite:Sprite;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			Console.Log(Console.MESSAGE,'Imagination v 0.0.1');
			Console.Log(Console.MESSAGE,'Credits to Paul NEAVE (http://www.neave.com)');
			Console.Log(Console.MESSAGE,'Adapted by Bruce LANE (http://www.batchass.fr)');
			
			sprite = new Sprite();
		
			// add a listener for mouse events
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.MOUSE_MOVE, 	handleInteraction);
			context.addEventListener(InteractionEvent.MOUSE_UP, 	handleInteraction);

			list = new Array();
			px = py = size = 0;
			spread = SPREAD_MAX;
			paused = false;
			
			// Start using red
			red = 0;
			green = 255;
			blue = 255;
			
			// The main lines shape
			lines = new Shape();
			// Stage sizes
			var sw2:int = Math.ceil(context.width / 2);
			var sh2:int = Math.ceil(context.height / 2);
			
			// Create the main bitmap to draw into (and half the size to run faster)
			bmp = new Bitmap(new BitmapData(sw2, sh2, true, 0xFF000000));
			bmp.smoothing = true;
			bmp.scaleX = bmp.scaleY = 2;
			bmp.x = context.width / 2;
			bmp.y = context.height / 2;
			sprite.addChild(bmp);
			
			// Create bitmap data for fading into black
			blackBitmap = new BitmapData(sw2, sh2, true, 0xFF000000);
			
			// Bitmap is moved over into position then halved in size to run faster
			m = new Matrix();
			m.translate(-bmp.x, -bmp.y);
			m.scale(0.5, 0.5);
			
			// Origin and blur filter
			p = new Point(0, 0);
			blur = new BlurFilter(4, 4, 1);
			

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
			
			// Line movement is set by how much the mouse has moved since its previous position and a random value
			var dx:Number = (px - px + Math.random() * 4 - 2) / 2;
			var dy:Number = (py - py + Math.random() * 4 - 2) / 2;
			
			// Limit the amount of movement
			if (dx < -spread) dx = -spread;
			if (dx > spread) dx = spread;
			if (dy < -spread) dy = -spread;
			if (dy > spread) dy = spread;

			
			// Line thickness varies up and down with sine
			var s:Number = Math.sin(size += 0.2) * 8 + 4;
			
			// Put the red, green and blue values together into a single hexadecimal value
			var c:uint = (Math.sin(red += RED_STEP) * 128 + 127) << 16
				| (Math.sin(green += GREEN_STEP) * 128 + 127) << 8
				| (Math.sin(blue += BLUE_STEP) * 128 + 127);
			
			// Create a new point on the line
			list.push(new ImaginationPoint(px, py, dx, dy, s, c));
			
			// Draw!
			drawLines();
			drawBitmap();		
			// draw the shape
			context.draw(sprite);
			
			// return
			return true;
		}
		/**
		 * Draws the line animation
		 */
		private function drawLines():void
		{
			// Clear the graphics before we draw the lines
			var g:Graphics = lines.graphics;
			g.clear();
			g.moveTo(px, py);
			
			// Draw a curve through all points in the list
			for (var i:int = list.length - 1; i > 0; i--)
			{
				// Animate the lines outwards
				list[i].x += list[i].dx;
				list[i].y += list[i].dy;
				
				// Draw the curve, fading out the last 8 points with alpha
				g.lineStyle(list[i].size, list[i].color, (list.length > (MAX_LENGTH - 8) && i < 8) ? i / 8 : 1);
				g.curveTo(list[i].x, list[i].y, (list[i].x + list[i - 1].x) / 2, (list[i].y + list[i - 1].y) / 2);
				
				// Remove the last point from the list if we've reached the maximum length
				if (list.length > MAX_LENGTH) list.splice(0, 1);
			}
		}
		/**
		 * Draws the lines into the bitmap with a fade effect
		 */
		private function drawBitmap():void
		{
			// Repeatedly fade out and blur the lines then draw in the new ones
			var b:BitmapData = bmp.bitmapData;
			b.lock();
			b.merge(blackBitmap, b.rect, p, 4, 4, 4, 0);
			b.applyFilter(b, b.rect, p, blur);
			b.draw(lines, m, null, BlendMode.ADD);
			b.unlock();
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

final class ImaginationPoint
{
	// Position variables
	internal var x:Number;
	internal var y:Number;
	
	// Movement variables
	internal var dx:Number;
	internal var dy:Number;
	
	// Other variables
	internal var size:Number;
	internal var color:uint;
	
	/**
	 * Declares a 'Neave Imagination' point, a point with extra properties
	 *
	 * @param       x               The x position
	 * @param       y               The y position
	 * @param       dx              The movement in the x-axis
	 * @param       dy              The movement in the y-axis
	 * @param       size    The size of the line
	 * @param       color   The colour of the line
	 */
	public function ImaginationPoint(x:Number, y:Number, dx:Number, dy:Number, size:Number, color:uint)
	{
		this.x = x;
		this.y = y;
		this.dx = dx;
		this.dy = dy;
		this.size = size;
		this.color = color;
	}
}

