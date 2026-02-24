with VSS.Characters;
with VSS.IRIs;
with VSS.String_Vectors;
with VSS.Strings.Formatters.Integers;
with VSS.Strings.Templates;
with VSS.XML.Attributes.Containers;

with Markdown.Attribute_Lists;
with Markdown.Inlines;
with Markdown.Blocks;
with Markdown.Blocks.ATX_Headings;
with Markdown.Blocks.Fenced_Code;
with Markdown.Blocks.HTML;
with Markdown.Blocks.Indented_Code;
with Markdown.Blocks.Lists;
with Markdown.Blocks.Paragraphs;
with Markdown.Blocks.Quotes;
with Markdown.Blocks.Tables;

package body Vyasa.Emitters is

   use type VSS.Strings.Virtual_String;

   URI : constant VSS.IRIs.IRI :=
     VSS.IRIs.To_IRI ("http://www.w3.org/1999/xhtml");

   XML : constant VSS.IRIs.IRI :=
     VSS.IRIs.To_IRI ("http://www.w3.org/XML/1998/namespace");

   New_Line : constant VSS.Strings.Virtual_String :=
     1 * VSS.Characters.Virtual_Character'Val (10);

   Nil : VSS.XML.Attributes.Containers.Attributes;

   Header_Template : VSS.Strings.Templates.Virtual_String_Template :=
     "h{}";

   Tag : constant array
     (Markdown.Inlines.Start_Emphasis .. Markdown.Inlines.End_Strong)
       of VSS.Strings.Virtual_String := ["em", "em", "strong", "strong"];

   package Dummy_Highlighters is
      type Highlighter is new Vyasa.Highlighters.Highlighter with null record;

      overriding procedure Highlight
        (Self   : Highlighter;
         Info   : VSS.Strings.Virtual_String;
         Lines  : VSS.String_Vectors.Virtual_String_Vector;
         Action : not null access procedure
           (Text     : VSS.Strings.Virtual_String;
            Style    : VSS.Strings.Virtual_String;
            New_Line : Boolean));

      Dummy : aliased Highlighter;
   end Dummy_Highlighters;

   procedure Emit_Annotated_Text
     (Writer : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      Text   : Markdown.Inlines.Inline_Vector);

   procedure Emit_Block
     (Self     : Emitter'Class;
      Writer   : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      Block    : Markdown.Blocks.Block;
      Is_Tight : Boolean);

   procedure Emit_List
     (Self   : Emitter'Class;
      Writer : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      List   : Markdown.Blocks.Lists.List);

   package body Dummy_Highlighters is

      ---------------
      -- Highlight --
      ---------------

      overriding procedure Highlight
        (Self   : Highlighter;
         Info   : VSS.Strings.Virtual_String;
         Lines  : VSS.String_Vectors.Virtual_String_Vector;
         Action : not null access procedure
           (Text     : VSS.Strings.Virtual_String;
            Style    : VSS.Strings.Virtual_String;
            New_Line : Boolean)) is
      begin
         for Index in 1 .. Lines.Last_Index loop
            Action
              (Lines (Index),
               VSS.Strings.Empty_Virtual_String,
               Index /= Lines.Last_Index);
         end loop;
      end Highlight;

   end Dummy_Highlighters;

   procedure Emit_Annotated_Text
     (Writer : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      Text   : Markdown.Inlines.Inline_Vector)
   is
      type Print_State (In_Image : Boolean := False) is record
         case In_Image is
            when True =>
               Destination : VSS.Strings.Virtual_String;
               Title       : VSS.String_Vectors.Virtual_String_Vector;
               Description : VSS.Strings.Virtual_String;
               Attributes  : Markdown.Attribute_Lists.Attribute_List;
            when False =>
               null;
         end case;
      end record;

      procedure Print
        (State : in out Print_State;
         Item  : Markdown.Inlines.Inline);

      -----------
      -- Print --
      -----------

      procedure Print
        (State : in out Print_State;
         Item  : Markdown.Inlines.Inline)
      is
         function To_Style
           (Attributes : Markdown.Attribute_Lists.Attribute_List)
             return VSS.String_Vectors.Virtual_String_Vector;

         --------------
         -- To_Style --
         --------------

         function To_Style
           (Attributes : Markdown.Attribute_Lists.Attribute_List)
             return VSS.String_Vectors.Virtual_String_Vector is
         begin
            return Result : VSS.String_Vectors.Virtual_String_Vector do
               for Item of Attributes loop
                  Result.Append (Item.Name & ": " & Item.Value);
               end loop;
            end return;
         end To_Style;

         Ok : Boolean := True;
      begin
         if State.In_Image then
            case Item.Kind is
               when Markdown.Inlines.Text | Markdown.Inlines.Code_Span =>
                  State.Description.Append (Item.Text);

               when Markdown.Inlines.End_Image =>
                  declare
                     use VSS.IRIs;
                     Attr : VSS.XML.Attributes.Containers.Attributes;
                  begin
                     Attr.Insert (Empty_IRI, "alt", State.Description);
                     Attr.Insert (Empty_IRI, "src", State.Destination);

                     if not State.Title.Is_Empty then
                        Attr.Insert
                          (Empty_IRI, "title",
                           State.Title.Join_Lines (VSS.Strings.LF, False));
                     end if;

                     if State.Attributes.Length > 0 then
                        declare
                           Value : constant
                             VSS.String_Vectors.Virtual_String_Vector :=
                               To_Style (State.Attributes);
                        begin
                           Attr.Insert
                            (VSS.IRIs.Empty_IRI, "style", Value.Join (';'));
                        end;
                     end if;

                     Writer.Start_Element (URI, "img", Attr, Ok);
                     Writer.End_Element (URI, "img", Ok);

                     State := (In_Image => False);
                  end;

               when others =>
                  null;
            end case;

            return;
         end if;

         case Item.Kind is
            when Markdown.Inlines.Text =>
               Writer.Characters (Item.Text, Ok);

            when Markdown.Inlines.Start_Emphasis
               | Markdown.Inlines.Start_Strong
               =>

               Writer.Start_Element (URI, Tag (Item.Kind), Nil, Ok);

            when Markdown.Inlines.End_Emphasis
               | Markdown.Inlines.End_Strong
               =>
               Writer.End_Element (URI, Tag (Item.Kind), Ok);

            when Markdown.Inlines.Code_Span =>
               Writer.Start_Element (URI, "code", Nil, Ok);
               Writer.Characters (Item.Code_Span, Ok);
               Writer.End_Element (URI, "code", Ok);

            when Markdown.Inlines.Start_Link =>
               declare
                  Attr : VSS.XML.Attributes.Containers.Attributes;
               begin
                  Attr.Insert (VSS.IRIs.Empty_IRI, "href", Item.Destination);

                  if not Item.Title.Is_Empty then
                     Attr.Insert
                       (VSS.IRIs.Empty_IRI,
                        "title",
                        Item.Title.Join_Lines (VSS.Strings.LF, False));
                  end if;

                  Writer.Start_Element (URI, "a", Attr, Ok);
               end;

            when Markdown.Inlines.End_Link =>
               Writer.End_Element (URI, "a", Ok);
            when Markdown.Inlines.Start_Image =>
               State :=
                 (In_Image    => True,
                  Destination => Item.Destination,
                  Title       => Item.Title,
                  Attributes  => Item.Attributes,
                  Description => <>);

            when Markdown.Inlines.End_Image =>
               null;

            when Markdown.Inlines.Hard_Line_Break =>
               Writer.Start_Element (URI, "br", Nil, Ok);
               Writer.End_Element (URI, "br", Ok);

            when Markdown.Inlines.Soft_Line_Break =>
               Writer.Characters (New_Line, Ok);

            when others =>
               null;
         end case;

      end Print;

      State : Print_State;
   begin
      for Item of Text loop
         Print (State, Item);
      end loop;
   end Emit_Annotated_Text;

   ----------------
   -- Emit_Block --
   ----------------

   procedure Emit_Block
     (Self     : Emitter'Class;
      Writer   : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      Block    : Markdown.Blocks.Block;
      Is_Tight : Boolean)
   is
      procedure Action
        (Text     : VSS.Strings.Virtual_String;
         Style    : VSS.Strings.Virtual_String;
         New_Line : Boolean);

      Ok : Boolean := True;

      procedure Action
        (Text     : VSS.Strings.Virtual_String;
         Style    : VSS.Strings.Virtual_String;
         New_Line : Boolean)
      is
      begin
         if Text.Is_Empty then
            null;
         elsif Style.Is_Empty then
            Writer.Characters (Text, Ok);
         else
            declare
               Attr  : VSS.XML.Attributes.Containers.Attributes;
               Class : constant VSS.Strings.Virtual_String :=
                 "token " & Style;
            begin
               Attr.Insert (URI, "class", Class);
               Writer.Start_Element (URI, "span", Attr, Ok);
               Writer.Characters (Text, Ok);
               Writer.End_Element (URI, "span", Ok);
            end;
         end if;

         if New_Line then
            Writer.Characters (Vyasa.Emitters.New_Line, Ok);
         end if;
      end Action;
   begin

      if Block.Is_Paragraph then
         if Is_Tight then
            Emit_Annotated_Text (Writer, Block.To_Paragraph.Text);
         else
            Writer.Start_Element (URI, "p", Nil, Ok);
            Emit_Annotated_Text (Writer, Block.To_Paragraph.Text);
            Writer.End_Element (URI, "p", Ok);
         end if;

      elsif Block.Is_Thematic_Break then
         Writer.Start_Element (URI, "hr", Nil, Ok);
         Writer.End_Element (URI, "hr", Ok);

      elsif Block.Is_ATX_Heading then
         declare
            Image : constant VSS.Strings.Virtual_String :=
              Header_Template.Format
                (VSS.Strings.Formatters.Integers.Image
                  (Block.To_ATX_Heading.Level));
         begin
            Writer.Start_Element (URI, Image, Nil, Ok);
            Emit_Annotated_Text (Writer, Block.To_ATX_Heading.Text);
            Writer.End_Element (URI, Image, Ok);
         end;

      elsif Block.Is_Quote then
         Writer.Start_Element (URI, "blockquote", Nil, Ok);
         Emit_Blocks (Self, Writer, Block.To_Quote, Is_Tight => False);
         Writer.End_Element (URI, "blockquote", Ok);

      elsif Block.Is_Fenced_Code_Block then
         declare
            Info : constant VSS.Strings.Virtual_String :=
              Block.To_Fenced_Code_Block.Info_String;

            List : constant VSS.String_Vectors.Virtual_String_Vector :=
              Info.Split (' ');

            Attr : VSS.XML.Attributes.Containers.Attributes;
            HL   : constant not null Highlighter_Access :=
              (if List.Length > 0 and then Self.Map.Contains (List (1))
               then Self.Map (List (1))
               else Dummy_Highlighters.Dummy'Access);
         begin
            Attr.Insert (XML, "space", "preserve");

            if not Info.Is_Empty then
               Attr.Insert (VSS.IRIs.Empty_IRI, "class", List (1));
            end if;

            Writer.Start_Element (URI, "pre", Nil, Ok);
            Writer.Start_Element (URI, "code", Attr, Ok);

            HL.Highlight
              (Info, Block.To_Fenced_Code_Block.Text, Action'Access);

            Writer.End_Element (URI, "code", Ok);
            Writer.End_Element (URI, "pre", Ok);
         end;

      elsif Block.Is_Indented_Code_Block then
         Writer.Start_Element (URI, "pre", Nil, Ok);
         Writer.Start_Element (URI, "code", Nil, Ok);

         for Line of Block.To_Indented_Code_Block.Text loop
            Writer.Characters (Line, Ok);
            Writer.Characters (New_Line, Ok);
         end loop;

         Writer.End_Element (URI, "code", Ok);
         Writer.End_Element (URI, "pre", Ok);

      elsif Block.Is_List then
         Emit_List (Self, Writer, Block.To_List);

      --  elsif Block.Is_HTML_Block then
         --  Writer.Raw_HTML (Block.To_HTML_Block.Text);

      --  elsif Block.Is_Table then
         --  Print_Table (Writer, Block.To_Table);

      else
         raise Program_Error;
      end if;
   end Emit_Block;

   -----------------
   -- Emit_Blocks --
   -----------------

   procedure Emit_Blocks
     (Self     : Emitter'Class;
      Writer   : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      List     : Markdown.Block_Containers.Block_Container'Class;
      Is_Tight : Boolean) is
   begin
      for Block of List loop
         Emit_Block (Self, Writer, Block, Is_Tight);
      end loop;
   end Emit_Blocks;

   procedure Emit_List
     (Self   : Emitter'Class;
      Writer : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
      List   : Markdown.Blocks.Lists.List)
   is
      Tag : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String
          (if List.Is_Ordered then "ol" else "ul");

      Attr : VSS.XML.Attributes.Containers.Attributes;
      Ok : Boolean := True;
   begin
      if List.Is_Ordered then
         declare
            Image : constant Wide_Wide_String := List.Start'Wide_Wide_Image;
         begin
            if Image /= " 1" then
               Attr.Insert
                 (VSS.IRIs.Empty_IRI,
                  "start",
                   VSS.Strings.To_Virtual_String (Image (2 .. Image'Last)));
            end if;
         end;
      end if;

      Writer.Start_Element (URI, Tag, Attr, Ok);

      for Item of List loop
         Writer.Start_Element (URI, "li", Nil, Ok);
         Emit_Blocks (Self, Writer, Item, Is_Tight => not List.Is_Loose);
         Writer.End_Element (URI, "li", Ok);
      end loop;

      Writer.End_Element (URI, Tag, Ok);
   end Emit_List;

   --------------------------
   -- Register_Highlighter --
   --------------------------

   procedure Register_Highlighter
     (Self  : in out Emitter'Class;
      Name  : VSS.Strings.Virtual_String;
      Value : not null Highlighter_Access) is
   begin
      Self.Map.Insert (Name, Value);
   end Register_Highlighter;

end Vyasa.Emitters;
