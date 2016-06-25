package  {
public class Program {
  // --- errors -------------------------------------------------------------
  private var error : int,
              error_loc : int,
              error_sr  : int,
              error_det : String;
  // --- data ---------------------------------------------------------------
  private var main : Array; // an array of code pages
  private var code : Array; // an array of code pages
                            // [code page][line number][symbol]
  private var labels : Array; // an array of array of labels [subrout][index]
  private var registers : Array,
              memory : Array,
              stack : Stack,
              call_stack : Stack; // first elem = LOC, second elem = code page
  private var problem : Problem;
  public static const memory_amt : int = 20;
  public static const stack_amt  : int = 10;
  private var done : Boolean;
  private var compiler : Compiler; // for output purposes only
  public var mod_used : Boolean;
  private var t_jumps : int,
              t_loc   : int,
              t_style : int;

  // --- functions ----------------------------------------------------------
  // syms -> array of code pages
  public function Program(_code:Array, pr:Problem, _compiler:Compiler) {
    compiler = _compiler;
    code = _code;
    main = code[0];
    t_jumps = 0;
    t_loc = 0;
    t_style = 0;
    var i : int;
    // fill with empty lines
    for ( i = 0; i != code.length; ++ i )
      while ( code[i].length < Input.console_h )
        code[i].push(new Array());
    /*// remove empty lines at end of code pages
    for ( i = 0; i != code.length; ++ i )
      while ( code[i].length > 0 && code[code.length-1].length == 0 )
        code[i].pop();*/
    // make sure not empty
    if ( main.length == 0 ) {
      error = Error_Code.Empty_Program;
      error_det = "RTFM!"
      return;
    }
    // -- initialize data
    registers = new Array();
    for ( i = 0; i != Symbol.Register_names.length; ++ i )
      registers.push(0);
    memory = new Array();
    for ( i = 0; i != memory_amt; ++ i )
      memory.push(0);
    stack = new Stack(10);
    call_stack = new Stack(5);
    labels = new Array();
    // -- compile program
    Error_Check();
    problem = pr;
    done = false;
    t_loc = R_LOC_No_Emp();
  }
  
  public var style_counts : Boolean = false;

  public function Run_Line(loc : int, sr : int) : Exec_Ret {
    var line : Array, instr : Symbol;
    line  = code[sr][loc];
    instr = line[0];
    if ( instr == null ) {
      error = Error_Code.Empty_Program;
      error_det = "subroutine empty\n";
      return new Exec_Ret(Exec_Ret.T_good, 0);
    }
     var instruction : Instruction = Symbol.Instructions[instr.R_Value()];
    if ( instr == null ) return new Exec_Ret(Exec_Ret.T_empty_line, 0);
    if ( instr.R_Type() == Symbol.JmpLabel )
      return new Exec_Ret(Exec_Ret.T_empty_line, 0);;
    if ( instruction.R_Custom_Only() && !compiler.R_Is_Custom() ) {
      error = Error_Code.Invalid_Instruction;
      error_det = instruction.R_Name();
      error_loc = loc;
      error_sr  = sr;
      return new Exec_Ret(Exec_Ret.T_good, 0, 0);
    }
    var srite : Symbol,
        sleft : Symbol;
    if ( line.length > 1 ) sleft = line[1];
    if ( line.length > 2 ) srite = line[2];
    if ( style_counts ) {
      t_style += Symbol.Instructions[instr.R_Value()].R_Style();
    }
    // -- execute command
    switch ( instr.R_Value() ) {
      case Symbol.I_ADD:
        registers[sleft.R_Value()] += R_Value(srite);
      break;
      case Symbol.I_INC:  
        ++ registers[sleft.R_Value()];
      break;
      case Symbol.I_DEC:
        -- registers[sleft.R_Value()];
      break;
      case Symbol.I_SUB:
        registers[sleft.R_Value()] -= R_Value(srite);
      break;
      case Symbol.I_ABS:
        registers[sleft.R_Value()] = Math.abs(registers[sleft.R_Value()]);
      break;
      case Symbol.I_AND:
        registers[sleft.R_Value()] &= R_Value(srite);
      break;
      case Symbol.I_NOT:
        registers[sleft.R_Value()] = ~registers[sleft.R_Value()];
      break;
      case Symbol.I_OR:
        registers[sleft.R_Value()] |= R_Value(srite);
      break;
      case Symbol.I_SHL:
        registers[sleft.R_Value()] <<= R_Value(srite);
      break;
      case Symbol.I_SHR:
        registers[sleft.R_Value()] >>= R_Value(srite);
      break;
      case Symbol.I_XOR:
        registers[sleft.R_Value()] ^= R_Value(srite);
      break;
      case Symbol.I_CALLR:
        
      case Symbol.I_CALL:
        ++ t_jumps;
        var call_sr : int = R_Value(sleft);
        if ( call_sr < 0 || call_sr > 5 ) {
          error = Error_Code.Out_Of_Range_Sr;
          error_det = "SR index " + String(call_sr) + " finvalid\n";
          error_loc = loc;
          error_sr  = sr;
        }
        call_stack.Push(loc+1 + sr*1000);
        return new Exec_Ret(Exec_Ret.T_subroutine, 0, call_sr);
      break;
      case Symbol.I_RETR:
      
      case Symbol.I_RET:
        var sr : int = call_stack.Pop();
        var loc : int = sr%1000;
        sr = int(sr/1000);
        return new Exec_Ret(Exec_Ret.T_subroutine, loc, sr);
      break;
      case Symbol.I_SEX:
        switch ( registers[sleft.R_Value()] ) {
          case 0:  compiler.Output_User("You approach a beautiful lady");  break;
          case 1:  compiler.Output_User("The lady is riding on her bike"); break;
          case 2:  compiler.Output_User("She jumps off her bikes and");    break;
          case 3:  compiler.Output_User("she approaches you calmly");      break;
          case 4:  compiler.Output_User("She starts to strip herself");    break;
          case 5:  compiler.Output_User("and when she is fully nude");     break;
          case 6:  compiler.Output_User("She tells you something:");       break;
          case 7:  compiler.Output_User("'You can have anything you");     break;
          case 8:  compiler.Output_User("want from me, baby.' Well,");     break;
          case 9:  compiler.Output_User("after all is said and done,");    break;
          case 10: compiler.Output_User("it's a goodthing you chose;");    break;
          case 11: compiler.Output_User("her bike; her clothes would");    break;
          case 12: compiler.Output_User("not have fit you anyways!");       break;
          default:
        }
      break;
      case Symbol.I_IN:
        if ( problem.input.length > problem.input_it )
          registers[sleft.R_Value()] = problem.input[problem.input_it++];
        else
          registers[sleft.R_Value()] = 0;
      break;
      case Symbol.I_OUT:
        // notify user
        var t_in : String = "IN: " + 
              Util.Format_Int(problem.input [problem.output_it]);
        while ( t_in.length != 15 ) t_in += " ";
        var t_out : String = " OUT: " +
              Util.Format_Int(registers[sleft.R_Value()]);
        compiler.Output_User( t_in + t_out );
        
        if ( problem.custom ) {
          problem.output.push(registers[sleft.R_Value()]);
          return new Exec_Ret(Exec_Ret.T_out, 0, 0);
        }
        
        if ( uint(problem.output[problem.output_it]) != 
                    uint(registers[sleft.R_Value()]) ) {
          error = Error_Code.Invalid_Output;
          compiler.Output_User("      ---- ERROR ---- ");
          compiler.Output_User("Expected " + problem.output[problem.output_it]);
          compiler.Output_User("");
        }
        if ( ++ problem.output_it >= problem.output.length ) {
          done = true;
        }
        return new Exec_Ret(Exec_Ret.T_out, 0, 0);
      break;
      case Symbol.I_JEZ:
          ++ t_jumps;
        if ( registers[Symbol.R_AX] == 0 )
          return new Exec_Ret(Exec_Ret.T_jump, sleft.R_Value());
      break;
      case Symbol.I_JGZ:
          ++ t_jumps;
        if ( registers[Symbol.R_AX] >  0 )
          return new Exec_Ret(Exec_Ret.T_jump, sleft.R_Value());
      break;
      case Symbol.I_JLZ:
          ++ t_jumps;
        if ( registers[Symbol.R_AX] <  0 )
          return new Exec_Ret(Exec_Ret.T_jump, sleft.R_Value());
      break;
      case Symbol.I_JMP:
          ++ t_jumps;
          return new Exec_Ret(Exec_Ret.T_jump, sleft.R_Value());
      break;
      case Symbol.I_JNZ:
          ++ t_jumps;
        if ( registers[Symbol.R_AX] != 0 )
          return new Exec_Ret(Exec_Ret.T_jump, sleft.R_Value());
      break;
      case Symbol.I_JRO:
          ++ t_jumps;
          return new Exec_Ret(Exec_Ret.T_jump_offset, R_Value(sleft));
      break;
      case Symbol.I_MOV:
        if ( sleft.R_Type() == Symbol.Register )
          registers[sleft.R_Value()] = R_Value(srite);
        else // memory
          if ( sleft.R_Type() == Symbol.Memory )
            memory[sleft.R_Value()] = R_Value(srite)
          else {// memreg
            var regv : int = registers[sleft.R_Value()];
            if ( regv > 20 || regv < 0 ) {
              error = Error_Code.Out_Of_Range;
              error_det = "Tried to access memory at\n" +
                   "illegal index (" + regv.toString().slice(0, 3) + ")\n";
              error_loc = loc;
              error_sr  = sr;
            } else
              memory[regv] = R_Value(srite);
          }
      break;
      case Symbol.I_NOP:
        // -- do nothing
      break;
      case Symbol.I_POP:
        switch ( sleft.R_Type() ) {
          case Symbol.Register:
            registers[sleft.R_Value()] = stack.Pop();;
          break;
          case Symbol.Memory:
            memory[sleft.R_Value()] = stack.Pop();;
          break;
          case Symbol.MemoryReg:            
          var t : int = registers[sleft.R_Value()];
          if ( t < 0 || t >= memory.length ) {
            error = Error_Code.Out_Of_Range;
            error_det = "Tried to access memory at\n" +
                 "illegal index (" + t.toString().slice(0, 3) + ")\n";
            return new Exec_Ret(0, 0);;
          }
          memory[t] = stack.Pop();
        }
      break;
      case Symbol.I_PUSH:
        stack.Push(R_Value(sleft));
      break;
      case Symbol.I_MDD:
        compiler.Inform_Input_Change(loc, sr, null);
        code[sr][loc] = new Array(null);;
      case Symbol.I_MOD:
        mod_used = true;
        // get values
        var t : int = R_Value(sleft);
        var page   : int = (t >> (29))&0x07,
            nloc   : int = (t >> (4*6))&0x1F,
            lhtype : int = (t >> (4*5))&0x0F,
            rhtype : int = (t >> (4*4))&0x0F,
            lhval  : int = (t >> (4*2))&0xFF,
            ninstr : int = (t         )&0xFF,
            rhval  : int = R_Value(srite);
        // check validity
        if ( code.length <= page || page < 0 ) {
          error = Error_Code.Out_Of_Range;
          error_det = "Tried to access code page at\n" +
                      "illegal index (" + page.toString().slice(0,3) + ")\n";
          return new Exec_Ret(Exec_Ret.T_good, 0);
        }
        if ( code[page].length <= nloc || nloc < 0 ) {
          error = Error_Code.Out_Of_Range;
          error_det = "Tried to access LOC at\n" +
                      "illegal index (" + nloc.toString().slice(0,3) + ")\n";
          return new Exec_Ret(Exec_Ret.T_good, 0);
        }
        if ( ninstr != 0xFF ) {
          if ( Symbol.Instructions.length <= ninstr || ninstr < 0 ) {
            error = Error_Code.Out_Of_Range;
            error_det = "Tried to access invalid\n" +
                        "instruction ID " + ninstr.toString().slice(0,3) + ")\n";
            return new Exec_Ret(Exec_Ret.T_good, 0);
          }
        }
        code[page][nloc] = new Array(new Symbol(""));
        if ( ninstr != 0xFF ) { // erase line?
          code[page][nloc][0].Set_Value(ninstr);
          code[page][nloc][0].Set_Type (Symbol.Command);
          var instruction : Instruction = Symbol.Instructions[ninstr];
          if ( instruction.R_Params() > 0 ) {
            var lhsym : Symbol = new Symbol("");
            lhsym.Set_Value(lhval);
            lhsym.Set_Type (lhtype );
            code[page][nloc].push(lhsym);
            if ( instruction.R_Params() > 1 ) {
              var rhsym : Symbol = new Symbol("");
              rhsym.Set_Value(rhval);
              rhsym.Set_Type(rhtype );
              code[page][nloc].push(rhsym);
            }
          }
          error = Error_Check_Line(nloc, page);
        } else {        
          code[page][nloc] = new Array(null);;
          compiler.Inform_Input_Change(nloc, page, null);
          return new Exec_Ret(Exec_Ret.T_good, 0);
        }
        // inform input of the change
        if ( !error )
          compiler.Inform_Input_Change(nloc, page, code[page][nloc]);
      break;
      // --- custom problem instrucitons --
      case Symbol.I_MULT:
        registers[sleft.R_Value()] = int(R_Value(sleft) * R_Value(srite));
      break;
      case Symbol.I_DIV:
        registers[sleft.R_Value()] = int(R_Value(sleft) / R_Value(srite));
      break;
      case Symbol.I_POW:
        registers[sleft.R_Value()] = int(Math.pow(R_Value(sleft),
                                                R_Value(srite)));
      break;
      case Symbol.I_SQRT:
        registers[sleft.R_Value()] = int(Math.sqrt(R_Value(sleft)));
      break;
      case Symbol.I_LOG:
        registers[sleft.R_Value()] = int(Math.log(R_Value(sleft))/
                                        Math.log(R_Value(srite)));
      break;
    }
    return new Exec_Ret(Exec_Ret.T_good, 0);
  }
  // in: LOC to exec ret: 1 empty, 0 not empty
  public function Is_Empty(loc : int, sr : int ) : Boolean {
    return ( code[sr][loc][0] == null );
  }
  // -- error check also builds labels --
  private function Error_Check() : int {
    // -- build labels
    var page : int,
        loc  : int;
    for ( page = 0; page != code.length;       ++ page )
    for ( loc  = 0; loc  != code[page].length; ++ loc  ) {
      if ( code[page][loc].length == 0 ) continue;
      error = Build_Label(page, loc);
      if ( error ) {
        error_loc = loc;
        error_sr  = page;
      }
    }
    // -- find errors
    for ( page = 0; page != code.length;       ++ page )
    for ( loc  = 0; loc  != code[page].length; ++ loc  ) {
      if ( code[page][loc].length == 0 ) continue;
      error = Error_Check_Line(loc, page);
      if ( error ) {
        error_loc = loc;
        error_sr  = page;
        return error;
      }
    }
    return 0;
  }
  private function Build_Label(page:int, loc:int) : int {
    var labl : Symbol = code[page][loc][0];
    if ( labl.R_Type() == Symbol.JmpLabel ) {
      // check valid label name
      if ( labl.R_Name().charAt(0) < 'A' ||
          labl.R_Name().charAt(0) > 'Z' ) {
        error_det = "First char must start with letter\n" + labl.R_Name();
        return Error_Code.Invalid_Label;
      }
      labels.push(new Label(labl.R_Name(), loc, page));
    }
    return 0;
  }
  
  private function Error_Check_Line(line:int, sr:int) : int {
    var syms : Array = code[sr][line];
    var inst : Symbol = code[sr][line][0];
    var ins : Array = Symbol.Instructions;
    var instr : Instruction = ins[inst.R_Value()];
    // -- check label
    if ( inst.R_Type() == Symbol.JmpLabel ) {
      if ( syms.length > 1 ) { // check length
        error_det = "Labels must occupy their own line";
        return Error_Code.Invalid_Parameters;
      }
      return 0;
    }
    // -- check command and proper parameters
    if ( inst.R_Type() != Symbol.Command ) {
      error_det = Symbol.Type_Names[inst.R_Type()] + " invalid.";
      return Error_Code.Missing_Instruction;
    }
    // check length
    if ( instr.R_Params() != syms.length - 1 ) {
      error_det = String(instr.R_Params()) +
                          " parameters required";
      return Error_Code.Invalid_Parameters;
    }
    // check left parameter
    if (syms.length > 1 && !R_Valid_Type(instr.R_Param_Left(),
                                          syms[1].R_Type()) ) {
      error_det = Symbol.Type_Names[syms[1].R_Type()] + " invalid\n" +
                  "expecting " + Symbol.Type_Names[instr.R_Param_Left()];
      return Error_Code.Invalid_Parameters;
    }
    // check parameter
    if (syms.length > 2 && !R_Valid_Type(instr.R_Param_Right(),
                                         syms[2].R_Type()) ) {
      error_det = Symbol.Type_Names[syms[2].R_Type()] + " invalid\n" +
                  "expecting " + Symbol.Type_Names[instr.R_Param_Right()];
      return Error_Code.Invalid_Parameters;
    }
    // -- specific parameters --
    switch ( inst.R_Value() ) {
      case Symbol.I_JMP: case Symbol.I_JEZ: case Symbol.I_JNZ:
      case Symbol.I_JGZ: case Symbol.I_JLZ:
        // check label exists & save line
        for ( var i : int = 0; i != labels.length; ++ i ) {
          if ( labels[i].R_Name() == syms[1].R_Name() &&
               labels[i].R_Page() == sr ) {
            syms[1].Set_Value(labels[i].R_Line());
            return 0;
          }
        }
        error_det = syms[1].R_Name();
        return Error_Code.Unknown_Label;
      break;
    }
    return 0;
  }

  // T2 can not be of type "any"
  private function R_Valid_Type(t1 : int, t2 : int) : Boolean {
    if ( t1 == Symbol.Any )
      return (t2 == Symbol.Literal   || t2 == Symbol.Register ||
              t2 == Symbol.MemoryReg || t2 == Symbol.Memory);
    if ( t1 == Symbol.Any_Mem )
      return (t2 == Symbol.Register || t2 == Symbol.Memory ||
              t2 == Symbol.MemoryReg);
    if ( t1 == Symbol.Any_Quick )
      return (t2 == Symbol.Register || t2 == Symbol.Literal);
    return t1 == t2;
  }

  private function R_Value(sym : Symbol) : int {
    if ( sym == null ) {
      error = Error_Code.Invalid_Parameters;
      error_det = "Weird bug, contact me w/ code\n";
      return 0;
    }

    switch ( sym.R_Type() ) {
      case Symbol.Literal:
        return sym.R_Value();
      case Symbol.Register:
        return registers[sym.R_Value()];
      case Symbol.Memory:
        return memory[sym.R_Value()];
      case Symbol.MemoryReg:
        var t : int = registers[sym.R_Value()];
        if ( t < 0 || t >= memory.length ) {
              error_det = "Tried to access memory at\n" +
                   "illegal index (" + t.toString().slice(0, 3) + ")\n";
          return 0;
        }
        return memory[registers[sym.R_Value()]];
      default:
        return 0;
    }
  }

  public function Set_Problem(p : Problem) : void {
    problem = p;
  }

  // --- returns -----------------------------------------------
  public function R_LOC_Array(l:int, sr:int) : Array {
    return code[sr][l];
  }
  public function R_Error()     : int     { return error;       }
  public function R_Error_Det() : String  { return error_det;   }
  public function R_Error_LOC() : int     { return error_loc;   }
  public function R_Error_SR()  : int     { return error_sr;    }
  public function R_LOC(t:int)  : int     {
    for ( var i : int = code[t].length-1; i != 0; -- i )
      if ( code[t][i].length != 0 )
        return i+1;
    return 0;
  }
  public function R_LOC_No_Emp(): int     {
    if ( t_loc == 0 ) {
      var cnt : int = 0;
      for ( var o : int = 0; o != code.length; ++ o )
      for ( var i : int = 0; i != code[o].length; ++ i ) {
        if ( code[o][i].length != 0 ) ++ cnt;
      }
      return cnt;
    } else return t_loc;
  }
  public function R_Tot_Jumps() : int     {
    return t_jumps;
  }
  public function R_Tot_Style() : int {
    return t_style;
  }
  public function R_Registers() : Array   { return registers;  }
  public function R_Memory()    : Array   { return memory;     }
  public function R_Stack()     : Stack   { return stack;      }
  public function R_Call_Stack(): Stack   { return call_stack; }
  public function R_Done()      : Boolean { return done;       }
  public function R_Mod_Used()  : Boolean { return mod_used;   }
}}
