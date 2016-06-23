package  {
  public class Instruction {
    
    private var name : String;
    private var params : int,
                param_left : int,
                param_right : int,
                custom_only : Boolean,
                style:int;
    
    public function Instruction(nam:String, amt:int,
                       left:int = Symbol.Invalid, right:int = Symbol.Invalid,
                       _style:int = 0, _custom_only:Boolean = false) {
      name        = nam;
      params      = amt;
      param_left  = left;
      param_right = right;
      custom_only = _custom_only;
      style = _style;
    }
    
    public function R_Name       () : String  { return name;        }
    public function R_Params     () : int     { return params;      }
    public function R_Param_Left () : int     { return param_left;  }
    public function R_Param_Right() : int     { return param_right; }
    public function R_Style      () : int     { return style;       }
    public function R_Custom_Only() : Boolean { return custom_only; }
  }

}