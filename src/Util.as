package  {
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextRenderer;
  import flash.ui.Keyboard;;
  public class Util {
    public function Util() { }

    static public function To_Char(c:uint, shift:Boolean) : String {
      if ( c == 189 ) return "-";
      if ( shift && c ==  52 ) return '$';
      if ( shift && c ==  51 ) return "#";
      if ( shift && c ==  50 ) return '@';
      if ( shift && c == Keyboard.NUMBER_0 ) return ':';
      if ( c == Keyboard.SLASH    ) return ':';
      if ( c == Keyboard.PERIOD   ) return ':';
      if ( c == Keyboard.BACKSLASH) return ':';
      if ( c == Keyboard.COMMA    ) return ':';
      if ( shift && c == Keyboard.L) return ':';
      if ( shift && c == Keyboard.N) return '-';
      if ( c == Keyboard.QUOTE    ) return ':';
      if ( c == 186 )
        if ( shift ) return ":";
        else         return ";";
      return String.fromCharCode(c);
    }
  static public function Format_Int(t:int, ins_x : Boolean = false) : String {
    if ( t > 99999999 ||
         t < -9999999 ) {
      var st : String = uint(t).toString(16).toUpperCase();
      if ( ins_x )
        st = "X" + st;
      return st;
    }
    return t.toString();
  }
  static public function R_Key_Hit(key:Key, key_code:uint,
                                  shift_hit : Boolean,
                                  ctrl_hit  : Boolean) : Boolean {
    return (key_code  == key.key   &&
            shift_hit == key.shift &&
            ctrl_hit  == key.ctrl);
  }
  static public function R_Key_String(key:Key, min_len:uint = 0) : String {
    var s : String = "";
    if ( key.ctrl )
      s = "CTRL ";
    if ( key.shift )
      s += "SHIFT ";
    s += Key_To_String.key_to_str[key.key];
    while ( s.length < min_len ) s += " ";
    return s;
  }
  public static function In_Range(x:int, y:int, w:int, h:int,
                           mx:int, my:int) : Boolean {
    return !(x > mx || y > my || (x + w) < mx || (y + h) < my);
  }
  static public function Create_TextField() : TextField {
    var s : TextField = new TextField();
    s.embedFonts = true;
    s.textColor = 0xC8C8C8;
    s.autoSize = TextFieldAutoSize.LEFT;
    s.defaultTextFormat = DejaVuSansMono.style;
    s.antiAliasType = "advanced";
    s.gridFitType = "pixel";
    s.setTextFormat(R_Text_Format(10));
    s.selectable = false;
    s.mouseEnabled = false;
    s.text = "";
    return s;
  }
  static private function R_Text_Format(font_size:Number) : TextFormat {
    var tf:TextFormat = new TextFormat();
    tf.align = "center";
    tf.size = font_size;
    tf.font = "_DejaVuSansMono_";
    return tf;
  }
}}