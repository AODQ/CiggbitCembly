package {
  import flash.net.SharedObject;
  public class Saver {
    public function Saver() {}
    
    /* change log
     * 
     * 
     * 
     * 100 - saving implemented
     * 101 - key config implemented
     * 102 - key config fix
     * 103 - sub routines implemented
     * 104-5 - undocumented
     * 106 - version count, custom levels,
     *       line numbers, copy/paste |, SWP, optional termination
     * */
    
    private static const version : uint = 106;
    
    public static var played_before : Boolean;
    public static var output_global : Array; // array of strings (saved code)
    public static var levels_complete : Array; // bools
    public static var ticks : Array; // ints
    public static var style : Array; // ints
    public static function Save() : void {
      var saved_file : SharedObject = SharedObject.getLocal("ciggbitt", "/");
      saved_file.data.output_global    = output_global;
      saved_file.data.levels_complete  = levels_complete;
      saved_file.data.ticks  = ticks;
      saved_file.data.style  = style;
      saved_file.data.version          = version;
      // ------------- KEYS ----------------------------------
      saved_file.data.key_sp2x_c  = KeyConfig.speedup_2x.ctrl;
      saved_file.data.key_sp2x_k  = KeyConfig.speedup_2x.key;
      saved_file.data.key_sp2x_s  = KeyConfig.speedup_2x.shift;
      saved_file.data.key_sp32x_c = KeyConfig.speedup_32x.ctrl;
      saved_file.data.key_sp32x_k = KeyConfig.speedup_32x.key;
      saved_file.data.key_sp32x_s = KeyConfig.speedup_32x.shift;
      saved_file.data.key_start_c = KeyConfig.start.ctrl;
      saved_file.data.key_start_k = KeyConfig.start.key;
      saved_file.data.key_start_s = KeyConfig.start.shift;
      saved_file.data.key_pause_c = KeyConfig.pause.ctrl;
      saved_file.data.key_pause_k = KeyConfig.pause.key;
      saved_file.data.key_pause_s = KeyConfig.pause.shift;
      saved_file.data.key_next_c  = KeyConfig.next_prob.ctrl;
      saved_file.data.key_next_k  = KeyConfig.next_prob.key;
      saved_file.data.key_next_s  = KeyConfig.next_prob.shift;
      saved_file.data.key_prev_c  = KeyConfig.prev_prob.ctrl;
      saved_file.data.key_prev_k  = KeyConfig.prev_prob.key;
      saved_file.data.key_prev_s  = KeyConfig.prev_prob.shift;
      saved_file.data.key_help_c  = KeyConfig.help.ctrl;
      saved_file.data.key_help_k  = KeyConfig.help.key;
      saved_file.data.key_help_s  = KeyConfig.help.shift;
      // -- flush/close
      saved_file.flush();
      saved_file.close();
    }
    public static function Load() : void {
      // --- assign and clear
      output_global   = new Array();
      levels_complete = new Array();
      ticks = new Array();
      style = new Array();
      while ( output_global.length != Problem.tot_levels ) {
        ticks.push(0);
        style.push(0);
        output_global.push( new Array() );
        for ( var o : int = 0; o != Input.subrout_total; ++ o ) {
          output_global[output_global.length-1][o] = new String("");
        }
        levels_complete[levels_complete.length-1] = 0;
      }
      // --- load
      var saved_file : SharedObject = SharedObject.getLocal("ciggbitt", "/");
      if ( !saved_file.data.hasOwnProperty("version") ) {
        played_before = true;
        Saver.output_global[0][0] = "IN AX\nADD AX -1\nOUT AX";
        return;
      }
      played_before = true;
      levels_complete = saved_file.data.levels_complete;
      // ------------- KEYS ----------------------------------
      KeyConfig.speedup_2x.ctrl   =  saved_file.data.key_sp2x_c;
      KeyConfig.speedup_2x.key    =  saved_file.data.key_sp2x_k;
      KeyConfig.speedup_2x.shift  =  saved_file.data.key_sp2x_s;
      KeyConfig.speedup_32x.ctrl  =  saved_file.data.key_sp32x_c;
      KeyConfig.speedup_32x.key   =  saved_file.data.key_sp32x_k;
      KeyConfig.speedup_32x.shift =  saved_file.data.key_sp32x_s;
      KeyConfig.start.ctrl        =  saved_file.data.key_start_c;
      KeyConfig.start.key         =  saved_file.data.key_start_k;
      KeyConfig.start.shift       =  saved_file.data.key_start_s;
      KeyConfig.pause.ctrl        =  saved_file.data.key_pause_c;
      KeyConfig.pause.key         =  saved_file.data.key_pause_k;
      KeyConfig.pause.shift       =  saved_file.data.key_pause_s;
      KeyConfig.next_prob.ctrl    =  saved_file.data.key_next_c;
      KeyConfig.next_prob.key     =  saved_file.data.key_next_k;
      KeyConfig.next_prob.shift   =  saved_file.data.key_next_s;
      KeyConfig.prev_prob.ctrl    =  saved_file.data.key_prev_c;
      KeyConfig.prev_prob.key     =  saved_file.data.key_prev_k;
      KeyConfig.prev_prob.shift   =  saved_file.data.key_prev_s;
      KeyConfig.help.ctrl         =  saved_file.data.key_help_c;
      KeyConfig.help.key          =  saved_file.data.key_help_k;
      KeyConfig.help.shift        =  saved_file.data.key_help_s;
      output_global = saved_file.data.output_global;
      if ( saved_file.data.ticks != null ) {
        ticks = saved_file.data.ticks;
        style = saved_file.data.style;
      }
    }
}}
