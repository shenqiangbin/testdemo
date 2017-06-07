// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.control.ImgButton

package com.kingnare.control{
    import flash.display.SimpleButton;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.display.BitmapData;
    import flash.display.Bitmap;

    public class ImgButton extends SimpleButton {

        private var _default:DisplayObject;
        private var _over:DisplayObject;
        private var _down:DisplayObject;

        public function ImgButton(_arg_1:String, _arg_2:String, _arg_3:String){
            var _local_4:Loader = new Loader();
            _local_4.contentLoaderInfo.addEventListener(Event.COMPLETE, this.drawDefault);
            var _local_5:URLRequest = new URLRequest(_arg_1);
            _local_4.load(_local_5);
            this._default = _local_4;
            var _local_6:Loader = new Loader();
            _local_6.contentLoaderInfo.addEventListener(Event.COMPLETE, this.drawOver);
            var _local_7:URLRequest = new URLRequest(_arg_2);
            _local_6.load(_local_7);
            this._over = _local_6;
            var _local_8:Loader = new Loader();
            _local_8.contentLoaderInfo.addEventListener(Event.COMPLETE, this.drawDown);
            var _local_9:URLRequest = new URLRequest(_arg_3);
            _local_8.load(_local_9);
            this._down = _local_8;
        }

        private function drawDefault(_arg_1:Event):void{
            var _local_2:BitmapData = new BitmapData(this._default.width, this._default.height, true);
            _local_2.draw(this._default);
            var _local_3:Bitmap = new Bitmap(_local_2);
            upState = _local_3;
            hitTestState = _local_3;
        }

        private function drawOver(_arg_1:Event):void{
            var _local_2:BitmapData = new BitmapData(this._over.width, this._over.height, true);
            _local_2.draw(this._over);
            var _local_3:Bitmap = new Bitmap(_local_2);
            overState = _local_3;
        }

        private function drawDown(_arg_1:Event):void{
            var _local_2:BitmapData = new BitmapData(this._down.width, this._down.height, true);
            _local_2.draw(this._down);
            var _local_3:Bitmap = new Bitmap(_local_2);
            downState = _local_3;
        }


    }
}//package com.kingnare.control

