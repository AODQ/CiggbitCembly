package {
public class Exec_Ret {
  
  public static const T_good = 0,
                      T_jump = 1,
                      T_jump_offset = 2,
                      T_empty_line = 3,
                      T_subroutine = 4,
                      T_out        = 5;
  
  public var type  : int,
             value : int,
             subroutine : int;
  
  public function Exec_Ret(_type:int, _value:int, _subroutine : int = 0) {
    type  = _type;
    value = _value;
    subroutine = _subroutine;
  }
}}