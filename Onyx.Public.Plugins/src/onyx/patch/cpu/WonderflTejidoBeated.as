/**
 * Copyright aobyrne ( http://wonderfl.net/user/aobyrne )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/2lP7
 */

package onyx.patch.cpu
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;

	public class WonderflTejidoBeated extends PluginPatchCPU 
	{
		static private const GOLDEN_RATIO:Number = 0.618;
		private var tejidoGrid:TejidoGrid;
		private var elementWidth:Number;
		private var gridWidth:int;
		private var gridHeight:int;
		private var isRandom:Boolean;
		private var isTransforming:Boolean;
		private var perlinNoiseOffset:uint;
		private var pnOffsetPoint:Point;
		private var textTransformationMatrix:Matrix;
		private var bgSprite:Sprite;
		//private var _container : Sprite;

		/**
		 * 	@private
		 */
		//private var buffer:BitmapData;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			gridWidth				= context.width;
			gridHeight				= context.height;	
			// buffer!
			//buffer					= new DisplaySurface(context.width, context.height, true, 0x00);
			
			//_container = new Sprite();
			graphics.lineStyle(0);
			
			elementWidth = 22;
			isRandom = true;
			isTransforming = true;
			
			
			resetTejidoGrid();
			
			var number:Number = 2;
			
			bgSprite = new Sprite;
			//_container.addChild(bgSprite);
			new Beated(bgSprite);
			tejidoGrid.bitmapData.draw(bgSprite);
			bgSprite.visible = false;
			
			tejidoGrid.draw(graphics,isTransforming);
			//_container.addChild(tejidoGrid);
			pnOffsetPoint = new Point(perlinNoiseOffset, 0);  
		
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
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
		
			/*if (isRandom) 
			{*/
				var bmd:BitmapData = tejidoGrid.bitmapData;
				perlinNoiseOffset += 10;
				bmd.lock();
				pnOffsetPoint.x=perlinNoiseOffset;

				bmd.fillRect(bmd.rect, 0xff000000);
				bmd.draw(bgSprite);
				clearGraphics();
				tejidoGrid.draw(graphics, isTransforming);
				bmd.unlock();
			//}
			// this is the same as a clear pretty much
			context.copyPixels(bmd);
			
			// return
			return true;
		}
		
		private function onTransform(e:Event):void 
		{
			isTransforming = true;//false
			clearGraphics();
			tejidoGrid.draw(graphics, isTransforming);

		}
		
		
		
		private function onRandom(e:Event):void 
		{
			clearGraphics();
			isRandom= tejidoGrid.isRandomRatio = true;
			tejidoGrid.draw(graphics, isTransforming);

		}
		
		private function onSize(e:Event):void 
		{
			clearGraphics();
			elementWidth = 25;
			resetTejidoGrid();
		}
		
		private function onRatio(e:Event):void 
		{
			clearGraphics();
			tejidoGrid.ratio = 2;
			tejidoGrid.draw(graphics, isTransforming);
		}
		
		private function resetTejidoGrid():void 
		{
			var elementHeight:Number = GOLDEN_RATIO * elementWidth;
			var separation:Number = elementHeight * 0.5 + elementWidth * 0.5;

			var columns:int = Math.ceil(gridWidth / separation);
			columns = columns % 2 ? columns + 1:columns;
			var rows:int = Math.ceil(gridHeight / separation);
			rows++;
			var totalElements:int = columns * rows;
			if (!tejidoGrid) 
			{
				tejidoGrid = new TejidoGrid(columns, totalElements, elementWidth, elementHeight, 0.2,[0x00,0x555555],isRandom);
			}
			else
			{
				tejidoGrid.colsAmount = columns;
				tejidoGrid.totalAmount = totalElements;
				tejidoGrid.eWidth = elementWidth;
				tejidoGrid.eHeight = elementHeight;
				tejidoGrid.draw(graphics,isTransforming)
			}
		}
		
		private function clearGraphics():void 
		{
			graphics.clear();
			graphics.lineStyle(0);
		}
		
	}
	
}
import flash.display.BitmapData;
import flash.display.Graphics;
class TejidoGrid 
{
	private var _colsAmount:uint;
	private var _totalAmount:uint;
	private var _eWidth:Number;
	private var _eHeight:Number;
	private var separation:Number;
	private var _ratio:Number;
	private var colors:Array;
	public var bitmapData:BitmapData;
	private var _isRandomRatio:Boolean;
	private var rowsAmount:uint;
	
	public function TejidoGrid(colsAmount:uint, totalAmount:uint, width:Number, height:Number, ratio:Number, colors:Array,isRandomRatio:Boolean=false) 
	{
		this.isRandomRatio = isRandomRatio;
		this.colors = colors;
		this.ratio = ratio;
		this.eHeight = height;
		this.eWidth = width;
		this.totalAmount = totalAmount;
		this.colsAmount = colsAmount;
		setSeparation();
		rowsAmount = totalAmount / colsAmount;
		bitmapData = new BitmapData(colsAmount*separation, rowsAmount*separation);
		bitmapData.perlinNoise(50,50,1,1,false,true,1,true)
	}
	
	public function draw(g:Graphics, isTransforming:Boolean = true):void 
	{
		var orientation:Number;
		var actualRatio:Number;
		var yy:Number;
		var xx:uint;
		var fundamentalElement:FundamentalElement;
		for (var i:int = 0; i <= totalAmount; i++) 
		{
			yy = Math.floor(i / colsAmount);
			xx = uint(i % colsAmount);
			actualRatio = isTransforming?GaussianDistribution.getNormalizedValue(2 * xx / colsAmount - 1, 0, 0.25):ratio;
			actualRatio = isTransforming?GaussianDistribution.getNormalizedValueBivariate(2 * xx / colsAmount - 1, 2 * yy / rowsAmount - 1, 0, 0.25, 0, 0.25, 0):ratio;
			actualRatio = isRandomRatio?((bitmapData.getPixel(xx*separation, yy*separation) & 0xff) / 255):actualRatio;
			fundamentalElement = new FundamentalElement(separation * xx, separation * yy, eHeight, eWidth, actualRatio);
			orientation = (yy % 2 + i) % 2;
			g.beginFill(colors[orientation]);
			fundamentalElement.draw(g, orientation);			
		}
		g.beginFill(0, 0);
	}
	
	private function setSeparation():void 
	{
		separation = _eWidth * 0.5 + _eHeight * 0.5;
	}
	
	public function get ratio():Number 
	{
		return _ratio;
	}
	
	public function set ratio(value:Number):void 
	{
		_ratio = value;
	}
	
	public function get colsAmount():uint 
	{
		return _colsAmount;
	}
	
	public function set colsAmount(value:uint):void 
	{
		_colsAmount = value;
		setRows();
	}
	
	public function get totalAmount():uint 
	{
		return _totalAmount;
	}
	
	public function set totalAmount(value:uint):void 
	{
		_totalAmount = value;
		setRows();
	}
	
	private function setRows():void 
	{
		rowsAmount = _totalAmount / _colsAmount;
	}
	
	public function get eWidth():Number 
	{
		return _eWidth;
	}
	
	public function set eWidth(value:Number):void 
	{
		_eWidth = value;
		setSeparation();
	}
	
	public function get eHeight():Number 
	{
		return _eHeight;
	}
	
	public function set eHeight(value:Number):void 
	{
		_eHeight = value;
		setSeparation();
	}
	
	public function get isRandomRatio():Boolean 
	{
		return _isRandomRatio;
	}
	
	public function set isRandomRatio(value:Boolean):void 
	{
		_isRandomRatio = value;
	}
	
	
}

import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
class FundamentalElement 
{
	private var cx:Number;
	private var cy:Number;
	private var height:Number;
	private var width:Number;
	private var ratio:Number;
	private var AA:Point;
	private var BB:Point;
	private var matrix:Matrix;
	private var array:Array;
	
	public function FundamentalElement(cx:Number, cy:Number, height:Number, width:Number, ratio:Number) 
	{
		this.ratio = ratio;
		this.width = width;
		this.height = height;
		this.cy = cy;
		this.cx = cx;
		AA = new Point;
		BB = new Point;
		matrix = new Matrix;
		matrix.rotate(Math.PI * 0.5);
		
		doSet();
	}
	
	private function doSet():void 
	{
		AA.x = ratio * width * 0.5;
		AA.y = 0.5 * height;
		
		
		BB.x = 0.5 * width;
		array = [AA,BB,new Point(AA.x,-AA.y),new Point(-AA.x,-AA.y),new Point(-BB.x,BB.y),new Point(-AA.x,AA.y)];
	}
	
	public function draw(g:Graphics,isRotated:uint=0):void 
	{
		if (isRotated) 
		{
			for (var i:int = 0; i < array.length; i++) 
			{
				array[i] = matrix.transformPoint(array[i]);
			}
		}
		g.moveTo(cx + array[array.length-1].x, cy + array[array.length-1].y);
		for (var j:int = 0; j < array.length; j++) 
		{
			g.lineTo(cx+array[j].x, cy+array[j].y);
		}
	}
	
	
}
class SCMath
{
	static private var normalDistriutionFactor:Number = 1 / Math.sqrt(Math.PI * 2);
	static public function normalDistribution(x:Number, mu:Number, sigma:Number):Number
	{
		var s:Number = 1 / sigma;
		return s*normalDistriutionFactor*Math.pow(Math.E,-(x-mu)*(x-mu)*s*s*0.5);
	}
}
class GaussianDistribution 
{
	private var mu:Number;
	private var _sigma:Number;
	private var factor:Number;
	
	public function GaussianDistribution(mu:Number, sigma:Number) 
	{
		this.sigma = sigma;
		this.mu = mu;
		
		
	}
	
	public function getData():Array 
	{
		var gaussian:Number;
		var pow:Number;
		var xx:Number;
		var normal:Number;
		var steps:int = 100;
		var delta:Number = 1 / steps;
		var data:Array = [];
		var initxx:Number = -5;
		var finalxx:Number = 5;
		var size:Number = 10;
		size = finalxx > initxx?finalxx - initxx:initxx - finalxx;
		for (var i:int = 0; i < steps; i++) 
		{
			normal = i * delta;
			xx = size * (normal - 0.5);
			pow = -(xx - mu) * (xx - mu)/(2*sigma*sigma);
			gaussian = factor * Math.pow(Math.E, pow);
			data[i] = gaussian;
		}
		return data;
		
	}
	
	public static function getNormalizedValue(xx:Number, mu:Number, sigma:Number):Number
	{
		return getValue(xx, mu, sigma) / getValue(mu, mu, sigma);
	}
	public static function getValue(xx:Number, mu:Number, sigma:Number):Number
	{
		var gaussian:Number;
		var pow:Number;
		var s:Number = 1 / sigma;
		var factor:Number  = s / Math.sqrt(2 * Math.PI);
		pow = -(xx - mu) * (xx - mu)*s*s*0.5;            
		gaussian = factor * Math.pow(Math.E, pow);
		return gaussian
	}
	
	public function get sigma():Number 
	{
		return _sigma;
	}
	
	public function set sigma(value:Number):void 
	{
		_sigma = value;
		factor = 1 /( sigma * Math.sqrt(2 * Math.PI));
	}
	public static function getNormalizedValueBivariate(xx:Number, yy:Number, mux:Number, sigmax:Number, muy:Number, sigmay:Number, rho:Number):Number
	{
		return getBivariate(xx, yy, mux,sigmax,muy, sigmay, rho) / getBivariate(mux, muy, mux, sigmax, muy,sigmay, rho);
	}
	public static function getBivariate(xx:Number, yy:Number, mux:Number, sigmax:Number, muy:Number, sigmay:Number, rho:Number):Number
	{
		var s:Number = 1 / (sigmax * sigmay);
		var r:Number = 1 - rho * rho;
		var factor:Number = s / (2 * Math.PI * Math.sqrt(r));
		var dx:Number = xx - mux;
		var dy:Number = yy - muy;
		var sxy:Number = sigmax * sigmay;
		var squareBracket:Number = (dx * dx) / (sigmax * sigmax) + (dy * dy) / (sigmay * sigmay) - 2 * rho * (dx * dy) * s;
		var gaussian:Number = 0.5*s/(Math.PI*Math.sqrt(r))*Math.pow(Math.E, -0.5*squareBracket/r);
		return gaussian;
	}    
}

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;
import flash.media.SoundMixer;
import flash.net.URLRequest;
import flash.utils.ByteArray;

class Beated extends EventDispatcher 
{
	private var sprite:Sprite;
	private var cont:Sprite;
	private var strechFactor:int;
	private var urls:Array;
	private var hasInitialized:Boolean;
	private var sprites:Array;
	private const SPECTRUM_MAX:Number = 1 / 1.41;
	private var isDebugging:Boolean=true;
	
	
	public function Beated(sprite:Sprite) 
	{
		this.sprite = sprite;
		//urls = ['assets/realentada.mp3', 'assets/turkish.mp3'];
		urls = ['http://www.takasumi-nagai.com/soundfiles/sound007.mp3', 
			'http://www.takasumi-nagai.com/soundfiles/sound005.mp3'];
		var ul:uint = urls.length;
		var i:int = int(Math.random() * ul);
		trace( "i : " + i );
		new Sound(new URLRequest(urls[i])).addEventListener(Event.COMPLETE, oc);
		initSprites();
		init();
		//Style.setStyle(Style.DARK);
	}
	
	private function onOne(e:Event):void 
	{
		SoundMixer.stopAll();
		var ii:int = 1;
		new Sound(new URLRequest(urls[ii])).addEventListener(Event.COMPLETE, oc);
	}
	
	private function initSprites():void 
	{
		
	}
	
	private function oc(e:Event):void 
	{
		var sound:Sound = e.target as Sound;
		sound.removeEventListener(Event.COMPLETE, oc);
		sound.play();
		if (!hasInitialized)
		{
			sprite.addEventListener(Event.ENTER_FRAME, loop);
		}
		hasInitialized = true;
	}
	
	private function loop(e:Event):void 
	{
		var normalizedRatio:Number;
		var shape:Shape;
		var twoFiveSix:Number = 256;
		var min:Number=0;
		var max:Number=0;
		var rr:Number;
		var byteArray:ByteArray = new ByteArray;
		SoundMixer.computeSpectrum(byteArray,true,strechFactor);
		var bytesTotal:uint = byteArray.bytesAvailable;
		//trace( "bytesTotal : " + bytesTotal );
		var bytesPerFloatingPoint:int = 4;
		var floatingPointAmount:int = bytesTotal / bytesPerFloatingPoint;
		var floatingPointAmount2:int = floatingPointAmount / 2;
		//trace( "floatingPointAmount : " + floatingPointAmount );
		//trace( "byteArray.bytesAvailable : " + byteArray.bytesAvailable );
		var array:Array = [];
		
		for (var i:int = 0; i < floatingPointAmount2; i++) 
		{
			//trace( "i : " + i );
			rr = byteArray.readFloat();
			max = Math.max(max, rr);
			min = Math.max(min, rr);
			array[i] = rr;
			shape = sprites[i] as Shape;
			normalizedRatio = rr * SPECTRUM_MAX ;
			shape.scaleX = shape.scaleY = normalizedRatio * 2;
			//shape.alpha = normalizedRatio * normalizedRatio;
			shape.alpha = Math.sqrt(normalizedRatio);
		}
	}
	
	private function init():void 
	{
		var shape:Shape;
		var sq:Number = Math.sqrt(256);
		var five:Number = 512;
		var sq2:Number = sq/2;
		trace( "sq : " + sq );
		var twoFiveSix:Number = 256;
		var columnAmount:int = twoFiveSix / sq2;
		trace( "columnAmount : " + columnAmount );
		var size:Number = 465;
		cont = sprite.addChild(new Sprite) as Sprite;
		sprites = [];
		for (var i:int = 0; i < twoFiveSix; i++) 
		{
			shape = cont.addChild(new Shape) as Shape;
			var g:Graphics = shape.graphics;
			g.beginFill(0xff);
			shape.x = (i % 8) * 32
			shape.y = int(i / 8) * 32;
			shape.scaleX = 0; 
			shape.scaleY = 0;
			g.drawCircle(0, 0, 10);
			//g.drawCircle((i % 8) * 32, int(i / 8) * 32, 10);
			g.endFill();
			sprites[i] = shape;
		}
		if (sprite.parent && isDebugging) 
		{
			var followerModel:FollowerModel = new FollowerModel;
			followerModel.amount = 2;
			followerModel.sprite = sprite.parent as Sprite;
			followerModel.xx = 260;
			followerModel.autoScale = false;
			followerModel.minimum = 0;
			followerModel.maximum = 1;

		}
	}
	
	private function onStretch(e:Event):void 
	{

		strechFactor = 4;
		trace( "strechFactor : " + strechFactor );
		var p:Number = Math.pow(2, int(strechFactor));
		trace( "p : " + p );
		strechFactor = p;
	}
	
	private function draw():void 
	{
		
	}
	
}

import flash.display.Sprite;
class FollowerModel
{
	private var _fixedAmount:int;
	private var _xx:Number;
	private var _yy:Number;
	private var _name:String;
	private var _referencesx:Array;
	private var _referencesy:Array;
	private var _maximum:Number;
	private var _minimum:Number;
	private var _sprite:Sprite;
	private var _amount:int;
	private var _autoScale:Boolean;
	
	public function FollowerModel() 
	{
		super();
		xx = 0;
		yy = 0;
		name = 'defalut name';
		referencesx = [];
		referencesy = [];
		maximum = 1;
		minimum = 0;
		amount = 1;
		autoScale = true;
		fixedAmount = 100;
	}
	
	public function get xx():Number 
	{
		return _xx;
	}
	
	public function set xx(value:Number):void 
	{
		_xx = value;
	}
	
	public function get yy():Number 
	{
		return _yy;
	}
	
	public function set yy(value:Number):void 
	{
		_yy = value;
	}
	
	public function get name():String 
	{
		return _name;
	}
	
	public function set name(value:String):void 
	{
		_name = value;
	}
	
	public function get referencesx():Array 
	{
		return _referencesx;
	}
	
	public function set referencesx(value:Array):void 
	{
		_referencesx = value;
	}
	
	public function get referencesy():Array 
	{
		return _referencesy;
	}
	
	public function set referencesy(value:Array):void 
	{
		_referencesy = value;
	}
	
	public function get maximum():Number 
	{
		return _maximum;
	}
	
	public function set maximum(value:Number):void 
	{
		_maximum = value;
	}
	
	public function get minimum():Number 
	{
		return _minimum;
	}
	
	public function set minimum(value:Number):void 
	{
		_minimum = value;
	}
	
	public function get sprite():Sprite 
	{
		return _sprite;
	}
	
	public function set sprite(value:Sprite):void 
	{
		_sprite = value;
	}
	
	public function get amount():int 
	{
		return _amount;
	}
	
	public function set amount(value:int):void 
	{
		_amount = value;
	}
	
	public function get autoScale():Boolean 
	{
		return _autoScale;
	}
	
	public function set autoScale(value:Boolean):void 
	{
		_autoScale = value;
	}
	
	public function get fixedAmount():int 
	{
		return _fixedAmount;
	}
	
	public function set fixedAmount(value:int):void 
	{
		_fixedAmount = value;
	}
}
