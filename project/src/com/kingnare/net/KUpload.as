/*
KUpload by Jinxin.

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
	import com.kingnare.events.KUploadResumeEvent;
	import com.kingnare.managers.KUploadDataManager;
	import com.kingnare.managers.LocalFSOManager;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	[Event(name="loadComplete", type="com.kingnare.events.KUploadEvent")]
	[Event(name="complete", type="com.kingnare.events.KUploadEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="uploadCompleteData", type="flash.events.DataEvent")]
	[Event(name="select", type="flash.events.Event")]
	[Event(name="partComplete", type="com.kingnare.events.KUploadPartEvent")]
	[Event(name="partBegin", type="com.kingnare.events.KUploadPartEvent")]
	[Event(name="partError", type="com.kingnare.events.KUploadPartEvent")]
	[Event(name="resume", type="com.kingnare.events.KUploadResumeEvent")]
	
	public class KUpload extends EventDispatcher
	{
		private var _url:String = "";
		private var _block:uint = 1024*10;
		private var _thread:uint = 1;
		private var _md5Length:uint = 1024;
		private var _paused:Boolean = false;
		private var _partlist:Array;
		private var _fileTypes:String="*.*";
		private var _fileTypesDesc:String="Files ";
		
		private var file:FileReference;
		private var request:URLRequest;
		private var loader:URLLoader;
		private var lc:LoaderContext;
		private var count:int = 0;
		private var test:Boolean = false;
		private var manager:KUploadDataManager;
		
		public function KUpload()
		{
			lc=new LoaderContext();
			lc.checkPolicyFile=true;
			_partlist = [];
			file = new FileReference();
			request = new URLRequest();
			request.contentType ="application/octet-stream";
            request.method = URLRequestMethod.POST;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			initLoaderEvents();
			initFileEvents();
			
			manager = new KUploadDataManager();
			manager.block = _block;
			manager.md5Length = _md5Length;
		}
		
		private function initLoaderEvents():void
		{
			loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
		}
		
		private function initFileEvents():void
		{
			if(file && file is FileReference)
			{
				file.addEventListener(Event.COMPLETE, completeHandler);
				file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				file.addEventListener(Event.SELECT, selectHandler);
				file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler);
			}
		}
		 
		private function getTypeFilter():Array
		{
			
			//return new Array(getAllTypeFilter());
			return new Array( new FileFilter(_fileTypesDesc+"("+_fileTypes+")", _fileTypes));
		}
		
//		private function getAllTypeFilter():FileFilter
//		{
//			return new FileFilter("Files (*.*)", "*.*");
//		}

//		private function getImageTypeFilter():FileFilter
//		{
//			return new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
//		}
//
//		private function getTextTypeFilter():FileFilter
//		{
//			return new FileFilter("Text Files (*.txt, *.rtf)", "*.txt;*.rtf");
//		}

		private function progressHandler(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}

		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace("ioErrorHandler: " + event);
			dispatchEvent(event);
		}

		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			trace("securityErrorHandler: " + event);
			dispatchEvent(event);
		}

		private function uploadCompleteDataHandler(event:DataEvent):void
		{
			trace("uploadCompleteData: " + event);
			dispatchEvent(event);
		}
		
		private function selectHandler(event:Event):void
		{
			if(file)
			{
				manager.suffix = file.type.replace(".", "");
			//	file.load();
				dispatchEvent(event);
			}
		}
		
		private function completeHandler(event:Event):void
		{
			manager.data = file.data;
			//testFinished();
			//startUpload(manager.code, manager.suffix);
			var evt:KUploadEvent = new KUploadEvent(KUploadEvent.LOAD_COMPLETE);
			dispatchEvent(evt);
		}
		
		/**
		 * 测试以前是否上传过，上传成功与否 
		 * @param code
		 * @return 
		 * 
		 */		
		public function isFinished():Boolean
		{
			var localFile:LocalFSO = LocalFSOManager.readFile(manager.code);
			return localFile != null && localFile.finished;
		}
		
		public function isExistFSO():Boolean
		{
			var localFile:LocalFSO = LocalFSOManager.readFile(manager.code);
			return localFile != null;
		}
		
		public function testFinished():void
		{
			var localFile:LocalFSO = LocalFSOManager.readFile(manager.code);
			if(localFile && localFile.uid != "" && localFile.suffix != "")
			{
				manager.uid = localFile.uid;
				manager.suffix = localFile.suffix;
				var bytes:ByteArray = manager.getEndBytes(0);
				count = -2;
				uploadData(bytes);
			}
		}
		
		/**
		 * 上传数据块 
		 * @param bytes
		 * 
		 */		
		private function uploadData(data:ByteArray):void
		{
			request.data = data;
			loader.load(request);
		}
		
		/**
		 * 开始上传 
		 * @param encode
		 * 
		 */	
		private function startUpload(encode:String, suffix:String):void
		{
			var bytes:ByteArray = manager.getBeginBytes();
			count = -1;
			if(bytes && bytes.length>0)
				uploadData(bytes);
			else
				trace("Type 1:End of file.");
		}
		
		private function loaderIOErrorHandler(event:IOErrorEvent):void
		{
			var partIOEEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
			partIOEEvt.count = manager.getPartCount(count);
			dispatchEvent(partIOEEvt);
		}
		
		private function loaderCompleteError():void
		{
			var partIOEEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
			partIOEEvt.count = manager.getPartCount(count);
			dispatchEvent(partIOEEvt);
		}
		
		private function loaderSecurityErrorHandler(event:SecurityErrorEvent):void
		{
			var partSEEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
			partSEEvt.count = manager.getPartCount(count);
			dispatchEvent(partSEEvt);
		}
		
		private function loaderCompleteHandler(event:Event):void
		{
			var fso:LocalFSO;
			if(count==-2)
			{
				//检查是否还有剩余
				//没有
				if(loader.data == "1")
				{
					trace("Upload Completed.Successfully.");
					fso = new LocalFSO();
					fso.uid = manager.uid;
					fso.suffix = manager.suffix;
					fso.finished = true;
					LocalFSOManager.setFile(manager.uid, fso);
					
					var evt:KUploadEvent = new KUploadEvent(KUploadEvent.COMPLETE);
					dispatchEvent(evt);
					return;
				}
				else if(loader.data == "-1")
				{
					trace("loader.data:"+loader.data);
					startUpload(manager.code, manager.suffix);
					return;
				}
				else
				{
					//还有剩余,解析数据，重新上传
					trace("Not completed.", loader.data);
					resumeUpload(loader.data);
					return;
				}
			}
			if(count==-1)
			{
				if(loader.data == "")
				{
					//trace("UID is Empty.Stop.");
					loaderCompleteError();
					return;
				}
				
				var uidArray:Array = loader.data.toString().split(".");
				manager.uid = uidArray[0];
				manager.suffix = uidArray[1];
				trace("count=-1:"+manager.uid);
				//
				fso = new LocalFSO();
				fso.uid = manager.uid;
				fso.suffix = manager.suffix;
				fso.finished = false;
				LocalFSOManager.setFile(manager.uid, fso);
			}
			
			clearPartList();

			for(var p:uint=0;p<_thread;p++)
			{
				var part:KUploadParts = new KUploadParts();
					part.block = this._block;
					part.md5Length = this._md5Length;
					part.data = manager.data;
					part.list = getPartFromArray(manager.list, _thread, p);
					trace("LENGTH:",manager.list.length, part.list.length);
					part.uid = manager.uid;
					part.suffix = manager.suffix;
					part.url = this._url;
					part.addEventListener(KUploadPartEvent.PART_BEGIN, partBeginHandler);
					part.addEventListener(KUploadPartEvent.PART_ERROR, partErrorHandler);
					part.addEventListener(KUploadPartEvent.PART_COMPLETE, partCompleteHandler);
					part.addEventListener(KUploadEvent.COMPLETE, totalCompleteHandler);
				_partlist.push(part);
			}

			for(var q:uint=0;q<_thread;q++)
			{
				var cell:KUploadParts = _partlist[q] as KUploadParts;
				if(cell)
					cell.upload();
			}
		}
		
		private function clearPartList():void
		{
			for(var i:uint=0;i<_partlist.length;i++)
			{
				while(_partlist.length>0)
				{
					var cell:KUploadParts = _partlist.pop() as KUploadParts;
					cell.removeEventListener(KUploadPartEvent.PART_BEGIN, partBeginHandler);
					cell.removeEventListener(KUploadPartEvent.PART_ERROR, partErrorHandler);
					cell.removeEventListener(KUploadPartEvent.PART_COMPLETE, partCompleteHandler);
					cell.removeEventListener(KUploadEvent.COMPLETE, totalCompleteHandler);
					cell = null;
				}
			}
		}
		
		private function getPartFromArray(array:Array, count:int = -1, index:int = -1):Array
		{
			if(count == -1 || index == -1) return array;
			var every:uint = Math.floor(array.length/count);
			var beginIndex:int = every*index;
			var endIndex:int = every*(index+1);
			if(endIndex>=array.length || index==count-1)
			{
				endIndex = array.length;
			}
			return array.slice(beginIndex, endIndex);
		}
		
		private function partBeginHandler(event:KUploadPartEvent):void
		{
			var partBeginEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_BEGIN);
			partBeginEvt.count = event.count;
			dispatchEvent(partBeginEvt);
		}
		
		private function partErrorHandler(event:KUploadPartEvent):void
		{
			var partBeginEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
			partBeginEvt.count = event.count;
			dispatchEvent(partBeginEvt);
		}
		
		private function partCompleteHandler(event:KUploadPartEvent):void
		{
			var partBeginEvt:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_COMPLETE);
			partBeginEvt.count = event.count;
			dispatchEvent(partBeginEvt);
		}
		
		private function totalCompleteHandler(event:KUploadEvent):void
		{
			var completed:Boolean = true;
			for(var i:uint=0;i<_thread;i++)
			{
				var part:KUploadParts = _partlist[i];
				if(!part.completed)
					completed = false;
			}
			if(completed)
			{
				trace("3.end of file.");
				var bytes:ByteArray = manager.getEndBytes(0);
				count = -2;	
				uploadData(bytes);
			}
		}
		
		//继续上传
		private function resumeUpload(re:String):void
		{
			if(re=="") return;
			trace("resume:");
			test = false;
			var tmpArray:Array = re.split(",");
			var list:Array = [];
			var len:uint = tmpArray.length;
			for(var i:uint=0;i<len;i++)
			{
				//序号，起始位置
				var index:uint = parseInt(tmpArray[i]);
				list.push([index, index*manager.block]);
			}
			manager.list = list;
			count = 0;
			var bytes:ByteArray = manager.getPartBytes(count);
			if(bytes)
			{
				uploadData(bytes);
			}
			else
			{
				trace("resume:end of file.");
				bytes = manager.getEndBytes(count);
				count = -2;	
				uploadData(bytes);
			}
			
			var evt:KUploadResumeEvent = new KUploadResumeEvent(KUploadResumeEvent.RESUME);
			evt.list = list;
			dispatchEvent(evt);
		}
		
		/**
		 * 开始浏览文件
		 * @param typeFilter
		 * 
		 */		
		public function browse(typeFilter:Array = null):void
		{
			file.browse(getTypeFilter());
		}
		
		/**
		 * 开始上传 
		 * 
		 */		
		public function upload():void
		{
			if(manager && manager.code != "")
			{
				startUpload(manager.code, manager.suffix);
			}
		}
		
		/**
		 * 暂停上传 
		 * 
		 */		
		public function pause():void
		{
			_paused = true;
			
			for(var i:uint=0;i<_thread;i++)
			{
				var part:KUploadParts = _partlist[i];
				if(part)
					part.pause();
			}
		}
		
		/**
		 * 继续上传
		 * 
		 */		
		public function resume():void
		{
			_paused = false;
			for(var i:uint=0;i<_thread;i++)
			{
				var part:KUploadParts = _partlist[i];
				part.resume();
			}
		}
		
		/**
		 * 取消上传 
		 * 
		 */		
		public function cancel():void
		{
			//
		}
		
		
		public function clear():void
		{
			if(manager)
				manager.clear();
		}
		
		public function startLoad():void
		{
			file.load();
		}
		
		public function set block(value:uint):void
		{
			_block = value;
			if(manager)
				manager.block = _block;
		}
		
		public function get block():uint
		{
			return _block;
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
		
		public function set thread(value:uint):void
		{
			_thread = value;
		}
		
		public function get thread():uint
		{
			return _thread;
		}
		
		public function get filePartCount():uint
		{
			return manager.partCount;
		}
		
		public function get paused():Boolean
		{
			return _paused;
		}
		
		public function get speed():Number
		{
			var tmp:Number = 0;
			for(var q:uint=0;q<_thread;q++)
			{
				var cell:KUploadParts = _partlist[q] as KUploadParts;
				if(cell)
					tmp += cell.speed;
			}
			
			if(tmp > 0)
				return tmp;
			else
				return 0;
		}
		
		//设置filter属性
		public function setTypes(_fTypes:String,_fDesc:String):void
		{
			this._fileTypes=_fTypes;
			this._fileTypesDesc=_fDesc;
		}
		
		public function get name():String
		{
			return file.name;
		}
		
		public function get fileInfo():FileReference
		{
			return file;
		}
	}
	
}