/**
 * Copyright ile ( http://wonderfl.net/user/ile )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/h4en
 */

package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
		
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	final public class Bubbles extends PluginPatchCPU {
		
		private const GRID_SIZE:Number = 80;
		private var _grid_size:Number = 80;
		private const RADIUS:Number = 40;
		
		private var _balls:Vector.<DisplayObject>;
		private var _grid:CollisionGrid;
		private var _numBalls:int = 25;
		private var sprite:Sprite;
	

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {

			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			sprite = new Sprite();
			//makeBalls();
			_grid = new CollisionGrid(context.width, context.height, _grid_size);

			// success
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			makeBalls();
			
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
			updateBalls();
			
			_grid.check(_balls);
			
			var numChecks:int = _grid.checks.length;
			for (var j:int = 0; j < numChecks; j += 2)
			{
				checkCollision(_grid.checks[j] as Ball, 	_grid.checks[j + 1] as Ball);
			}
			// draw the shape
			context.draw(sprite);
			
			// return
			return true;
		}
		private function makeBalls():void
		{
			var max:Number = 0;
			
			//backgroundColor
			var bgColor:uint = Math.random() * 0x1000000;
			
			graphics.beginFill(bgColor);
			graphics.drawRect(0, 0, context.width, context.height);
			graphics.endFill();
			graphics.beginFill (Math.random() * 0x1000000, 1.0);
			graphics.drawCircle  ( 270, 100 , 150);
			graphics.endFill();
		
			_balls = new Vector.<DisplayObject>(_numBalls);
			for (var i:int = 0; i < _numBalls; i++)
			{
				
				//var ball:Ball = new Ball(RADIUS);
				var ball:Ball = new Ball(Math.random() * 30 + 5);
				ball.x = Math.random() * context.width;
				ball.y = Math.random() * context.height;
				ball.vx = Math.random() * 4 - 2;
				ball.vy = Math.random() * 4 - 2;
				
				if(ball.radius > max) max = ball.radius;
				sprite.addChild(ball);
				_balls[i] = ball;
			}
			_grid_size = max*2;
		}
		
		private function updateBalls():void
		{
			
			for (var i:int = 0; i < _numBalls; i++)
			{
				var ball:Ball = _balls[i] as Ball;
				
				ball.update();
				
				if (ball.x < 0)
				{
					ball.x = 0;
					ball.vx *= -1;
				}
				else if (ball.x > context.width )
				{
					ball.x = context.width;
					ball.vx *= -1;
				}
				
				if (ball.y < 0)
				{
					ball.y = 0;
					ball.vy *= -1;
				}
				else if (ball.y > context.height )
				{
					ball.y = context.height;
					ball.vy *= -1;
				}
				
				ball.color = 0xffffff;
				ball.visible = true;
			}
		}
		
		private function checkCollision(ballA:Ball, ballB:Ball):void
		{

			var dx:Number = ballB.x - ballA.x;
			var dy:Number = ballB.y - ballA.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			
			if (dist < ballA.radius + ballB.radius)
			{
				ballA.color = 0xff0000;
				ballB.color = 0xff0000;
				ballA.visible = false;
				ballB.visible = false;
			}
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

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.display.BlendMode;

class Ball extends Sprite {
	private var shadowColor:uint = 0x000000;
	private var lightColor:uint = 0xffffff;
	//
	private var _color:uint;
	private var _radius:Number;
	private var _vx:Number = 0;
	private var _vy:Number = 0;
	
	private var shape:Shape = new Shape();
	
	public function Ball(radius:Number, color:uint = 0xffffff):void {
		
		_radius = radius;
		_color = color;
		
		draw();
	}
	private function draw():void {
		
		addChild(shape);
		var g:Graphics = shape.graphics;
		var matrix:Matrix = new Matrix;
		
		//long shadow
		//createGradientBox(w,h,r,X,Y)
		matrix.createGradientBox(_radius * 2, _radius * 4, 0, -_radius, -_radius*2);
		g.beginGradientFill(GradientType.RADIAL, [shadowColor, shadowColor, shadowColor], [0.0,0.1,0], [0,200,255], matrix, SpreadMethod.PAD);
		g.moveTo(-_radius, 0);
		g.curveTo ( -_radius , _radius * 2, 0 , _radius * 2 );
		g.curveTo ( _radius , _radius*2, _radius , 0 );
		g.curveTo ( _radius*0.88 , _radius*0.88, 0 , _radius );
		g.curveTo ( -_radius*0.88 , _radius*0.88, -_radius , 0 );
		g.endFill();
		
		//around OUTSIDE shadow
		
		matrix.createGradientBox(_radius * 2.6, _radius * 2.6+_radius/5, 0, -_radius*1.3, -_radius*1.3);
		g.beginGradientFill(GradientType.RADIAL, [shadowColor,shadowColor, shadowColor], [0.02,0.05,0], [0,200,255], matrix, SpreadMethod.PAD);
		g.drawCircle(0, _radius/5, _radius*1.5);
		g.endFill();
		
		//base color
		
		g.beginFill (0x888888, 0.15);
		g.drawCircle  ( 0, 0 , _radius);
		g.endFill();
		shape.blendMode = BlendMode.LIGHTEN;
		
		//around INSIDE shadow
		
		matrix.createGradientBox(_radius * 3.5, _radius * 3.7, 0, -_radius * 1.8, -_radius * 1.0);
		g.beginGradientFill(GradientType.RADIAL, [shadowColor,shadowColor, shadowColor], [0,0.05,0.07], [0,200,255], matrix, SpreadMethod.PAD);
		g.drawCircle  ( 0, 0 , _radius);
		g.endFill();
		
		//underã€€shadow
		
		matrix.createGradientBox(_radius * 5, _radius * 5, 0, -_radius*2.5, -_radius*3);
		g.beginGradientFill(GradientType.RADIAL, [shadowColor,shadowColor,shadowColor,shadowColor], [0,0, 0.3,1], [0,95,222,255], matrix, SpreadMethod.PAD);
		g.drawCircle(0, 0, _radius);
		g.endFill();
		
		//base gradation
		
		matrix.createGradientBox(_radius * 3.5, _radius * 3.7, 0, -_radius*1.8, -_radius*1.0);
		g.beginGradientFill(GradientType.RADIAL, [lightColor,lightColor, lightColor,lightColor,lightColor,lightColor], [0.8,0.5, 0.1,0,0,0.3], [0,70, 181,216,245,255], matrix, SpreadMethod.PAD);
		g.drawCircle(0, 0, _radius);
		g.endFill();
		shape.blendMode = BlendMode.OVERLAY;
		
		//highlight
		
		matrix.createGradientBox(_radius/2, _radius/2, 0, -_radius/4, -_radius*0.9);
		g.beginGradientFill(GradientType.RADIAL, [lightColor,lightColor,lightColor], [0.8,0.1 ,0], [0,85,255], matrix, SpreadMethod.PAD);
		g.drawCircle(0, 0, _radius);
		g.endFill();
	}
	
	public function update():void
	{
		// ä??ç??ã??é??åº?ã??è??ã??
		x += _vx;
		y += _vy;
	}
	
	public function set color(value:uint):void
	{
		_color = value;
		//draw
	}
	
	public function get color():uint
	{
		return _color;
	}        
	
	public function set radius(value:Number):void
	{
		_radius = value;
		//draw
	}
	
	public function get radius():Number
	{
		return _radius;
	}
	
	public function set vx(value:Number):void
	{
		_vx = value;
	}
	
	public function get vx():Number
	{
		return _vx;
	}
	
	public function set vy(value:Number):void
	{
		_vy = value;
	}
	
	public function get vy():Number
	{
		return _vy;
	}
}

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.EventDispatcher;

class CollisionGrid extends EventDispatcher
{
	
	private var _checks:Vector.<DisplayObject>;
	private var _grid:Vector.<Vector.<DisplayObject>>;
	private var _gridSize:Number;
	private var _height:Number;
	private var _numCells:int;
	private var _numCols:int;
	private var _numRows:int;
	private var _width:Number;
	public function CollisionGrid(width:Number,
								  height:Number,
								  gridSize:Number)
		
	{
		_width = width;
		_height = height;
		_gridSize = gridSize;
		_numCols = Math.ceil(_width / _gridSize);
		_numRows = Math.ceil(_height / _gridSize);
		_numCells = (_numCols * _numRows) + 1;
	}    
	
	public function check(objects:Vector.<DisplayObject>):void
	{
		var numObjects:int = objects.length;
		_grid = new Vector.<Vector.<DisplayObject>>(_numCells);
		_checks = new Vector.<DisplayObject>();
		// å??ã??ã??ã?ªã??ã??ã??ã??ã??ã??ã??ã??ã??ã??ã??ã??ã??ã??
		for (var i:int = 0; i < numObjects; i++)
		{
			var obj:DisplayObject = objects[i];
			// 1æ??å??ã??æ??å??ä??ã??ä??ç??ã??è??ã??é??å??ã??æ??ã??å??ã??
			// è??ç??ã??ã??
			var index:int = Math.floor(obj.y / _gridSize) *
				_numCols + Math.floor(obj.x / _gridSize);
			
			// iã??ã?ªã??ã??ã??ã??ã??ã??ã?ªã??ã??ã??ã??æ??å??ã??ç??æ??ã??ã??
			if (_grid[index] == null)
			{
				_grid[index] = new Vector.<DisplayObject>;
			}
			
			// æ??å??ã??ã?ªã??ã??ã??ã??ã??ã??è??å??ã??ã??
			_grid[index].push(obj);
		}
		checkGrid();
	}
	
	private function checkGrid():void
	{
		// å??æ??å??ã??ã??ã??ã??ã??ã??
		for (var i:int = 0; i < _numCols; i++)
		{
			for (var j:int = 0; j < _numRows; j++)
			{
				// æ??å??ã??æ??å??ã??ä??ã??ã?ªã??ã??ã??ã??ã??ã??äº?ã??ã??èª?ã??ã??
				checkOneCell(i, j);
				checkTwoCells(i, j, i + 1, j);     // å??
				checkTwoCells(i, j, i - 1, j + 1); // å??ä??
				checkTwoCells(i, j, i,     j + 1); // ä??
				checkTwoCells(i, j, i + 1, j + 1); // å??ä??
			}
		}
	}    
	
	private function checkOneCell(x:int, y:int):void
	{
		// (x, y)ã??è??ã??ã??ã??æ??å??ã??å??ã??
		var cell:Vector.<DisplayObject> = _grid[y * _numCols + x];
		if (cell == null) return;        
		
		// æ??å??ä??ã??ã?ªã??ã??ã??ã??ã??ã??å??æ??
		var cellLength:int = cell.length;
		
		// å??ã??ã??ã?ªã??ã??ã??ã??ã??ã??äº?ã??ã??æ??è??ã??ã??
		for (var i:int = 0; i < cellLength - 1; i++)
		{
			var objA:DisplayObject = cell[i];
			for (var j:int = i + 1; j < cellLength; j++)
			{
				var objB:DisplayObject = cell[j];
				_checks.push(objA, objB);
			}
		}
	}
	
	
	private function checkTwoCells(x1:int, y1:int,
								   x2:int, y2:int):void
	{
		// æ??å??ã??å??å??ã??ã??ã??ã??ã??ç?ºèª?
		if (x2 >= _numCols || x2 < 0 || y2 >= _numRows) return;
		
		// å??æ??å??ã??ã?ªã??ã??ã??ã??ã??ã??å??å??ã??ã??ã??ã??ã??ç?ºèª?
		var cellA:Vector.<DisplayObject> =
			_grid[y1 * _numCols + x1];
		
		var cellB:Vector.<DisplayObject> =
			_grid[y2 * _numCols + x2];
		
		if (cellA == null || cellB == null) return;
		var cellALength:int = cellA.length;
		var cellBLength:int = cellB.length;
		
		// æ??å??ä??ã??å??ã??ã??ã?ªã??ã??ã??ã??ã??ã??ä??ã??æ??å??ã??å??ã??ã??
		// ã?ªã??ã??ã??ã??ã??ã??æ??è??ã??ã??
		for (var i:int = 0; i < cellALength; i++)
		{
			var objA:DisplayObject = cellA[i];
			for (var j:int = 0; j < cellBLength; j++)
			{
				var objB:DisplayObject = cellB[j];
				_checks.push(objA, objB);
			}
		}
	}
	
	public function get checks():Vector.<DisplayObject>
	{
		return _checks;
	}
}