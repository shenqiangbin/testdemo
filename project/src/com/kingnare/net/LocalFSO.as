// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.net.LocalFSO

package com.kingnare.net{
    public class LocalFSO {

        private var _uid:String;
        private var _suffix:String;
        private var _finished:Boolean;


        public function set uid(_arg_1:String):void{
            this._uid = _arg_1;
        }

        public function get uid():String{
            return (this._uid);
        }

        public function set suffix(_arg_1:String):void{
            this._suffix = _arg_1;
        }

        public function get suffix():String{
            return (this._suffix);
        }

        public function set finished(_arg_1:Boolean):void{
            this._finished = _arg_1;
        }

        public function get finished():Boolean{
            return (this._finished);
        }


    }
}//package com.kingnare.net

