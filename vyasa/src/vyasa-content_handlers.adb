with VSS.XML.Events;

package body Vyasa.Content_Handlers is

   ----------------
   -- Characters --
   ----------------

   overriding procedure Characters
     (Self    : in out SAX_Content_Handler;
      Text    : VSS.Strings.Virtual_String;
      Success : in out Boolean)
   is
      pragma Unreferenced (Success);
   begin
      Self.Value.Append
        (VSS.XML.Events.XML_Event'
           (Kind => VSS.XML.Events.Text, Text => Text));
   end Characters;

   -----------------
   -- End_Element --
   -----------------

   overriding procedure End_Element
     (Self    : in out SAX_Content_Handler;
      URI     : VSS.IRIs.IRI;
      Name    : VSS.Strings.Virtual_String;
      Success : in out Boolean)
   is
      pragma Unreferenced (Success);
   begin
      Self.Value.Append
        (VSS.XML.Events.XML_Event'
           (Kind => VSS.XML.Events.End_Element,
            URI  => URI,
            Name => Name));
   end End_Element;

   -------------------
   -- Start_Element --
   -------------------

   overriding procedure Start_Element
     (Self       : in out SAX_Content_Handler;
      URI        : VSS.IRIs.IRI;
      Name       : VSS.Strings.Virtual_String;
      Attributes : VSS.XML.Attributes.XML_Attributes'Class;
      Success    : in out Boolean)
   is
      pragma Unreferenced (Success);
   begin
      Self.Value.Append
        (VSS.XML.Events.XML_Event'
           (Kind => VSS.XML.Events.Start_Element,
            URI  => URI,
            Name => Name));

      for J in 1 .. Attributes.Get_Length loop
         Self.Value.Append
           (VSS.XML.Events.XML_Event'
              (Kind  => VSS.XML.Events.Attribute,
               URI   => Attributes.Get_URI (J),
               Name  => Attributes.Get_Name (J),
               Value => Attributes.Get_Value (J)));
      end loop;
   end Start_Element;

end Vyasa.Content_Handlers;
