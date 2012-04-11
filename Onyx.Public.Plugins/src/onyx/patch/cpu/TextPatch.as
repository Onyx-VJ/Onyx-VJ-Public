package onyx.patch.cpu {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='color',		name='color', 		target='format/color')]
	[Parameter(type='number',		name='size', 		target='format/size',	clamp='6,350')]
	[Parameter(type='font',			name='font', 		target='format/font')]
	[Parameter(type='boolean',		name='embedFonts', 	target='label/embedFonts')]
	[Parameter(type='text',			name='text', 		target='label/text')]

	final public class TextPatch extends PluginPatch {
		
		/**
		 * 	@private
		 */
		parameter const label:TextField		= new TextField();
		
		/**
		 * 	@private
		 */
		parameter const format:TextFormat	= new TextFormat(null, 28, 0xFFFFFF);

		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContext, path:IFileReference, content:Object):PluginStatus {
			
			dimensions.width 	= context.width;
			dimensions.height	= context.height;
			
			label.autoSize			= TextFieldAutoSize.LEFT;
			label.antiAliasType		= AntiAliasType.ADVANCED;
			label.text				= '';
			label.defaultTextFormat	= format;
			label.embedFonts		= true;
			
			// success
			return super.initialize(context, path, content);
		}
		
		/**
		 * 	@public
		 */
		override public function validate():void {
			
			label.setTextFormat(format);
			label.defaultTextFormat = format;
						
			// reset the label text
			super.validate();

		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return invalid;
		}

		/**
		 * 	@public
		 */
		override public function render(surface:IDisplaySurface):Boolean {
			
			// invalid?
			if (invalid) {
				
				// validate the everything
				validate();

			}
			
			surface.fillRect(surface.rect, 0x00);
			surface.draw(label, null, null, null, null, true);
			
			// return
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			super.dispose();

		}
	}
}