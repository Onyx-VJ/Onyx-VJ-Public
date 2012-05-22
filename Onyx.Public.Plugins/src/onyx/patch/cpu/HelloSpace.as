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
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='colorTransform',	id='colorTransform',	target='colorTransform',	channels='argb')]
	final public class HelloSpace extends PluginPatchCPU {
		
		/**
		 * 	@private
		 */
		parameter var colorTransform:ColorTransform	= new ColorTransform(0.96,0.33,0.12,0.5);
		
		/**
		 * 	@private
		 */
		private var buffer:BitmapData;
		
		private static const R:Number = 300;
		private static const HR:Number = R / 2;
		private var particles:Vector.<Number> = new Vector.<Number>();
		private var letterPoints:Vector.<Number> = new Vector.<Number>();
		private var colors:Vector.<uint> = new Vector.<uint>();
		
		private var canvasGlow:BitmapData;
		
		private var mtx:Matrix = new Matrix(0.25, 0, 0, 0.25);
		private var mtx3d:Matrix3D = new Matrix3D();
		private var counter:int = 0;
		private var moveCounter:int = 0;
		private var f:Boolean = false;
		private var projMat:Matrix3D;
		private var proj:PerspectiveProjection = new PerspectiveProjection();
		private var particles2:Vector.<Number> = new Vector.<Number>();
		private var uvts:Vector.<Number> = new Vector.<Number>();
		private var xys:Vector.<Number>;
		private var xysRandom:Vector.<Number> = new Vector.<Number>();
		private var canvasBMP:Bitmap;
		private var text:String = "WareHouse";
		private var _color:uint=0x005599;
		private var _drawColor:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		private var sprite:Sprite;
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			// buffer
			buffer					= new DisplaySurface(context.width, context.height, true, 0x00);
			
			sprite = new Sprite();
			
			refreshTextParticles();	
			
			// é??è??æ??å??ç??ã??å??æ??è??å??ä??æ??
			proj.fieldOfView = 90;
			projMat = proj.toMatrix3D();			
			// å??ã??ã??ã??ã??ã??ã?? BitmapData ã??å??æ??å??ã??ã??
			canvasGlow = new DisplaySurface(context.width/4, context.height/4, true, 0x00);
			var bmp:Bitmap = new Bitmap(canvasGlow, PixelSnapping.NEVER, true);
			bmp.scaleX = bmp.scaleY = 4;
			bmp.smoothing = true;
			bmp.blendMode = BlendMode.ADD;
			addChild(bmp);
			
			// å®šæœŸçš„ã« f ã‚’åè»¢ã•ã›ã‚‹
			setInterval(function():void{ f = !f; }, 14000);
			// success
			return super.initialize(context, channel, path, content);
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
			
			if (xys.length > 0 )
			{				
				mtx3d.identity();
				mtx3d.appendRotation(counter, Vector3D.Y_AXIS);
				mtx3d.appendRotation(15, Vector3D.X_AXIS);
				mtx3d.appendTranslation(0, 0, context.width / 2);
				mtx3d.transformVectors(particles, particles2);
				
				// é??è??æ??å??ã??ã??å??è??å??ã??åº?æ??ã??è??ç??ã??ã??
				Utils3D.projectVectors(projMat, particles2, xysRandom, uvts);
				
				// moveCounter ä??ä??ã?ªã??ã??ã??ã??ã??ã??ã??ã??æ??å??å??ã??é??ç??ã??è??ã??ã??ã??
				// ã??ã??ã??ã?ªã??å??å??ã??ã??ã??ã??ã??ã??å??ç??ã??ã??ã??ã??ã??ã??ä??ç??ã??é??ç??ã??è??ã??ã??ã??
				for (var i:int = 0; i < xysRandom.length; i++){
					if (i < moveCounter * 2){
						xys[i] += (letterPoints[i] - xys[i]) * .13;
					} else {
						xys[i] += (xysRandom[i] - xys[i]) * .12;
					}
				}
				
				// æ–‡å­—åˆ—è¡¨ç¤ºä¸­ã¯moveCounter ã‚’åŠ ç®—ã™ã‚‹
				moveCounter = (f ? moveCounter + 100 : 0);
				
				// BitmapData ã«æç”»ã™ã‚‹
				buffer.lock();
				buffer.fillRect(buffer.rect, 0x000000);
				for (var j:int = 0; j < xys.length / 2; j++){
					//canvas.setPixel32(xys[j * 2] + DISPLAY_WIDTH / 2, xys[j * 2 + 1] + DISPLAY_HEIGHT / 2, colors[j]);
					buffer.setPixel32(xys[j * 2] + context.width / 2, xys[j * 2 + 1] + context.height / 2, 0xFFFFFF);
				}
				buffer.unlock();
				
				// å…‰ã‚‰ã›ã‚‹ãŸã‚ã®ã‚­ãƒ£ãƒ³ãƒã‚¹ã«ã‚³ãƒ”ãƒ¼ã™ã‚‹
				canvasGlow.fillRect(canvasGlow.rect, 0x000000);
				canvasGlow.draw(buffer, mtx);
				
				counter++;
			
			}
			// draw 
			context.copyPixels(buffer);

			// return
			return true;
		}
		private function createBitmapData(letters:String):BitmapData{
			var fmt:TextFormat = new TextFormat();
			fmt.size = 50;
			fmt.font = 'Arial';
			var tf:TextField = new TextField();
			tf.defaultTextFormat = fmt;
			tf.autoSize = "left";
			tf.textColor = 0x00FF00;
			tf.text = letters;
			
			var bmd:BitmapData = new BitmapData(tf.textWidth, tf.textHeight, true, 0x000000);
			var mtx:Matrix = new Matrix();
			bmd.draw(tf, mtx);
			
			return bmd;
		}
		
		private function initParticles(bmd:BitmapData):void
		{
			particles = null;
			particles = new Vector.<Number>();
			for (var yy:int = 0; yy < bmd.height; yy++){
				for (var xx:int = 0; xx < bmd.width; xx++){
					var c:uint = bmd.getPixel(xx, yy);
					if (c != 0){
						letterPoints.push(xx - 220, yy - 20);
						particles.push(R * Math.random() - HR, R * Math.random() - HR, R * Math.random() - HR);
						colors.push(c);
					}
				}
			}
		}
		private function refreshTextParticles():void
		{
			particles2 = null;
			uvts = null;
			xysRandom = null;
			particles2 = new Vector.<Number>();
			uvts = new Vector.<Number>();
			xysRandom = new Vector.<Number>();
			letterPoints = new Vector.<Number>();
			var bmd:BitmapData = createBitmapData(text);
			initParticles(bmd);
			xys = new Vector.<Number>(letterPoints.length);
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
