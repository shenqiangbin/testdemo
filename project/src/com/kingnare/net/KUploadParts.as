/*
KUploadParts by Jinxin.

Copyright (c) 2008 www.kingnare.com  See:
http://code.google.com/p/kuploader/
or http://www.kingnare.com/auzn

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package com.kingnare.net
{
	import com.kingnare.events.KUploadEvent;
	import com.kingnare.events.KUploadPartEvent;
	import com.kingnare.managers.KUploadDataManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	[Event(name="complete", type="com.kingnare.events.KUploadEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="partComplete", type="com.kingnare.events.KUploadPartEvent")]
	[Event(name="partBegin", type="com.kingnare.events.KUploadPartEvent")]
	[Event(name="partError", type="com.kingnare.events.KUploadPartEvent")]
	
	
	public class KUploadParts extends EventDispatcher
	{
		private var _completed:Boolean;
		private var _suffix:String;
		private var _uid:String;
		private var _url:String;
		private var _list:Array;
		private var _paused:Boolean = false;
		private var _block:uint = 1024*10;
		private var _md5Length:uint = 1024;
		private var manager:KUploadDataManager;
		private var request:URLRequest;
		private var loader:URLLoader;
		private var count:int = 0;
		private var uploadTime:Number = 0;
		private var _speed:Number = 0;
		
		
		public function KUploadParts(target:IEventDispatcher=null)
		{
			super(target);
			request = new URLRequest();
			request.contentType ="application/octet-stream";
            request.method = URLRequestMethod.POST;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			initLoaderEvents();
			
			manager = new KUploadDataManager();
			manager.block = _block;
			manager.md5Length = _md5Length;
		}
		
		private function initLoaderEvents():void
		{
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		}
		
		
		/**
		 * 
		 * 得到上传list,manager,上传list中的元素
		 * 
		 * */
		
		 
		private function uploadNextPart():void
		{
			if(_paused) return;
			
			var bytes:ByteArray = manager.getPartBytes(count);
			if(bytes)
			{
				var partBeginEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_BEGIN);
				partBeginEvt.count = manager.getPartCount(count);
				dispatchEvent(partBeginEvt);
				uploadData(bytes);
			}
			else
			{
				_completed = true;
				//发布上传结束事件
				var evt:KUploadEvent = new KUploadEvent(KUploadEvent.COMPLETE);
				dispatchEvent(evt);
			}
		}
		
		/**
		 * 上传数据块 
		 * @param bytes
		 * 
		 */		
		private function uploadData(data:ByteArray):void
		{
			uploadTime = getTimer();
			request.data = data;
			loader.load(request);
		}
		
		private function loaderCompleteHandler(event:Event):void
		{
			var dur:Number = getTimer() - uploadTime;
			if(dur > 0)
			{
				//(_block/1024)/(dur/1000)
				_speed = Math.round(125*_block/(128*dur));
			}
			var partCompleteEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_COMPLETE);
			partCompleteEvt.count = manager.getPartCount(count);
			dispatchEvent(partCompleteEvt);
			count++;
			uploadNextPart();
		}
		
		private function loaderIOErrorHandler(event:IOErrorEvent):void
		{
			//trace(event);
			var partIOEEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
			partIOEEvt.count = manager.getPartCount(count);
			dispatchEvent(partIOEEvt);
			count++;
			uploadNextPart();
		}
		
		/**
		 * 开始上传 
		 * 
		 */		
		public function upload():void
		{
			if(manager && manager.code != "")
			{
				_completed = false;
				count = 0;
				uploadNextPart();
			}
		}
		
		/**
		 * 暂停上传 
		 * 
		 */		
		public function pause():void
		{
			_paused = true;
		}
		
		/**
		 * 继续上传
		 * 
		 */		
		public function resume():void
		{
			_paused = false;
			uploadNextPart();
		}
		
		
		public function set list(value:Array):void
		{
			_list = value;
			if(manager)
				manager.list = _list;
		}
		
		public function get list():Array
		{
			return _list;
		}
		
		public function set block(value:uint):void
		{
			_block = value;
			if(manager)
				manager.block = _block;
		}
		
		public function set md5Length(value:uint):void
		{
			_md5Length = value;
			if(manager)
				manager.md5Length = _block;
		}
		
		public function set data(value:ByteArray):void
		{
			manager.dataReadOnly = value;
		}
		
		public function set url(value:String):void
		{
			_url = value;
			request.url = _url;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function set suffix(value:String):void
		{
			_suffix = value;
			if(manager)
				manager.suffix = _suffix;
		}
		
		public function get suffix():String
		{
			return _suffix;
		}
		
		public function set uid(value:String):void
		{
			_uid = value;
			if(manager)
				manager.uid = _uid;
		}
		
		public function get uid():String
		{
			return _uid;
		}
		
		public function get completed():Boolean
		{
			return _completed;
		}
		
		public function get speed():Number
		{
			return _speed;
		}
		
	}
}