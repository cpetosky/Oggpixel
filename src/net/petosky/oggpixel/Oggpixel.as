package net.petosky.oggpixel {	
	import com.automatastudios.audio.audiodecoder.AudioDecoder;
	import com.automatastudios.audio.audiodecoder.decoders.OggVorbisDecoder;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLStream;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	public class Oggpixel extends Sprite {
		private const BUFFER_SIZE:uint = 8192;

		private var _decoder:AudioDecoder;
		private var _stream:URLStream;
		private var _channel:SoundChannel;

		public function Oggpixel() {
			Security.allowDomain("*");
			if (stage) {
				onStageInit(null);
			} else {
				addEventListener(Event.ADDED_TO_STAGE, onStageInit);
			}
		}

		private function onStageInit(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onStageInit);

			_decoder = new AudioDecoder();
			_decoder.addEventListener(Event.INIT, onDecoderInit);
			_decoder.addEventListener(Event.COMPLETE, onDecoderComplete);
			_decoder.addEventListener(IOErrorEvent.IO_ERROR, onDecoderIOError);

			ExternalInterface.addCallback("play", play);
			ExternalInterface.addCallback("stop", play);
			ExternalInterface.addCallback("getVolume", getVolume);
			ExternalInterface.addCallback("setVolume", setVolume);

			try {
				ExternalInterface.call(
						"Oggpixel.attach", ExternalInterface.objectID);
			} catch (error:Error) {
				// ignore it; let the JS attach us itself.
			}
			
		}
		
		public function play(fileName:String):void {
			stop();
			_stream = new URLStream();		
			_decoder.load(_stream, OggVorbisDecoder, BUFFER_SIZE);
			_stream.load(new URLRequest(fileName));
		}

		public function stop():void {
			if (_stream != null) {
				_stream.close();
				_channel.stop();
				ExternalInterface.call("Oggpixel._onStop");
			}
		}

		public function setVolume(volume:Number):void {
			var transform:SoundTransform = _channel.soundTransform;
			transform.volume = volume;
			_channel.soundTransform = transform;
		}

		public function getVolume():Number {
			return _channel.soundTransform.volume;
		}
		
		private function onDecoderInit(event:Event):void {
			_channel = _decoder.play();
			ExternalInterface.call("Oggpixel._onStart");
		}
		
		private function onDecoderComplete(event:Event):void { }
		private function onDecoderIOError(event:IOErrorEvent):void { }
	}
}
