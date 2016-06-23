package  {
  public class Stack {
    private var max_size : int;
    private var arr : Array;
    public function Stack(_max_size:int) {
      arr = new Array();
      max_size = _max_size;
    }
    
    public function Push(el:int) : void {
      if ( arr.length >= max_size )
        arr[arr.length - 1] = el;
      else
        arr.push(el);
    }
    
    public function Pop() : int {
      if ( arr.length > 0 )
        return arr.pop();
      return 0;
    }
    public function Is_Empty() : Boolean {
      return arr.length == 0;
    }
    public function R_Arr() : Array { return arr; }
  }
}