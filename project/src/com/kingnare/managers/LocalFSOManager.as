// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.managers.LocalFSOManager

package com.kingnare.managers{
    import com.kingnare.net.LocalFSO;
    import flash.net.SharedObject;

    public class LocalFSOManager {


        public static function readFile(_arg_1:String):LocalFSO{
            var _local_4:LocalFSO;
            var _local_2:SharedObject = getSO("kuploader");
            var _local_3:Object = _local_2.data.kupload[_arg_1];
            if (_local_3){
                _local_4 = new LocalFSO();
                _local_4.finished = _local_3.finished;
                _local_4.uid = _local_3.uid;
                _local_4.suffix = _local_3.suffix;
                return (_local_4);
            };
            return (null);
        }

        public static function setFile(_arg_1:String, _arg_2:LocalFSO):void{
            var _local_3:SharedObject = getSO("kuploader");
            _local_3.data.kupload[_arg_1] = _arg_2;
            _local_3.flush();
        }

        public static function delFile(_arg_1:String):void{
            var _local_2:SharedObject = SharedObject.getLocal("kuploader");
            var _local_3:Object = _local_2.data.kupload;
            delete _local_3[_arg_1];
            _local_2.data.kupload = _local_3;
            _local_2.flush();
        }

        public static function delAllFiles():void{
            var _local_1:SharedObject = SharedObject.getLocal("kuploader");
            _local_1.data.kupload = null;
            _local_1.flush();
        }

        public static function getSO(_arg_1:String):SharedObject{
            var _local_2:SharedObject = SharedObject.getLocal(_arg_1);
            if ((((_local_2.size == 0)) || ((!(_local_2.data.kupload))))){
                _local_2.data.kupload = {};
            };
            return (_local_2);
        }


    }
}//package com.kingnare.managers

