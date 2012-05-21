/**
 * Copyright George0rwell ( http://wonderfl.net/user/George0rwell )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/lLeD
 */

// forked from gyo's forked from: Painting
// forked from chutaicho's Painting
package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;
	import __AS3__.vec.Vector;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='channelCPU',	id='targetChannel', target='targetChannel')]
	
	final public class ChannelAbstractPainting extends PluginPatchTransformCPU {
		
		/**
		 * 	@private
		 */
		parameter var targetChannel:IChannel;
		
		/**
		 * 	@private
		 */
		private var listenChannel:IChannelCPU;
		
		/**
		 * 	@private
		 */
		private var buffer:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var updated:Boolean;
		
		private const DOTS_MAX:Number = 50;      
		private const FRICTION:Number = 0.98;         

		private var _dotNumber:Number = 0;
		private var _dots:Vector.<Vertex>;
		private var _codeWidth:Number = 1;
		
		private var _startX:Number;
		private var _startY:Number;
		
		private var _layerA:Sprite; 
		private var _layerB:Sprite;
		private var _drawTarget:Sprite; 
		
		private var _canvas:BitmapData;
		private var _holder:Sprite;    
		private var _color:uint = 0xFFFFFF00;
		private var edge_color:uint = 0x00;         
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// create
			buffer					= new DisplaySurface(context.width, context.height, true, 0x00);

			Console.Log(3,'AbstractPainting');
			Console.Log(3,'Credits to George0rwell ( http://wonderfl.net/user/George0rwell )');
			Console.Log(3,'Adapted by Bruce LANE (http://www.batchass.fr)');
			_startX = context.width/2;
			_startY = context.height/2;
			
			_layerA = new Sprite();
			_layerB = new Sprite();
			_layerB.x = 10;
			_layerB.y = 10;
			
			var colorTransform:ColorTransform = new ColorTransform(1,1,1,2,20,30,20,20);
			_layerB.transform.colorTransform = colorTransform;
			
			_drawTarget = new Sprite();
			_drawTarget.addChild(_layerA);
			_drawTarget.addChild(_layerB);
			
			_holder = new Sprite();
			_holder.x = context.width/2;
			_holder.z = 300;
			addChild(_holder);
			
			_canvas = new BitmapData(context.width,context.height,true,0);
			var canvasBitmap:Bitmap = new Bitmap(_canvas,"auto",true);
			canvasBitmap.x = -232;
			_holder.addChild(canvasBitmap);
			
			_dots = new Vector.<Vertex>();
			
			var timer:Timer = new Timer(30, 0);
			timer.addEventListener(TimerEvent.TIMER, createDot);
			timer.start();
			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			// the channel has changed!
			if (invalidParameters.targetChannel) {
				
				if (listenChannel) {
					listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);	
				}
				
				listenChannel = targetChannel as IChannelCPU;
				if (listenChannel) {
					listenChannel.addEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);	
				}
				
				updated = false;

			}
			
			// invalid as well
			super.validate(invalidParameters);
		}
		
		/**
		 * 	@private
		 */
		private function handleRender(event:OnyxEvent):void {
			
			var target:BitmapData = listenChannel.surface;
			buffer.copyPixels(target, target.rect, CONST_IDENTITY);
			
			updated = true;
		}
		
		private function randomRange( min:Number, max:Number ):Number
		{
			return min + Math.random() * (max + 1 - min);
		}

		private function createDot(e:TimerEvent):void 
		{
			var dot:Vertex = new Vertex();            
			var px:Number = _startX + randomRange(-40,40);
			var py:Number = _startY + randomRange(-40,40);
			
			// ã‚¹ãƒ†ãƒ¼ã‚¸ã‹ã‚‰ã¯ã¿å‡ºãŸã‚‰é©å½“ãªå ´æ‰€ã¸æˆ»ã™
			if(px > context.width || py > context.height || px < 0 || py < 0)
			{
				px = Math.random() * context.width;
				py = Math.random() * context.height;
				
				dot.ajust = true; // ä½ç½®å¤‰æ›´ãƒ•ãƒ©ã‚°
			}
			
			_startX = px;
			_startY = py;
			
			dot.x = _startX;
			dot.y = _startY;
			
			
			
			_dots.push(dot);    
			
			if (_dotNumber >= DOTS_MAX) 
			{
				var target:Vertex = _dots.shift();
				target = null;
			}    
			_dotNumber ++;    
		}		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return invalid || updated;
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			if (updated) {
				updated	= false;
				
				_layerA.graphics.clear();
				_layerB.graphics.clear();
				
				var codeWidth:Number = 1; // layerBã®ç·šã®å¤ªã•
				var brushThickness:Number = 4; // ç·šã®å¤ªã•
				var pressure:Number = 0;       // ç­†åœ§ã£ã½ã•
				var l:int = _dots.length;            
				
				// ä¸€å›žã¾ã‚ã—ã¦è§’åº¦ã‚’è¨ˆç®—ã—ã¦ãŠã
				for(var i:int = l-1; i > 0; i-- )
				{
					if( i != l-1 )
					{
						var dot:Vertex = _dots[i];                    
						var dotB:Vertex = _dots[i-1]; // ä¸€ã¤å‰ã®ãƒã‚¤ãƒ³ãƒˆï¼ˆåŸºæº–å€¤ï¼‰
						var disX:Number = dotB.x - dot.x;
						var disY:Number = dotB.y - dot.y;
						// X:Yã®è§’åº¦ã‹ã‚‰åž‚ç›´ã«ãªã‚‹ãƒã‚¤ãƒ³ãƒˆã¸ã®è§’åº¦
						dot.angle = Math.atan2(disX, disY) + Math.PI / 2; 
					}
				}
				
				//ã€€ç·šã®æç”»éƒ¨åˆ† 
				for(var j:int = l-1; j > 0; j-- )
				{    
					dot = _dots[j];
					var color:uint = buffer.getPixel(dot.x, dot.y);                
					
					if (j>0)
					{
						brushThickness += 0.1;
						codeWidth += 0.01;
						pressure += 0.02;
					}
					else
					{
						brushThickness *= FRICTION;
						codeWidth *= FRICTION;
						pressure *= FRICTION;
					}
					
					if( j == l-1 )
					{
						// ã¯ã¿å‡ºãŸãƒã‚¤ãƒ³ãƒˆã‚’æˆ»ã™ã‚¿ã‚¤ãƒŸãƒ³ã‚°ã§å††ã‚’æ›¸ã
						if(dot.ajust)
							drawCircle(dot,color);
						
						_layerA.graphics.moveTo(dot.x, dot.y);
						_layerB.graphics.moveTo(dot.x, dot.y);
					}
					else
					{
						dotB = _dots[j-1];
						disX = dotB.x - dot.x;
						disY = dotB.y - dot.y;
						var mx:Number = dot.x + (disX)*0.4;
						var my:Number = dot.y + (disY)*0.4;
						var cosA:Number = brushThickness*Math.cos(dot.angle);
						var cosB:Number = brushThickness*Math.cos(dotB.angle);
						var sinA:Number = brushThickness*Math.sin(dot.angle);
						var sinB:Number = brushThickness*Math.sin(dotB.angle);
						
						// ä¸Šã®ãƒ¬ã‚¤ãƒ¤ãƒ¼
						_layerB.graphics.lineStyle(codeWidth, color, pressure);
						_layerB.graphics.curveTo(dotB.x, dotB.y, mx, my);
						_layerB.graphics.lineTo(mx, my);
						
						// ä¸‹ã®ãƒ¬ã‚¤ãƒ¤ãƒ¼
						if(!dot.ajust)
						{
							_layerA.graphics.beginFill(color,0.4);
							_layerA.graphics.moveTo(mx,my);                                            
							_layerA.graphics.lineStyle(0.2, edge_color, 0);
							_layerA.graphics.moveTo(dot.x + cosA, dot.y + sinA);
							_layerA.graphics.lineTo(dot.x - cosA, dot.y - sinA);
							_layerA.graphics.lineStyle(0.2, edge_color, 0.2);                    
							_layerA.graphics.lineTo(dotB.x - cosB, dotB.y - sinB);
							_layerA.graphics.lineStyle(0.2, edge_color, 0);
							_layerA.graphics.lineTo(dotB.x + cosB, dotB.y + sinB);
							_layerA.graphics.lineStyle(0.2, edge_color, 0.2);    
							_layerA.graphics.lineTo(dot.x + cosA, dot.y + sinA);
							
							_layerA.graphics.moveTo(mx, my);
						}
					}                
				}
				_canvas.draw(_drawTarget);
				
				var center:Number = context.width/2;
				var p:Number = (center - mouseX)/center* -180;
				
				SimpleTween.addTween(_holder, {rotationY:p}); 
				
				context.draw(_canvas, renderMatrix);
				return true;
			}
			
			return false;
		}
		private function drawCircle(target:Vertex, color:uint):void
		{
			for(var i:int = 0; i<8; i++)
			{
				var px:Number = target.x + randomRange( -100, 100 );
				var py:Number = target.y + randomRange( -100, 100 );
				var r:Number = Math.random()* 4;
				_layerA.graphics.beginFill(color,1);
				_layerA.graphics.drawCircle(px,py,r);
			}
		}			
		/**
		 * 	@public
		 */
		override public function dispose():void {

			// bind
			if (listenChannel) {
				listenChannel.removeEventListener(OnyxEvent.CHANNEL_RENDER_CPU, handleRender);
				listenChannel = null;
			}
						
			// dispose
			super.dispose();
			
			buffer.dispose();
			_canvas.dispose();
		}
	}
}

class Vertex
{
	private const GRAVITY:Number  = 0.5; 
	private const FRICTION:Number = 0.98; 
	
	public var x:Number;
	public var y:Number;
	public var rad:Number = 2;
	public var color:uint;
	public var randonNum:Number;
	public var angle:Number;
	public var ajust:Boolean = false;
	
	private var speedX:Number;
	private var speedY:Number;
	
	public function Vertex()
	{
		init();
	}
	private function init():void
	{
		var angle:Number = Math.random()*Math.PI*2;
		randonNum = Math.random() * 4;
		speedX = Math.cos(angle) * randonNum;
		speedY = Math.sin(angle) * randonNum;       
	}
	public function upDate():void
	{            
		speedX *= FRICTION;
		speedY *= FRICTION;
		
		x += speedX;
		y += speedY;
	}
}

class SimpleTween
{
	private static const EASE_VALUE:Number = 0.2;
	
	public static function addTween( target:Object, obj:Object ):void
	{    
		for(var istr:String in obj)
		{
			var a:Number = target[istr];
			var b:Number = obj[istr];
			target[istr] = a + (b-a) * EASE_VALUE;
		}        
	}
	
}