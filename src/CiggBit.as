package {
  import flash.display.Bitmap;
public class CiggBit {
  [Embed("../Imgs/cigg/01.png")] private var Img_Cigg01 : Class;
  [Embed("../Imgs/cigg/02.png")] private var Img_Cigg02 : Class;
  [Embed("../Imgs/cigg/03.png")] private var Img_Cigg03 : Class;
  [Embed("../Imgs/cigg/04.png")] private var Img_Cigg04 : Class;
  [Embed("../Imgs/cigg/05.png")] private var Img_Cigg05 : Class;
  [Embed("../Imgs/cigg/06.png")] private var Img_Cigg06 : Class;
  [Embed("../Imgs/cigg/07.png")] private var Img_Cigg07 : Class;
  [Embed("../Imgs/cigg/08.png")] private var Img_Cigg08 : Class;
  [Embed("../Imgs/cigg/09.png")] private var Img_Cigg09 : Class;
  [Embed("../Imgs/cigg/10.png")] private var Img_Cigg10 : Class;
  [Embed("../Imgs/cigg/11.png")] private var Img_Cigg11 : Class;
  [Embed("../Imgs/cigg/12.png")] private var Img_Cigg12 : Class;
  [Embed("../Imgs/cigg/13.png")] private var Img_Cigg13 : Class;
  [Embed("../Imgs/cigg/14.png")] private var Img_Cigg14 : Class;
  [Embed("../Imgs/cigg/15.png")] private var Img_Cigg15 : Class;
  
  public var Ciggs : Array;
  public function CiggBit() {
    Ciggs = new Array(
      Bitmap(new Img_Cigg01), Bitmap( new Img_Cigg02),
      Bitmap(new Img_Cigg03), Bitmap( new Img_Cigg04),
      Bitmap(new Img_Cigg05), Bitmap( new Img_Cigg06),
      Bitmap(new Img_Cigg07), Bitmap( new Img_Cigg08),
      Bitmap(new Img_Cigg09), Bitmap( new Img_Cigg10),
      Bitmap(new Img_Cigg11), Bitmap( new Img_Cigg12),
      Bitmap(new Img_Cigg13), Bitmap( new Img_Cigg14),
      Bitmap(new Img_Cigg15));
  }
}}