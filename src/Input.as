package  {
  import flash.display.Sprite;
  import flash.display.Bitmap;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.TextEvent;
  import flash.ui.Keyboard;
  import flash.text.Font;
  import flash.text.FontType;
  import flash.text.TextFormat;
  import flash.text.TextField;
  import flash.text.TextFieldType;
  import flash.text.TextFieldAutoSize;
  import flash.desktop.Clipboard;
  import flash.desktop.ClipboardFormats;

  public class Input {
    [Embed("../Imgs/Cursor.png")] private var Img_Cursor : Class;
    [Embed("../Imgs/Checkmark.png")] private var Img_Checkmark : Class;
    private var output : Array;
    private var debug : TextField;
    private var font  : DejaVuSansMono;
    private var custom_prob : Problem;
    private var shift_hit : Boolean;
    private var ctrl_hit : Boolean;
    private var inp_x : Array,
                inp_y : Array,
                rem_x : Array;
    private var speedup : int;
    public var guide : Guide;
    private var update_program : int;
    public var curr_problem : int,
                curr_subrout : int;
    public static const subrout_total : int = 6;
    private const update_program_start : int = 30;
    public  static const console_w : int = 17 ,
                         console_h : int = 20 ,
                         console_x : int = 320,
                         console_y : int = 230;
    public var focus : int;
    public const Focus_main   = 0,
                 Focus_desc   = 1,
                 Focus_title  = 2,
                 Focus_lrange = 3,
                 Focus_urange = 4;
    private var cursor : Bitmap;
    private var checkmark : Bitmap;
    private var compiler : Compiler;
    private var esc_hit : Boolean;
    private var spc_hit : Boolean;
    public var stage : Sprite;

    public function Input(s:Sprite) : void {
      stage = s;
      focus = Focus_main;
      update_program = update_program_start;
      curr_problem = 0;
      curr_subrout = 0;
      speedup = 0;
      // -- guide
      if ( Saver.played_before == true )
        guide = new Guide(s);
      // -- font
      font = new DejaVuSansMono();
      // -- text
      output = new Array();
      debug = new TextField();
      debug.x = 20; debug.y = 500;
      s.addChild(debug);
      for ( var i : int = 0; i != console_h; ++ i ) {
        output.push( Util.Create_TextField() );
        output[i].x = console_x;
        output[i].y = console_y + i*Source.ft_y;
        output[i].text = "";
        s.addChild(output[i]);
      }
      // -- input position
      inp_x = new Array();
      rem_x = new Array();
      inp_y = new Array();
      for ( var i : int = 0; i != subrout_total; ++ i ) {
        inp_x.push(0);
        inp_y.push(0);
        rem_x.push(0);
      }
      // -- cursor
      cursor = Bitmap(new Img_Cursor());
      s.addChild(cursor);
      Refresh_Cursor();
      // -- checkmark
      checkmark = Bitmap(new Img_Checkmark);
      checkmark.x = 532; checkmark.y = 5;
      checkmark.visible = false;
      s.addChild(checkmark);
      // -- compiler
      compiler = new Compiler(s, this);
      compiler.Set_Problem(Problem.problem_set[0]);
      // -- load saved text
      Apply_String_To_Output(Saver.output_global[curr_problem][curr_subrout]);
    }
    
    private function R_Key_Hit(key : Key, key_code : uint) : Boolean {
      return Util.R_Key_Hit(key, key_code, shift_hit, ctrl_hit);
    }
    
    private function Next_Problem() : void {
      compiler.Clear_Error_Line();
      if ( curr_problem+1 < Problem.problem_set.length ) {
        // save current problem to array
        inp_x[curr_subrout] = 0;
        inp_y[curr_subrout] = 0;
        rem_x[curr_subrout] = 0;
        Saver.output_global[curr_problem][curr_subrout] = Output_To_String();
        ++ curr_problem;
        compiler.Set_Problem(Problem.problem_set[curr_problem]);
        // load new problem from array
        Apply_String_To_Output(Saver.output_global[curr_problem][curr_subrout]);
      }
    }
    
    private function Prev_Problem() : void {
      if ( curr_problem > 0 ) {
        inp_x[curr_subrout] = 0;
        inp_y[curr_subrout] = 0;
        rem_x[curr_subrout] = 0;
        compiler.Clear_Error_Line();
        // save current problem to array
        Saver.output_global[curr_problem][curr_subrout] = Output_To_String();
        // apply change
        -- curr_problem;
        compiler.Set_Problem(Problem.problem_set[curr_problem]);
        // load new problem from array
        Apply_String_To_Output(Saver.output_global[curr_problem][curr_subrout]);
      }
    }
    
    private function Set_Speed_32x() : void {
      speedup = update_program_start*16;
    
    }
    
    private function Set_Speed_2x() :  void {
      speedup = update_program_start/2;
    }
    
    private function Set_Speed_128x() : void {
      speedup = update_program_start*512;
    }
    
    public function Set_Pause() : void {
      speedup = -1;
      update_program = 1; // causes step by step
      
    }
    
    private function Toggle_Compiler() : void {
      if ( !compiler.R_Running() ) {
        Saver.output_global[curr_problem][curr_subrout] = Output_To_String();
        Saver.Save(); // JIC it crashes
        Problem.problem_set[curr_problem].Refresh_Problem();
        compiler.Set_Problem(Problem.problem_set[curr_problem]);
        compiler.Compile(Saver.output_global[curr_problem]);
        if ( custom_prob )
          Refresh_Custom_Problem();
      } else {
        compiler.Stop_Running();
        speedup = 0;
      }
    }
    public static const timeup_tot : int = 180;
    public var timeup : int = timeup_tot;
    public var total_loc : int = 9999;
    public function Key_Input(key:uint) : void {
      if ( custom_prob && focus != Focus_main ) {
        var txt : TextField = null;
        switch ( focus ) {
          case Focus_desc:
            txt = compiler.pr_desc;
          break;
          case Focus_title:
            txt = compiler.pr_name;
          break;
          case Focus_urange:
            txt = compiler.pr_rangeh;
          break;
          case Focus_lrange:
            txt = compiler.pr_rangel;
          break;
        }
        if ( txt == null ) return;
        if ( key == Keyboard.BACKSPACE )
          txt.text = txt.text.substr(0, txt.text.length-1);
        else
          txt.text += String.fromCharCode(key);
        return;
      }
    
      if ( Saver.played_before == false ) {
        if ( timeup  < 0 ) {
          if ( key == Keyboard.SPACE ) {
            spc_hit = 1;
            timeup = timeup_tot;
            if ( Tutorial.count++ > total_loc ) {
              Saver.played_before = true;
              Tutorial.Destroy();
              total_loc = 9999;
              return;
            }
          }
        }
        if ( !compiler.R_Running() ) {
          if ( esc_hit || spc_hit ) {
            compiler.Compile(Saver.output_global[curr_problem]);
            compiler.Update(true);
            total_loc = compiler.R_Line_Tot();
            spc_hit = 0;
            speedup = -1;
            esc_hit = 0;
          }
        }
        return;
      }
      // -- key modifiers
      if ( key == Keyboard.SHIFT )
        shift_hit = true;
      if ( key == Keyboard.CONTROL )
        ctrl_hit = true;
      // -- key binds
      if ( compiler.R_Running() ) {
        if ( speedup != -1 ) {
          if ( R_Key_Hit(KeyConfig.speedup_2x, key) )  Set_Speed_2x();
          if ( R_Key_Hit(KeyConfig.speedup_32x, key) ) Set_Speed_32x();
          if ( R_Key_Hit(KeyConfig.speedup_128x, key) ) Set_Speed_128x();
        }
        if ( R_Key_Hit(KeyConfig.pause, key) )       Set_Pause();
        if ( R_Key_Hit(KeyConfig.start, key) )       Toggle_Compiler();
        return; // don't capture key events if compiler running
      } else {
        // --- compiler is not running ---
        // --- next/prev problem ----------------------------------------------
        if ( R_Key_Hit(KeyConfig.next_prob, key) ) {
          Prev_Problem();
          return;
        }
        if ( R_Key_Hit(KeyConfig.prev_prob, key) ) {
          Next_Problem();
          return;
        }
        
        // --- next/prev page -------------------------------------------------
        if ( R_Key_Hit(KeyConfig.prev_page, key) ) {
          Set_Subroutine(curr_subrout-1);
          return;
        }
        if ( R_Key_Hit(KeyConfig.next_page, key) ) {
          Set_Subroutine(curr_subrout+1);
          return;
        }
        // start
        if ( R_Key_Hit(KeyConfig.start, key) ) {
          Toggle_Compiler();
          return;
        }
      }
      
      var update_text : Boolean = true;;
      var s : String;
      // -- text navigation
      switch ( key ) {
        case Keyboard.ESCAPE:
          guide.Clear_Data();
          return;
        break;
        case Keyboard.DOWN:
          if ( inp_y[curr_subrout] < console_h-1 ) {
            ++ inp_y[curr_subrout];
            rem_x[curr_subrout] = Math.max(inp_x[curr_subrout], 
                                           rem_x[curr_subrout]);
            inp_x[curr_subrout] = Math.min(rem_x[curr_subrout],
                             output[inp_y[curr_subrout]].text.length);
          }
          update_text = false;
        break;
        case Keyboard.UP:
          if ( inp_y[curr_subrout] > 0 ) {
            -- inp_y[curr_subrout];
            rem_x[curr_subrout] = Math.max(inp_x[curr_subrout],
                                           rem_x[curr_subrout])
            inp_x[curr_subrout] = Math.min(rem_x[curr_subrout],
                            output[inp_y[curr_subrout]].text.length);
          }
          update_text = false;
        break;
        case Keyboard.LEFT:
          if ( inp_x[curr_subrout] > 0 ) -- inp_x[curr_subrout];
          rem_x[curr_subrout] = 0;
          update_text = false;
        break;
        case Keyboard.RIGHT:
          if ( inp_x[curr_subrout] < output[inp_y[curr_subrout]].text.length )
            ++ inp_x[curr_subrout];
          rem_x[curr_subrout] =  0;
          update_text = false;
        break;
        case Keyboard.ENTER:
          update_text = false;
          compiler.Clear_Error_Line();
          // -- check valid (last line is empty, not on last line)
          var tfield : TextField = output[output.length - 1];
          tfield.text = tfield.text.replace(" ", "");
          if ( tfield.length > 0 ) break;
          if ( inp_y[curr_subrout] == output.length - 1 ) break;
          // -- grab before and after inp_x[curr_subrout]
          var tstr : String = output[inp_y[curr_subrout]].text;
          output[inp_y[curr_subrout]].text = tstr.slice(0, inp_x[curr_subrout]);
          tstr               = tstr.slice(inp_x[curr_subrout], tstr.length);
          // -- push everything along
          for ( var i : int = inp_y[curr_subrout]+1; i < output.length; ++ i ) {
            var t_tstr : String = output[i].text;
            output[i].text = tstr;
            tstr = t_tstr;
          };
          ++ inp_y[curr_subrout];
          inp_x[curr_subrout] = 0;
          rem_x[curr_subrout] = 0;
        break;
        case Keyboard.ALTERNATE:
          update_text = false;
        break;
        case Keyboard.BACKSPACE:
          compiler.Clear_Error_Line();
          update_text = false;
          if ( inp_x[curr_subrout] > 0 ) { // remove a character
            s = output[inp_y[curr_subrout]].text;
            -- inp_x[curr_subrout];
            output[inp_y[curr_subrout]].text = s.substr(0, inp_x[curr_subrout]) +
                                 s.substr(inp_x[curr_subrout]+1, s.length);
            rem_x[curr_subrout] = 0;
          } else { // remove a line
            if ( inp_y[curr_subrout] == 0 ) break;
            if ( output[inp_y[curr_subrout] - 1].text.length +
                 output[inp_y[curr_subrout]    ].text.length >= console_w ) break;
            inp_x[curr_subrout] = output[inp_y[curr_subrout] - 1].text.length;
            output[inp_y[curr_subrout] - 1].text += output[inp_y[curr_subrout]].text;
            -- inp_y[curr_subrout];
            // (Y, X) -> (X, X)
            for ( i = inp_y[curr_subrout] + 1; i != output.length - 1; ++ i ) {
              output[i].text = output[i + 1].text;
            }
            output[output.length - 1].text = "";
          }
        break;
        case Keyboard.HOME:
          inp_x[curr_subrout] = 0;
          update_text = false;
        break;
        case Keyboard.END:
          inp_x[curr_subrout] = output[inp_y[curr_subrout]].text.length;
          update_text = false;
        break;
        case Keyboard.DELETE:
          compiler.Clear_Error_Line();
          s = output[inp_y[curr_subrout]].text;
          output[inp_y[curr_subrout]].text = s.substr(0, inp_x[curr_subrout]) + s.substr(inp_x[curr_subrout]+1, s.length);
           rem_x[curr_subrout] = 0;
          update_text = false;
        break;
        case Keyboard.SHIFT:
          update_text = false;
        break;
      }
      // -- text input
      if ( update_text ) {
        if ( output[inp_y[curr_subrout]].text.length < console_w && !ctrl_hit ) {
          compiler.Clear_Error_Line();
          var str : String = output[inp_y[curr_subrout]].text;
          output[inp_y[curr_subrout]].text = str.substring(0, inp_x[curr_subrout]) +
            Util.To_Char(key, shift_hit) +
            str.substring(inp_x[curr_subrout], str.length);
          if ( output[inp_y[curr_subrout]].length <= console_w ) ++ inp_x[curr_subrout];
          rem_x[curr_subrout] = 0;
        }
      }
      Refresh_Cursor();
    }
    
    public function Copy_To_Clipboard() : void {
      var txt : String = Output_To_String();
      ctrl_hit = false;
      Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, txt, true);
      refresh_hint = 300;
      compiler.Notify_User("Program copied to Clipboard!\n" +
                           "Be sure to save it somewhere\n");
    }
	
    public function Paste_From_Clipboard() : void {
      ctrl_hit = false;
      refresh_hint = 200;
      inp_x[curr_subrout] = 0;
      rem_x[curr_subrout] = 0;
      inp_y[curr_subrout] = 0;
      Apply_String_To_Output(
        String(Clipboard.generalClipboard.getData(
                          ClipboardFormats.TEXT_FORMAT))
      );
    }
    
    public function Output_To_String() : String {
      var txt : String = "";
      for ( var i : int = 0; i != output.length; ++ i )
        txt += output[i].text + '\n';
      while ( txt.length > 0 && txt.charAt(txt.length - 1) == '\n' )
        txt = txt.slice(0, txt.length-1);
      return txt;
    }
    
    public function Apply_String_To_Output(text:String) : void {
      var arr : Array = text.split("\n");
      while ( arr.length > Input.console_h ) arr.pop();
      for ( var i : int = 0; i != output.length; ++ i )
        output[i].text = "";
      for ( i = 0; i != arr.length; ++ i ) {
        var st : String = arr[i];
        st = st.substr(0, Input.console_w);
        st = st.replace('\n', '');
        st = st.toUpperCase();
        output[i].text = st;
      }
      Refresh_Cursor();
    }
    
    public function Update_Mouse(mouse_x : int, mouse_y : int) : void {
      if ( text_hi ) {
        var ox : int = mouse_x - 317,
            oy : int = mouse_y - 230;
        oy = R_Text_Range_Y(oy);
        ox = R_Text_Range_X(ox);
        highlight_text.Update_Highlight(inp_x[curr_subrout],
                                inp_y[curr_subrout], ox, oy, null);
      }
    }
    
    public var mouse_speed : Boolean; // if mouse was the one that sped up or not
    
    public var mouse_held : Boolean,
               text_hi : Boolean;
    
    public function R_Text_Range_X(ox:int) : int {
      ox /= 10;
      if ( ox >= output[0].length )
        ox = output.length-1;
      return ox;
    }
    public function R_Text_Range_Y(oy:int):int {
      oy /= Source.ft_y;
      if ( oy >= output.length )
        oy = output.length-1;
      if ( oy < 0 ) oy = 0;
      return oy;
    }
    public function Drop_Mouse_Click(mouse_x : int, mouse_y : int ) : void {
      if ( text_hi ) {
        text_hi = false;
        var ox : int = mouse_x - 317,
            oy : int = mouse_y - 230;
        ox = R_Text_Range_X(ox);
        oy = R_Text_Range_Y(oy);
        highlight_text.Update_Highlight(inp_x[curr_subrout],
                                inp_y[curr_subrout], ox, oy, output);
      }
    }
    
    public function Update_Mouse_Click(mouse_x : int, mouse_y : int ) : void {
      guide.Clear_Data();
      for ( var i : int = 0; i != Guide.Out.length; ++ i ) {
        var d : Guide_Data = Guide.Out[i];
        if ( Util.In_Range(d.hitx, d.hity, d.hitw, d.hith, mouse_x, mouse_y) ) {
          guide.Update_Data(i);
          return;
        }
      }
      if ( Util.In_Range(210, 4, 322, 25, mouse_x, mouse_y) ) {
        guide.Update_Data(-1);
        return;
      }
    
      if ( Saver.played_before == false )
        return;
      text_hi = false;
      
      if ( compiler.R_Running() && Util.In_Range(317, 230, 176, 365, mouse_x, mouse_y) ) {
        var oy : int = mouse_y - 230;
        oy = R_Text_Range_Y(oy);
        compiler.Add_Breakpoint(new Array(curr_subrout, oy));
        return;
      }
      
      // -- highilgght
      if ( Util.In_Range(317, 230, 176, 365, mouse_x, mouse_y) ) {
        var ox : int = mouse_x - 317,
            oy : int = mouse_y - 230;
        ox /= 10;
        oy /= Source.ft_y;
        if ( oy >= output.length )
          oy = output.length-1;
        inp_x[curr_subrout] = Math.min(output[oy].length, ox);
        inp_y[curr_subrout] = oy;
        rem_x[curr_subrout] = 0;
        Refresh_Cursor();
        text_hi = true;
        mouse_held = true;
      }
      // sub routine nodes
      if ( Util.In_Range(487, 233, 33, 150, mouse_x, mouse_y) && !compiler.R_Running() )
        Set_Subroutine((mouse_y-233)/(150/subrout_total));
      // misc buttons
      if ( !compiler.R_Running() ) {
        if ( Util.In_Range(531, 109, 31, 15, mouse_x, mouse_y) )
          Next_Problem();
        if ( Util.In_Range(500, 109, 31, 15, mouse_x, mouse_y) )
          Prev_Problem();
      }
      if ( Util.In_Range(184, 30, 17, 32, mouse_x, mouse_y) )
        Toggle_Compiler();
      if ( Util.In_Range(164, 30, 17, 32, mouse_x, mouse_y) ) {
        if ( speedup == 0 ) {
          Set_Pause();
        } else
          speedup = 0;
      }
      if ( Util.In_Range(184, 67, 17, 32, mouse_x, mouse_y) ) {
        if ( speedup == 0 ) {
          Set_Speed_2x();
        } else
          speedup = 0;
      }
      if ( Util.In_Range(164, 67, 17, 32, mouse_x, mouse_y) ) {
        if ( speedup == 0 ) {
          Set_Speed_32x();
        } else
          speedup = 0;
      }
      if ( Util.In_Range(184, 104, 17, 32, mouse_x, mouse_y) ) {
        if ( speedup == 0 ) {
          Set_Speed_128x();
        } else
          speedup = 0;
      }
      if ( Util.In_Range(210, 111, 117, 13, mouse_x, mouse_y) ) {
        if ( compiler.R_Running() )
          return;
        if ( Tutorial.tutorial_hints[curr_problem] == null ) {
          Saver.played_before = false;
          timeup = timeup_tot;
          Tutorial.Initialize(this, stage);
          inp_x[0] = 0;
          inp_y[0] = 0;
          rem_x[0] = 0;
          Set_Subroutine(0);
          
          Apply_String_To_Output(Tutorial.tutorial_codes[curr_problem]);
          for ( var i : int = 1; i != 6; ++ i ) {
            Set_Subroutine(i);
            Apply_String_To_Output("");
          }
          compiler.Compile(Saver.output_global[curr_problem]);
          total_loc = compiler.R_Line_Tot();
        } else {
          for ( var i : int = 0; i != Tutorial.tutorial_hints[curr_problem].length; ++ i ) {
            compiler.Output_User(Tutorial.tutorial_hints[curr_problem][i]);
          }
        }
      }
      // ------ custom problem -----------------------------
      // create custom problem
      if ( Util.In_Range(308, 111, 169, 13, mouse_x, mouse_y) ) {
        compiler.custom = true;
        custom_prob = new Problem("", "", null, -9999, 9999, true);
        curr_problem = Problem.problem_set.length-1;
        Problem.problem_set.push(custom_prob);
        for ( var o : int = 0; o != Input.subrout_total; ++ o ) {
          output[o].text = new String("");
        }
        Apply_String_To_Output(
                   "IN AX\n"+
                   "MULT AX, -64\n"+
                   "OUT AX\n");
        Refresh_Custom_Problem();
        Set_Subroutine(0);
      }
      if ( custom_prob ) {
        if ( Util.In_Range(5,96,156, 18, mouse_x, mouse_y) ) {
          focus = Focus_urange;
        }
        else if ( Util.In_Range(5, 72, 156, 18, mouse_x, mouse_y) ) {
          focus = Focus_lrange;
        }
        else if ( Util.In_Range(209, 4, 323, 25, mouse_x, mouse_y) ) {
          focus = Focus_title;
        }
        else if ( Util.In_Range(211, 29, 350, 80, mouse_x, mouse_y) ) {
          focus = Focus_desc;
        } else
          focus = Focus_main;
      } else
        focus = Focus_main;
    }
    
    public function Extract_Token(text:String,
                      find:String, replace_semicolon:Boolean = true) : String {
      var tstr : String = new String("");
      
      var it : int = text.search(find);
      if ( it == -1 ) return "";
      while ( text.length != it && text.charAt(++it) != ':' );
      if ( it == text.length ) return "";
      while ( text.length != it && text.charAt(++it) != ':' ) {
        if ( text.charAt(it) == ';' ) {
          if ( replace_semicolon ) tstr += '\n';
        } else if ( text.charAt(it) != '\r' ) {
          tstr += text.charAt(it).toLowerCase();
        }
      }
      return tstr;
    }
    
    public function Refresh_Custom_Problem() : void {
      if ( custom_prob != null ) {
        var str : String = output[0].text;
        custom_prob.name = Extract_Token(str, "TITLE");
        custom_prob.description = Extract_Token(str, "DESC");
        custom_prob.lrange = int(Extract_Token(str, "LRANGE", false));
        custom_prob.urange = int(Extract_Token(str, "URANGE", false));
        if ( custom_prob.urange < custom_prob.lrange ) {
          custom_prob.urange ^= custom_prob.lrange;
          custom_prob.lrange ^= custom_prob.urange;
          custom_prob.urange ^= custom_prob.lrange;
        }
        custom_prob.Refresh_Problem();
        compiler.Set_Problem(custom_prob, true);
      }
    }
    
    public function Clear_Guide() : void {
      guide.Clear_Data();
    }
    
    public function Drop_Key(key:uint) : void {
      
      if ( Keyboard.ESCAPE )
        esc_hit = 0;
      if ( Keyboard.SPACE )
        spc_hit = 0;
      // -- drop modifiers
      switch ( key ) {
        case Keyboard.SHIFT:
          shift_hit = false;
        break;
        case Keyboard.CONTROL:
          ctrl_hit = false;
        break;
      }
      
      // -- drop config keys
      if ( mouse_speed ) return;
      if ( KeyConfig.pause.key == key ) {
        speedup = 0;
      } else if ( KeyConfig.speedup_2x.key  == key || KeyConfig.speedup_32x.key == key 
               || KeyConfig.speedup_128x.key == key ) {
        if ( speedup != -1 )
          speedup = 0;
      }
    }
    
    private var save_count : int = 180;
    private var refresh_hint : int = -1;
    public function Update() : void {
      if ( Saver.played_before == false ) {
        Tutorial.Update(curr_problem, (--timeup)<0);
        if ( !spc_hit && !esc_hit ) {
          if ( Tutorial.count != compiler.R_Line_Tot() )
            speedup = -1;
        } else {
          compiler.Update(true);
          speedup = -1;
          spc_hit = 0;
          esc_hit = 0;
          timeup = timeup_tot;
        }
        return;
      }
      update_program -= 1 + speedup;
      if ( !compiler.R_Running() )
        compiler.Refresh_Output();
      while ( update_program < 0 ) {
        update_program += update_program_start;
        compiler.Update(update_program+update_program_start>0);
      }
      if ( -- save_count < 0 ) {
        Saver.output_global[curr_problem][curr_subrout] = Output_To_String();
        save_count = 180;
        Saver.Save();
      }
      if ( -- refresh_hint == 0 ) {
        compiler.Reset_Text();
      }
      checkmark.visible = Saver.levels_complete[curr_problem];
      cursor.visible    = !compiler.R_Running();
    }
    public function Clear_Speed() : void {
      speedup = 0;
      update_program = 0;
    }

    private function Refresh_Cursor() : void {
      cursor.x = console_x + (inp_x[curr_subrout]) * 10;
      cursor.y = console_y + inp_y[curr_subrout] * Source.ft_y + 3;
    }
    
    public function Reset_Text() : void {
      compiler.Reset_Text();
    }
    
    public function Clear_Mods() : void {
      if ( !speedup == -1 )
        speedup = 0;
      shift_hit = false;
      ctrl_hit  = false;
    }
    
    public function R_Subroutine() : int { return curr_subrout; }
    public function Set_Subroutine(s:int) : void {
      compiler.Clear_Error_Line();
      Saver.output_global[curr_problem][curr_subrout] = Output_To_String();
      if ( s < 0 )
        curr_subrout = subrout_total-1;
      else if ( s >= subrout_total )
        curr_subrout = 0;
      else
        curr_subrout = s;
      Apply_String_To_Output(Saver.output_global[curr_problem][curr_subrout]);
    }
    
    public function Change_Line(str:String, line:int, sr:int) : void {
      // sort of hacky/bad
      Apply_String_To_Output(Saver.output_global[curr_problem][sr]);
      output[line].text = str;
      Saver.output_global[curr_problem][sr] = Output_To_String();
      Apply_String_To_Output(Saver.output_global[curr_problem][curr_subrout]);
    }
    
    public function R_Running() : Boolean { return compiler.R_Running(); }
  }
}