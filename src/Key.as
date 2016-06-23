package {
import flash.ui.Keyboard;
public class Key {
  
  public var key : *;
  public var shift : Boolean;
  public var ctrl  : Boolean;
  
  public function Key(_key : *, _shift : Boolean,
                                    _ctrl : Boolean) {
    key   = _key;
    shift = _shift;
    ctrl  = _ctrl;
  }
}}