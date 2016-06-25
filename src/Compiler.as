package  {
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
import flash.media.Sound;
public class Compiler {
  [Embed("../Imgs/currentline.png")]    private var Img_CLine          : Class;
  [Embed("../Imgs/errorline.png")  ]    private var Img_ErrorLine      : Class;
  [Embed("../Imgs/stack_light.png")]    private var Img_StackLight     : Class;
  [Embed("../Imgs/failed.mp3")]         private var Snd_Failed         : Class;
  [Embed("../Imgs/start.mp3")]          private var Snd_Start          : Class;
  [Embed("../Imgs/stop.mp3")]           private var Snd_Stop           : Class;
  [Embed("../Imgs/success.mp3")]        private var Snd_Success        : Class;
  [Embed("../Imgs/compile_failed.mp3")] private var Snd_Compile_Failed : Class;
  private var running : Boolean;
  private var score_out_it : int;
  public  var out     : TextField,
              o_regs  : Array, // of textfields
              o_mem   : Array, // of textfields
              o_stack : Array, // of textfields
              o_callstack : Array, // of textfields
              pr_name : TextField,
              pr_desc : TextField,
              pr_inp  : TextField,
              pr_out  : TextField,
              pr_cnt  : TextField,
              pr_cnt2 : TextField,
              pr_tick : TextField,
              pr_styl : TextField,
              pr_rangel: TextField,
              pr_rangeh: TextField;
  private var cline  : Bitmap, eline : Bitmap;
  public var code_copy : Array;
  private var callstack_lights : Array,
              stack_lights : Array;
  private var highliter : Highlighter;
  private var input : Input;
  private var ticks : int;
  public var  custom : Boolean;

  private var snd_failed         : Sound;
  private var snd_start          : Sound;
  private var snd_stop           : Sound;
  private var snd_success        : Sound;
  private var snd_compile_failed : Sound;


  private static const console_x : int = 500,
                       console_y : int = 425,
                       registr_h : int = 20;

  private var program : Program;
  private var problem : Problem;

  public function Compiler(s:Sprite, _input : Input) {
    input = _input;
    var i : int ; // temp iteration purposes
    score_out_it = -1;
    // -- sounds
    snd_failed         = new Snd_Failed()          as Sound;
    snd_start          = new Snd_Start()           as Sound;
    snd_stop           = new Snd_Stop()            as Sound;
    snd_success        = new Snd_Success()         as Sound;
    snd_compile_failed = new Snd_Compile_Failed () as Sound;
    // -- font
    running = false;
    // -- text (out)
    out = Util.Create_TextField();
    out.x = console_x; out.y = console_y;
    s.addChild(out);
    // -- text (registers)
    o_regs = new Array;
    for ( i = 0; i != Symbol.Register_names.length; ++ i ) {
      o_regs.push(Util.Create_TextField());
      var treg : TextField = o_regs[i];
      treg.x = 55 + 160*i;
      treg.y = 268;
      s.addChild(treg);
    }
    // -- setup highlights
    cline = new Img_CLine() as Bitmap;
    eline = new Img_ErrorLine() as Bitmap;
    s.addChild(cline);
    s.addChild(eline);
    cline.x = 318;
    cline.y = -40;
    eline.x = 318;
    eline.y = -40;
    highliter = new Highlighter(s, this);
    callstack_lights = new Array();
    for ( i = 0; i != Input.subrout_total; ++ i ) {
      callstack_lights.push(Bitmap(new Img_StackLight()));
      callstack_lights[i].x = 603;
      callstack_lights[i].y = 270 + i*21;
      callstack_lights[i].visible = false;
      s.addChild(callstack_lights[i]);
    }
    stack_lights = new Array();
    for ( i = 0; i != 10; ++ i ) {
      stack_lights.push(Bitmap(new Img_StackLight()));
      stack_lights[i].x = 711;
      stack_lights[i].y = 165 + i*21;
      stack_lights[i].visible = false;
      s.addChild(stack_lights[i]);
    }
    breakpoints = new Array();
    breakpoint_imgs = new Array();
    for ( i = 0; i != 200; ++ i ) {
      breakpoint_imgs.push(new Img_ErrorLine() as Bitmap);
      breakpoint_imgs[i].x = 318;
      breakpoint_imgs[i].visible = false;
      s.addChild(breakpoint_imgs[i]);
    }
    // -- text (memory)
    o_mem = new Array;
    for ( i = 0; i != Program.memory_amt; ++ i ) {
      o_mem.push(Util.Create_TextField());
      treg = o_mem[i];
      treg.x = 82 + int(i/10)*127;
      treg.y = 390 + 21 * i - int(i/10)*210;
      s.addChild(treg);
    }
    // -- text (stack)
    o_stack = new Array;
    for ( i =0; i != Program.stack_amt; ++ i ) {
      o_stack.push(Util.Create_TextField());
      treg = o_stack[i];
      treg.x = 714;
      treg.y = 164 + 21 * i;
      s.addChild(treg);
    }
    // -- text (callstack)
    o_callstack = new Array;
    for ( i = 0; i != Input.subrout_total; ++ i ) {
      o_callstack.push(Util.Create_TextField());
      treg = o_callstack[i];
      treg.x = 606;
      treg.y = 270 + 21*i;
      s.addChild(treg);
    }
    // -- text (problems)
    // desc
    pr_desc = Util.Create_TextField();
    pr_desc.x = 210;
    pr_desc.y = 26;
    s.addChild(pr_desc);
    // title
    pr_name = Util.Create_TextField()
    pr_name.x = 210;
    pr_name.y = 5;
    pr_name.textColor = 0x0;
    s.addChild(pr_name);
    // input
    pr_inp = Util.Create_TextField();
    pr_inp.x = 53;
    pr_inp.y = 227;
    s.addChild(pr_inp);
    // output
    pr_out = Util.Create_TextField();
    pr_out.x = 53;
    pr_out.y = 311;
    s.addChild(pr_out);
    // counter in
    pr_cnt = Util.Create_TextField();
    pr_cnt.x = 66;
    pr_cnt.y = 42;
    s.addChild(pr_cnt);
    // counter out
    pr_cnt2 = Util.Create_TextField();
    pr_cnt2.x = 66;
    pr_cnt2.y = 3;
    s.addChild(pr_cnt2);
    // clock cycle
    pr_tick = Util.Create_TextField();
    pr_tick.x = 646;
    pr_tick.y = 44;
    s.addChild(pr_tick);
    // style
    pr_styl = Util.Create_TextField();
    pr_styl.x = 646;
    pr_styl.y = 79;
    s.addChild(pr_styl);
    // input high range
    pr_rangeh = Util.Create_TextField();
    pr_rangeh.x = 76;
    pr_rangeh.y = 93;
    s.addChild(pr_rangeh);
    // input range low
    pr_rangel = Util.Create_TextField();
    pr_rangel.x = 76;
    pr_rangel.y = 69;
    s.addChild(pr_rangel);
  }

  public function Set_Problem(p:Problem, _custom:Boolean = false) : void {
    custom = _custom;
    problem = p;
    running = false;
    input.Clear_Speed();
    Reset_Text();
    pr_desc.text = p.description;
    pr_name.text = p.name;
    pr_rangel.text = p.lrange.toString();
    pr_rangeh.text = p.urange.toString();
    Refresh_Output();
  }
  
  public function Reset_Text() : void {
    if ( !running )
      out.text = "Ready\n"+
                 "Hover over units for help\n\n"+
                 Util.R_Key_String(KeyConfig.help, 15) +"= more help\n"+
                 Util.R_Key_String(KeyConfig.start, 15) + "= Start program\n"+
                 "CTRL C         = Copy  program\n"+
                 "CTRL V         = Paste program\n";
  }
  
  public function Refresh_Output() : void {
    highliter.Update(null, input.R_Subroutine());
    if ( problem.output_it < problem.output.length )
      pr_out.text = Util.Format_Int(problem.output[problem.output_it]);
    else
      pr_out.text = "Done";
    if ( problem.input_it  < problem.input.length )
      pr_inp.text = Util.Format_Int(problem.input[problem.input_it]);
    else
      pr_inp.text = "Done";
    pr_cnt.text  = String(problem.input_it)  + "/" +
                   String(problem.input.length);
    pr_cnt2.text = String(problem.output_it) + "/" +
                   String(problem.output.length);
    pr_tick.text = String(ticks);
    // -- update register, memory & stack
    if ( program == null ) return;
    pr_styl.text = String(program.R_Tot_Style());
    var i : int; // AS3 won't stop screaming because it doesn't like scopes
    if ( !running ) {
      for ( i = 0; i != o_regs.length;      ++ i ) o_regs[i].text      = "";
      for ( i = 0; i != o_mem.length;       ++ i ) o_mem[i].text       = "";
      for ( i = 0; i != o_stack.length;     ++ i ) {
        o_stack[i].text     = "";
        stack_lights[i].visible = false;
      }
      for ( i = 0; i != o_callstack.length; ++ i ) {
        o_callstack[i].text = "";
        callstack_lights[i].visible = false;
      }
    } else {
      var registers : Array = program.R_Registers();
      if ( registers != null ) {
        for ( i = 0; i != registers.length; ++ i ) {
          o_regs[i].text = Util.Format_Int(registers[i]);
        }
      }
      if ( program.R_Memory() != null ) {
        for ( i = 0; i != Program.memory_amt; ++ i ) {
          o_mem[i].text = Util.Format_Int(program.R_Memory()[i]);
        }
      }
      var stackarr : Array;
      if ( program.R_Stack() != null ) {
        stackarr = program.R_Stack().R_Arr();
        for ( i = 0; i != Program.stack_amt; ++ i ) {
          o_stack[i].text = "";
          stack_lights[i].visible = false;
          if ( stackarr.length > i ) {
            o_stack[i].text = Util.Format_Int(stackarr[i]);
            stack_lights[i].visible = true;
          }
        }
      }
      if ( program.R_Call_Stack() != null ) {
        stackarr = program.R_Call_Stack().R_Arr();
        for ( i = 0; i != Input.subrout_total; ++ i ) {
          o_callstack[i].text = "";
          callstack_lights[i].visible = false;
          if ( stackarr.length > i ) {
            o_callstack[i].text = Util.Format_Int(stackarr[i]);
            callstack_lights[i].visible = true;
          }
        }
      }
      
      // highlight nodes, registers, and units
      if ( running )
        highliter.Update(program.R_LOC_Array(line_to_exec, sr_to_exec),
                         input.R_Subroutine());
    }
  }
  public function Reset_Problem() : void {
    problem.input_it  = 0;
    problem.output_it = 0;
    Refresh_Output();
  }

  // pass in array of code pages (string form)
  // code[subroutine] = string
  public function Compile(code:Array) : void {
    code_copy = code.concat();
    out.text = "Compiling...";
    problem.output_it = 0;
    problem.input_it  = 0;
    cline.y = -40;
    running = false;
    input.Clear_Speed();
    Refresh_Output();
    var s : String;
    var page : int;
    var i : int
    // -- extract commands
    var sr_commands : Array = new Array();
    for ( page = 0; page != code.length; ++ page ) {
      var commands : Array = new Array();
      var cpage : Array = String(code[page]).split("\n");
      for ( i = 0; i != cpage.length; ++ i ) {
        // extrapolating all symbols to commands
        var symbols : Array = new Array();
        s = cpage[i] + ' ';
        // -- remove comments quickly
        if ( s.search("#") != -1 )
          s = s.substr(0, s.search("#"));
        if ( s.search(";") != -1 ) {
          s = s.substr(0, s.search(";"));
          s += ' ';
        }
        // continue extrapolation
        while ( s.length > 0 ) {
          // remove spaces from beginning
          while ( s.length > 0 && s.charAt(0) == ' ' )
            s = s.substr(1, s.length);
          if ( s.length == 0 ) break;
          // extract symbol
          var tstr : String = s.substr(0, s.indexOf(' '));
          var tsym : Symbol = new Symbol(tstr);
          if ( tsym.R_Type() == Symbol.Invalid ) {
            out.text = "Invalid symbol " + tstr.substr(0, 4) + "";
            input.Set_Subroutine(page);
            eline.y = 233 + Source.ft_y * i;
            snd_compile_failed.play();
            return;
          }
          if ( tsym.R_Type() == Symbol.Memory &&
                (tsym.R_Value() < 0 || tsym.R_Value() > Program.memory_amt ) ) {
            out.text = "Memory out of range\n(" + tsym.R_Value() + ")\n" +
                       "Line " + i + "\n";
            input.Set_Subroutine(page);
            eline.y = 233 + Source.ft_y * i;
            snd_compile_failed.play();
            return;
          }
          // store
          symbols.push(tsym);
          // remove extracted symbol from str
          s = s.substr(s.indexOf(' '), s.length);
        }
        // pack symbol
        commands.push(symbols);
      }
      sr_commands.push(commands);
    }
    // -- compile program --
    program = new Program(sr_commands, problem, this);
    if ( program.R_Error() ) {
      out.text = Error_Code.Instruction_strings[program.R_Error()] + '\n' +
                 program.R_Error_Det() + '\n' +
                 "Line " + program.R_Error_LOC().toString();
      input.Set_Subroutine(program.R_Error_SR());
      eline.y = 233 + Source.ft_y * program.R_Error_LOC();
      snd_compile_failed.play();
      return;
    }
    running = true;
    ticks = 0;
    line_to_exec = -99;
    cline.y = 233;
    input.Set_Subroutine(0);
    sr_to_exec   = 0;
    snd_start.play();
  }

  // --- code runner --------------------------------------------
  static public var line_to_exec : int;
  public function R_Line_Exec() : int { return line_to_exec; }
  public function R_Line_Tot()  : int {
    if ( running )
      return program.R_LOC_No_Emp();
    return 999999;
  }
  private var sr_to_exec : int;
  private var brk_hit : Boolean = false;

  public function Update(vup:Boolean):void {
    if ( running ) {
      if ( line_to_exec == -99 ) {
        out.text = "Running\n"+
           Util.R_Key_String(KeyConfig.pause, 15) + "= pause\n"+
          Util.R_Key_String(KeyConfig.speedup_2x, 15) + "=   2x speed\n"+
          Util.R_Key_String(KeyConfig.speedup_32x, 15) +"=  32x speed!\n"+
          Util.R_Key_String(KeyConfig.speedup_128x, 15) + "= 128x speed!";
        line_to_exec = 0;
        Refresh_Output();
        cline.y = 233 + Source.ft_y * line_to_exec;
        return;
      }
      score_out_it = -1;
      if ( line_to_exec >= program.R_LOC(sr_to_exec) )
        line_to_exec = 0;
      if ( !brk_hit ) {
        for ( var i : int = 0; i != breakpoints.length; ++ i ) {
          if ( breakpoints[i][0] == sr_to_exec && breakpoints[i][1] == line_to_exec ) {
            input.Set_Pause();
            brk_hit = true;
            return;
          }
        }
      }
      brk_hit = false;
      var ret : Exec_Ret = program.Run_Line(line_to_exec, sr_to_exec);
      // -- check if error
      if ( program.R_Error() ) {
        Stop_Running(false);
        if ( program.R_Error() != Error_Code.Invalid_Output )
          out.text = Error_Code.Instruction_strings[program.R_Error()] + '\n' +
                    program.R_Error_Det() + '\n';
        Refresh_Output();
        snd_failed.play();
        return;
      }
      // progress program counter
      ++line_to_exec;
      // -- apply return effect
      switch ( ret.type ) {
        case Exec_Ret.T_empty_line:
          // this shouldn't happen... do nothing
        break;
        case Exec_Ret.T_jump:
          line_to_exec = ret.value;
        break;
        case Exec_Ret.T_jump_offset:
          line_to_exec += ret.value - 1;
        break;
        case Exec_Ret.T_subroutine:
          sr_to_exec = ret.subroutine;
          line_to_exec = ret.value;
          Refresh_Breakpoints();
          input.Set_Subroutine(sr_to_exec);
        break;
      }      
      if ( problem.input_it / problem.input.length > 0.5 ) {
        if ( ret.type != Exec_Ret.T_empty_line )
          ++ticks;
        program.style_counts = true;
      }
      if ( line_to_exec >= program.R_LOC(sr_to_exec) )
        line_to_exec = 0;
      while ( program.Is_Empty(line_to_exec, sr_to_exec) ) {
        if ( ++ line_to_exec >= program.R_LOC(sr_to_exec) ) {
          line_to_exec = 0;
          if ( program.R_LOC(sr_to_exec) == 0 )
            break;
        }
      }
      cline.y = 233 + Source.ft_y * line_to_exec;
      Refresh_Output();
      // -- check if done
      if ( program.R_Done() ) {
        if ( Saver.ticks[problem.level] == 0 ) {
          Saver.ticks[problem.level] = Math.pow(2, 31)-1;
          Saver.style[problem.level] = Math.pow(2, 31)-1;
        }
        Saver.ticks[problem.level] = Math.min(ticks, Saver.ticks[problem.level]);
        Saver.style[problem.level] = Math.min(program.R_Tot_Style(),
                                      Saver.style[problem.level]);
        running = false;
        Stop_Running();
        input.Clear_Speed();
        cline.y = -30;
        score_out_it = 0;
        Saver.levels_complete[problem.level] = true;
        QuickKong.stats.submit(problem.name + " Ticks", ticks);
        QuickKong.stats.submit(problem.name + " Style", program.R_Tot_Style());
        if ( !program.R_Mod_Used() )
          QuickKong.stats.submit(problem.name + " NoMod", program.R_Tot_Style());
        Saver.Save();
        var count : int = 0;
        for ( var i : int = 0; i != Saver.levels_complete.length; ++ i )
          if ( Saver.levels_complete[i] == true ) ++ count;
        snd_success.play();
        QuickKong.stats.submit("Levels Complete", count);
      }
    } else {
      if ( score_out_it != -1 ) {
        // arrays would be better but whatever
        switch ( score_out_it ) {
          case 0: Output_User("----------------------------"); break;
          case 1: Output_User("Problem solved, Kongrats!");    break;
          case 2: Output_User("Ticks: " + String(ticks));      break;
          case 3: Output_User("LOC: " + String(program.R_LOC_No_Emp()));  break;
          case 4:
            var str : String = "";
            if ( program.R_Mod_Used() ) str = "Invalid";
            else                        str = "Valid";
            Output_User("NoMod: " + str);
          break;
          case 5: Output_User("Style: " + String(program.R_Tot_Style())); break;
          case 6: Output_User("Try more problems or optimize"); break;
          case 7: Output_User("solution to gloat on hiscores"); break;
          case 8:
            Output_User("----------------------------");
            score_out_it = -2;
          break;
        }
        ++score_out_it
      }
    }
  }

  // --- returns/sets
  public function R_Running() : Boolean { return running; }
  public function Stop_Running(change_out:Boolean = true) : void {
    running = false;
    Saver.output_global[input.curr_problem] = code_copy;
    input.Apply_String_To_Output(Saver.output_global[input.curr_problem]
                                                           [sr_to_exec]);
    Clear_Breakpoints();
    input.Clear_Speed();
    problem.output_it = 0;
    problem.input_it = 0;
    cline.y = -30;
    Refresh_Output();
    if ( change_out ) {
      out.text = "Ready!\n\n" +
                 Util.R_Key_String(KeyConfig.help, 15) +"= help\n"+
                 Util.R_Key_String(KeyConfig.start, 15) +  "= Start program\n"+
                 "CTRL C         = Copy  program\n"+
                 "CTRL V         = Paste program\n"+
                 Util.R_Key_String(KeyConfig.next_prob, 15) + "= next\n"+
                 Util.R_Key_String(KeyConfig.prev_prob, 15) + "= prev\n";
    }
  }
  public function R_Register_Value(reg:int) : int {
    return program.R_Registers()[reg];
  }
  // sets out to string
  public function Notify_User(s:String) : void {
    out.text = s;
  }
  // adds string to out (do not include new lines!)
  public function Output_User(s:String) : void {
    s.replace("[\n\r]","");
    out.appendText( "\n" + s );
    // find all new lines
    var nlines : int = 0;
    for ( var i : int = 0; i != out.length; ++ i ) {
      if ( out.text.charAt(i) == '\n' ||
           out.text.charAt(i) == '\r') ++nlines;
    }
    while ( nlines-- >= 9 )
      out.text = out.text.substr(out.text.search("[\r\n]")+1, out.text.length);
  }
  public function Clear_Error_Line() : void {
    eline.y = -35;
  }
  public function Inform_Input_Change(line:int, sr:int, code:Array) {
    // grab useful information
    if ( code == null ) {
      input.Change_Line("", line, sr);
      return;
    }
    var inst : Instruction = Symbol.Instructions[code[0].R_Value()];
    var args  : Array = new Array
    if ( code.length > 1 )
      args.push(code[1]);
    if ( code.length > 2 )
      args.push(code[2]);
    
    // put code into string form
    var code_str : String = inst.R_Name();
    for ( var i : int = 0; i != args.length; ++ i ) {
      var sym : Symbol = args[i];
      switch ( sym.R_Type() ) {
        case Symbol.Register:
          if ( sym.R_Value() == 0 ) code_str += " AX";
          else                      code_str += " BX";
        break;
        case Symbol.Literal:
          code_str += " " + Util.Format_Int(sym.R_Value(), true);
        break;
        case Symbol.Memory:
          code_str += " $" + Util.Format_Int(sym.R_Value(), true);
        break;
        case Symbol.MemoryReg:
          code_str += " $";
          if ( sym.R_Value() == 0 ) code_str += "AX";
          else                      code_str += "BX";
        break;
      }
    }
    input.Change_Line(code_str, line, sr);
  }
  public var breakpoints : Array;
  public var breakpoint_imgs : Array;
  
  public function Refresh_Breakpoints() : void {
    
    for ( var i : int = 0; i != breakpoint_imgs.length; ++ i ) {
      breakpoint_imgs[i].visible = false;
    }
    for ( var i : int = 0; i != breakpoints.length; ++ i ) {
      if ( breakpoints[i][0] == sr_to_exec ) {
        breakpoint_imgs[i].visible = true;
        breakpoint_imgs[i].y = 232 + breakpoints[i][1]*Source.ft_y;
      }
    }
  }
  
  public function Add_Breakpoint(el:Array) : void {
    for ( var i : int = 0; i != breakpoints.length; ++ i ) {
      if ( breakpoints[i][0] == el[0] && breakpoints[i][1] == el[1] ) {
        breakpoints.splice(i, 1);
        Refresh_Output();
        Refresh_Breakpoints();
        return;
      }
    }
    breakpoints.push(el);
    Refresh_Breakpoints();
    Refresh_Output();
  }
  public function Clear_Breakpoints() : void {
    for ( var i : int = 0; i != breakpoint_imgs.length; ++ i )
      breakpoint_imgs[i].visible = false;
    breakpoints.splice(0, breakpoints.length);
  }
  public function R_Is_Custom() : Boolean { return custom; }
}}
