
package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.text.*;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	
	use namespace parameter;
	
	[Parameter(type='color',		id='color', 		target='format/color')]
	[Parameter(type='number',		id='size', 			target='format/size',	clamp='6,350')]
	[Parameter(type='font',			id='font', 			target='format/font')]
	[Parameter(type='boolean',		id='embedFonts', 	target='label/embedFonts')]
	[Parameter(type='text',			id='text', 			target='label/text')]
	[Parameter(type='function',		id='start',			target='start')]
	[Parameter(type='function',		id='clear',			target='clear')]
	final public class LiveCoding extends PluginPatchTransformCPU {
		
		/**
		 * 	@private
		 */
		parameter var size:int			= 40;
		
		
		/**
		 * 	@private
		 */
		parameter const label:TextField		= new TextField();
		
		/**
		 * 	@private
		 */
		parameter const format:TextFormat	= new TextFormat(null, 28, 0xFFFFFF);
		
		private const initText = 'package onyx.patch.cpu {' +
			'\n' +
			'\timport flash.display.*;\n' +
			'import flash.events.*;\n' +
			'import flash.geom.*;\n' +
			'import flash.media.*;\n' +
			'import flash.text.*;\n' +
			'import flash.utils.*;\n' +
			'\n' +
			'import onyx.core.*;\n' +
			'import onyx.display.*;\n' +
			'import onyx.event.*;\n' +
			'import onyx.parameter.*;\n' +
			'import onyx.plugin.*;\n' +
			'\n' +
			'override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {\n' +
			'\n' +
				'// set our size to the context size\n' +
				'dimensions.width 		= context.width;\n' +
				'dimensions.height		= context.height;\n' +
				'\n' +
				'// success\n' +
				'return super.initialize(context, channel, path, content);\n' +
			'}\n' +
			'\n' +
			'final public class DrawPatch extends PluginPatchCPU {\n' +
			'\n' +
				'override public function dispose():void {\n' +
				'\n' +
					'// dispose\n' +
					'super.dispose();\n' +
					'' +
				'}\n' +
				'override protected function validate(invalidParameters:Object):void {\n' +
				'\n' +
					'label.setTextFormat(format);\n' +
					'label.defaultTextFormat = format;\n' +
					'\n' +
				'}\n' +
				'\n' +
				'override public function update(time:Number):Boolean {\n' +
				'\n' +
					'// only say we should be rendered if invalid\n' +
					'return invalid;\n' +
				'}\n' +
				'\n' +
				'override public function render(context:IDisplayContextCPU):Boolean {\n' +
				'\n' +
					'// draw the shape\n' +
					'context.clear();\n' +
					'context.draw(label, renderMatrix, null, null, null, true, StageQuality.HIGH_8X8);\n' +
					'\n' +
					'// return\n' +
					'return true;\n' +
				'}\n' +
				'\n' +
			'}\n' +
		'}\n';
		/**
		 * 	@private
		 */
		private var timer:Timer		= new Timer(120);
		private var loader:Loader				= new Loader();
		
		private var templateFile:File;
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set our size to the context size
			dimensions.width 		= context.width;
			dimensions.height		= context.height;
			
			
			label.autoSize			= TextFieldAutoSize.LEFT;
			label.antiAliasType		= AntiAliasType.ADVANCED;
			label.text				= initText;
			label.defaultTextFormat	= format;
			label.embedFonts		= true;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoader);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoader)
			loader.load(new URLRequest('template.as'));	 		
			// success
			return super.initialize(context, channel, path, content);
		}
		private function handleLoader(e:Event):void {
			
			const info:LoaderInfo = e.currentTarget as LoaderInfo;
			info.removeEventListener(Event.COMPLETE,		handleLoader);
			info.removeEventListener(IOErrorEvent.IO_ERROR, handleLoader);
			
			if (e is ErrorEvent) {
				return;
			}
			
			
			// unload
			loader.unload();
			loader = null;
			
			
		}		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			label.setTextFormat(format);
			label.defaultTextFormat = format;
			
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
			
			// draw the shape
			context.clear();
			context.draw(label, renderMatrix, null, null, null, true, StageQuality.HIGH_8X8);
			
			// return
			return true;
		}
		
		
		/**
		 * 	@private
		 */
		parameter function start():void {
			
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();

		}	
		
		/**
		 * 	@private
		 */
		parameter function clear():void {
			
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			
			label.text = '';
			
			// set invalid to true, so that we'll redraw
			invalid = true;
		}	
		
		/**
		 * 	@private
		 */		
		private function onTimer(event:TimerEvent):void {
			
			//label.text ;
			
			// set invalid to true, so that we'll redraw
			invalid = true;
			
			
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer.stop();
			
			// dispose
			super.dispose();
			
		}
	}
}