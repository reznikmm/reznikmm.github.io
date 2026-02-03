with VSS.IRIs;
with VSS.Strings;
with VSS.XML.Attributes;
with VSS.XML.Content_Handlers;
with VSS.XML.Event_Vectors;

package Vyasa.Content_Handlers is

   type SAX_Content_Handler is
     new VSS.XML.Content_Handlers.SAX_Content_Handler
   with record
      Value : access VSS.XML.Event_Vectors.Vector;
   end record;

   overriding procedure Start_Element
     (Self       : in out SAX_Content_Handler;
      URI        : VSS.IRIs.IRI;
      Name       : VSS.Strings.Virtual_String;
      Attributes : VSS.XML.Attributes.XML_Attributes'Class;
      Success    : in out Boolean);

   overriding procedure End_Element
     (Self    : in out SAX_Content_Handler;
      URI     : VSS.IRIs.IRI;
      Name    : VSS.Strings.Virtual_String;
      Success : in out Boolean);

   overriding procedure Characters
     (Self    : in out SAX_Content_Handler;
      Text    : VSS.Strings.Virtual_String;
      Success : in out Boolean);

end Vyasa.Content_Handlers;
