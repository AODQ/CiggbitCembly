package {
  import flash.display.Bitmap;
  import flash.display.InteractiveObject;
  import flash.display.Stage;
  public class highlight_text {
    [Embed("../Imgs/highlight.png")] private static var Img_Cursor : Class;
    
    private static var highlights : Array;
    
    public static function init(s:Stage) {
      highlights = new Array();
      for ( var i : int = 0; i != Input.console_w*Input.console_h+20; ++ i ) {
        highlights.push(new Img_Cursor() as Bitmap);
        highlights[i].visible = false;
        s.addChild(highlights[i]);
      }
      text_selected = "";
    }
    
    public static var text_selected : String;
    
    public static function Update_Highlight(lx:int, ly:int, ux:int, uy:int, str:Array) { 
      // if i need to reverse
      return;
      var dir_y : Boolean = false,
          dir_x : Boolean = false;
      if ( uy < ly ) {
        uy ^= ly;
        ly ^= uy;
        uy ^= ly;
        dir_y = true;
      }
      /*if ( ux < lx ) {
        ux ^= lx;
        lx ^= ux;
        ux ^= lx;
        dir_x = true;
      }*/
      for ( var i : int = 0; i != highlights.length; ++ i )
        highlights[i].visible = false;
      var tot : int = 0;
      var l : int = ly*(Input.console_w)+lx,
          h : int = uy*(Input.console_w)+ux;
      for ( var i : int = l; i != h; ++ i ) {
        var c_x : int =    (i%Input.console_w),
            c_y : int = int(i/Input.console_w);
        highlights[tot].x = 320 + c_x*10;
        highlights[tot].y = 235 + c_y*Source.ft_y;
        highlights[tot].visible = true;
        ++ tot;
        if ( str != null ) {
          if ( c_y >= str.length )
            c_y = str.length-1;
          if ( str[c_y].text.length == c_x )
            text_selected += "\n";
          else if ( str[c_y].length > c_x )
            text_selected += str[c_y].text.charAt(c_x);
        }
      }
    }
    
}}