package {
import flash.display.DisplayObject;
import flash.ui.Keyboard;
import flash.utils.describeType;
import flash.utils.Dictionary;
public class Key_To_String  {
  
/*source:
http://stackoverflow.com/questions/19739556/
  convert-key-code-to-string-in-actionscript-3
*/
  
  public static function R_Key_To_String_Trans() : Dictionary {
    var key_desc : XML = describeType(Keyboard);
    var key_names : XMLList = key_desc..constant.@name;
    
    var keyboard_dict : Dictionary = new Dictionary();
    for ( var i : int = 0; i != key_names.length(); ++ i )
      keyboard_dict[Keyboard[key_names[i]]] = key_names[i];
    return keyboard_dict;
  }
  
  public static var key_to_str : Dictionary;
}}