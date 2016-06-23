package  {
  public class Label {
    private var name : String;
    private var line : int;
    private var page : int;
    public function Label(_name:String, _line:int, _page:int) {
      name = _name;
      line = _line;
      page = _page;
    }
    
    public function R_Name() : String { return name; }
    public function R_Line() : int    { return line; }
    public function R_Page() : int    { return page; }
  }

}