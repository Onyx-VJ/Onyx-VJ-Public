package onyx.patch.cpu {
	
	import flash.events.AsyncErrorEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[Parameter(type='text',		id='host',			target='host')]
	[Parameter(type='text',		id='streamName',	target='streamName')]
	[Parameter(type='function',	id='connect',		target='connect')]
	
	final public class RTMPatch extends PluginPatchCPU {
		
		/**
		 * 	@parameter
		 */
		parameter var host:String								= 'rtmp://localhost/live';
		
		/**
		 * 	@parameter
		 */
		parameter var streamName:String							= 'livestream';
		
		/**
		 * 	@private
		 * 	This should share connections!
		 */
		private var connection:NetConnection					= new NetConnection();
		
		/**
		 * 	@private
		 */
		private var stream:NetStream;
		
		/**
		 * 	@private
		 */
		private var video:Video;
		/**
		 * 	@public
		 */
		override public function initialize(context:IDisplayContextCPU, channel:IChannelCPU, path:IFileReference, content:Object):PluginStatus {
			
			// set to the same size as the blah blah
			dimensions.width	= context.width;
			dimensions.height	= context.height;

			connect();
			
			return super.initialize(context, channel, path, content);
		}
		
		/**
		 * 	@parameter
		 */
		parameter function connect():void {
			trace("connect");
			if (connection.uri !== host) {
				
				if (connection.connected) {
					clearConnections();
				}
				
				connection.addEventListener(NetStatusEvent.NET_STATUS, handleConnection);
				connection.client = this;
				connection.connect(host);
				
			}
		}
		/**
		 * 	@public
		 */
		public function onBWDone():void {
			trace("onBWDone");
		}
		/**
		 * 	@public
		 */
		public function onFCSubscribe(info:Object):void{
			trace("onFCSubscribe");
		}

		/**
		 * 	@private
		 */
		private function clearConnections():void {
			
			connection.close();
			if (stream) {
				stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,		trace);
				stream.removeEventListener(NetStatusEvent.NET_STATUS,	handleStream);
				stream.close();
			}
			if (video) {
				video.attachNetStream(null);
				video = null;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleConnection(event:NetStatusEvent):void {
			Console.Log(CONSOLE::MESSAGE, 'RTMPatch: ' + event.info.code);
			switch (event.info.code) {
				case 'NetConnection.Connect.Success':
					
					stream = new NetStream(connection);
					stream.client	= this;
					stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, trace);
					stream.addEventListener(NetStatusEvent.NET_STATUS, handleStream);
					
					stream.bufferTime			= 0;
					stream.backBufferTime		= 0;
					stream.useHardwareDecoder	= true;
					stream.play(streamName);
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function onMetaData(info:Object):void {
			
			Console.Log(CONSOLE::MESSAGE, 'RTMPatch: ' + info.width, info.height);
			
			invalid = true;
			
			if (video) {
				video.attachNetStream(null);
				video = null;
			}
			
			dimensions.width 	= info.width;
			dimensions.height	= info.height;
			
			video	= new Video(info.width, info.height);
			video.attachNetStream(stream);

		}
		
		/**
		 * 	@public
		 */
		override public function update(time:Number):Boolean {
			return true;
		}
		
		/**
		 * 	@private
		 */
		private function handleStream(e:NetStatusEvent):void {
			trace(e.info.code);
		}
		
		/**
		 * 	@public
		 */
		override public function render(context:IDisplayContextCPU):Boolean {

			if (video) {
				context.clear();
				try {
					context.draw(video);
				} catch (e:Error) {
					Console.Log(CONSOLE::ERROR, e.message);
				}
			}
			return true;
		}
		
		/**
		 * 	@public
		 */
		override public function dispose():void {
			
			if (stream) {
				
				stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,		trace);
				stream.removeEventListener(NetStatusEvent.NET_STATUS,	handleStream);
				stream.close();
				stream = null;
				
			}
			
			if (connection) {
				connection.removeEventListener(NetStatusEvent.NET_STATUS, handleConnection);
				if (connection.connected) {
					connection.close();
				}
			}
			
			super.dispose();
			
		}

	}
}