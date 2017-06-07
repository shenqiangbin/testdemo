// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.events.KUploadPartEvent

package com.kingnare.events{
    import flash.events.Event;

    public class KUploadPartEvent extends Event {

        public static const PART_COMPLETE:String = "partComplete";
        public static const PART_BEGIN:String = "partBegin";
        public static const PART_ERROR:String = "partError";

        public var count:int;

        public function KUploadPartEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false){
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.kingnare.events

