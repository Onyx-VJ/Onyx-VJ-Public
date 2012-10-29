/**
 * Copyright osmanovx ( http://wonderfl.net/user/osmanovx )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/wHEi
 */

// forked from narutohyper's Heart Beat Clock
package onyx.patch.cpu
{

	import flash.display.Bitmap;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.display.BitmapData;    
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;    
	
	import flash.net.*;
	import flash.utils.escapeMultiByte;
	import flash.system.Security;
	import flash.net.URLRequest; 
	
	import flash.system.LoaderContext;
	import flash.media.SoundLoaderContext;    

	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;

	
	/**
	 * heartBeat
	 * 
	 * @author narutohyper
	 */
	public class HeartBeat extends PluginPatchCPU 
	{
		private var monitor:Sprite; 
		private var line:Sprite;        
		private var back:Sprite;
		private var marker:Sprite;        
		
		private var sec:int;
		private var counter:uint;
		private var update1:Boolean;
		private var points:Array;
		private var startTime:Array;
		
		private var sound:Array;        
		public var baseBmd:BitmapData;
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			sound=[];

			monitor = new Sprite();
			back = new Sprite();
			back.graphics.beginFill(0x000000,1)
			back.graphics.drawRect(0, 0, 450, 400)
			back.x = 8;
			back.y = 27;
			
			var i:uint
			var pitch:uint = 30;
			var sp:uint = 15;
			for (i = 0; i < 15; i++ ) {
				back.graphics.lineStyle(0, 0x005500, 1, true, LineScaleMode.NONE);
				back.graphics.moveTo(i * pitch + sp, 0);
				back.graphics.lineTo(i * pitch + sp, 400-1);
				if (i < 13) {
					back.graphics.moveTo(0,i * pitch + sp);
					back.graphics.lineTo(450-1, i * pitch + sp);
				}
				for (var n:uint = 0; n < 13; n++) {
					back.graphics.beginFill(0x005500, 1);
					back.graphics.drawCircle(i * pitch + sp, n * pitch + sp, 2);
					back.graphics.endFill();
				}
			}            
			monitor.addChild(back);
			
			line = new Sprite();
			line.x = 8
			line.y = 33 + 250
			monitor.addChild(line);
			
			line.filters = new Array(getBitmapFilter(0x00FF00));
			
			//ãƒžãƒ¼ã‚«ãƒ¼
			marker = new Sprite();
			marker.graphics.beginFill(0xFFFFFF,1)
			marker.graphics.drawCircle(0, 0, 4);
			monitor.addChild(marker)
			marker.filters = new Array(getBitmapFilter(0xFFFFFF));
			
			var timer:Timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			points = new Array()
			points[0] = new Vector.<lineParts>;
			points[1] = new Vector.<lineParts>;
			
			for (i = 0; i < 100;i++ ) {
				points[0][i] = new lineParts((450 / 100) * (i % 100), 0,true);
				points[1][i] = new lineParts((450 / 100) * (i % 100), 0,true);                
			}
			
			var tempArray:Array = new Array(5,-10,5,0,0,0,10,-45,-100,-45,30,15,0,0,0,0,0,0,-5,-12,-17,-19,-20,-19,-17,-12,-5,0,5,0,-5,0)
			
			for (i = 0; i < 32; i++ ) {
				if (tempArray[i] == -1) {
					points[0][i + 12].visible = false;
					points[1][i + 12].visible = false;
					points[0][i + 62].visible = false;
					points[1][i + 62].visible = false;                    
				} else {
					points[0][i + 12].y = tempArray[i];
					points[1][i + 12].y = tempArray[i];
					points[0][i + 62].y = tempArray[i];
					points[1][i + 62].y = tempArray[i];
				}    
			}
			startTime=new Array()
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
			

			context.draw(monitor);
			// return
			return true;
		}		
		private function onTimer(e:TimerEvent):void {
			var nowTime:Date = new Date();
			updateView(nowTime);
		}
		
		private function updateView(nowTime:Date):void {
			var i:uint, n:uint;
			//ãƒ©ã‚¤ãƒ³ã®æ›´æ–°
			line.graphics.clear();
			line.graphics.moveTo(0, 0);            
			
			var passTime:Array = new Array();
			
			for (n = 0; n < 2;n++ ) {
				if (startTime[n]) {
					passTime[n] = getPassTime(startTime[n],nowTime)
					line.graphics.moveTo(0, 0);            
					for (i = 0; i < passTime[n]; i++) {
						if (i < 100) {
							if (points[n][i].visible) {
								line.graphics.lineStyle(2, 0x00FF00, points[n][i].alpha);                                
								line.graphics.lineTo(points[n][i].x, points[n][i].y);
							}
						}
					}
				}
			}
			if (passTime[0]<100) {
				marker.x = points[0][passTime[0]].x + 8;
				marker.y = points[0][passTime[0]].y + 33 + 250;
			} else {
				if (passTime[1]<100) {                
					marker.x = points[1][passTime[1]].x + 8;
					marker.y = points[1][passTime[1]].y + 33 + 250;
				}
			}
			
			initLine(0);//1
				
				startTime[2] = new Date()
				update1=true
			
			
			//0.5ç§’å¾Œã«æ›´æ–°
			if (startTime[2]) {
				passTime[2] = getPassTime(startTime[2],nowTime)
				if (update1 && passTime[2] > 20) {
					sound[0].play(0)
					sound[1].play(0)                    

					update1 = false;
				}
			}

		}
		
		private function initLine(id:uint):void {
			startTime[id] = new Date();
			for (var i:uint = 0; i < 100; i++) {
				points[id][i].init()
			}                                
		}
		
		
		private function getPassTime(startTime:Date,nowTime:Date):Number {
			var passTime:Number = startTime.getTime() - nowTime.getTime();
			var result:Number = -1 * Math.floor(passTime / 20);    
			return result;
		}
		
		
		private function addZero(no:int):String {
			var result:String = (no < 10)? "0" + no.toString() : no.toString();
			
			return result;
		}
		
		
		private function getBitmapFilter(_color:uint):BitmapFilter {
			var color:Number = _color;
			var alpha:Number = 1;
			var blurX:Number = 16;
			var blurY:Number = 16;
			var strength:Number = 3;
			var inner:Boolean = false;
			var knockout:Boolean = false;
			var quality:Number = BitmapFilterQuality.HIGH;
			
			return new GlowFilter(color,
				alpha,blurX,blurY,strength,quality,inner,knockout);
		}
		
		
	}
	
}


import flash.geom.Point;

class lineParts {
	//å¯¿å‘½ã¤ãã®ãƒ©ã‚¤ãƒ³ãƒ‘ãƒ¼ãƒ„
	public var _point:Point;
	public var _alpha:Number;
	public var _color:uint;
	public var _visible:Boolean
	private var _startTime:Date;
	private var _counter:uint;
	
	public function lineParts(_x:Number,_y:Number,_vi:Boolean):void {
		_point = new Point(_x,_y);
		_color = 0x000000;
		_alpha = 1;
		_visible = _vi
		_startTime = new Date();        
	}
	
	public function init():void {
		_alpha = 1
		_counter = 0
	}
	
	public function get alpha():Number {
		if (!_counter) {
			_startTime = new Date();
			_counter = 1;
		}
		return _alpha
	}
	
	public function get x():Number {
		return _point.x
	}
	
	public function get y():Number {
		return _point.y
	}
	
	public function set visible(value:Boolean):void {
		_visible = value;
	}    
	
	public function get visible():Boolean {
		return _visible
	}
	
	public function set y(no:Number):void {
		_point.y=no
	}
	
}




