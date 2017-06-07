// Decompiled by AS3 Sorcerer 4.04
// www.as3sorcerer.com

//com.kingnare.events.KUploadResumeEvent

package com.kingnare.events{
    import flash.events.Event;

    public class KUploadResumeEvent extends Event {

        public static const RESUME:String = "resume";

        public var list:Array;

        public function KUploadResumeEvent(_arg_1:String, _arg_2:Boolean=false, _arg_3:Boolean=false){
            super(_arg_1, _arg_2, _arg_3);
        }

    }
}//package com.kingnare.events

