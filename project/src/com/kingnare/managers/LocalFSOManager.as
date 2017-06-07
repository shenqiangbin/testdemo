/*
LocalFSOManager by Jinxin.

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
	import com.kingnare.net.LocalFSO;
	
	import flash.net.SharedObject;
	
	public class LocalFSOManager 
	{
	
		public function LocalFSOManager() 
		{ 
			
		}
	
		public static function readFile(value:String):LocalFSO
		{
			var so:SharedObject = getSO("kuploader");
			var obj:Object = so.data.kupload[value];
			if(obj)
			{	
				var data:LocalFSO = new LocalFSO();
				data.finished = obj.finished;
				data.uid = obj.uid;
				data.suffix = obj.suffix;
				return data;
			}
			else
			{
				return null;
			}
		}
		
		public static function setFile(name:String, value:LocalFSO):void
		{
			var so:SharedObject = getSO("kuploader");
			so.data.kupload[name] = value;
			so.flush();
		}
		
		public static function delFile(name:String):void
		{
			var so:SharedObject = SharedObject.getLocal("kuploader");
			var data:Object = so.data.kupload;
			delete data[name];
			so.data.kupload = data;
			so.flush();
		}
		
		public static function delAllFiles():void
		{
			var so:SharedObject = SharedObject.getLocal("kuploader");
			so.data.kupload = null;
			so.flush();
		}
		
		
		public static function getSO(name:String):SharedObject
		{
			var so:SharedObject = SharedObject.getLocal(name);
			if (so.size == 0 || !so.data.kupload)
			{
			    trace("create shareobject...");
			    so.data.kupload = {};
			}
			return so;
		}
	}
	
}