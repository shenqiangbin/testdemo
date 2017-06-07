/*
LocalFSO by Jinxin.

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
	
	//记录上传文件的UID，大小，当前起始点， 块数
	
	public class LocalFSO 
	{
		
		private var _uid:String;
		private var _suffix:String;
		private var _finished:Boolean;

		public function LocalFSO() 
		{ 
			
		}
		
		public function set uid(value:String):void
		{
			_uid = value;
		}
		
		public function get uid():String
		{
			return _uid;
		}
		
		public function set suffix(value:String):void
		{
			_suffix = value;
		}
		
		public function get suffix():String
		{
			return _suffix;
		}
		
		public function set finished(value:Boolean):void
		{
			_finished = value;
		}
		
		public function get finished():Boolean
		{
			return _finished;
		}
	}
	
}