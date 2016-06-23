package {
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.display.Stage;;
  import flash.text.engine.BreakOpportunity;
  import flash.text.TextField;
  public class Tutorial {
    [Embed("../Imgs/helpmark.png")] public static var Img_Help : Class;
    public static var count : int;
    public static var input : Input;
    public static var img : Bitmap,
                      bg  : Sprite;
    public static var text : TextField;  
    private static var stage : Sprite;
    
    public static var tutorial_codes : Array,
                      tutorial_hints : Array,
                      tutorial_text  : Array;
    public function Tutorial() {}
    public static function Initialize(inp:Input, s:Sprite) : void {
      if ( inp != null ) {
        count = 0;
        input = inp;
        stage = s;
        
        img = Bitmap(new Img_Help());
        text = Util.Create_TextField();
        s.addChild(img);
        s.addChild(text);
        img.x = 150;
        img.y = 95;
        text.x = 160;
        text.y = 97;
      }
      // set up tutorial codes
      tutorial_codes = new Array(
        "IN AX\nADD AX -1\nOUT AX",
        "IN AX\nADD BX AX\nADD BX AX\nOUT BX",
        "",
        "",
        "",
        "",
        "",
        "IN AX\nMOV M0 AX\nXOR AX X80000000\nNOP\nSHR AX 31\nNOP\nMOV BX M0\nADD BX AX\n"
      );
      tutorial_text = new Array(
        new Array("Welcome to ciggbitcembly! Here is a program\n"+
                  "already made for you. Not all tutorial code\n"+
                  "is optimal (and some are intentionally broken\n"+
                  "for you to fix), but make sure to pay close\n"+
                  "attention as we watch it execute and see what\n"+
                  "each instruction does! Make sure you READ! :)",
                  
                  "Notice the highlighted line of code below, this\n"+
                  "is the next instruction that will be executed.\n"+
                  "When this line runs, AX will be set to IN's value\n"+
                  "AX = IN\n"+
                  "Watch the IN and AX nodes as the command executes\n",
                  
                  "We are going to decrement AX by one here:\n"+
                  "AX = AX - 1\n"+
                  "The easiest way to do this is by adding -1 to\n"+
                  "AX. There are better methods of accomplishing\n"+
                  "this (take a look at DEC), and you can find\n"+
                  "those in the arithmetic unit on the left.",
                  
                  "Now we have to output our solution, the program\n"+
                  "will check if it is correct. It is not correct,\n"+
                  "I leave it up to you to fix it to output the\n"+
                  "correct answer.\n"+
                  "OUT = AX (OUT = IN-1 (incorrect answer! Fix me!))",
                  
                  "You're pretty much good to go. You can check\n"+
                  "this tutorial out again, use the ? to view\n"+
                  "the manual, and click nodes to learn more\n"+
                  "instructions. There are more tutorials/hints\n"+
                  "on the other levels as well. Good luck.\n"
                  
                  ),
        //"IN AX\nADD BX AX\nADD BX AX\nOUT BX",
        new Array("For this problem we will try to double the input\n"+
                  "to the output. There are clever ways to do this,\n"+
                  "for instance if you were to use bit arithmetic\n"+
                  "but we'll focus on the basics for this tutorial.",
                  
                  "We grab input and set to AX like we did last time",
                  
                  "We want to double the input, so we add AX to BX\n"+
                  "twice, note that all registers and memory always\n"+
                  "start off at 0. Anyways, we're basically doubling:\n"+
                  "BX = BX + AX + AX\n"+
                  "alternatively: BX = BX + AX*2",
                  
                  "Since assembly is at such a 'low level' (meaning\n"+
                  "close to the machine), the arithmetic we perform\n"+
                  "is very primitive and basic. We have to add twice\n"+
                  "to double, as there is no inherit multiplication\n"+
                  "(You can emulate multiplication using SHL though)",
                  
                  "And now output the answer. Note that BX retains\n"+
                  "its original value even after an OUT.",
                  
                  "Since BX retains its original value, this program\n"+
                  "will not work. See if you can find out how to set\n"+
                  "BX back to 0 so we can use it to double again.\n"+
                  "(Check out the Move node)"
                ),
        null, null, null, null, null,
        new Array("For this problem we'll learn about bit operations\n"+
                  "This is a pretty complex subject and you should\n"+
                  "look it up if you really want to go far.\n"+
                  "We will focus on checking if the input is positive\n"+
                  "you should know how to count in binary to do this\n",
                  
                  "We grab input again and set it to AX",
                  
                  "We want to save AX's value, so we place it in\n"+
                  "M0, Memory unit 0. We could place it in BX\n"+
                  "but I wanted to show how to use memory units.",
                  
                  "The logical AND does the following:\n"+
                  "1&1 -> 1, 1&0 -> 0, 0&0 -> 0. By using\n"+
                  "80000000 (Which sets if the number is negative,\n"+
                  "which is dictated by the left-most bit.)\n"+
                  "We can look strictly at the number's sign.\n",
                  
                  "This looks like: (using only 2 bytes):\n"+
                  "1000 0000 0000 0000    (X8000000 hex)\n"+
                  "A??? ???? ???? ????    (AX register)\n"+
                  "if A = 0: 0\n"+
                  "if A = 1: 1\n"+
                  "All ? are set to 0",
                  
                  "Now that we have either a a neg number OR zero,\n"+
                  "Now we want to set the number to -1, just so we\n"+
                  "illustrate some math with it. To do this, we shift\n"+
                  "the bits to the right by 31. For SHR the MSB\n"+
                  "(Most Significant Bit) is preserved.",
                  
                  "This looks like: (using only 1 nibble):\n"+
                  "1000 - Zero right shifts\n"+
                  "1100 - One right shift\n"+
                  "1110 - Two right shifts\n"+
                  "etc, note that 1111 is equal to -1.\n"+
                  "1110 = -2, 11101 = -3, etc ...",
                  
                  "Now we are done, so we move M0 to BX (memory units\n"+
                  "can not use arithmetic or logic instructions)",
                  
                  "And finally we add it to AX. If the number was\n"+
                  "positive, it will be the same exact value. If\n"+
                  "it was negative, it would be the original value\n"+
                  "minus one.",
                  
                  "Unfortunately this topic I can only glance over,\n"+
                  "hopefully some of you will go out and learn!\n"+
                  "Try using the Windows Calculator, set it to\n"+
                  "programmer mode (view->programmer) and you can\n"+
                  "set bits and test the logic yourself! Use it!"
                )
      );
      tutorial_hints = new Array(
        null,
        null,
        new Array("Try viewing previous", "tutorial, I practically spell", "it out there."),
        new Array("Goto the manual and", "learn about branching!", "An example of this program", "is there too (p4/4)"),
        new Array("Try simplifying the formula",
                  "alternatively use SHL for",
                  "multiplication",
                  "(check logical units)"),
        new Array("Use branching and", "addition to solve this one"),
        new Array("Look up TWO's COMPLEMENT"),
        null,
        new Array("USE SHL if you","have neglected to","learn it by now"),
        new Array("Easy"),
        new Array("Use subtraction", "and JGZ."),
        new Array("Try using the","stack or memory","to hold the","operator"),
        new Array("Check tut on", "Bit Hack I"),
        new Array("Use the STACK!"),
        new Array("SHL"),
        new Array("SHR"),
        new Array("IDK, ask 0z9tu"),
        new Array("Try storing", "fibonacci in the code"),
        new Array("add 3 times AX", "sub 1 BX", "is close to divison", "very slow though"),
        new Array("No idea", "good luck"),
        new Array(),
        new Array(),
        new Array(),
        new Array("OR")
      );
    }
    public static function Destroy() : void {
      stage.removeChild(img);
      stage.removeChild(text);
    }
    
    public static function Update(problem:int, spac:Boolean) : void {
      count = Math.min(tutorial_text[problem].length-1, count);
      text.text = tutorial_text[problem][count];
      if ( spac ) {
        text.text += "\nSpace to continue...\n";
      }
    }
  }
}