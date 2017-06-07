package
{
	
	import com.kingnare.control.ImgButton;
	import com.kingnare.events.KUploadEvent;
	import com.kingnare.events.KUploadPartEvent;
	import com.kingnare.events.KUploadResumeEvent;
	import com.kingnare.net.KUpload;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	
	
	[SWF(width="78", height="30" ,backgroundColor="#CCCCCC")]
	public class KUploader extends Sprite
	{		
		
		private var fileTypes:String;		
		private var fileTypesDesc:String;
		private var uploadURL:String;
		private var speedTimer:Timer;
		private var js_obj:Object={};
		private var upcount:int=0;
		private var totcount:int=1;
		private var imgBtnUrl:String;
		//上传组件
		private var upload:KUpload;
		private var browseBtn:ImgButton;
		
		private var JSKUploadName:String;
		
		public function KUploader()
		{
			
			Init();
		}
		
		
		protected function Init():void
		{
			this.JSKUploadName = String(root.loaderInfo.parameters["JSKUploadName"]);
			
			upload = new KUpload();
			//Block size 每次上传的块大小
			upload.block = 1024*8;
			//Thread number 上传的"线程"数
			upload.thread = 2;
			upload.url = "http://localhost/kupload/Default.aspx";
			upload.addEventListener(KUploadPartEvent.PART_COMPLETE, partCompleteHandler);
			upload.addEventListener(KUploadEvent.LOAD_COMPLETE, loadCompleteHandler);
			upload.addEventListener(KUploadPartEvent.PART_BEGIN, partBeginHandler);
			upload.addEventListener(KUploadPartEvent.PART_ERROR, partErrorHandler);
			upload.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			upload.addEventListener(KUploadEvent.COMPLETE, completeHandler);
			upload.addEventListener(KUploadResumeEvent.RESUME, resumeHandler);
			upload.addEventListener(Event.SELECT, selectHandler);
			
			speedTimer = new Timer(1000);
			speedTimer.addEventListener(TimerEvent.TIMER, speedTimerHandler);
			
			
			initVariable();
			
			initButton(imgBtnUrl+"view.png",imgBtnUrl+"viewhover.png",imgBtnUrl+"viewclick.png");
			
		}
		
		
		//初始化交互变量
		private function initVariable():void
		{
			//	var _url:String=String(ExternalInterface.call(this.JSKUploadName + ".getUrlHandler"));
			//	this.upload.url = buildUrl(_url,decodeURIComponent(root.loaderInfo.parameters.params));			
			
			this.upload.block = uint(ExternalInterface.call(this.JSKUploadName + ".getBlockHandler"));
			this.upload.thread = uint(ExternalInterface.call(this.JSKUploadName + ".getThreadHandler"));
			var ftypes:String = String(ExternalInterface.call(this.JSKUploadName + ".getFileTypeHandler"));
			var ftypeDesc:String = String(ExternalInterface.call(this.JSKUploadName + ".getFileDescHandler"));
			imgBtnUrl = String(ExternalInterface.call(this.JSKUploadName + ".getImgBtnUrl"));
			ExternalInterface.addCallback("continueUpload",yesContinueUpload);
			ExternalInterface.addCallback("noContinueUpload",noContinueUpload);
			ExternalInterface.addCallback("startUpload",uploadBtnClick);
			
			
			//检查文件类型 add by 张瑞庆 2012-03-29 
			//优先出版文件支持类型
			if(ftypes==null || ftypes=="" || ftypes=="null" || ftypes=="undefined")
				ftypes="*.pdf;*.rar;*.zip;*.doc;*.docx";
			if(ftypeDesc==null || ftypeDesc=="" || ftypeDesc=="null" || ftypeDesc=="undefined")
				ftypeDesc="文件类型";
			this.upload.setTypes(ftypes,ftypeDesc);
			
			
			//KSimpleAlert.show(upload.url,this);
		}
		
		
		private function initButton(url:String,over_url:String,url_click:String):void
		{
			browseBtn = new ImgButton(url,over_url,url_click);
			browseBtn.addEventListener(MouseEvent.CLICK, browseBtn_clickHandler);
			
			addChild(browseBtn);
		}
		
		
		//浏览按钮事件
		protected function browseBtn_clickHandler(event:Event):void
		{	
			if(this.browseBtn.enabled)
			{
				upload.clear();
				upload.browse();
			}
		}
		
		//上传按钮事件
		//protected function uploadBtn_clickHandler(event:Event):void
		//{
		//	this.browseBtn.enabled=false;
		//	this.uploadBtn.enabled = false;
		//	upload.startLoad();
		
		
		//}
		
		
		private function uploadBtnClick():void
		{
			this.browseBtn.enabled=false;
			upload.startLoad();
		}
		
		
		
		private function loadProgressHandler(event:ProgressEvent):void
		{
			
			//load_txt.text = "Loading:\t"+Math.floor(100*event.bytesLoaded / event.bytesTotal) + "%";
		}
		
		private function loadCompleteHandler(event:KUploadEvent):void
		{
			//	pauseBtn.enable = true;
			//			matrix.count = upload.filePartCount;
			
			totcount=upload.filePartCount;
			
			//var timer:uint = setTimeout(startUpload, 100);
			
			//startBtn.enable = true;
			//this.uploadBtn.enabled=true;
			
			
			var temp_str:Boolean = Boolean(ExternalInterface.call(this.JSKUploadName + ".preUpload", js_obj));
			if(temp_str)
			{
				var _url:String=String(ExternalInterface.call(this.JSKUploadName + ".getUrlHandler"));
				var _param:String=String(ExternalInterface.call(this.JSKUploadName + ".getParamHandler",js_obj));
				this.upload.url = buildUrl(_url,decodeURIComponent(_param));
				
				
				var timer:uint = setTimeout(startUpload, 100);
				
				
			}	
			else
			{
				this.browseBtn.enabled = true;
			}
		}
		
		
		private function selectHandler(event:Event):void
		{
			this.browseBtn.enabled = false;
			//this.pathTxt.text=upload.name;
			
			var _file:FileReference=upload.fileInfo;
			
			
			this.js_obj.type=_file.type;
			this.js_obj.size=_file.size;
			this.js_obj.name=_file.name;
			this.js_obj.JSKUploadName=this.JSKUploadName;
			
			var temp_str:Boolean = Boolean(ExternalInterface.call(this.JSKUploadName + ".selectHandler", js_obj));
			if(temp_str)
			{	
				this.browseBtn.enabled =true;
				//this.uploadBtn.enabled=true;
				//upload.startLoad();
			}
		}
		
		private function speedTimerHandler(event:TimerEvent):void
		{
			var data:Object=new Object();
			var progress:int = Math.floor(100*upcount / totcount);
			var speed:String = upload.speed.toString() + " KB/s";
			
			data.progress = progress;
			data.speed=speed;
			ExternalInterface.call(this.JSKUploadName + ".speedHandler",data);
		}
		
		
		private function partCompleteHandler(event:KUploadPartEvent):void
		{	
			if(upcount<totcount)
				upcount++;
			//var progress:int = Math.floor(100*upcount / totcount);
			//ExternalInterface.call(this.JSKUploadName + ".refreshUploadProgHandler",progress);
			//--load_txt.text="进度:"+ Math.floor(100*upcount / totcount) + "%";	
			
		}
		
		private function partBeginHandler(event:KUploadPartEvent):void
		{
			//trace(event.count);
			//			matrix.setStatus(event.count, KMatrix.UPLOADING_FRAME);
			//load_txt.text="进度：\t"+ Math.floor(100*event.count / upload.filePartCount) + "%";
		}
		
		private function partErrorHandler(event:KUploadPartEvent):void
		{
			//trace(event.count);
			//			matrix.setStatus(event.count, KMatrix.ERROR_FRAME);
			//load_txt.text="进度：\t"+ Math.floor(100*event.count / upload.filePartCount) + "%";
			ExternalInterface.call(this.JSKUploadName + ".uploadPartErrorHandler");
		}
		
		private function completeHandler(event:KUploadEvent):void
		{
			//--load_txt.text = "上传成功.";
			this.browseBtn.enabled = true;
			
			speedTimer.stop();
			//--speed_txt.text ="速度:0 KB/s";
			upcount=0;
			ExternalInterface.call(this.JSKUploadName + ".uploadCompleteHandler", js_obj)
		}
		
		private function resumeHandler(event:KUploadResumeEvent):void
		{
			upcount=0;	
			var list:Array = event.list;
			upcount=totcount- list.length;		
			
		}
		
		
		
		
		private function startHandler(event:Event):void
		{
			var temp_str:Boolean = Boolean(ExternalInterface.call(this.JSKUploadName + ".preUpload", js_obj));
			if(temp_str)
			{
				var _url:String=String(ExternalInterface.call(this.JSKUploadName + ".getUrlHandler"));
				var _param:String=String(ExternalInterface.call(this.JSKUploadName + ".getParamHandler",js_obj));
				this.upload.url = buildUrl(_url,decodeURIComponent(_param));
				
				
				var timer:uint = setTimeout(startUpload, 100);
				//this.uploadBtn.enabled = false;
			}
			
		}
		
		
		
		
		
		private function startUpload():void
		{
			//trace("isExist:\t"+upload.isExistFSO());
			//trace("isFinished:\t"+upload.isFinished());
			if(upload.isExistFSO())
			{
				if(upload.isFinished())
				{
					upload.upload();
					speedTimer.start();
				}
				else
				{
					ExternalInterface.call(this.JSKUploadName + ".confirmResume");
					//var alert:Alert;
					// .show("是否续传?", this, yesHandler, noHandler);
				}
			}
			else
			{
				upload.upload();
				speedTimer.start();
			}
			
			
			function yesHandler():void
			{
				upload.testFinished();
				speedTimer.start();
			}
			function noHandler():void
			{
				upload.upload();
				speedTimer.start();
			}
		}
		
		//续传
		private function yesContinueUpload():void
		{
			upload.testFinished();
			speedTimer.start();
		}
		
		private function noContinueUpload():void
		{
			upload.upload();
			speedTimer.start();
		}
		
		
		private function loadPostParams(param_string:String):Object {
			var post_object:Object = {};
			
			if (param_string != null) {
				var name_value_pairs:Array = param_string.split("&amp;");
				
				for (var i:Number = 0; i < name_value_pairs.length; i++) {
					var name_value:String = String(name_value_pairs[i]);
					var index_of_equals:Number = name_value.indexOf("=");
					if (index_of_equals > 0) {
						post_object[decodeURIComponent(name_value.substring(0, index_of_equals))] = decodeURIComponent(name_value.substr(index_of_equals + 1));
					}
				}
			}
			return post_object;
		}
		
		private function buildUrl(_oldUrl:String,parmStr:String):String
		{
			var postObj:Object=	loadPostParams(parmStr);
			
			var pairs:Array = new Array();
			for (var key:String in postObj) {
				
				if (postObj.hasOwnProperty(key)) {
					pairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(postObj[key]));
				}
			}
			
			return _oldUrl  + (_oldUrl.indexOf("?") > -1 ? "&" : "?") + pairs.join("&");
		}
		
		
		
		
	}
}