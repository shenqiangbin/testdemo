// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.events.KUploadEvent

package com.kingnare.events{
    import flash.events.Event;

    public class KUploadEvent extends Event {

        public static const LOAD_COMPLETE:String = "loadComplete";
        public static const COMPLETE:String = "complete";

        public function KUploadEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false){
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.kingnare.events

