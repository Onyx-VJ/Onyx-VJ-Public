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
	[Parameter(type='integer',			id='xeclipse', 			target='xeclipse', 			clamp='0,2000', 	reset='1')]
	[Parameter(type='integer',			id='yeclipse', 			target='yeclipse', 			clamp='0,2000', 	reset='1')]
	final public class Eclipse extends PluginPatchCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var xeclipse:int				= 1;

		/**
		 * 	@parameter
		 */
		parameter var yeclipse:int				= 1;

		/**
		 * 	@private
		 */
		parameter var colorTransform:ColorTransform	= new ColorTransform(1,1,1,1);
		
		private var eclipse:FlareCircle;
		private var sprite:Sprite;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			xeclipse = context.width/2;
			yeclipse = context.height/2;
			
			sprite = new Sprite();
			var rect:Rectangle = new Rectangle(0, 0, 400, 400);
			eclipse = new FlareCircle(rect, 140);
			sprite.addChild(eclipse);
			eclipse.x = xeclipse;
			eclipse.y = yeclipse;
			eclipse.start();

			// success
			return super.initialize(context, channel, path, content);
		}

		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			eclipse.x = xeclipse;
			eclipse.y = yeclipse;				
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
			
				
			// draw the sprite
			context.draw( sprite, null, colorTransform );

			// return
			return true;
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

//////////////////////////////////////////////////
// FlareCircleã‚¯ãƒ©ã‚¹
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import flash.display.Shape;
import flash.geom.Rectangle;

class FlareCircle extends Sprite {
	private var rect:Rectangle;
	private var radius:uint;
	private var shape:Shape;
	private var flare:FlareMap;
	private var detection:DetectPixels;
	
	public function FlareCircle(area:Rectangle, r:uint) {
		rect = area;
		radius = r;
		init();
	}
	
	private function init():void {
		shape = new Shape();
		shape.graphics.lineStyle(8, 0xFFFFFF, 0.5);
		shape.graphics.drawCircle(rect.width/2, rect.height/2, radius);
		//addChild(shape);
		shape.x = rect.x;
		shape.y = rect.y;
		flare = new FlareMap(rect);
		addChild(flare);
		flare.x = rect.x + rect.width/2;
		flare.y = rect.y + rect.height/2;
		detection = new DetectPixels(2);
		detection.search(shape, rect, 0x66FFFFFF);
		flare.map = detection.pixels();
		flare.setup(60);
		flare.addEventListener(Event.COMPLETE, complete, false, 0, true);
		//flare.start();
	}
	public function start():void {
		flare.start();
	}
	public function stop():void {
		flare.stop();
	}
	private function complete(evt:Event):void {
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
}


//////////////////////////////////////////////////
// FlareMapã‚¯ãƒ©ã‚¹
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.display.BlendMode;
//import sketchbook.colors.ColorUtil;

class FlareMap extends Sprite {
	private var rect:Rectangle;
	private var fire:Rectangle;
	private var flare:BitmapData;
	private var bitmapData:BitmapData;
	private var bitmap:Bitmap;
	private var rPalette:Array;
	private var gPalette:Array;
	private var bPalette:Array;
	private static var point:Point = new Point(0, 0);
	private var speeds:Point = new Point(0, 0);
	private static var unit:uint = 2;
	private var segments:uint = 8;
	private var blur:BlurFilter;
	private var maps:Array;
	public var offset:Object = {x: 0, y: 0};
	private var faded:uint = 0;
	public static const COMPLETE:String = Event.COMPLETE;
	
	public function FlareMap(r:Rectangle) {
		rect = r;
		initialize();
		draw();
	}
	
	public function setup(seg:uint = 8):void {
		segments = seg;
	}
	public function set map(list:Array):void {
		maps = list;
	}
	private function initialize():void {
		rPalette = new Array();
		gPalette = new Array();
		bPalette = new Array();
		for (var n:uint = 0; n < 256; n++) {
			var luminance:uint = (n < 128) ? n*2 : 0;
			//var rgb:Object = ColorUtil.HLS2RGB(n*360/256, luminance, 100);
			var rgb:Object = HLS2RGB(n*360/256, luminance, 100);
			var color:uint = rgb.r << 16 | rgb.g << 8 | rgb.b;
			rPalette[n] = color;
			gPalette[n] = 0;
			bPalette[n] = 0;
		}
		blur = new BlurFilter(4, 4, 3);
		blendMode = BlendMode.ADD;
	}
	private function draw():void {
		fire = new Rectangle(0, 0, rect.width, rect.height);
		flare = new BitmapData(fire.width, fire.height, false, 0xFF000000);
		bitmapData = new BitmapData(rect.width, rect.height, true, 0xFF000000);
		bitmap = new Bitmap(bitmapData);
		addChild(bitmap);
		bitmap.x = - rect.width/2;
		bitmap.y = - rect.height/2;
	}
	public function start():void {
		addEventListener(Event.ENTER_FRAME, update, false, 0, true);
	}
	public function stop():void {
		removeEventListener(Event.ENTER_FRAME, update);
		faded = 0;
		addEventListener(Event.ENTER_FRAME, clear, false, 0, true);
	}
	private function update(evt:Event):void {
		if (!maps) return;
		flare.lock();
		bitmapData.lock();
		for (var n:uint = 0; n < segments; n++) {
			var id:uint = Math.random()*maps.length;
			var px:int = maps[id].x + offset.x;
			var py:int = maps[id].y + offset.y;
			var range:Rectangle = new Rectangle(px, py, unit, unit)
			flare.fillRect(range, 0xFFFFFF);
		}
		flare.applyFilter(flare, fire, speeds, blur);
		bitmapData.paletteMap(flare, rect, point, rPalette, gPalette, bPalette);
		flare.unlock();
		bitmapData.unlock();
	}
	private function clear(evt:Event):void {
		faded ++;
		flare.lock();
		bitmapData.lock();
		flare.applyFilter(flare, fire, speeds, blur);
		bitmapData.paletteMap(flare, rect, point, rPalette, gPalette, bPalette);
		if (faded > 20) {
			bitmapData.fillRect(rect, 0x000000);
			removeEventListener(Event.ENTER_FRAME, clear);
			dispatchEvent(new Event(FlareMap.COMPLETE));
		}
		flare.unlock();
		bitmapData.unlock();
	}
	private function HLS2RGB(h:Number, l:Number, s:Number):Object{
		var max:Number;
		var min:Number;
		h = (h < 0)? h % 360+360 : (h>=360)? h%360: h;
		l = (l < 0)? 0 : (l > 100)? 100 : l;
		s = (s < 0)? 0 : (s > 100)? 100 : s;
		l *= 0.01;
		s *= 0.01;
		if (s == 0) {
			var val:Number = l*255;
			return {r:val, g:val, b:val};
		}
		if (l < 0.5) {
			max = l*(1 + s)*255;
		} else {
			max = (l*(1 - s) + s)*255;
		}
		min = (2*l)*255 - max;
		return _hMinMax2RGB(h, min, max);
	}
	private function _hMinMax2RGB(h:Number, min:Number, max:Number):Object{
		var r:Number;
		var g:Number;
		var b:Number;
		var area:Number = Math.floor(h/60);
		switch(area){
			case 0:
				r = max;
				g = min + h * (max - min)/60;
				b = min;
				break;
			case 1:
				r = max - (h - 60)*(max - min)/60;
				g = max;
				b = min;
				break;
			case 2:
				r = min ;
				g = max;
				b = min + (h - 120)*(max - min)/60;
				break;
			case 3:
				r = min;
				g = max - (h - 180)*(max - min)/60;
				b =max;
				break;
			case 4:
				r = min + (h - 240)*(max - min)/60;
				g = min;
				b = max;
				break;
			case 5:
				r = max;
				g = min;
				b = max - (h - 300)*(max - min)/60;
				break;
			case 6:
				r = max;
				g = min + h*(max - min)/60;
				b = min;
				break;
		}
		r = Math.min(255, Math.max(0, Math.round(r)));
		g = Math.min(255, Math.max(0, Math.round(g)));
		b = Math.min(255, Math.max(0, Math.round(b)));
		return {r:r, g:g, b:b};
	}
	
}


//////////////////////////////////////////////////
// DetectPixelsã‚¯ãƒ©ã‚¹
//////////////////////////////////////////////////

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.display.IBitmapDrawable;

class DetectPixels {
	private var bd:IBitmapDrawable;
	private var rect:Rectangle;
	private var map:BitmapData;
	private var mapList:Array;
	private var accuracy:uint;
	private var threshold:uint = 0x80FFFFFF;
	private var offset:Object = {x: 0, y: 0};
	
	public function DetectPixels(a:uint = 1) {
		accuracy = a;
	}
	
	public function search(t:IBitmapDrawable, r:Rectangle, th:uint = 0x80FFFFFF, o:Object = null):void {
		bd = t;
		rect = r;
		threshold = th;
		if (o) offset = o;
		var w:uint = rect.width/accuracy;
		var h:uint = rect.height/accuracy;
		detect(w, h);
	}
	private function detect(w:uint, h:uint):void {
		map = new BitmapData(w, h, true, 0x00000000);
		var matrix:Matrix = new Matrix();
		matrix.translate(-rect.x, -rect.y);
		matrix.scale(1/accuracy, 1/accuracy);
		map.lock();
		map.draw(bd, matrix);
		map.unlock();
		mapList = new Array();
		for (var x:uint = 0; x < w; x++) {
			for (var y:uint = 0; y < h; y++) {
				var color:uint = map.getPixel32(x, y);
				if (color >= threshold) {
					var px:int = x*accuracy + rect.x + offset.x;
					var py:int = y*accuracy + rect.y + offset.y;
					var point:Point = new Point(px, py);
					mapList.push(point);
				}
			}
		}
	}
	public function pixels():Array {
		return mapList;
	}
	
}


//////////////////////////////////////////////////
// PerlinNoiseã‚¯ãƒ©ã‚¹
//////////////////////////////////////////////////

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

class PerlinNoise extends BitmapData {
	private var bx:uint;
	private var by:uint;
	private var octaves:uint;
	private var seed:uint;
	private var stitch:Boolean = true;
	private var fractalNoise:Boolean = true;
	private var channel:uint = 0;
	private var grayScale:Boolean = true;
	private var offsets:Array = new Array();
	
	public function PerlinNoise(rect:Rectangle, x:uint, y:uint, o:uint = 1, g:Boolean = true, c:uint = 0, s:uint = 1, st:Boolean = false, f:Boolean = true) {
		super(rect.width, rect.height, false, 0xFF000000);
		bx = x;
		by = y;
		octaves = o;
		grayScale = g;
		channel = c;
		if (grayScale) channel = 0;
		for (var n:uint = 0; n < octaves; n++) {
			var point:Point = new Point();
			offsets.push(point);
		}
		stitch = st;
		fractalNoise = f;
		create(s, offsets);
	}
	
	private function create(s:uint, o:Array = null):void {
		seed = s;
		offsets = o;
		if (offsets == null) offsets = [new Point()];
		lock();
		perlinNoise(bx, by, octaves, seed, stitch, fractalNoise, channel, grayScale, offsets);
		draw(this);
		unlock();
	}
	public function update(speeds:Array):void {
		for (var n:uint = 0; n < octaves; n++) {
			var offset:Point = offsets[n];
			var speed:Point = speeds[n];
			offset.x += speed.x;
			offset.y += speed.y;
		}
		lock();
		perlinNoise(bx, by, octaves, seed, stitch, fractalNoise, channel, grayScale, offsets);
		draw(this);
		unlock();
	}
	
}


