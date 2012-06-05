/**
 * Contains code from: http://wonderfl.net/c/3nhD
 */
package onyx.patch.cpu {
	
	import flash.display.IBitmapDrawable;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.ByteArray;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.InteractionEvent;
	import onyx.plugin.*;
	import onyx.util.encoding.Base64;
	
	use namespace parameter;
	
	
	final public class QuarternionLights extends PluginPatchCPU {
		
		private static const asShader:Vector.<String> = Vector.<String>([
			"pQEAAACkBQB0d2lybKAMbmFtZXNwYWNlADEAoAx2ZW5kb3IASldCAKAIdmVyc2lv",
			"bgABAKAMZGVzY3JpcHRpb24AZ3JhZGllbnQgaW50ZXJwb2xhdGlvbgChAQIAAAxf",
			"T3V0Q29vcmQAoQEDAQAOY29sMQCiA2RlZmF1bHRWYWx1ZQAAAAAAAAAAAAAAAACh",
			"AQMCAA5jb2wyAKIDZGVmYXVsdFZhbHVlAAAAAAA/gAAAAAAAAKEBAwMADmNvbDMA",
			"ogNkZWZhdWx0VmFsdWUAAAAAAAAAAAA/gAAAoQEDBAAOY29sNACiA2RlZmF1bHRW",
			"YWx1ZQA/gAAAP4AAAAAAAAChAQIAAANjZW50ZXIAogJtaW5WYWx1ZQAAAAAAAAAA",
			"AKICbWF4VmFsdWUAQ/oAAEP6AACiAmRlZmF1bHRWYWx1ZQBDegAAQ3oAAKEBAQEA",
			"AXN0YXJ0QW5nbGUAogFtaW5WYWx1ZQAAAAAAogFtYXhWYWx1ZQBAyQ/bogFkZWZh",
			"dWx0VmFsdWUAAAAAAKECBAUAD2RzdAAdBgDBAAAQAAIGAMEAALAAHQYAMQYAEAAd",
			"AgAQBgDAAAYCABAGAIAAHQMAEAIAwAAdAgAQAwDAAAICABABAMAAHQMAEAIAwAAy",
			"AgAQQMkP2x0EABADAMAAAQQAEAIAwAAdAgAQBADAADIEABDASQ/bKgMAEAQAwAAd",
			"AYCAAIAAADMEABABgAAAAgDAAAMAwAAdAwAQBADAADIEABBAgAAAHQYAgAMAwAAD",
			"BgCABADAADIEABBAyQ/bBAYAQAQAwAADBgBABgAAAB0DABAGAEAAMgQAEAAAAAAq",
			"AwAQBADAAB0BgIAAgAAANAAAAAGAAAAyBAAQv4AAACoDABAEAMAAHQGAQACAAAA0",
			"AAAAAYBAADIEABBAAAAAHQYAgAMAwAABBgCABADAAB0CABAGAAAAHQcA4gEAGAAd",
			"CADiAgAYADUAAAAAAAAAMgQAED+AAAAdBgCAAwDAAAEGAIAEAMAAHQIAEAYAAAAd",
			"BwDiAgAYAB0IAOIDABgANgAAAAAAAAA1AAAAAAAAADIEABA/gAAAKgMAEAQAwAAd",
			"AYBAAIAAADQAAAABgEAAHQIAEAMAwAAdBwDiAwAYAB0IAOIEABgANQAAAAAAAAAy",
			"BAAQP4AAAB0GAIADAMAAAgYAgAQAwAAdAgAQBgAAAB0HAOIEABgAHQgA4gEAGAA2",
			"AAAAAAAAADYAAAAAAAAAHQkAgAIAwAAdCQBAAgDAAB0JACACAMAAMgoA4D+AAAAC",
			"CgDiCQAYAB0LAOIHABgAAwsA4goAGAAdDADiCAAYAAMMAOIJABgAAQsA4gwAGAAd",
			"CQDiCwAYAB0KAOIIABgAAgoA4gcAGAAyCwDgAAAAADIMAOA/gAAAHQ0A4gkAGAAC",
			"DQDiBwAYAB0OAOIIABgAAg4A4gcAGAAEDwDiDgAYAAMNAOIPABgACg0A4gsAGAAJ",
			"DQDiDAAYADIOAOBAAAAAAw4A4g0AGAAyDwDgQEAAAAIPAOIOABgAHQ4A4g0AGAAD",
			"DgDiDQAYAAMOAOIPABgAHQsA4goAGAADCwDiDgAYAB0KAOIHABgAAQoA4gsAGAAd",
			"CQDiCgAYAB0KAIAJAAAAHQoAQAkAQAAdCgAgCQCAADIEABA/gAAAHQoAEAQAwAAd",
			"BQDzCgAbAA=="])
		private var shader:Shader;
		private var fAngle:Number;
		private var shape:Shape = new Shape();
		
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			Console.Log(Console.MESSAGE, 'QuarternionLights from: http://wonderfl.net/c/3nhD');
			
			var decoded:ByteArray = Base64.decode(asShader.join(""));  
			decoded.position = 0;  
			
			shader = new Shader(decoded);
			
			fAngle = 0;
			
			// add a listener for mouse events
			context.addEventListener(InteractionEvent.MOUSE_DOWN, 	handleInteraction);
			context.addEventListener(InteractionEvent.MOUSE_MOVE, 	handleInteraction);
			
			return super.initialize(context, channel, path, content);
		}
		/**
		 * 	@private
		 */
		private function handleInteraction(e:InteractionEvent):void {

			switch (e.type) {
				case InteractionEvent.MOUSE_DOWN:
					
					shader.data.startAngle.value = [fAngle];
					fAngle += 0.5;
					if (fAngle > 6.283) fAngle -= 6.283;
					
					// move graphics
					shader.data.center.value = [e.x, e.y];
					
					break;
				case InteractionEvent.MOUSE_MOVE:
					
					shader.data.center.value = [e.x, e.y];
					
					break;
				case InteractionEvent.MOUSE_UP:
					
					
					
					break;
			}
			
			invalid = true;
			
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
			
			shader.data.startAngle.value = [fAngle];
			fAngle += 0.005;
			if (fAngle > 6.283) fAngle -= 6.283;
			shape.graphics.clear();
			shape.graphics.beginShaderFill(shader);
			shape.graphics.drawRect(0, 0, context.width,context.height);
			shape.graphics.endFill();
			
			context.draw(shape);
			return true;
		}
		override public function dispose():void {
			
			// dispose
			super.dispose();
			
		}
	}
}
