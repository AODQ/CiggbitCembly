package  {
  public class Error_Code {
    
    public static const Missing_Instruction : int = 1,
                        Unknown_Instruction : int = 2,
                        Invalid_Parameters  : int = 3,
                        Unknown_Label       : int = 4,
                        Invalid_Label       : int = 5,
                        Invalid_Output      : int = 6,
                        Empty_Program       : int = 7,
                        Out_Of_Range        : int = 8,
                        Sr_Memory           : int = 9,
                        Out_Of_Range_Sr     : int = 10,
                        Invalid_Instruction : int = 11;
    public static var Instruction_strings : Array;
    public function Error_Code() { }
    public static function Setup() : void {
      Instruction_strings = new Array(
        "", "Missing Instruction", "Unknown Instruction",
        "Invalid Parameters", "Unknown Label",
        "Invalid Label", "Invalid Output", "Empty Program",
        "Memory index out-of-range",
        "Subroutine trying to access\nmemory",
        "Subroutine index out of range",
        "Can not use this instruction\noutside of level-editting");
    }
    
  }

}