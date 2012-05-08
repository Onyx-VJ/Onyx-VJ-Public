/**
 * 25-Line ActionScript Contest Entry
 *
 * Project: Water
 * Author:  Bruce Jawn   (http://bruce-lab.blogspot.com/)
 * Date:    2009-1-10
 */
package onyx.filter.cpu
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Filter.Water::CPU',
		name		= 'CPU Style::Water',
		depends		= 'Onyx.Core.Display',
		vendor		= 'Bruce Lane',
		version		= '1.0'
	)]
	
	[Parameter(type='int',		id='delay',		target='delay',  	reset='1',	 	clamp='1,100')]
	[Parameter(type='int',		id='mesh_size',	target='mesh_size', reset='200',	clamp='1,500')]

	final public class CPUWaterFilter extends PluginFilterCPU implements IPluginFilterCPU 
	{
		/**
		 * 	@parameter
		 */
		parameter var mesh_size:Number = 200;
		
		/**
		 * 	@parameter
		 */
		parameter var delay:int	= 0;
		
		private var buffer:DisplaySurface;
		
		private var num_details:int = 48;
		private var inv_num_details:Number = 1 / num_details;
		private var count:uint;
		private var lastTime:int;
		
		private var frames:Array	= [];
		private var vertices:Vector.<Vertex>;
		private var transformedVertices:Vector.<Number>;
		private var indices:Vector.<int>;
		private var uvt:Vector.<Number>;
		
		private var heights:Vector.<Vector.<Number>>;
		private var velocity:Vector.<Vector.<Number>>;
		private var press:Boolean;
		private var mox:int = 320;
		private var moy:int = 240;
		private var sprite:Sprite;
		
		/**
		 * 	@parameter
		 */
		private var blend:IPluginBlendCPU		= Onyx.CreateInstance('Onyx.Display.Blend.Overlay::CPU') as IPluginBlendCPU;
		/**
		 * 	@public
		 */
		public function initialize(owner:IChannelCPU, channel:IDisplayContextCPU):PluginStatus {
			this.context	= channel;
			this.owner		= owner;
			
			count = 0;
			sprite = new Sprite();
			
			addEventListener( MouseEvent.MOUSE_DOWN, onClick );
			addEventListener(MouseEvent.MOUSE_UP,
				function(e:Event = null):void {
					press = false;
				});
			addEventListener(MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent = null):void {
					mox = e.localX; 
					moy = e.localY; 
					
					if (press) drag();
				});
			
			vertices = new Vector.<Vertex>(num_details * num_details, true);
			transformedVertices = new Vector.<Number>(num_details * num_details * 2, true);
			indices = new Vector.<int>();
			uvt = new Vector.<Number>(num_details * num_details * 2, true);
			var i:int;
			var j:int;
			
			for (i = 2; i < num_details - 2; i++) {
				for (j = 2; j < num_details - 2; j++) {
					vertices[getIndex(j, i)] = new Vertex(
						(j - (num_details - 1) * 0.5) / num_details * mesh_size, 0,
						(i - (num_details - 1) * 0.5) / num_details * mesh_size);
					if (i != 2 && j != 2) {
						indices.push(getIndex(i - 1, j - 1), getIndex(i, j - 1), getIndex(i, j));
						indices.push(getIndex(i - 1, j - 1), getIndex(i, j), getIndex(i - 1, j));
					}
				}
			}
			
			heights = new Vector.<Vector.<Number>>(num_details, true);
			velocity = new Vector.<Vector.<Number>>(num_details, true);
			for (i = 0; i < num_details; i++) {
				heights[i] = new Vector.<Number>(num_details, true);
				velocity[i] = new Vector.<Number>(num_details, true);
				for (j = 0; j < num_details; j++) {
					heights[i][j] = 0;
					velocity[i][j] = 0;
				}
			}
			
			buffer = new DisplaySurface( context.width, context.height, true, 0x00);
			
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU):Boolean {
						
			count++;
			move();
			setMesh();
			transformVertices();
			
			buffer.copyPixels(context.surface, context.rect, CONST_IDENTITY);
			
			sprite.graphics.clear();
			sprite.graphics.beginBitmapFill(buffer);
			sprite.graphics.drawTriangles(transformedVertices, indices, uvt, TriangleCulling.POSITIVE);
			sprite.graphics.endFill();
			
			context.draw(sprite);
			// swap buffer
			return blend.render(context.target, context.surface, buffer);			
		}			
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
			// dispose
			buffer.dispose();
		}	

		
		private function onClick(event:MouseEvent):void {
			mox = event.localX; 
			moy = event.localY; 
			press = true;
		}
		
		private function setMesh():void {
			for (var i:int = 2; i < num_details - 2; i++) {
				for (var j:int = 2; j < num_details - 2; j++) {
					const index:int = getIndex(i, j);
					vertices[index].y = heights[i][j] * 0.15;
					
					// ---Sphere map---
					
					var nx:Number;
					var ny:Number;
					// nz is 1
					nx = (heights[i][j] - heights[i - 1][j]) * 0.15;
					ny = (heights[i][j] - heights[i][j - 1]) * 0.15;
					var len:Number = 1 / Math.sqrt(nx * nx + ny * ny + 1);
					nx *= len;
					ny *= len;
					
					uvt[index * 2] = nx * 0.5 + 0.5 + ((i - num_details * 0.5) * inv_num_details * 0.25);
					uvt[index * 2 + 1] = ny * 0.5 + 0.5 + ((num_details * 0.5 - j) * inv_num_details * 0.25);
				}
			}
		}
		
		public function move():void {
			
			// ---Water simulation---
			
			var i:int;
			var j:int;
			for (i = 1; i < num_details - 1; i++) {
				for (j = 1; j < num_details - 1; j++) {
					heights[i][j] += velocity[i][j];
					if (heights[i][j] > 100) heights[i][j] = 100;
					else if (heights[i][j] < -100) heights[i][j] = -100;
				}
			}
			for (i = 1; i < num_details - 1; i++) {
				for (j = 1; j < num_details - 1; j++) {
					velocity[i][j] = (velocity[i][j] +
						(heights[i - 1][j] + heights[i][j - 1] + heights[i + 1][j] +
							heights[i][j + 1] - heights[i][j] * 4) * 0.5) * 0.95;
				}
			}
		}
		
		public function drag():void {
			var i:int;
			var j:int;
			var mmx:Number = mox / context.width * num_details;
			var mmy:Number = (1 - moy / context.height) * num_details;
			for (i = mmx - 3; i < num_details - 1 && mmx + 3; i++) {
				for (j = mmy - 3; j < num_details - 1 && mmy + 3; j++) {
					if (i > 1 && j > 1 && i < num_details - 1 && j < num_details - 1) {
						var len:Number = 3 - Math.sqrt((mmx - i) * (mmx - i) + (mmy - j) * (mmy - j));
						if (len < 0) len = 0;
						velocity[i][j] -= len * (press ? 1 : 5);
					}
				}
			}
		}
		
		private function getIndex(x:int, y:int):int {
			return y * num_details + x;
		}
		
		private function transformVertices():void {

			
			var angle:Number = 70 * Math.PI / 180;
			var sin:Number = Math.sin(angle);
			var cos:Number = Math.cos(angle);
			for (var i:int = 0; i < vertices.length; i++) {
				var v:Vertex = vertices[i];
				if(v != null) {
					var x:Number = v.x;
					
					var y:Number = cos * v.y - sin * v.z;
					var z:Number = sin * v.y + cos * v.z;
					
					z = 1 / (z + 60);
					
					x *= z;
					y *= z;
					
					x = x * context.width/2 + context.width/2;
					y = y * context.height/2 + context.height/2;
					transformedVertices[i * 2] = x;
					transformedVertices[i * 2 + 1] = y;
				}
			}
		}
		
	}
}
class Vertex {
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
	public function Vertex(x:Number, y:Number,z:Number) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
}
