// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.net.KUploadParts

package com.kingnare.net{
    import flash.events.EventDispatcher;
    import com.kingnare.managers.KUploadDataManager;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.net.URLRequestMethod;
    import flash.net.URLLoaderDataFormat;
    import flash.events.IEventDispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import com.kingnare.events.KUploadPartEvent;
    import com.kingnare.events.KUploadEvent;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;

    public class KUploadParts extends EventDispatcher {

        private var _completed:Boolean;
        private var _suffix:String;
        private var _uid:String;
        private var _url:String;
        private var _list:Array;
        private var _paused:Boolean = false;
        private var _block:uint = 0x2800;
        private var _md5Length:uint = 0x0400;
        private var manager:KUploadDataManager;
        private var request:URLRequest;
        private var loader:URLLoader;
        private var count:int = 0;
        private var uploadTime:Number = 0;
        private var _speed:Number = 0;

        public function KUploadParts(_arg_1:IEventDispatcher=null){
            super(_arg_1);
            this.request = new URLRequest();
            this.request.contentType = "application/octet-stream";
            this.request.method = URLRequestMethod.POST;
            this.loader = new URLLoader();
            this.loader.dataFormat = URLLoaderDataFormat.BINARY;
            this.initLoaderEvents();
            this.manager = new KUploadDataManager();
            this.manager.block = this._block;
            this.manager.md5Length = this._md5Length;
        }

        private function initLoaderEvents():void{
            this.loader.addEventListener(Event.COMPLETE, this.loaderCompleteHandler);
            this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.loaderIOErrorHandler);
        }

        private function uploadNextPart():void{
            var _local_2:KUploadPartEvent;
            var _local_3:KUploadEvent;
            if (this._paused){
                return;
            };
            var _local_1:ByteArray = this.manager.getPartBytes(this.count);
            if (_local_1){
                _local_2 = new KUploadPartEvent(KUploadPartEvent.PART_BEGIN);
                _local_2.count = this.manager.getPartCount(this.count);
                dispatchEvent(_local_2);
                this.uploadData(_local_1);
            }
            else {
                this._completed = true;
                _local_3 = new KUploadEvent(KUploadEvent.COMPLETE);
                dispatchEvent(_local_3);
            };
        }

        private function uploadData(_arg_1:ByteArray):void{
            this.uploadTime = getTimer();
            this.request.data = _arg_1;
            this.loader.load(this.request);
        }

        private function loaderCompleteHandler(_arg_1:Event):void{
            var _local_2:Number = (getTimer() - this.uploadTime);
            if (_local_2 > 0){
                this._speed = Math.round(((125 * this._block) / (128 * _local_2)));
            };
            var _local_3:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_COMPLETE);
            _local_3.count = this.manager.getPartCount(this.count);
            dispatchEvent(_local_3);
            this.count++;
            this.uploadNextPart();
        }

        private function loaderIOErrorHandler(_arg_1:IOErrorEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
            _local_2.count = this.manager.getPartCount(this.count);
            dispatchEvent(_local_2);
            this.count++;
            this.uploadNextPart();
        }

        public function upload():void{
            if (((this.manager) && ((!((this.manager.code == "")))))){
                this._completed = false;
                this.count = 0;
                this.uploadNextPart();
            };
        }

        public function pause():void{
            this._paused = true;
        }

        public function resume():void{
            this._paused = false;
            this.uploadNextPart();
        }

        public function set list(_arg_1:Array):void{
            this._list = _arg_1;
            if (this.manager){
                this.manager.list = this._list;
            };
        }

        public function get list():Array{
            return (this._list);
        }

        public function set block(_arg_1:uint):void{
            this._block = _arg_1;
            if (this.manager){
                this.manager.block = this._block;
            };
        }

        public function set md5Length(_arg_1:uint):void{
            this._md5Length = _arg_1;
            if (this.manager){
                this.manager.md5Length = this._block;
            };
        }

        public function set data(_arg_1:ByteArray):void{
            this.manager.dataReadOnly = _arg_1;
        }

        public function set url(_arg_1:String):void{
            this._url = _arg_1;
            this.request.url = this._url;
        }

        public function get url():String{
            return (this._url);
        }

        public function set suffix(_arg_1:String):void{
            this._suffix = _arg_1;
            if (this.manager){
                this.manager.suffix = this._suffix;
            };
        }

        public function get suffix():String{
            return (this._suffix);
        }

        public function set uid(_arg_1:String):void{
            this._uid = _arg_1;
            if (this.manager){
                this.manager.uid = this._uid;
            };
        }

        public function get uid():String{
            return (this._uid);
        }

        public function get completed():Boolean{
            return (this._completed);
        }

        public function get speed():Number{
            return (this._speed);
        }


    }
}//package com.kingnare.net

