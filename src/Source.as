package {
  import flash.desktop.Clipboard;
  import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
  import flash.display.Bitmap;
	import flash.events.Event;
  import flash.events.FocusEvent;
  import flash.events.KeyboardEvent;
  import flash.media.SoundMixer;
  import flash.net.URLRequest;
  import flash.ui.Keyboard;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.text.TextFormat;
  import flash.text.TextFieldAutoSize;
  import flash.utils.Dictionary;
  import flash.media.Sound;
  
  [SWF(width = "800", height = "600", backgroundColor = "#000000", frameRate = "60")]
	[Frame(factoryClass="Preloader")]
	public class Source extends Sprite {
    [Embed("../Imgs/HUD.png")] private var Img_HUD : Class;
    [Embed("../Imgs/slide0.png")] private var Img_Slide0 : Class;
    [Embed("../Imgs/slide1.png")] private var Img_Slide1 : Class;
    [Embed("../Imgs/slide2.png")] private var Img_Slide2 : Class;
    [Embed("../Imgs/slide3.png")] private var Img_Slide3 : Class;
    [Embed("../Imgs/slide4.png")] private var Img_Slide4 : Class;
    [Embed("../Imgs/slide5.png")] private var Img_Slide5 : Class;
    [Embed("../Imgs/slide6.png")] private var Img_Slide6 : Class;
    [Embed("../Imgs/slide7.png")] private var Img_Slide7 : Class;
    [Embed("../Imgs/instructions.png")] public static var Img_Ins : Class;
    [Embed("../Imgs/titlescreen.png")] private var Img_Title : Class;
    [Embed("../Imgs/control_selection.png")] private var Img_Controls : Class;
    [Embed("../Imgs/Intro.mp3")]             private var Intro_Sound1 : Class;
		internal var input : Input;
    private var hud : Bitmap, controls_hilight : Bitmap;
    private var controls_text : Array;
    private var slides : Array,
                title : Bitmap,
                title_text : TextField;
    private var intro_sound : Sound;
    public static const  ft_x : int = 16,
                         ft_y : int = 18;
        
		public function Source():void {
      //intro_sound = new Intro_Sound1() as Sound;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		public var clip_capture : Sprite;
		private function init(e:Event = null):void {
      removeEventListener(Event.ADDED_TO_STAGE, init);
      DejaVuSansMono.Init();
      Tutorial.Initialize(null, this);
      var i : int;
      slide_it   =  0;
      key_config = -1;
      key_shift  = false;
      key_ctrl   = false;
      // -- Compiler
      Symbol.Setup_Arrays();
      Error_Code.Setup();
      
      Key_To_String.key_to_str = Key_To_String.R_Key_To_String_Trans();
      // -- HUD
      hud = new Img_HUD() as Bitmap;
      addChild(hud);
      var tsp : Sprite = new Sprite();
      tsp.width = 3000;
      tsp.height = 3000;
      tsp.x = -3;
      tsp.y = -3;
      
      // -- problems
      Problem.Initialize();
      // -- config
      KeyConfig.Setup_Keys();
      // -- load
      Saver.Load();
      
      // -- input
      input = new Input(this);
      stage.addEventListener(KeyboardEvent.KEY_DOWN, Key_Inp);
      stage.addEventListener(KeyboardEvent.KEY_UP  , Key_Drop);
      stage.addEventListener(Event.ENTER_FRAME, Update);
      stage.addEventListener(Event.PASTE, Bullshit_Paste);
      stage.addEventListener(Event.COPY,  Bullshit_Copy);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, Bullshit_Mouse);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, Shameless_Self_Advertising);
      stage.addEventListener(MouseEvent.MOUSE_UP, Mouse_Up);
      stage.addEventListener(FocusEvent.FOCUS_OUT, Clear_Mods);
      focusRect = true;
      addChild(tsp);
      stage.focus = tsp;
      tsp.addEventListener(Event.PASTE, Bullshit_Paste);
      tsp.addEventListener(Event.COPY, Bullshit_Copy);
      clip_capture = tsp;
      stage.stageFocusRect = true;
      
      // -- Kong high scores
      QuickKong.connectToKong(stage);
      // -- guide
      Guide.Initialize();
      // -- slides
      slides =
        new Array(Bitmap(new Img_Slide0), Bitmap(new Img_Ins),
                  Bitmap(new Img_Slide1),
                  Bitmap(new Img_Slide2), Bitmap(new Img_Slide3),
                  Bitmap(new Img_Slide4), Bitmap(new Img_Slide5),
                  Bitmap(new Img_Slide6), Bitmap(new Img_Slide7)
                  
      );
      for ( i = slides.length-1; i != -1; -- i ) {
        addChild(slides[i]);
        // if user has played before, don't show
        if ( Saver.played_before  )
          slides[i].visible = false;
      }
      if ( Saver.played_before == true )
        slide_it = slides.length;
      // -- controls text / highlight
      controls_text = new Array();
      for ( i = 0; i != KeyConfig.keys.length; ++ i ) {
        var c : TextField = Util.Create_TextField();;
        c.visible = false;
        c.x =   6;
        c.y = 347 + 19.5*i;
        stage.addChild(c);
        controls_text.push(c);
      }
      controls_hilight = new Img_Controls() as Bitmap;
      addChild(controls_hilight);
      controls_hilight.visible = false;
      // -- title
      addChild(Preloader.bg);
      addChild(Preloader.img);
      title = Bitmap(new Img_Title);
      title.alpha = 0;
      addChild(title);
      title_text = Util.Create_TextField();
      addChild(title_text);
      title_text.x = 300;
      title_text.y = 500;
      title_text.alpha = 0;
      Preloader.img.alpha = 0;
      title_text.text = "Written by CiggBit";
      title_it = 1;
      gametit_fadein = 60 * 3;
      gametit_fadeout = 60 * 3;
      ciggtit_fadein = 60*3;
      ciggtit_fadeout = 60*3;
      ciggbit = new CiggBit();
      for ( var i : int = 0; i != ciggbit.Ciggs.length; ++ i ) {
        addChild(ciggbit.Ciggs[i]);
        ciggbit.Ciggs[i].width  = 400;
        ciggbit.Ciggs[i].height = 400;
        ciggbit.Ciggs[i].x = 400 - ciggbit.Ciggs[i].width/2;
        ciggbit.Ciggs[i].y = 300 - ciggbit.Ciggs[i].height/2;
        ciggbit.Ciggs[i].visible = false;
      }
      timer = 50;
      
      highlight_text.init(stage);
      //intro_sound.play();
		}
    private var ciggbit : CiggBit;
    private var title_it : int;
    private var gametit_fadein : int,
                gametit_fadeout;
    private var ciggtit_fadein : int,
                ciggtit_fadeout : int;
    private var timer : int;
    private var slide_it : int;
    private var key_config : int;
    private var key_shift : Boolean;
    private var key_ctrl  : Boolean;
    
    private function R_Cigg_It() : int {
      return int(timer/7)%ciggbit.Ciggs.length;
    }
    
    private function Key_Inp(e:KeyboardEvent) : void {
      if ( title_it > 0 )
        return;
      var i : int;
      var key : Key;
      if ( e.keyCode == Keyboard.SHIFT ) {
        key_shift = true;
      }
      if ( e.keyCode == Keyboard.CONTROL ) {
        key_ctrl = true;
      }
      if ( slide_it == slides.length ) {
        input.Key_Input(e.keyCode);
        if ( Util.R_Key_Hit(KeyConfig.help, e.keyCode, key_shift, key_ctrl) ) {
          if ( input.R_Running() )
            return;
          slide_it = 0;
          input.Clear_Guide();
          for ( i = slides.length-1; i != -1; -- i ) {
            slides[i].visible = true;
          }
        }
      } else { // slides still open
        if ( key_config == -1 ) { // not configging keys
          if ( e.keyCode == Keyboard.SPACE ) {
            slides[slide_it].visible = false;
            for ( i = 0; i != KeyConfig.keys.length; ++ i )
              controls_text[i].visible = false;
            if ( Saver.played_before == false && slide_it == 1 ) {
              for ( var i : int = 0; i != slides.length; ++ i )
                slides[i].visible = false;
              Tutorial.Initialize(input, this);
              input.guide = new Guide(this);
              slide_it = slides.length-1;
            }
            ++slide_it;
            if ( slide_it >= slides.length )
              input.Reset_Text();
          }
          if ( slide_it == 0 && e.keyCode == Keyboard.ENTER ) {
            key_config = 0;
            // set highlight and text visible
            controls_hilight.visible = true;
            controls_hilight.x =   6;
            controls_hilight.y = 376;
            for ( i = 0; i != KeyConfig.keys.length; ++ i ) {
              controls_text[i].visible = true;
              key = KeyConfig.keys[i];
            }
          }
          if ( slide_it == 0 && e.keyCode == Keyboard.ESCAPE ) {
            KeyConfig.Setup_Keys(); // reset keys
          }
        } else { // key config
          // check not modifier
          if ( e.keyCode == Keyboard.SHIFT ) {
            return;
          }
          if ( e.keyCode == Keyboard.CONTROL ) {
            return;
          }
          // assign key
          key = KeyConfig.keys[key_config++];
          key.ctrl = key_ctrl;
          key.shift = key_shift;
          key.key = e.keyCode;
          controls_hilight.y += 19;
          if ( key_config == KeyConfig.keys.length ) { // end key assign
            key_config = -1;
            controls_hilight.visible = false;
            for ( i = 0; i != KeyConfig.keys.length; ++ i )
              controls_text[i].visible = false;
          }
        }
      }
    }
    private function Key_Drop(e:KeyboardEvent) : void {
      if ( title_it > 0 ) {
        if ( ciggtit_fadeout != -500 ) {
          ciggtit_fadein = 0;
          ciggtit_fadeout = -59;
        } else {
          gametit_fadein = 0;
          if ( Preloader.bg != null ) {
            removeChild(Preloader.bg);
            Preloader.bg = null;
          }
          gametit_fadeout = 1;
        }
      }
      if ( e.keyCode == Keyboard.SHIFT )
        key_shift = false;
      else
        key_ctrl = false;
      if ( slide_it == slides.length )
        input.Drop_Key(e.keyCode);
    }
    private function Update(e:Event) : void {
      if ( title_it > 0 ) {
        if ( ciggtit_fadeout != -500 ) {
          ciggbit.Ciggs[R_Cigg_It()].visible = false;
          ++ timer;
          ciggbit.Ciggs[R_Cigg_It()].visible = true;
          if ( ciggtit_fadein > 0 ) {
            ciggbit.Ciggs[R_Cigg_It()].alpha = 1-((ciggtit_fadein)/(60*3.0)+0.01);
            title_text.alpha                 = 1-((ciggtit_fadein)/(60*3.0)+0.01);
            Preloader.img.alpha              = 1-((ciggtit_fadein)/(60*3.0)+0.01);
            --ciggtit_fadein;
          } else {
            ciggbit.Ciggs[R_Cigg_It()].alpha = (ciggtit_fadeout)/(60*3);
            title_text.alpha                 = (ciggtit_fadeout)/(60*3);
            Preloader.img.alpha              = (ciggtit_fadeout)/(60*3);
            --ciggtit_fadeout;
          }
          if ( ciggtit_fadeout <= 0 ) {
            if ( --ciggtit_fadeout <= -60 ) {              
              for ( var i : int = 0; i != ciggbit.Ciggs.length; ++ i )
                removeChild(ciggbit.Ciggs[i]);
              removeChild(title_text);
              ciggtit_fadeout = -500;
              SoundMixer.stopAll();
            }
          }
        } else {
          if ( gametit_fadein > 0 ) {
            title.alpha = 1-(gametit_fadein--)/(60*3);
            if ( gametit_fadein <= 0 ) {
              if ( Preloader.bg != null )
                removeChild(Preloader.bg);
              removeChild(Preloader.img);
              Preloader.bg = null;
            }
          } else {
            title.alpha = (gametit_fadeout--)/(60*3);
          }
          if ( gametit_fadeout < 0 ) {
            removeChild(title);
            title_it = -1;
          }
        }
        return;
      }
      if ( slide_it == slides.length ) {
        input.Update();
      }
      else if ( slide_it == 0 ) {
        // reassign key text
        for ( var i : int = 0; i != KeyConfig.keys.length; ++ i ) {
          var key : Key = KeyConfig.keys[i];
          controls_text[i].text = "";
          if ( key_config <= i && key_config != -1 ) break;
          controls_text[i].text = Util.R_Key_String(key);
          controls_text[i].visible = true;
        }
      }
      stage.focus = clip_capture;
    }
    private function Bullshit_Paste(useless:Event) : void {
      if ( title_it > 0 )
        return;
      /*
       * exception, information=SecurityError: Error #2179:
       * The Clipboard.generalClipboard object may only be
       * read while processing a flash.events.Event.PASTE event.
       * 
       * YUCK!
       */
      if ( slide_it == slides.length )
        input.Paste_From_Clipboard();
    }
    private function Bullshit_Copy(useless:Event) : void {
      // AS3 overrides copy function from input so CTRL+C is never grabbed.
      // Again, YUCK
      if ( title_it > 0 )
        return;
      if ( slide_it == slides.length )
        input.Copy_To_Clipboard();
    }
    private function Bullshit_Mouse(sort_of_useless:MouseEvent) : void {
      if ( title_it > 0 )
        return;
      if ( slide_it == slides.length )
        input.Update_Mouse(sort_of_useless.stageX, sort_of_useless.stageY);
    }
    private function Shameless_Self_Advertising(e:MouseEvent) : void {
      if ( title_it > 0 )
        return;
      if ( slide_it != slides.length )
        return;
      if ( e.stageX > 566 && e.stageY < 40 )
        Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,
                                          "http://steamcommunity.com/groups/stdprog");
      input.Update_Mouse_Click(e.stageX, e.stageY);
      if ( Util.In_Range(164, 104, 17, 32, e.stageX, e.stageY) ) {
        if ( input.R_Running() )
          return;
        slide_it = 0;
        input.Clear_Guide();
        for ( var i : int = slides.length-1; i != -1; -- i ) {
          slides[i].visible = true;
        }
      }
    }
    private function Clear_Mods(e:FocusEvent) : void {
      key_shift = false;
      key_ctrl = false;
      input.Clear_Mods();
    }
    private function Mouse_Up(e:MouseEvent) : void {
      if ( title_it > 0 )
        return;
      trace(e.type);
      input.Drop_Mouse_Click(e.stageX, e.stageY);
    }
	}
}