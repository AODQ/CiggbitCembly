package {
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.Stage;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;
public class Guide  {
  [Embed("../Imgs/guide.png")] private var Img_CLine : Class;  
  public var font : Font;
  public const T_outcount  : int = 0,
               T_incount   : int = 1,
               T_arith     : int = 2,
               T_logic     : int = 3,
               T_in        : int = 4,
               T_out       : int = 5,
               T_regax     : int = 6,
               T_regbx     : int = 7,
               T_mem       : int = 8,
               T_tick      : int = 9,
               T_PC        : int = 10,
               T_branch    : int = 11,
               T_stack     : int = 12,
               T_integer   : int = 13,
               T_move      : int = 14,
               T_misc      : int = 15,
               T_KAProgAd  : int = 16,
               T_Subrout   : int = 17,
               T_Callstack : int = 18;
  private var text : TextField;  
  public static var Out : Array;
  private static var background : Bitmap;
  private var stage : Sprite;
  public function Guide(s:Sprite) {
    stage = s;
    background = Bitmap(new Img_CLine());
    background.visible = false;
    s.addChild(background);
    text = Util.Create_TextField();
    text.visible = false;
    s.addChild(text);
  }
  public function Update_Data(t:int) : void {
    text.visible = true;
    if ( t != -1 ) {
      var o : Guide_Data = Out[t];
      text.text = o.info;
      text.x = o.posx + 3;
      text.y = 0;
      background.x = o.posx;
      background.visible = true;
    } else {
      var s : String = "---- PROBLEM      TICKS     STYLE \n";
      for ( var i : int = 0; i != Problem.tot_levels; ++ i ) {
        var st : String = Problem.problem_set[i].name;
        while ( st.length < 17 ) st += " ";
        s += st + " ";
        st = String(Saver.ticks[i]);
        while ( st.length < 9 ) st += " ";
        s += st + " ";
        st = String(Saver.style[i]);
        while ( st.length < 9 ) st += " ";
        s += st + '\n';
      }
      text.text = s;
      text.x = 400;
      text.y = 10;
      background.visible = true;
      background.x = 400
    }
    
    // kind of messy but whatever, need to assure
    // that this is at the top
    stage.removeChild(background);
    stage.removeChild(text);
    stage.addChild(background);
    stage.addChild(text);
  }
  public function Clear_Data() : void {
    text.visible = false;
    background.visible = false;
  }
  public static function Initialize() : void {
    var cx  : int = 400,
        lx  : int = 200,
        rx  : int = 0,
         y  : int = 300;
    // init text and image
    Out = new Array(
      // ---- out count -------------------------\n"+
      new Guide_Data(
        "OUT COUNT\n" +
        "Keeps track of how many times OUT has\n" +
        "received input, relative to each problem\n\n"+
        "Increments every time OUT is called",
        cx, y, 17, 2, 133, 24),
      // ---- in count --------------------------\n"+
      new Guide_Data(
        "IN COUNT\n" +
        "Keeps track of times IN has received\n"+
        "input, relative to each problem\n\n" +
        "Increments every time IN is called\n",
        cx, y, 17, 42, 133, 24),
      // ---- arithmetic ------------------------\n"+
      new Guide_Data(
        "GENERAL ARITHMETIC UNIT\n" +
        "A set of arithmetic instructions for use\n"+
        "by AX and BX registers.\nCan not be\n"+
        "applied to memory\n\n" +
        "--- instructions ---\n" + 
        "INC REG - Increments value of reg by 1\n"+
        "DEC REG - Decrements value of reg by 1\n"+
        "ADD REG ANYQ - Adds Y to X\n"+
        "SUB REG ANYQ - Subtracts Y to X\n" +
        "ABS REG - Absolute value of X to X\n" +
        "SHL REG ANYQ - Shifts X left by Y\n"+
        "SHR REG ANYQ - Shifts X right by Y\n\n"+
        "Shifting implies manipulation of bits\n"+
        "The value 5 equals:    0101\n"+
        "Shifting 5 left by 1:  1010\n"+
        "Shifting 5 right by 1: 0010\n\n"+
        "Example (AX = AX - BX)\n" +
        "SUB AX, BX\n" +
        "\n\n" +
        "Most problems do NOT require shifting,\n"+
        "however it will make them optimal,\n"+
        "therefore if you do not understand bit\n" +
        "operations you should not worry about\n" +
        "this until you want to optimize\n",
        cx, y, 11, 127, 94, 40),
      // ---- logic -----------------------------\n"+
      new Guide_Data(
        "LOGICAL EXPRESSION UNIT\n" +
        "A set of bit-wise logical instructions\n"+
        "for use by AX and BX registers.\n"+
        "Can not be applied to memory\n"+
        "\n\n"+
        "--- instructions ---\n"+
        "OR REG ANQ - Stores X|Y to X\n" + 
        "      5(b0101)|3(b11) -> 6(b0111)\n" +
        "  (1 if bitX or bitY = 1 else 0)\n"+
        "AND REG ANQ - Stores X&Y to X\n" +
        "      5(b0101)&3(b11) -> 5(b0101)\n" +
        "      5(b0101)&0(b0)  -> 0(b0000)\n" + 
        "  (1 if bitX and bitY = 1 else 0)\n"+
        "XOR REG ANQ - Stores X^Y to X\n" +
        "  (1 if bitX = 1 or bitY = 1 else 0,\n"+
        "    unless bitX and bitY = 1 then 0)\n"+
        "NOT REG - Stores ~X to X\n" +
        "       ~5(b0101) -> 10(b1010)\n" +
        "  (flips bitX: 0 if bitX = 1 otherwise 1\n"+ 
        "\n"+
        "Most problems do NOT require the logic\n"+
        "unit, however it will make them optimal,\n"+
        "therefore if you do not understand bit\n" +
        "operations you should not worry about\n" +
        "this until you want to optimize\n",
        cx, y, 11, 173, 94, 40),
      // ---- input -----------------------------\n"+
      new Guide_Data(
        "PROBLEM INPUT\n" +
        "Provides register with input values\n"+
        "for problem.\n\n" +
        " --- instructions ---\n" +
        "IN REG: Sets register REG (ei: AX) with\n"+
        "    current input, updates input\n"+
        "    If input is exhausted, sets REG to 0",
        cx, y, 6, 226, 130, 22),
      // ---- output ----------------------------\n"+
      new Guide_Data(
        "PROBLEM OUTPUT\n" +
        "Grabs value in register, sends to\n"+
        "output to compare to current output\n\n"+
        " --- instructions ---\n" +
        "OUT REG - Gets register REG and sends to\n"+
        "  updates output.  If output is\n" +
        "  exhausted, program is finished\n"+
        "  If output does not match, program\n"+
        "  exits with an error\n",
        cx, y, 6, 312, 130, 22),
      // ---- register AX ---------------------\n"+
      new Guide_Data(
        "REGISTER AX\n" +
        "Stores a single value.\n\n" +
        "Register can perform arithmetic and\n" +
        "logical ops, has access to the stack,\n" +
        "and can move its value to memory and\n" +
        "registers\n\n"+
        "Also can receive input along with send\n"+
        "output\n\n" +
        "-- example (Sending input-1 to output)\n" +
        "IN ; assigns input value to AX\n"+
        "SUB AX 1 ; Subtracts AX by 1\n"+
        "OUT ; outputs to AX\n",
        cx, y, 6, 269, 130, 22),
      // ---- register BX -----------------------\n"+
      new Guide_Data(
        "REGISTER BX\n" +
        "Stores a single value.\n\n" +
        "Register can perform arithmetic and\n" +
        "logical ops, has access to the stack,\n" +
        "and can move its value to memory and\n" +
        "registers\n\n"+
        "Also can receive input along with send\n"+
        "output",
        cx, y, 166, 269, 130, 22),
      // ---- memory ----------------------------\n"+
      new Guide_Data(
        "MEMORY UNITS\n" +
        "Stores 10 values indexed at 0 (0 .. 9)\n\n"+
        "To access, prefix literal or register\n"+
        "with M OR $. Ei: M0 for first slot of\n" +
        "memory, M9 for last, MAX for index based\n"+
        "off the current value of AX\n\n"+
        "Each unit can move its value to other\n"+
        "units and to registers AX and BX\n\n"+
        "DOES NOT have access to arithmetic and\n"+
        "logical ops nor the stack\n\n" +
        "You CAN access Local Memory Units by\n"+
        "using M10 .. M19, etc, but they will be\n"+
        "interpreted as 'L0 .. L9'\n"+
        "-- example (moving $0 to $2)\n" +
        "MOV M0 $2\n\n"+
        "You can also access memory by register\n" +
        "offsets, the value of the register\n" +
        "corresponds to the slot being accessed.\n" +
        "(Prenote with $ and register name)\n\n" +
        "-- example (setting value to index)\n" +
        "INC BX ;  0\n" +
        ";$0 0, $1 1, ETC"+
        "MOV $BX, BX\n",
        cx, y, 30, 374, 127, 226),
      // ---- local -----------------------------\n"+
      new Guide_Data(
        "LOCAL MEMORY UNITS\n"+
        "**Same as MEMORY UNITS in this version**\n"+
        "In whatever future version they will be\n"+
        "implemented correctly.\n"+
        "Stores 10 values indexed at 0 (0 .. 9)\n\n"+
        "To access, prefix literal or register with\n"+
        "L (L0, LAX). Same rules that apply to\n"+
        "Units are applied here.\n\n"+
        "The only difference is that the memory is\n"+
        "local to the subroutine you are in.",
        cx, y, 160, 374, 122, 226),
      // ---- tick ------------------------------\n"+
      new Guide_Data(
        "TICK COUNTER/CLOCK CYCLE\n" +
        "Keeps track of the amount of ticks\n"+
        "(instructions executed).\n\n"+
        "Starts about halfway through problem;\n"+
        "the first half of questions are\n"+
        "randomized, while the last half are not\n"+
        "in order to insure everyone has the same\n"+
        "input values when doing high scores.\n",
        rx, y, 584, 45, 168, 22),
      // ---- style -----------------------------\n"+
      new Guide_Data(
        "STYLE\n"+
        "Every time an instruction is executed,\n"+
        "style points are given. The less style,\n"+
        "the better (we are programmers after all)\n"+
        "The purpos of this is to promote clever\n"+
        "solutions (using bit hacks, sub routs\n"+
        "MOD, etc)\n\n"+
        "There is a NoMOD category for those who\n"+
        "wish to compete without using\n"+
        "self-modifying code. You are automatically\n"+
        "sent in if a MOD instruction is not\n"+
        "executed.\n\n"+
        "Like the Cycle, this does not start until\n"+
        "about halfway through the problem.\n\n"+
        "------------- style points -------------\n"+
        "0 point: IN NOP OUT MOD RET\n"+
        "1 point: XOR OR AND NOT SHR SHL MOV POP\n"+
        "         PUSH\n"+
        "2 point: CALL IN DEC\n"+
        "3 point: JRO\n"+
        "4 point: SUB ADD JMP JLZ JGZ JEZ JNZ\n"+
        "5 point: ABS",
        rx, y, 584, 77, 168, 22),
      // ---- PC --------------------------------\n"+
      new Guide_Data(
        "PROGRAM COUNTER\n" +
        "Keeps track of curent line of code (LOC)\n\n"+
        "Highlights line of code to be executed\n"+
        "next.\nWill also highlight errors\n\n" +
        "Can be manipulated using branching unit",
        cx, y, 315, 179, 72, 27),
      // ---- branch ----------------------------\n"+
      new Guide_Data(
        "BRANCHING OPERATIONS\n" +
        "Can override program counter's value\n"+
        "Sometimes requires register AX to\n"+
        "determine if a jump should be made\n\n"+
        "---- instructions ----\n"+
        "JMP LABEL - Jumps PC to LABEL\n"+
        "JEZ LABEL - Jumps PC to LABEL if AX == 0\n"+
        "JNZ LABEL - Jumps PC to LABEL if AX != 0\n"+
        "JGZ LABEL - Jumps PC to LABEL if AX >  0\n"+
        "JLZ LABEL - Jumps PC to LABEL if AX <  0\n"+
        "JRO REGISTER - Adds REG value to PC. PC\n"+
        "     will not be incremented that tick\n\n"+
        "-- example (decrement until 0 is hit)\n" +
        "READD:\n"+
        "DEC AX\n"+
        "JMP READD:\n\n" +
        "Note LABELs require ':' at the end no\n"+
        "matter the context\n\n" +
        "-- example (loops infinitely)\n" +
        "MOV AX, 3" +
        "MOV BX, -3" +
        "JRO AX\n" +
        "NOP ;these two NOP (no operation)\n" +
        "NOP ;are never hit\n" +
        "JRO BX\n",
        rx, y, 407, 178, 84, 30),
      // --- stack ------------------------------\n"+
      new Guide_Data(
        "STACK UNIT\n" +
        "A First In Last Out (FILO) unit holding\n"+
        "a maximum of 10 values\n\n"+
        "What this means is that the stack can\n" +
        "push literals, and the last that has\n" +
        "been pushed is the literal that will\n" +
        "be popped. Check example for details\n\n"+
        "---- instructions ----\n"+
        "PUSH (REGISTER/LITERAL) - Pushes value\n" +
        " into stack if stack is full, overrides\n" +
        " 10th slot\n"+
        "POP - Pops values from stack and assigns\n"+
        " to register AX, if stack is empty, AX\n"+
        " is set to 0\n"+
        "-- example (to show stack ordering)\n"+
        "PUSH 30\n" +
        "PUSH 50\n"+
        "POP ; 50 stored to AX\n"+
        "POP ; 30 stored to AX\n",
        rx, y,  678, 139, 111, 26),
      // --- integer ----------------------------\n"+
      new Guide_Data(
        "LITERAL UNIT\n"+
        "Can create a signed four byte integer,\n"+
        "range of –2,147,483,648 to 2,147,483,647\n"+
        "Literals can be moved to registers,\n" +
        "the stack and memory, along with being\n" +
        "able to be used in arithmetic and logical\n" +
        "operations\n\n"+
        "The integer in hex form looks like:\n"+
        "XFFFFFFFF (X is hex notation, like 0xf)\n"+
        "-- example (to show how to invoke a lit)\n"+
        "MOV AX, 30\n"+
        "MOV $0, 30\n\n"+
        "-- useful numbers to know\n" +
        "X80000000 - Most  significant bit (MSB)\n"+
        "X00000001 - Least significant bit (LSB)\n"+
        "XFFFFFFFF - -1\n"+
        "X7FFFFFFF - All bits but the MSB\n"+
        "XFFFFFFFE - All bits but the LSB\n"+
        "XDEADBEEF - ??????????????????\n",
        cx, y, 186, 305, 72, 27),
      // --- move -------------------------------\n"+
      new Guide_Data(
        "MOVE INSTRUCTION\n" +
        "Can 'move' registers/memory/literals to\n"+
        "any register or memory. Moving implies\n"+
        "setting the source to destination,\n"+
        "destination is left unhindered\n\n" +
        "MOV ANY, ANY - Assigns Y -> X\n\n"+ 
        "-- example\n" +
        "MOV AX 30 ; sets AX to 30\n" +
        "MOV $0 $2 ; sets $0 to $2's value\n",
        cx, y, 171, 172, 72, 27),
      // --- misc -------------------------------\n"+
      new Guide_Data(
        "MISC INSTRUCTIONS\n" +
        "\n" +
        "NOP - No operation. Does nothing, still\n"+
        "      takes up a clock tick however\n\n"+
        ";   - Comment, everything on line after\n"+
        "      is ignored. \n\n"+
        "MOD ANYQ, ANYQ - Changes specified LOC\n"+
        "     to another instruction:\n\n"+
        "     left hand argument (binary)\n"+
        "PPPL LLLL EEEE RRRR FFFF FFFF IIII IIII\n\n"+
        "P = Page # |L = Line|E = LH-type\n"+
        "R = RH-type|F = LH-Value|I = Instruction\n\n"+
        "RH argment is just value for the RH value\n"+
        "Check advanced slide 2/2 for more info\n",
        cx, y, 171, 215, 72, 27),
      // --- KAProg guide -----------------------\n"+
      new Guide_Data(
        "Kickass Programmer's main purpose is to\n"+
        "provide a list of source/links to\n" +
        "programming documentation, references and\n" +
        "tutorials. We also keep members up to\n" +
        "date with upcoming game jams and other\n"+
        "related programming events.\n\n"+
        "We are also, of course, a community of\n"+
        "programmers. Feel free to drop in chat\n"+
        "and have a discussion (or question)\n"+
        "with us on Game Development Room (GDR)\n"+
        "located here on the glorious Kongregate\n\n\n"+
        "Steam URL:\n"+
        "steamcommunity.com/groups/stdprog\n"+
        "Click to copy URL...\n\n",
        rx, y, 566, 3, 230, 36),
        // --- subroutines ---------------------\n"+
        new Guide_Data(
          "SUBROUTINE UNIT\n" +
          "Manages subroutine calls using the\n"+
          "call stack.\n\n"+
          "---- instructions ----\n"+
          "CALL ANYQ - 'Calls' subroutine by\n"+
          "     pushing current position in the\n"+
          "     call stack, and then pointing the\n"+
          "     program counter to the subroutine\n"+
          "     called at line 0.\n\n"+
          "RET       - 'Returns' subroutine by\n"+
          "     popping previous position in the\n"+
          "     call stack, and then pointing the\n"+
          "     program counter to the popped\n"+
          "     position.",
          rx, y, 525, 178, 84, 30),
        // --- call stack -----------------------\n"+
        new Guide_Data(
          "CALL STACK\n" +
          "The same as the stack unit except it\n"+
          "can only hold five values. Programmers\n"+
          "do not have direct access to the call\n"+
          "stack, instead it is abstracted by\n"+
          "using the instructions listed in the\n"+
          "subroutine unit to handle subroutine\n"+
          "calls and returns",
          rx, y, 570, 244, 111, 26)
    );
  }
}}