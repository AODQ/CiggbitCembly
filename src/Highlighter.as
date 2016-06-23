package {
import flash.display.Sprite;
import flash.display.Bitmap;
public class Highlighter {
  [Embed("../Imgs/highlight_branch.png")      ] private var Img_HBranc : Class;
  [Embed("../Imgs/highlight_memory.png")      ] private var Img_HMem   : Class;
  [Embed("../Imgs/highlight_stack.png")       ] private var Img_HStack : Class;
  [Embed("../Imgs/highlight_register.png")    ] private var Img_HReg   : Class;
  [Embed("../Imgs/highlight_special_unit.png")] private var Img_HSunit : Class;
  [Embed("../Imgs/highlight_tick.png")        ] private var Img_HTick  : Class;
  [Embed("../Imgs/highlight_units.png")       ] private var Img_Hunits : Class;
  [Embed("../Imgs/highlight_subroutine.png")  ] private var Img_SRout  : Class;
  // arrays of bitmaps that contain image data
  // have three for each that corresponds to each
  // parameter in a command. I know it's not "the right way"
  // but it's not much memory lost.
  private var htick  : Array, // tick counter
              hsunit : Array, // arithmetic and logical unit
              hunits : Array, // move misc literal pc
              hreg   : Array, // registers
              hmem   : Array, // memory
              hstack : Array, // stack unit itself
              hbranc : Array, // branching unit
              hrout  : Bitmap;
  private var compiler : Compiler;
  public function Highlighter(s:Sprite, c:Compiler) {
    compiler = c;
    hbranc = new Array();   
    hmem   = new Array();
    hstack = new Array();
    hsunit = new Array();
    htick  = new Array();
    hunits = new Array();
    hreg   = new Array();
    hrout  = Bitmap(new Img_SRout());
    s.addChild(hrout);
    for ( var i : int = 0; i != 3; ++ i ) {
      hbranc[i] = Bitmap(new Img_HBranc   ());
      hmem  [i] = Bitmap(new Img_HMem     ());
      hstack[i] = Bitmap(new Img_HStack   ());
      hsunit[i] = Bitmap(new Img_HSunit   ());
      htick [i] = Bitmap(new Img_HTick    ());
      hunits[i] = Bitmap(new Img_Hunits   ());
      hreg  [i] = Bitmap(new Img_HReg     ());
      s.addChild(hbranc[i]);
      s.addChild(hmem  [i]);
      s.addChild(hsunit[i]);
      s.addChild(hstack[i]);
      s.addChild(htick [i]);
      s.addChild(hunits[i]);
      s.addChild(hreg  [i]);
    }
    Clear();
  }
  
  public function Clear() : void {
    for ( var i : int = 0; i != 3; ++ i ) {
      hbranc[i].visible = false;
      hmem  [i].visible = false;
      hstack[i].visible = false;
      hsunit[i].visible = false;
      htick [i].visible = false;
      hunits[i].visible = false;
      hreg  [i].visible = false;
    }
  }
  
  public function Update(hi_code : Array, hi_subrout : int) : void {
    Clear();
    hrout.x = 494;
    hrout.y = 234 + 25*hi_subrout;
    if ( hi_code == null ) return;
    // highlight appropiate nodes/registers/units
    for ( var i : int = 0; i != hi_code.length; ++ i ) {
      var s : Symbol = hi_code[i];
      var v : int = s.R_Value();
      switch ( s.R_Type() ) {
        case Symbol.Literal:
          hunits[i].visible = true;
          hunits[i].x = 187;
          hunits[i].y = 308;
        break;
        case Symbol.Register:
          hreg[i].visible = true;
          hreg[i].x = 8   + 159 * s.R_Value();
          hreg[i].y = 270;
        break;
        case Symbol.Memory:
          hmem[i].visible = true;
          hmem[i].x = 45  + int(v/10)*127;
          hmem[i].y = 390 + 21*v - int(v/10)*210;
        break;
        case Symbol.MemoryReg:
          v = compiler.R_Register_Value(v); // get real value
          // check valid, no reason to throw an error
          // to user if their register is OOB... program
          // will handle that itself once it execs command
          if ( v >= 0 && v <= 20) {
            hmem[i].visible = true;
            hmem[i].x = 45 + int(v/10)*127;
            hmem[i].y = 390 + 21*v - int(v/10)*210;
          }
        break;
        case Symbol.Command:
          // instructions must be first symbol of a command,
          // so using "0" instead of i is fine
          switch ( v ) {
            // arithmetic
            case Symbol.I_INC: case Symbol.I_DEC: case Symbol.I_ADD:
            case Symbol.I_SUB: case Symbol.I_ABS: case Symbol.I_SHL:
            case Symbol.I_SHR:
              hsunit[i].visible = true;
              hsunit[i].x =  12;
              hsunit[i].y = 128;
            break;
            // logic
            case Symbol.I_OR: case Symbol.I_AND: case Symbol.I_XOR:
            case Symbol.I_NOT:
              hsunit[i].visible = true;
              hsunit[i].x =  12;
              hsunit[i].y = 174;
            break;
            // branching
            case Symbol.I_JEZ: case Symbol.I_JGZ: case Symbol.I_JLZ:
            case Symbol.I_JMP: case Symbol.I_JNZ: case Symbol.I_JRO:
              hbranc[0].visible = true;
              hbranc[0].x = 408;
              hbranc[0].y = 179;
              // 1 might be in use by other register, 2 is unused
              hunits[2].visible = true;
              hunits[2].x = 316;
              hunits[2].y = 180;
            break;
            // stack
            case Symbol.I_POP: case Symbol.I_PUSH:
              hstack[i].visible = true;
              hstack[i].x = 686;
              hstack[i].y = 140;
            break;
            case Symbol.I_CALL: case Symbol.I_RET:
              hstack[0].visible = true;
              hstack[0].x = 571;
              hstack[0].y = 245;
              hbranc[2].visible = true;
              hbranc[2].x = 526;
              hbranc[2].y = 179;
            break;
            // -- single instruction units --
            case Symbol.I_IN:
              // -- IN
              hreg[0].visible = true;
              hreg[0].x =   7;
              hreg[0].y = 229;
              // -- IN #
              hreg[1].visible = true;
              hreg[1].x = 19;
              hreg[1].y = 44;
            break;
            case Symbol.I_OUT:
              // 0 args, can manipulate what we want
              // -- OUT
              hreg[0].visible = true;
              hreg[0].x =   7;
              hreg[0].y = 313;
              // -- OUT #
              hreg[1].visible = true;
              hreg[1].x = 19;
              hreg[1].y =  4;
            break;
            case Symbol.I_MOV:
              hunits[i].visible = true;
              hunits[i].x = 172;
              hunits[i].y = 173;
            break;
            case Symbol.I_NOP:
              hunits[i].visible = true;
              hunits[i].x = 173;
              hunits[i].y = 218;
            break;
          }
        break;
      }
    }
  }
}}