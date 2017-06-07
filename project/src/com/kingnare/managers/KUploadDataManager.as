// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.managers.KUploadDataManager

package com.kingnare.managers{
    import flash.utils.ByteArray;
    import com.adobe.crypto.MD5;

    public class KUploadDataManager {

        private var _data:ByteArray;
        private var _code:String;
        private var _block:uint = 0x2800;
        private var _uid:String;
        private var _md5Length:uint = 0x0400;
        private var _suffix:String;
        private var _list:Array;

        public function KUploadDataManager(){
            this._list = [];
        }

        private function getList(_arg_1:ByteArray, _arg_2:uint=0x2800):Array{
            var _local_4:int;
            var _local_5:uint;
            var _local_3:Array = [];
            if (_arg_1){
                _local_4 = Math.ceil((_arg_1.length / _arg_2));
                _local_5 = 0;
                while (_local_5 < _local_4) {
                    _local_3.push([_local_5, (_local_5 * _arg_2)]);
                    _local_5++;
                };
            };
            return (_local_3);
        }

        public function getEndBytes(_arg_1:uint=0):ByteArray{
            if (!this._data){
                return (null);
            };
            var _local_2:ByteArray = new ByteArray();
            var _local_3:ByteArray = new ByteArray();
            var _local_4:String = ((((("e_" + this._uid) + ".") + this._suffix) + "_") + _arg_1.toString());
            _local_3.writeInt(_local_4.length);
            _local_3.writeUTFBytes(_local_4);
            _local_3.position = 0;
            _local_2.writeBytes(_local_3);
            return (_local_2);
        }

        public function getBeginBytes():ByteArray{
            if (!this._data){
                return (null);
            };
            var _local_1:ByteArray = new ByteArray();
            var _local_2:ByteArray = new ByteArray();
            var _local_3:int = Math.ceil((this._data.length / this._block));
            var _local_4:String = ((((((("b_" + this._data.length) + "_") + this._suffix) + "_") + _local_3.toString()) + "_") + this._code);
            _local_2.writeInt(_local_4.length);
            _local_2.writeUTFBytes(_local_4);
            _local_2.position = 0;
            _local_1.writeBytes(_local_2);
            return (_local_1);
        }

        public function getPartBytes(_arg_1:int):ByteArray{
            var _local_5:ByteArray;
            var _local_6:String;
            var _local_7:Boolean;
            var _local_8:uint;
            if (!this._data){
                return (null);
            };
            var _local_2:ByteArray = new ByteArray();
            var _local_3:ByteArray = new ByteArray();
            var _local_4:Number = this._data.length;
            if ((((((_arg_1 < this._list.length)) && (this._list[_arg_1]))) && ((this._list[_arg_1][0] < _local_4)))){
                _local_8 = this._list[_arg_1][1];
                this._data.position = _local_8;
                _local_5 = new ByteArray();
                _local_7 = ((this._list[_arg_1][1] + this._block) < _local_4);
                if (_local_7){
                    this._data.readBytes(_local_3, 0, this._block);
                }
                else {
                    this._data.readBytes(_local_3, 0);
                };
                if (_local_7){
                    _local_6 = ((((((((((("p_" + this._list[_arg_1][0].toString()) + "_") + _local_8) + "_") + this._block.toString()) + "_") + this._uid) + ".") + this._suffix) + "_") + this.encodeFilePart(_local_3));
                }
                else {
                    _local_6 = ((((((((((("p_" + this._list[_arg_1][0].toString()) + "_") + _local_8) + "_") + (this._data.length - _local_8).toString()) + "_") + this._uid) + ".") + this._suffix) + "_") + this.encodeFilePart(_local_3));
                };
                _local_5.writeInt(_local_6.length);
                _local_5.writeUTFBytes(_local_6);
                _local_5.position = 0;
                _local_2.writeBytes(_local_5);
                _local_3.readBytes(_local_2, _local_2.position, _local_3.length);
            }
            else {
                return (null);
            };
            return (_local_2);
        }

        public function getPartCount(_arg_1:int):int{
            if ((((_arg_1 > -1)) && ((_arg_1 < this._list.length)))){
                return (this._list[_arg_1][0]);
            };
            return (-1);
        }

        public function clear():void{
            if (this._data){
                this._data.clear();
            };
            if (this._list){
                this._list = [];
            };
        }

        private function encodeFile(_arg_1:ByteArray):String{
            var _local_2:ByteArray = new ByteArray();
            _local_2.length = 0x0400;
            if (this._data.length >= 0x0400){
                this._data.readBytes(_local_2, 0, 0x0400);
            }
            else {
                this._data.readBytes(_local_2, 0, this._data.length);
            };
            return (MD5.hash(_local_2.toString()));
        }

        private function encodeFilePart(_arg_1:ByteArray):String{
            var _local_2 = "";
            var _local_3:int;
            while (_local_3 < _arg_1.length) {
                _local_2 = (_local_2 + _arg_1[_local_3].toString());
                _local_3++;
            };
            return (MD5.hash(_local_2));
        }

        public function set data(_arg_1:ByteArray):void{
            if (_arg_1){
                this._data = _arg_1;
                this._code = this.encodeFile(this._data);
                if (!isNaN(this._block)){
                    this._list = this.getList(this._data, this._block);
                };
            };
        }

        public function set dataReadOnly(_arg_1:ByteArray):void{
            if (_arg_1){
                this._data = _arg_1;
            };
        }

        public function set code(_arg_1:String):void{
            if (_arg_1){
                this._code = _arg_1;
            };
        }

        public function get data():ByteArray{
            return (this._data);
        }

        public function get code():String{
            return (this._code);
        }

        public function set block(_arg_1:uint):void{
            this._block = _arg_1;
            if (this._data){
                this._list = this.getList(this._data, this._block);
            };
        }

        public function get block():uint{
            return (this._block);
        }

        public function set uid(_arg_1:String):void{
            this._uid = _arg_1;
        }

        public function get uid():String{
            return (this._uid);
        }

        public function set md5Length(_arg_1:uint):void{
            this._md5Length = _arg_1;
        }

        public function set list(_arg_1:Array):void{
            this._list = _arg_1;
        }

        public function get list():Array{
            return (this._list);
        }

        public function get partCount():uint{
            return (this._list.length);
        }

        public function set suffix(_arg_1:String):void{
            this._suffix = _arg_1;
        }

        public function get suffix():String{
            return (this._suffix);
        }


    }
}//package com.kingnare.managers

