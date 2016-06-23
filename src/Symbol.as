package  {
  public class Symbol {

    public static const Literal  : int = 0,
                        Register : int = 1,
                        Command  : int = 2,
                        Memory   : int = 3,
                        MemoryReg: int = 4,
                        JmpLabel : int = 5,
                        Any      : int = 6,
                        Any_Mem  : int = 7,
                        Any_Quick: int = 8,
                        Invalid  : int = 9;
    public static var Register_names : Array;
    public static var Instructions   : Array;
    public static var Type_Names : Array;

    public static const
     I_MOV : int =  0, I_JMP  : int =  1, I_JEZ  : int =  2, I_IN  : int =  3,
     I_NOP : int =  4, I_POP  : int =  5, I_PUSH : int =  6, I_JNZ : int =  7,
     I_JGZ : int =  8,
     I_JLZ : int =  9, I_CALL : int = 10, I_JRO : int = 11,
     I_INC : int = 12, I_SUB  : int = 13, I_ADD : int = 14, I_SHL : int = 15,
     I_SHR : int = 16, I_DEC  : int = 17, I_OR  : int = 18, I_AND : int = 19,
     I_XOR : int = 20, I_NOT  : int = 21, I_OUT : int = 22, I_ABS : int = 23,
     I_SEX : int = 24, I_RET  : int = 25, I_MOD : int = 26, I_MDD : int = 27,
     I_CALLR : int = 28, I_RETR : int = 29, I_MULT : int = 30, I_DIV : int = 31,
     I_POW : int = 32, I_SQRT : int = 33, I_LOG : int = 34;
    public static const R_AX : int = 0,
                        R_BX : int = 1;

    private var type  : int;
    private var value : int;
    // name only applicable to labels(!)
    private var name  : String;
    
    public static var Style : int = 4;

    public static function Setup_Arrays() : void {
      Register_names = new Array("AX", "BX");
      Instructions = new Array(
      // -- standard ---------------------------------
      new Instruction("MOV",  2, Any_Mem,  Any    ,1),
      new Instruction("JMP",  1, JmpLabel, Invalid,4),
      new Instruction("JEZ",  1, JmpLabel, Invalid,4),
      new Instruction("IN",   1, Register, Invalid,0),
      new Instruction("NOP",  0, Invalid,  Invalid,0),
      new Instruction("POP",  1, Any_Mem,  Invalid,1),
      new Instruction("PUSH", 1, Any,  Invalid,1),
      // -- branching --------------------------------
      new Instruction("JNZ",  1, JmpLabel,  Invalid,4),
      new Instruction("JGZ",  1, JmpLabel,  Invalid,4),
      new Instruction("JLZ",  1, JmpLabel,  Invalid,4),
      new Instruction("CALL", 1, Any_Quick, Invalid,2),
      new Instruction("JRO",  1, Register,  Invalid,3),
      // -- arithmetic -------------------------------
      new Instruction("INC",  1, Register, Invalid  ,2),
      new Instruction("SUB",  2, Register, Any_Quick,4),
      new Instruction("ADD",  2, Register, Any_Quick,4),
      new Instruction("SHL",  2, Register, Any_Quick,1),
      new Instruction("SHR",  2, Register, Any_Quick,1),
      new Instruction("DEC",  1, Register, Invalid  ,2),
      // -- logic ------------------------------------
      new Instruction("OR",   2, Register, Any_Quick,1),
      new Instruction("AND",  2, Register, Any_Quick,1),
      new Instruction("XOR",  2, Register, Any_Quick,1),
      new Instruction("NOT",  1, Register, Invalid  ,1),
      new Instruction("OUT",  1, Register,  Invalid  ,0),
      // -- posthumously added -----------------------
      new Instruction("ABS", 1, Register,  Invalid,5),
      new Instruction("SEX", 1, Register,  Invalid,0),
      new Instruction("RET", 0, Invalid,   Invalid,0),
      new Instruction("MOD", 2, Any,       Any    ,0),
      new Instruction("MDD", 2, Any,       Any    ,0),
      new Instruction("CALLR", 2, Any_Quick, Memory, 2),
      new Instruction("RETR",  1, Memory, Invalid, 0),
      new Instruction("MULT",  2, Register, Any, 0, true),
      new Instruction("DIV",   2, Register, Any, 0, true),
      new Instruction("POW",   2, Register, Any, 0, true),
      new Instruction("SQRT",  1, Register, Invalid, 0, true),
      new Instruction("LOG",   2, Register, Any, 0, true)
      );
      Type_Names = new Array(
        "Literal", "Register", "Command", "Memory",
        "MemoryReg",
        "Label", "Reg/Mem/Lit", "Reg/Mem", "Invalid");
    }

    public function Symbol(s:String) {
      value = -1;
      // -- remove spaces
      s = s.replace(" ", "");
      // -- remove commas
      s = s.replace(",", "");
      // -- check if literal
      type = Literal;
      var hex : Boolean = false;
      var neg_hit : Boolean = false;
      for ( var i : int = 0; i != s.length; ++ i ) {
        if ( i == 0 && s.charAt(0) == '-' ) {
          continue;
        }
        if ( i == 0 && s.charAt(0) == 'N' ) {
          neg_hit = true;
          continue;
        }
        if ( (i == 0 && s.charAt(0) == 'X') && s.length > 1 ) {
          hex = true;
          continue;
        }
        if ( (s.charAt(i) < '0' || s.charAt(i) > '9') ) {
          if ( !(hex && !(s.charAt(i) < 'A' || s.charAt(i) > 'F')) ) {
            type = Invalid;
            hex = false;
            break;
          }
        }
      }
      if ( type == Literal ) {
        if ( hex ) {
          if ( neg_hit ) {
            s.slice(0, 1);
            s = String(~int(s));
          }
          s = '0' + s;
          
        }
        value = int(s);
        return;
      }
      // -- check if register
      for ( i = 0; i != Register_names.length; ++ i ) {
        if ( s == Register_names[i] ) {
          type = Register;
          value = i;
          return;
        }
      }
      if ( s == 'A' ) {
        type = Register;
        value = 0;
        return;
      }
      if ( s == 'B' ) {
        type = Register;
        value = 1;
        return;
      }
      // -- check if memory or memreg
      if ( s.length > 1 && (s.charAt(0) == '$' || s.charAt(0) == '@' ||
                            s.charAt(0) == 'M' ) ) {
        // check if all integers
        for ( i = 1; i != s.length; ++ i )
          if ( s.charAt(i) < '0' || s.charAt(i) > '9' ) {
            break;
          }
        if ( i == s.length ) {
          type = Memory;
          value = int(s.substr(1, s.length));
        }
        // check if memreg
        if ( s == "$A" || s == "$AX" || s == "@A" || s == "@AX" || 
             s == "MA" || s == "MAX" ) {
          type = MemoryReg;
          value = 0;
        }
        if ( s == "$B" || s == "$BX" || s == "@B" || s == "@BX" ||
             s == "MB" || s == "MBX" ) {
          type = MemoryReg;
          value = 1;
        }
      }
      // -- check if label
      if ( s.length > 1 && s.charAt(s.length - 1) == ':' &&
           s.charAt(0) >= 'A' && s.charAt(0) <= 'Z' )  {
        // check only one ":"
        for ( i = 0; i != s.length-1; ++ i )
          if ( s.charAt(i) == ':' )
            return; // invalid
        type = JmpLabel;
        name = s;
      }
      // -- check if command
      for ( i = 0; i != Instructions.length; ++ i ) {
        if ( s == Instructions[i].R_Name() ) {
          type = Command;
          value = i;
        }
      }

      // type is invalid
    }

    public function R_Type () : int { return type;  }
    public function R_Value() : int { return value; }
    public function R_Name () : String {
      if ( type == Symbol.JmpLabel )
        return name;
      return "N/A";
    }
    public function Set_Value(v:int) : void {
      value = v;
    }
    public function Set_Type (t:int) : void {
      type = t;
    }
  }

}