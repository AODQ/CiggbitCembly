package {
  public class Guide_Data {
    public var info : String,
               posx : int,
               posy : int,
               hitx : int,
               hity : int,
               hitw : int,
               hith : int;
    public function Guide_Data(_info:String, _x : int, _y : int,
            hx:int, hy:int, hw:int, hh:int)  {
      info = _info;
      posx = _x;
      posy = _y;
      hitx = hx;
      hity = hy;
      hitw = hw;
      hith = hh;
    }
}}