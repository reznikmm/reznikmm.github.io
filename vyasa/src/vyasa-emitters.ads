with VSS.XML.Content_Handlers;

with Markdown.Block_Containers;

package Vyasa.Emitters is

   procedure Emit_Blocks
     (Writer   : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      List     : Markdown.Block_Containers.Block_Container'Class;
      Is_Tight : Boolean);

end Vyasa.Emitters;
