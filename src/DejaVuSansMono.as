package {
  import flash.text.CSMSettings;
  import flash.text.Font;
  import flash.text.AntiAliasType;
  import flash.text.TextRenderer;
  import flash.text.TextColorType;
  import flash.text.TextFormat;
  public class DejaVuSansMono {
    public static var standard : CSMSettings;
    public static var standard_table : Array;
    public static var style : TextFormat;
    [Embed(source     = "VeraMono.ttf",
           fontFamily = "_DejaVuSansMono_",
           fontStyle  = "normal",
           fontWeight = "normal",
           mimeType   = "application/x-font-truetype",
           embedAsCFF = false)] private static const _Font:Class;
    public static const name:String = "_DejaVuSansMono_";
    public function DejaVuSansMono() {}
    static public function Init() {
      standard = new CSMSettings(10, 0.6, -0.1);
      style = new TextFormat(DejaVuSansMono.name, Source.ft_x);
      standard_table = new Array(standard);
      TextRenderer.setAdvancedAntiAliasingTable(name, "normal",
                                    TextColorType.LIGHT_COLOR, standard_table);
      Font.registerFont(_Font);
    } 
  }
}