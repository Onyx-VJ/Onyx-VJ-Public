package {
	
	import flash.display.*;
	
	%PLUGIN.IMPORTS%
		
	[PluginInfo(manifest='%PLUGIN.MANIFEST%', onyxSDKVersion='%PLUGIN.SDK.VERSION%', timestamp='%PLUGIN.TIMESTAMP%')]
	
	final public class %PLUGIN.CLASSNAME% extends Sprite {
		
		%PLUGIN.INCLUDES%
		%PLUGIN.CLASSES%
		
	}
}