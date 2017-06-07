
package  com.kingnare.control
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.net.URLRequest;
		
		public class ImgButton extends SimpleButton {
			private var _default:DisplayObject;
			private var _over:DisplayObject;
			private var _down:DisplayObject;
			public function ImgButton(defaultUrl:String,overUrl:String,downUrl:String) {
				
					var _defaultLoader:Loader=new Loader;
					_defaultLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,drawDefault);
					var request:URLRequest=new URLRequest(defaultUrl);
					_defaultLoader.load(request);
					_default=_defaultLoader;
					var _overLoader:Loader=new Loader;
					_overLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,drawOver);
					var request_over:URLRequest=new URLRequest(overUrl);
					_overLoader.load(request_over);
					_over=_overLoader;
					var _downLoader:Loader=new Loader;
					_downLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,drawDown);
					var request_down:URLRequest=new URLRequest(downUrl);
					_downLoader.load(request_down);					
					_down=_downLoader;
			}
			private function drawDefault(event:Event):void {
				
				var btmd:BitmapData=new BitmapData(_default.width,_default.height,true);
				btmd.draw(_default);
				var up:Bitmap=new Bitmap(btmd);
				//var over:Bitmap=new Bitmap(btmd);
				//var down:Bitmap=new Bitmap(btmd);
				
				//var mat:Array = [ 	2,0,0,0,0,
				//				   	0,2,0,0,0,
				//					0,0,1,0,0,
				//					0,0,0,1,0 ];
				
				//var filter_over:ColorMatrixFilter = new ColorMatrixFilter(mat);
				//over.filters = [filter_over];
				//var bv1:BevelFilter=new BevelFilter;
				//var bv2:BevelFilter=new BevelFilter(4,235);
				//up.filters=[bv1];
				//over.filters=[bv1];
				//down.filters=[bv2];
				//var cf:ColorTransform=new ColorTransform(.9,.9,.9);
				//over.transform.colorTransform=cf;
				//var cf:ColorTransform=new ColorTransform(.5,.5,.5);
				//down.transform.colorTransform=cf;
				upState=up;
				//overState=over;
				//downState=down;
				hitTestState=up;
			}
			
			
			
			private function drawOver(event:Event):void 
			{
				var btmd:BitmapData=new BitmapData(_over.width,_over.height,true);
				btmd.draw(_over);
				var over:Bitmap=new Bitmap(btmd);
				overState=over;
			}
			
			
			
			private function drawDown(event:Event):void {
			
				var btmd:BitmapData=new BitmapData(_down.width,_down.height,true);
				btmd.draw(_down);
				var down:Bitmap=new Bitmap(btmd);
				downState=down;
			}
		}
}