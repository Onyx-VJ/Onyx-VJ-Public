/**
 * Copyright julienne ( http://wonderfl.net/user/julienne )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/hoAk
 */

// forked from nutsu's Kaleidoscope: forked from: adobe challenge 1
// forked from checkmate's adobe challenge 1
package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.media.*;
		
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	final public class CameraKaleidoscope extends PluginPatchCPU {
		
		private var bmpd     :BitmapData;
		
		private var mx     	 :int;
		private var my     	 :int;
		private var verD     :Vector.<Number>;
		private var indD     :Vector.<int>;
		private var uvtD     :Vector.<Number>;
		private var uvID     :Vector.<int>;
		private var uvVal    :Vector.<Number>;
		
		private var _display :DisplayObject;
		private var ptnShape :Shape;
		private var ptn      :BitmapData;
		
		private var camera   :Camera;
		private var video    :Video;
		
		private var mtx:Matrix;
		private var mtxt:Matrix;
		private var mtx0:Matrix;
		
		private var psize    :Number = 100;
		private var hx       :Number;
		private var hy       :Number;
		private var tx       :Number;
		private var ty       :Number;
		private var a        :Number = 0;

		/**
		 * 	@private
		 */
		//private var buffer:BitmapData;
		private var _container : Sprite;
		

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			hx						= context.width / 2;
			hy						= context.height / 2;
			tx       				= hx;
			ty        				= hy;
			
			// add a listener for mouse down
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.MOUSE_MOVE,	handleInteraction);
			
			initTriangles();
			
			//texture src triangle
			bmpd = new BitmapData( 320, 240, true, 0x00 );
			ptn  = new BitmapData( 3 * psize, 2 * psize * Math.sin(Math.PI / 3 ), true, 0x00 );
			ptnShape = new Shape();
			_container = new Sprite();

			mtx  = new Matrix();
			mtx0 = new Matrix();
			mtxt = new Matrix( 1, 0, 0, 1, psize / 2 );
			
			camera = Camera.getCamera();
			if ( camera != null ) {
				camera.setMode(320, 240, 15);
				video = new Video(320, 240);
				video.attachCamera(camera);
				_display = video;
			}

			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@private
		 */
		private function handleInteraction(e:InteractionEvent):void {

			switch (e.type) {
				case InteractionEvent.MOUSE_DOWN:
					
					context.addEventListener(InteractionEvent.MOUSE_MOVE, 		handleInteraction);
					context.addEventListener(InteractionEvent.MOUSE_UP,			handleInteraction);
					
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
			bmpd.draw( _display, mtx0 );
			
			tx += ( mx - tx ) * 0.2;
			ty += ( my - ty ) * 0.2;
			
			var ra:Number = 2 * Math.PI * (hx - tx) / context.width;
			var nv:Number = 0.5 - 0.4 * Math.min( 1, Math.abs(ty/context.height) );
			
			var i:int;
			for ( i = 0; i < 3; i++ ) {
				var aa:Number = ra + i * 2 * Math.PI / 3;
				uvVal[i*2]   = ( 0.5 + nv * Math.cos( aa ) );
				uvVal[i*2+1] = ( 0.5 + nv * Math.sin( aa ) );
			}
			var len:int = uvID.length;
			for ( i = 0; i < len; i++ ) {
				uvtD[i] = uvVal[ uvID[i] ];
			}
			
			ptnShape.graphics.clear();
			ptnShape.graphics.beginBitmapFill( bmpd );
			ptnShape.graphics.drawTriangles( verD, indD, uvtD );
			ptnShape.graphics.endFill();
			ptn.draw( ptnShape, mtxt );
			
			mtx.identity();
			mtx.scale( nv / 0.5, nv / 0.5 );
			mtx.rotate( a );
			mtx.translate( hx, hy );
			_container.graphics.clear();
			_container.graphics.beginBitmapFill( ptn, mtx, true );
			_container.graphics.drawRect( 0, 0, context.width, context.height );
			_container.graphics.endFill();
			a += 0.005;
			
			// draw the shape
			context.draw(_container, null, null, null, null, true, StageQuality.HIGH_8X8);
			
			// return
			return true;
		}
		private function initTriangles():void {
			var xx:Number = psize;
			var yy:Number = psize * Math.sin(Math.PI / 3 );;
			
			uvVal = Vector.<Number>( [0,0,1,0,1,1] );
			verD  = new Vector.<Number>();
			uvID  = new Vector.<int>();
			
			verD.push( xx, yy );
			uvID.push( 0, 1 );//0
			var uf:Boolean = true;
			for ( var i:int = 0; i < 6; i++ ) {
				var vx:Number = psize * Math.cos( i * Math.PI / 3 );
				var vy:Number = psize * Math.sin( i * Math.PI / 3 );
				verD.push( xx + vx, yy + vy );
				if( uf=!uf )
					uvID.push( 2, 3 ); //1
				else
					uvID.push( 4, 5 ); //2
			}
			
			var ex:Number = psize * Math.cos( Math.PI / 3 );
			verD.push( 3 * xx,  yy );
			uvID.push( 2, 3 );//1
			verD.push( 2 * xx + ex,  2 * yy );
			uvID.push( 0, 1 );//0
			verD.push( - ex,  2 * yy );
			uvID.push( 0, 1 );//0
			verD.push( - xx,  yy );
			uvID.push( 4, 5 );//2
			verD.push( - ex,  0 );
			uvID.push( 0, 1 );//0
			verD.push( 2 * xx + ex,  0 );
			uvID.push( 0, 1 );//0
			
			uvtD = new Vector.<Number>( uvID.length );
			
			indD = Vector.<int>([
				0, 1, 2,
				0, 2, 3,
				0, 3, 4,
				0, 4, 5,
				0, 5, 6,
				0, 6, 1,
				1, 7, 8,
				1, 8, 2,
				3, 9, 4,
				4, 9, 10,
				4, 10, 11,
				4, 11, 5,
				6, 12, 1,
				1, 12, 7 ]);
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