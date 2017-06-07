// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.net.KUpload

package com.kingnare.net{
    import flash.events.EventDispatcher;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.system.LoaderContext;
    import com.kingnare.managers.KUploadDataManager;
    import flash.net.URLRequestMethod;
    import flash.net.URLLoaderDataFormat;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.DataEvent;
    import flash.net.FileFilter;
    import com.kingnare.events.KUploadEvent;
    import com.kingnare.managers.LocalFSOManager;
    import flash.utils.ByteArray;
    import com.kingnare.events.KUploadPartEvent;
    import com.kingnare.events.KUploadResumeEvent;

    public class KUpload extends EventDispatcher {

        private var _url:String = "";
        private var _block:uint = 0x2800;
        private var _thread:uint = 1;
        private var _md5Length:uint = 0x0400;
        private var _paused:Boolean = false;
        private var _partlist:Array;
        private var _fileTypes:String = "*.*";
        private var _fileTypesDesc:String = "Files ";
        private var file:FileReference;
        private var request:URLRequest;
        private var loader:URLLoader;
        private var lc:LoaderContext;
        private var count:int = 0;
        private var test:Boolean = false;
        private var manager:KUploadDataManager;

        public function KUpload(){
            this.lc = new LoaderContext();
            this.lc.checkPolicyFile = true;
            this._partlist = [];
            this.file = new FileReference();
            this.request = new URLRequest();
            this.request.contentType = "application/octet-stream";
            this.request.method = URLRequestMethod.POST;
            this.loader = new URLLoader();
            this.loader.dataFormat = URLLoaderDataFormat.BINARY;
            this.initLoaderEvents();
            this.initFileEvents();
            this.manager = new KUploadDataManager();
            this.manager.block = this._block;
            this.manager.md5Length = this._md5Length;
        }

        private function initLoaderEvents():void{
            this.loader.addEventListener(Event.COMPLETE, this.loaderCompleteHandler);
            this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.loaderIOErrorHandler);
        }

        private function initFileEvents():void{
            if (((this.file) && ((this.file is FileReference)))){
                this.file.addEventListener(Event.COMPLETE, this.completeHandler);
                this.file.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
                this.file.addEventListener(ProgressEvent.PROGRESS, this.progressHandler);
                this.file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
                this.file.addEventListener(Event.SELECT, this.selectHandler);
                this.file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.uploadCompleteDataHandler);
            };
        }

        private function getTypeFilter():Array{
            return (new Array(new FileFilter((((this._fileTypesDesc + "(") + this._fileTypes) + ")"), this._fileTypes)));
        }

        private function progressHandler(_arg_1:ProgressEvent):void{
            dispatchEvent(_arg_1);
        }

        private function ioErrorHandler(_arg_1:IOErrorEvent):void{
            dispatchEvent(_arg_1);
        }

        private function securityErrorHandler(_arg_1:SecurityErrorEvent):void{
            dispatchEvent(_arg_1);
        }

        private function uploadCompleteDataHandler(_arg_1:DataEvent):void{
            dispatchEvent(_arg_1);
        }

        private function selectHandler(_arg_1:Event):void{
            if (this.file){
                this.manager.suffix = this.file.type.replace(".", "");
                dispatchEvent(_arg_1);
            };
        }

        private function completeHandler(_arg_1:Event):void{
            this.manager.data = this.file.data;
            var _local_2:KUploadEvent = new KUploadEvent(KUploadEvent.LOAD_COMPLETE);
            dispatchEvent(_local_2);
        }

        public function isFinished():Boolean{
            var _local_1:LocalFSO = LocalFSOManager.readFile(this.manager.code);
            return ((((!((_local_1 == null)))) && (_local_1.finished)));
        }

        public function isExistFSO():Boolean{
            var _local_1:LocalFSO = LocalFSOManager.readFile(this.manager.code);
            return ((!((_local_1 == null))));
        }

        public function testFinished():void{
            var _local_2:ByteArray;
            var _local_1:LocalFSO = LocalFSOManager.readFile(this.manager.code);
            if (((((_local_1) && ((!((_local_1.uid == "")))))) && ((!((_local_1.suffix == "")))))){
                this.manager.uid = _local_1.uid;
                this.manager.suffix = _local_1.suffix;
                _local_2 = this.manager.getEndBytes(0);
                this.count = -2;
                this.uploadData(_local_2);
            };
        }

        private function uploadData(_arg_1:ByteArray):void{
            this.request.data = _arg_1;
            this.loader.load(this.request);
        }

        private function startUpload(_arg_1:String, _arg_2:String):void{
            var _local_3:ByteArray = this.manager.getBeginBytes();
            this.count = -1;
            if (((_local_3) && ((_local_3.length > 0)))){
                this.uploadData(_local_3);
            };
        }

        private function loaderIOErrorHandler(_arg_1:IOErrorEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
            _local_2.count = this.manager.getPartCount(this.count);
            dispatchEvent(_local_2);
        }

        private function loaderCompleteError():void{
            var _local_1:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
            _local_1.count = this.manager.getPartCount(this.count);
            dispatchEvent(_local_1);
        }

        private function loaderSecurityErrorHandler(_arg_1:SecurityErrorEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
            _local_2.count = this.manager.getPartCount(this.count);
            dispatchEvent(_local_2);
        }

        private function loaderCompleteHandler(_arg_1:Event):void{
            var _local_2:LocalFSO;
            var _local_5:KUploadEvent;
            var _local_6:Array;
            var _local_7:KUploadParts;
            var _local_8:KUploadParts;
            if (this.count == -2){
                if (this.loader.data == "ok"){
                    _local_2 = new LocalFSO();
                    _local_2.uid = this.manager.uid;
                    _local_2.suffix = this.manager.suffix;
                    _local_2.finished = true;
                    LocalFSOManager.setFile(this.manager.uid, _local_2);
                    _local_5 = new KUploadEvent(KUploadEvent.COMPLETE);
                    dispatchEvent(_local_5);
                    return;
                };
                if (this.loader.data == "-1"){
                    this.startUpload(this.manager.code, this.manager.suffix);
                    return;
                };
                this.resumeUpload(this.loader.data);
                return;
            };
            if (this.count == -1){
                if (this.loader.data == ""){
                    this.loaderCompleteError();
                    return;
                };
                _local_6 = this.loader.data.toString().split(".");
                this.manager.uid = _local_6[0];
                this.manager.suffix = _local_6[1];
                _local_2 = new LocalFSO();
                _local_2.uid = this.manager.uid;
                _local_2.suffix = this.manager.suffix;
                _local_2.finished = false;
                LocalFSOManager.setFile(this.manager.uid, _local_2);
            };
            this.clearPartList();
            var _local_3:uint;
            while (_local_3 < this._thread) {
                _local_7 = new KUploadParts();
                _local_7.block = this._block;
                _local_7.md5Length = this._md5Length;
                _local_7.data = this.manager.data;
                _local_7.list = this.getPartFromArray(this.manager.list, this._thread, _local_3);
                _local_7.uid = this.manager.uid;
                _local_7.suffix = this.manager.suffix;
                _local_7.url = this._url;
                _local_7.addEventListener(KUploadPartEvent.PART_BEGIN, this.partBeginHandler);
                _local_7.addEventListener(KUploadPartEvent.PART_ERROR, this.partErrorHandler);
                _local_7.addEventListener(KUploadPartEvent.PART_COMPLETE, this.partCompleteHandler);
                _local_7.addEventListener(KUploadEvent.COMPLETE, this.totalCompleteHandler);
                this._partlist.push(_local_7);
                _local_3++;
            };
            var _local_4:uint;
            while (_local_4 < this._thread) {
                _local_8 = (this._partlist[_local_4] as KUploadParts);
                if (_local_8){
                    _local_8.upload();
                };
                _local_4++;
            };
        }

        private function clearPartList():void{
            var _local_2:KUploadParts;
            var _local_1:uint;
            while (_local_1 < this._partlist.length) {
                while (this._partlist.length > 0) {
                    _local_2 = (this._partlist.pop() as KUploadParts);
                    _local_2.removeEventListener(KUploadPartEvent.PART_BEGIN, this.partBeginHandler);
                    _local_2.removeEventListener(KUploadPartEvent.PART_ERROR, this.partErrorHandler);
                    _local_2.removeEventListener(KUploadPartEvent.PART_COMPLETE, this.partCompleteHandler);
                    _local_2.removeEventListener(KUploadEvent.COMPLETE, this.totalCompleteHandler);
                    _local_2 = null;
                };
                _local_1++;
            };
        }

        private function getPartFromArray(_arg_1:Array, _arg_2:int=-1, _arg_3:int=-1):Array{
            if ((((_arg_2 == -1)) || ((_arg_3 == -1)))){
                return (_arg_1);
            };
            var _local_4:uint = Math.floor((_arg_1.length / _arg_2));
            var _local_5:int = (_local_4 * _arg_3);
            var _local_6:int = (_local_4 * (_arg_3 + 1));
            if ((((_local_6 >= _arg_1.length)) || ((_arg_3 == (_arg_2 - 1))))){
                _local_6 = _arg_1.length;
            };
            return (_arg_1.slice(_local_5, _local_6));
        }

        private function partBeginHandler(_arg_1:KUploadPartEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_BEGIN);
            _local_2.count = _arg_1.count;
            dispatchEvent(_local_2);
        }

        private function partErrorHandler(_arg_1:KUploadPartEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_ERROR);
            _local_2.count = _arg_1.count;
            dispatchEvent(_local_2);
        }

        private function partCompleteHandler(_arg_1:KUploadPartEvent):void{
            var _local_2:KUploadPartEvent = new KUploadPartEvent(KUploadPartEvent.PART_COMPLETE);
            _local_2.count = _arg_1.count;
            dispatchEvent(_local_2);
        }

        private function totalCompleteHandler(_arg_1:KUploadEvent):void{
            var _local_4:KUploadParts;
            var _local_5:ByteArray;
            var _local_2:Boolean = true;
            var _local_3:uint;
            while (_local_3 < this._thread) {
                _local_4 = this._partlist[_local_3];
                if (!_local_4.completed){
                    _local_2 = false;
                };
                _local_3++;
            };
            if (_local_2){
                _local_5 = this.manager.getEndBytes(0);
                this.count = -2;
                this.uploadData(_local_5);
            };
        }

        private function resumeUpload(_arg_1:String):void{
            var _local_8:uint;
            if (_arg_1 == ""){
                return;
            };
            this.test = false;
            var _local_2:Array = _arg_1.split(",");
            var _local_3:Array = [];
            var _local_4:uint = _local_2.length;
            var _local_5:uint;
            while (_local_5 < _local_4) {
                _local_8 = parseInt(_local_2[_local_5]);
                _local_3.push([_local_8, (_local_8 * this.manager.block)]);
                _local_5++;
            };
            this.manager.list = _local_3;
            this.count = 0;
            var _local_6:ByteArray = this.manager.getPartBytes(this.count);
            if (_local_6){
                this.uploadData(_local_6);
            }
            else {
                _local_6 = this.manager.getEndBytes(this.count);
                this.count = -2;
                this.uploadData(_local_6);
            };
            var _local_7:KUploadResumeEvent = new KUploadResumeEvent(KUploadResumeEvent.RESUME);
            _local_7.list = _local_3;
            dispatchEvent(_local_7);
        }

        public function browse(_arg_1:Array=null):void{
            this.file.browse(this.getTypeFilter());
        }

        public function upload():void{
            if (((this.manager) && ((!((this.manager.code == "")))))){
                this.startUpload(this.manager.code, this.manager.suffix);
            };
        }

        public function pause():void{
            var _local_2:KUploadParts;
            this._paused = true;
            var _local_1:uint;
            while (_local_1 < this._thread) {
                _local_2 = this._partlist[_local_1];
                if (_local_2){
                    _local_2.pause();
                };
                _local_1++;
            };
        }

        public function resume():void{
            var _local_2:KUploadParts;
            this._paused = false;
            var _local_1:uint;
            while (_local_1 < this._thread) {
                _local_2 = this._partlist[_local_1];
                _local_2.resume();
                _local_1++;
            };
        }

        public function cancel():void{
        }

        public function clear():void{
            if (this.manager){
                this.manager.clear();
            };
        }

        public function startLoad():void{
            this.file.load();
        }

        public function set block(_arg_1:uint):void{
            this._block = _arg_1;
            if (this.manager){
                this.manager.block = this._block;
            };
        }

        public function get block():uint{
            return (this._block);
        }

        public function set url(_arg_1:String):void{
            this._url = _arg_1;
            this.request.url = this._url;
        }

        public function get url():String{
            return (this._url);
        }

        public function set thread(_arg_1:uint):void{
            this._thread = _arg_1;
        }

        public function get thread():uint{
            return (this._thread);
        }

        public function get filePartCount():uint{
            return (this.manager.partCount);
        }

        public function get paused():Boolean{
            return (this._paused);
        }

        public function get speed():Number{
            var _local_3:KUploadParts;
            var _local_1:Number = 0;
            var _local_2:uint;
            while (_local_2 < this._thread) {
                _local_3 = (this._partlist[_local_2] as KUploadParts);
                if (_local_3){
                    _local_1 = (_local_1 + _local_3.speed);
                };
                _local_2++;
            };
            if (_local_1 > 0){
                return (_local_1);
            };
            return (0);
        }

        public function setTypes(_arg_1:String, _arg_2:String):void{
            this._fileTypes = _arg_1;
            this._fileTypesDesc = _arg_2;
        }

        public function get name():String{
            return (this.file.name);
        }

        public function get fileInfo():FileReference{
            return (this.file);
        }


    }
}//package com.kingnare.net

