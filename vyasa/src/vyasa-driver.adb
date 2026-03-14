--  SPDX-FileCopyrightText: 2023 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
----------------------------------------------------------------

with Ada.Calendar;
with Ada.Calendar.Formatting;

with Markdown.Blocks.ATX_Headings;
with Markdown.Documents;
with Markdown.Inlines;
with Markdown.Parsers;

with VSS.Characters;
with VSS.Command_Line;
with VSS.String_Vectors;
with VSS.Strings;
with VSS.Strings.Conversions;
with VSS.Text_Streams.File_Input;

with Vyasa.Atom;
with Vyasa.Posts;

procedure Vyasa.Driver is

   Input_File : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "i",
      Long_Name   => "input",
      Description => "Input Markdown file name",
      Value_Name  => "file");

   Output_File : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "o",
      Long_Name   => "output-file",
      Description => "Output HTML file name",
      Value_Name  => "file");

   Atom_Output : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "a",
      Long_Name   => "atom-output",
      Description => "Output Atom feed file name",
      Value_Name  => "file");

   Base_URL_Option : constant VSS.Command_Line.Value_Option :=
     (Short_Name  => "b",
      Long_Name   => "base-url",
      Description => "Base URL for the Atom feed",
      Value_Name  => "url");

   function Trim
     (Text : VSS.Strings.Virtual_String)
        return VSS.Strings.Virtual_String is
          (Text.Split (' ', False).Join (" "));

   function To_String
     (List : Markdown.Inlines.Inline_Vector)
        return VSS.Strings.Virtual_String;

   function Get_Title (Document : Markdown.Documents.Document)
     return VSS.Strings.Virtual_String is
       (Trim (To_String (Document (1).To_ATX_Heading.Text)));

   type Front_Matter is record
      Date : VSS.Strings.Virtual_String;
   end record;

   procedure Read_Front_Matter
     (Lines : in  out VSS.String_Vectors.Virtual_String_Vector;
      Value : out Front_Matter);

   -----------------------
   -- Read_Front_Matter --
   -----------------------

   procedure Read_Front_Matter
     (Lines : in  out VSS.String_Vectors.Virtual_String_Vector;
      Value : out Front_Matter)
   is
      Line : VSS.Strings.Virtual_String;
   begin
      while Lines.Length > 0 loop
         Line := Lines.First_Element;
         Lines.Delete_First;
         exit when Line.Starts_With ("---");

         if Line.Starts_With ("date:") then
            Value.Date := Trim (Line.Split (':')(2));
         end if;
      end loop;
   end Read_Front_Matter;

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

   Input  : aliased VSS.Text_Streams.File_Input.File_Input_Text_Stream;
   Parser : Markdown.Parsers.Markdown_Parser;
   Front  : Front_Matter;
begin
   VSS.Command_Line.Add_Option (Input_File);
   VSS.Command_Line.Add_Option (Output_File);
   VSS.Command_Line.Add_Option (Atom_Output);
   VSS.Command_Line.Add_Option (Base_URL_Option);
   VSS.Command_Line.Add_Help_Option;

   VSS.Command_Line.Process;

   VSS.Text_Streams.File_Input.Open (Input, Input_File.Value);

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
         Lines : VSS.String_Vectors.Virtual_String_Vector :=
           Text.Split_Lines;
      begin
         Read_Front_Matter (Lines, Front);
         Parser.Set_Extensions ((Link_Attributes => True));

         for Line of Lines loop
            Parser.Parse_Line (Line);
         end loop;
      end;
   end;

   declare
      Document : constant Markdown.Documents.Document := Parser.Document;
   begin
      if VSS.Command_Line.Is_Specified (Output_File) then
         Vyasa.Posts.Generate
           (Document    => Document,
            Output_File => Output_File.Value,
            Title       => Get_Title (Document),
            Date        => Front.Date);
      end if;

      if VSS.Command_Line.Is_Specified (Atom_Output) then
         declare
            Updated : constant VSS.Strings.Virtual_String :=
              VSS.Strings.Conversions.To_Virtual_String
                (Ada.Calendar.Formatting.Image (Ada.Calendar.Clock)(1 .. 10)
                 & "T00:00:00Z");
         begin
            Vyasa.Atom.Generate
              (Document    => Document,
               Output_File => Atom_Output.Value,
               Base_URL    => Base_URL_Option.Value,
               Updated     => Updated);
         end;
      end if;
   end;
end Vyasa.Driver;
