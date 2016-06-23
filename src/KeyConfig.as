package {
  import flash.display.Sprite;
  import flash.ui.Keyboard;
public class KeyConfig {
  public function KeyConfig() {}
  
  public static var speedup_2x  : Key,
                    speedup_32x : Key,
                    speedup_128x: Key,
                    pause       : Key,
                    prev_page   : Key,
                    next_page   : Key,
                    next_prob   : Key,
                    prev_prob   : Key,
                    help        : Key,
                    start       : Key;
  public static var keys        : Array;
  // run at first, but load should override
  public static function Setup_Keys() : void {
    speedup_2x  = new Key(Keyboard.Z, false, false);
    speedup_32x = new Key(Keyboard.X, false, false);
    speedup_128x= new Key(Keyboard.C, false, false);
    pause       = new Key(Keyboard.SPACE, false, false);
    next_page   = new Key(Keyboard.TAB, false, false);
    prev_page   = new Key(Keyboard.TAB, true, false);
    next_prob   = new Key(Keyboard.COMMA,  true, false);
    prev_prob   = new Key(Keyboard.PERIOD, true, false);
    help        = new Key(Keyboard.BACKSLASH, false, false);
    start       = new Key(Keyboard.NUMBER_5, true, false);
    keys = new Array(speedup_2x, speedup_32x, pause,
                next_page, prev_page, next_prob, prev_prob,
                help, start);
  }
}}