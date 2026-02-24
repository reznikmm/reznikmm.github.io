with Ada.Containers;
with Ada.Containers.Hashed_Maps;
with VSS.Strings.Hash;
with VSS.XML.Content_Handlers;

with Markdown.Block_Containers;
with Vyasa.Highlighters;

package Vyasa.Emitters is

   type Emitter is tagged limited private;

   type Highlighter_Access is access all
     Vyasa.Highlighters.Highlighter'Class with Storage_Size => 0;

   procedure Register_Highlighter
     (Self  : in out Emitter'Class;
      Name  : VSS.Strings.Virtual_String;
      Value : not null Highlighter_Access);

   procedure Emit_Blocks
     (Self     : Emitter'Class;
      Writer   : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      List     : Markdown.Block_Containers.Block_Container'Class;
      Is_Tight : Boolean);

private

   package Highlighter_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => VSS.Strings.Virtual_String,
      Element_Type    => Highlighter_Access,
      Hash            => VSS.Strings.Hash,
      Equivalent_Keys => VSS.Strings."=");

   type Emitter is tagged limited record
      Map : Highlighter_Maps.Map;
   end record;

end Vyasa.Emitters;
