/**
 * Copyright bradsedito ( http://wonderfl.net/user/bradsedito )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/o9xL
 */

// forked from sakef's simple 3D 03 (not using PV3D)


package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.utils.Timer;
	import flash.geom.Point;	
		
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	
	final public class BallSphere extends PluginPatchCPU {
		
		private static const RADIUS:Number=180;
		private static const N_POINT1:int=10;
		private static const N_POINT2:int=10;
		private static const RADIAN:Number=Math.PI / 180;
		private static const SIN2:Number=Math.sin(RADIAN * 2);
		private static const COS2:Number=Math.cos(RADIAN * 2);
		
		// è??å??ç?Œæ??åº?ç??åƒ?ç??
		private static const N_BLUR_IMG:int=5;
		private static const BLUR_RANGE:int=140;
		private static const STEP:Number=BLUR_RANGE / N_BLUR_IMG;
		
		// å??ãƒ?é??ã??ãƒ?ä??å?ƒ
		private var CENTER_X:int;
		private var CENTER_Y:int;
		/*private static const W:int;
		private static const H:int;*/
		
		// ä?Šã??ç?ºã??ãƒ?ã??ãƒ?ãƒ?ãƒ?ä??å?ƒã??ç?ºã??ãƒ?ã??ãƒ?ãƒ?ãƒ?ãƒ?ã??ãƒ?ã??ã??
		private var UP_VECTOR:MyVector3D=new MyVector3D(0, 1, 0);
		private var CENTER_VECTOR:MyVector3D=new MyVector3D(0, 0, 0);
		private var FOCUS:Number=360;
		
		// 3Dãƒœãƒ?ãƒ?ã??ä??æŒ?ã??ã??é??å??ãƒ?ç??åƒ?ã??ä??æŒ?ã??ã??é??å??ãƒ?3DBallã??æ??ã??ä??æŒ?ã??ã??å??æ??
		private var ballAry:Array;
		private var imgAry:Array;
		private var n_balls:int;
		
		// ã??ãƒ?ãƒ?ç??
		private var camera:MyVector3D;
		private var camera_radius:int;
		private var theta:Number;
		private var camera_calc_flug:int;
		private var sprite:Sprite;
		private var mx:int = 320;
		private var rx:int = 22;
		private var ry:int = 150;
		private var rz:int = 150;

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;

			Console.Log(3,'BallSphere v 0.0.11');
			Console.Log(3,'Credits to bradsedito ( http://wonderfl.net/user/bradsedito )');
			Console.Log(3,'Adapted by Bruce LANE (http://www.batchass.fr)');
			
			CENTER_X = context.width >> 1;
			CENTER_Y = context.height >> 1;
			
			sprite = new Sprite();
			var ballImg:BitmapData = new AssetForBallSphere();   
			
			mouseChildren=false;
			mouseEnabled=false;
			
			var i:int, j:int;
			theta=n_balls=0;
			camera_calc_flug=1;
			camera_radius=360;
			ballAry=[];
			imgAry=[];
			camera=new MyVector3D(0, 0, FOCUS);
			
			var p:Point=new Point();
			for(i=0; i < N_BLUR_IMG; i++)
			{
				var tmp:BitmapData=ballImg.clone();
				tmp.applyFilter(tmp, tmp.rect, p, new BlurFilter(0.6 * i, 0.6 * i));
				imgAry[i]=tmp;
			}
			
			for(i=0; i < N_POINT1; i++)
			{
				var theta1:Number=(360 / N_POINT1) * i * RADIAN;
				var start:int=(i == 0) ? (0) : (1);
				for(j=start; j < N_POINT2; j++)
				{
					var theta2:Number=((180 / N_POINT2) * j - 90) * RADIAN;
					var xx:Number=RADIUS * Math.cos(theta2) * Math.sin(theta1);
					var yy:Number=RADIUS * Math.sin(theta2);
					var zz:Number=RADIUS * Math.cos(theta2) * Math.cos(theta1);
					var ball:MyBall3D=new MyBall3D(ballImg, xx, yy, zz);
					ballAry[n_balls]=ball;
					sprite.addChild(ball);
					n_balls++;
				}
			}
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


			return true;
		}

		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {
			
			theta+=4 * (mx / context.width - 0.5);
			camera.x=camera_radius * Math.sin(RADIAN * rx);
			camera.y=camera_radius * Math.cos(RADIAN * ry);
			camera.z=camera_radius * Math.cos(RADIAN * rz);
			
			if (camera_calc_flug == 1)
			{
				camera_radius+=2;
				if (camera_radius > 600) camera_calc_flug=0;
			}
			else
			{
				camera_radius-=2;
				if (camera_radius < 250) camera_calc_flug=1;
			}
			
			var n:MyVector3D=CENTER_VECTOR.subtract(camera);
			n.normalize();
			
			var u:MyVector3D=UP_VECTOR.crossProduct(n);
			u.normalize();
			
			var v:MyVector3D=n.crossProduct(u);
			v.normalize();
			
			var dx:Number=-camera.innerProduct(u);
			var dy:Number=-camera.innerProduct(v);
			var dz:Number=-camera.innerProduct(n);
			
			var Mview:MyMatrix3D=new MyMatrix3D(u.x, u.y, u.z, dx, v.x, v.y, v.z, dy, n.x, n.y, n.z, dz, 0, 0, 0, 1);
			
			var Mmodel:MyMatrix3D=new MyMatrix3D(1, 0, 0, 0, 0, COS2, -SIN2, 0, 0, SIN2, COS2, 0, 0, 0, 0, 1);
			
			var Mmodeview:MyMatrix3D=Mview.productMatrix(Mmodel);
			
			var ball:MyBall3D;
			var position:MyVector3D;
			var eyeCord_position:MyVector3D;
			var scale:Number;
			var screenX:int, screenY:int;
			var blurIndex:int;
			for(var i:int=0; i < n_balls; i++)
			{
				ball=ballAry[i]as MyBall3D;
				position=ball.position;
				
				position=Mmodel.productVector(position);
				eyeCord_position=Mmodeview.productVector(position);
				
				ball.sortNumber=eyeCord_position.distance(CENTER_VECTOR);
				
				scale=FOCUS / ball.sortNumber;
				screenX=((eyeCord_position.x)) * scale + CENTER_X;
				screenY=-((eyeCord_position.y)) * scale + CENTER_Y;
				
				ball.scaleX=ball.scaleY=scale;
				ball.x=screenX;
				ball.y=screenY;
				
				blurIndex=((FOCUS - ball.sortNumber) / STEP) >> 0;
				blurIndex=(blurIndex ^ (blurIndex >> 31)) - (blurIndex >> 31)
				blurIndex=(blurIndex >= N_BLUR_IMG) ? (N_BLUR_IMG - 1) : (blurIndex);
				ball.bitmapData=imgAry[blurIndex]as BitmapData;
				
				ball.position=position;
			}
			
			ballAry.sortOn("sortNumber", Array.NUMERIC | Array.DESCENDING);
			for(i=0; i < n_balls; i++)
			{
				ball=ballAry[i]as MyBall3D;
				sprite.setChildIndex(ball, i)
			}
			// draw the shape
			context.draw(sprite);
			
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

import flash.display.Bitmap;
import flash.display.BitmapData;

final class MyBall3D extends Bitmap
{
	public var position:MyVector3D;
	public var sortNumber:Number;
	private var bmpd_w:Number;
	private var bmpd_h:Number;
	
	public function MyBall3D(material:BitmapData, x:Number=0, y:Number=0, z:Number=0)
	{
		position=new MyVector3D(x, y, z);
		sortNumber=0;
		bitmapData=material;
		bmpd_w=material.width >> 1;
		bmpd_h=material.height >> 1;
	}
	
	override public function set x(value:Number):void
	{
		super.x=value - bmpd_w;
	}
	
	override public function set y(value:Number):void
	{
		super.y=value - bmpd_h;
	}
}

final class MyMatrix3D
{
	// è¡Œåˆ—ã®è¦ç´ 
	public var v11:Number, v12:Number, v13:Number, v14:Number;
	public var v21:Number, v22:Number, v23:Number, v24:Number;
	public var v31:Number, v32:Number, v33:Number, v34:Number;
	public var v41:Number, v42:Number, v43:Number, v44:Number;
	

	public function MyMatrix3D(v11:Number=1, v12:Number=0, v13:Number=0, v14:Number=0, 
							   v21:Number=0, v22:Number=1, v23:Number=0, v24:Number=0, 
							   v31:Number=0, v32:Number=0, v33:Number=1, v34:Number=0, 
							   v41:Number=0, v42:Number=0, v43:Number=0, v44:Number=1)
	{
		this.v11=v11; this.v12=v12; this.v13=v13; this.v14=v14;
		this.v21=v21; this.v22=v22; this.v23=v23; this.v24=v24;
		this.v31=v31; this.v32=v32; this.v33=v33; this.v34=v34;
		this.v41=v41; this.v42=v42; this.v43=v43; this.v44=v44;
	}
	

	public function productMatrix(m:MyMatrix3D):MyMatrix3D
	{
		var newMat:MyMatrix3D=new MyMatrix3D();
		
		newMat.v11=v11 * m.v11 + v12 * m.v21 + v13 * m.v31 + v14 * m.v41;
		newMat.v12=v11 * m.v12 + v12 * m.v22 + v13 * m.v32 + v14 * m.v42;
		newMat.v13=v11 * m.v13 + v12 * m.v23 + v13 * m.v33 + v14 * m.v43;
		newMat.v14=v11 * m.v14 + v12 * m.v24 + v13 * m.v34 + v14 * m.v44;
		
		newMat.v21=v21 * m.v11 + v22 * m.v21 + v23 * m.v31 + v24 * m.v41;
		newMat.v22=v21 * m.v12 + v22 * m.v22 + v23 * m.v32 + v24 * m.v42;
		newMat.v23=v21 * m.v13 + v22 * m.v23 + v23 * m.v33 + v24 * m.v43;
		newMat.v24=v21 * m.v14 + v22 * m.v24 + v23 * m.v34 + v24 * m.v44;
		
		newMat.v31=v31 * m.v11 + v32 * m.v21 + v33 * m.v31 + v34 * m.v41;
		newMat.v32=v31 * m.v12 + v32 * m.v22 + v33 * m.v32 + v34 * m.v42;
		newMat.v33=v31 * m.v13 + v32 * m.v23 + v33 * m.v33 + v34 * m.v43;
		newMat.v34=v31 * m.v14 + v32 * m.v24 + v33 * m.v34 + v34 * m.v44;
		
		newMat.v41=v41 * m.v11 + v42 * m.v21 + v43 * m.v31 + v44 * m.v41;
		newMat.v42=v41 * m.v12 + v42 * m.v22 + v43 * m.v32 + v44 * m.v42;
		newMat.v43=v41 * m.v13 + v42 * m.v23 + v43 * m.v33 + v44 * m.v43;
		newMat.v44=v41 * m.v14 + v42 * m.v24 + v43 * m.v34 + v44 * m.v44;
		
		return newMat;
	}
	
	public function productVector(v:MyVector3D):MyVector3D
	{
		var newVec:MyVector3D=new MyVector3D();
		
		newVec.x=v11 * v.x + v12 * v.y + v13 * v.z + v14;
		newVec.y=v21 * v.x + v22 * v.y + v23 * v.z + v24;
		newVec.z=v31 * v.x + v32 * v.y + v33 * v.z + v34;
		
		return newVec;
	}
}

final class MyVector3D
{
	public var x:Number;
	public var y:Number;
	public var z:Number;
	public var w:Number;
	
	public function MyVector3D(x:Number=0, y:Number=0, z:Number=0)
	{
		this.x=x;
		this.y=y;
		this.z=z;
		this.w=1;
	}
	
	public function distance(v:MyVector3D):Number
	{
		return Math.sqrt((v.x - x) * (v.x - x) + (v.y - y) * (v.y - y) + (v.z - z) * (v.z - z));
	}
	
	public function subtract(v:MyVector3D):MyVector3D
	{
		var newVec:MyVector3D=new MyVector3D();
		
		newVec.x=x - v.x;
		newVec.y=y - v.y;
		newVec.z=z - v.z;
		
		return newVec;
	}
	
	public function normalize():void
	{
		var len:Number=Math.sqrt(x * x + y * y + z * z);
		x/=len;
		y/=len;
		z/=len;
	}
	
	public function innerProduct(v:MyVector3D):Number
	{
		return (x * v.x + y * v.y + z * v.z);
	}
	
	public function crossProduct(v:MyVector3D):MyVector3D
	{
		var newVec:MyVector3D=new MyVector3D();
		
		newVec.x=y * v.z - z * v.y;
		newVec.y=z * v.x - x * v.z;
		newVec.z=x * v.y - y * v.x;
		
		return newVec;
	}
}