package {
  import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
  import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
  
	public class Preloader extends MovieClip {
    [Embed("../Imgs/Background.png")] private var Img_BG : Class;
    public static var img : Bitmap,
                       bg : Sprite;
		public function Preloader() {
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, Check_Done);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			img = new Img_BG() as Bitmap;
      bg = new Sprite();
      bg.graphics.beginFill(0x0);
      bg.graphics.drawRect(0, 0, 800, 600);
      bg.graphics.endFill();
      stage.addChild(bg);
      //stage.addChild(img);
		}
    
    private function ioError(e:IOErrorEvent):void {
			trace(e.text);
		}
		
		private function progress(e:ProgressEvent):void {
			
		}
    
		private function Check_Done(e:Event):void {
			if (currentFrame == totalFrames) {
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void {
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
      stage.removeChild(bg);
      //stage.removeChild(img);
			removeEventListener(Event.ENTER_FRAME, Check_Done);
			var src : Sprite = new Source();
      addChild(src);
		}
	}
	
}