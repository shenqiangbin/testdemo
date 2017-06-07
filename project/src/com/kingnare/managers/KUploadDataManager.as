/*
KUploadDataManager by Jinxin.

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

package com.kingnare.managers
{
	import com.adobe.crypto.MD5;
	import flash.utils.ByteArray;
	
	public class KUploadDataManager
	{
		
		private var _data:ByteArray;
		private var _code:String;
		private var _block:uint = 10240;
		private var _uid:String;
		private var _md5Length:uint = 1024;
		private var _suffix:String;
		private var _list:Array;
		
		
		public function KUploadDataManager()
		{
			_list = [];
		}
		
		//生成文件拆分数组，默认分块大小 1M
		private function getList(bytes:ByteArray, slice:uint = 10240):Array
		{
			var tmpList:Array = [];
			if(bytes)
			{
				var len:int = Math.ceil(bytes.length/slice);
				for(var i:uint=0;i<len;i++)
				{
					//[序号，起始位置]
					tmpList.push([i, i*slice]);
				}
			}
			return tmpList;
		}
		
		public function getEndBytes(count:uint = 0):ByteArray
		{
			if(!_data) return null;
			var bytes:ByteArray = new ByteArray();
			var header:ByteArray = new ByteArray();
			var info:String = "e_" + _uid + "." + _suffix + "_" + count.toString();
			trace("e:"+info);
			header.writeInt(info.length);
			header.writeUTFBytes(info);
			header.position = 0;
			bytes.writeBytes(header);
			return bytes;
		}
		
		public function getBeginBytes():ByteArray
		{
			if(!_data) return null;
			var bytes:ByteArray = new ByteArray();
			var header:ByteArray = new ByteArray();
			var slice:int = Math.ceil(_data.length/_block);
			var info:String = "b_"+_data.length+"_"+_suffix+"_"+slice.toString()+"_"+_code;
			header.writeInt(info.length);
			header.writeUTFBytes(info);
			header.position = 0;
			bytes.writeBytes(header);
			return bytes;
		}
		
		public function getPartBytes(count:int):ByteArray
		{
			if(!_data) return null;
			var bytes:ByteArray = new ByteArray();
			var len:Number = _data.length;
			var header:ByteArray;
			var info:String;
			var isEnd:Boolean;
			if(count<_list.length && _list[count] && _list[count][0]<len)
			{
				_data.position = _list[count][1];
				header = new ByteArray();
				isEnd = _list[count][1] + _block < len;
				if(isEnd)
				{
					info = "p_"+_list[count][0].toString()+"_"+_data.position.toString()+"_"+_block.toString()+"_"+_uid+"."+_suffix;
				}
				else
				{
					info = "p_"+_list[count][0].toString()+"_"+_data.position.toString()+"_"+(_data.length - _data.position).toString()+"_"+_uid+"."+_suffix;
				}
				header.writeInt(info.length);
				header.writeUTFBytes(info);
				header.position = 0;
				bytes.writeBytes(header);
				
				isEnd?_data.readBytes(bytes, bytes.position, _block):_data.readBytes(bytes, bytes.length);
				
			}
			else
			{
				return null;
			}
			
			return bytes;
		}
		
		
		public function getPartCount(count:int):int
		{
			if(count>-1 && count<_list.length)
			{
				return _list[count][0];
			}
			else
			{
				return -1;
			}
		}
		
		public function clear():void
		{
			if(_data)
				_data.clear();
			if(_list)
				_list = [];
		}
		
		
		
		private function encodeFile(data:ByteArray):String
		{
			var md5:ByteArray = new ByteArray();
			md5.length = 1024;
			if(_data.length>=1024)
			{
				_data.readBytes(md5, 0, 1024);
			}
			else
			{
				_data.readBytes(md5, 0, _data.length);
			}
			return MD5.hash(md5.toString());
		}
		
		
		
		public function set data(value:ByteArray):void
		{
			if(value)
			{
				_data = value;
				_code = encodeFile(_data);
				if(!isNaN(_block))
				{
					_list = getList(_data, _block);
					//trace(_list);
				}
			}
		}
		
		public function set dataReadOnly(value:ByteArray):void
		{
			if(value)
			{
				_data = value;
			}
		}
		
		public function set code(value:String):void
		{
			if(value)
			{
				_code = value;
			}
		}
		
		
		public function get data():ByteArray
		{
			return _data;
		}
		
		public function get code():String
		{
			return _code;
		}
		
		//拆分每块大小
		public function set block(value:uint):void
		{
			_block = value;
			if(_data)
			{
				_list = getList(_data, _block);
			}
		}
		
		public function get block():uint
		{
			return _block;
		}
		
		public function set uid(value:String):void
		{
			_uid = value;
		}
		
		public function get uid():String
		{
			return _uid;
		}
		
		public function set md5Length(value:uint):void
		{
			_md5Length = value;
		}
		
		public function set list(value:Array):void
		{
			_list = value;
		}		
		
		public function get list():Array
		{
			return _list;
		}
		
		//获取拆分块数大小
		public function get partCount():uint
		{
			return _list.length;
		}
		
		public function set suffix(value:String):void
		{
			_suffix = value;
		}
		
		public function get suffix():String
		{
			return _suffix;
		}
		
	}
}