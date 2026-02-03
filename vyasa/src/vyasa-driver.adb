--  SPDX-FileCopyrightText: 2023 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
----------------------------------------------------------------

with Markdown.Blocks.ATX_Headings;
with Markdown.Documents;
with Markdown.Inlines;
with Markdown.Parsers;

with VSS.Characters;
with VSS.Command_Line;
with VSS.HTML.Writers;
with VSS.String_Vectors;
with VSS.Strings;
with VSS.Text_Streams.File_Input;
with VSS.Text_Streams.File_Output;
with VSS.XML.Dummy_Locators;
with VSS.XML.Templates.Processors;
with VSS.XML.Templates.Proxies.Event_Vectors;
with VSS.XML.Templates.Proxies.Strings;

with Vyasa.Content_Handlers;
with Vyasa.Emitters;
with Vyasa.Templates.Index;

procedure Vyasa.Driver is
   Template : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "i",
      Long_Name   => "input",
      Description => "Input Markdown file name",
      Value_Name  => "file");

   Output_File : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "o",
      Long_Name   => "output-file",
      Description => "Output HTML file name",
      Value_Name  => "file");

   function To_String
     (List : Markdown.Inlines.Inline_Vector)
        return VSS.Strings.Virtual_String;

   function Get_Title (Document : Markdown.Documents.Document)
     return VSS.Strings.Virtual_String is
       (To_String (Document (1).To_ATX_Heading.Text));

   ---------------
   -- To_String --
   ---------------

   function To_String
     (List : Markdown.Inlines.Inline_Vector)
        return VSS.Strings.Virtual_String
   is
      Result : VSS.Strings.Virtual_String;
   begin
      for Item of List loop
         case Item.Kind is
            when Markdown.Inlines.Text =>
               Result.Append (Item.Text);
            when Markdown.Inlines.Code_Span =>
               Result.Append (Item.Code_Span);
            when Markdown.Inlines.Soft_Line_Break
               | Markdown.Inlines.Hard_Line_Break =>
               Result.Append (' ');
            when others =>
               null;
         end case;
      end loop;
      return Result;
   end To_String;

   Locator : aliased VSS.XML.Dummy_Locators.SAX_Locator;

   Filter : aliased VSS.XML.Templates.Processors.XML_Template_Processor;
   Writer : aliased VSS.HTML.Writers.HTML5_Writer;
   Input  : aliased VSS.Text_Streams.File_Input.File_Input_Text_Stream;
   Output : aliased VSS.Text_Streams.File_Output.File_Output_Text_Stream;

   Parser : Markdown.Parsers.Markdown_Parser;
begin
   VSS.Command_Line.Add_Option (Output_File);
   VSS.Command_Line.Add_Option (Template);
   VSS.Command_Line.Add_Help_Option;

   VSS.Command_Line.Process;

   VSS.Text_Streams.File_Input.Open (Input, Template.Value);

   declare
      Text : VSS.Strings.Virtual_String;
   begin
      while not Input.Is_End_Of_Stream loop
         declare
            Item : VSS.Characters.Virtual_Character'Base;
            Ok   : Boolean := True;
         begin
            Input.Get (Item, Ok);
            exit when not Ok;
            Text.Append (Item);
         end;
      end loop;

      declare
         Lines : constant VSS.String_Vectors.Virtual_String_Vector :=
           Text.Split_Lines;
      begin
         for Line of Lines loop
            Parser.Parse_Line (Line);
         end loop;
      end;
   end;

   Output.Create (Output_File.Value);
   Writer.Set_Output_Stream (Output'Unchecked_Access);
   Filter.Set_Content_Handler (Writer'Unchecked_Access);
   Filter.Set_Document_Locator (Locator'Unchecked_Access);

   declare
      Ok : Boolean := True;
      Document : constant Markdown.Documents.Document := Parser.Document;

      Content : constant VSS.XML.Templates.Proxies.Event_Vectors
        .Event_Vector_Proxy_Access :=
          new VSS.XML.Templates.Proxies.Event_Vectors.Event_Vector_Proxy;

      Sink : Vyasa.Content_Handlers.SAX_Content_Handler :=
          (Value => Content.Value'Unchecked_Access);

      Title_Proxy : constant VSS.XML.Templates.Proxies.Proxy_Access :=
        new VSS.XML.Templates.Proxies.Strings.Virtual_String_Proxy'
          (Text => Get_Title (Document));

   begin
      Vyasa.Emitters.Emit_Blocks (Sink, Document, False);

      Filter.Bind
        ("content", VSS.XML.Templates.Proxies.Proxy_Access (Content));

      Filter.Bind ("title", Title_Proxy);

      Vyasa.Templates.Index (Filter, Ok);
   end;
end Vyasa.Driver;
