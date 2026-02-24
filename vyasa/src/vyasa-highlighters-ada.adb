--  SPDX-FileCopyrightText: 2025 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

pragma Ada_2022;

with VSS.Characters;
with VSS.Strings.Character_Iterators;
with VSS.Strings.Cursors;
with VSS.Transformers.Caseless;

package body Vyasa.Highlighters.Ada is

   Identifier : constant Wide_Wide_String :=
     "[\p{Lu}\p{Ll}\p{Lt}\p{Lm}\p{Lo}\p{Nl}](?:\p{Pc}?" &
     "[\p{Lu}\p{Ll}\p{Lt}\p{Lm}\p{Lo}\p{Nl}\p{Mn}\p{Mc}\p{Nd}])*";

   Comment    : constant Wide_Wide_String := "--.*";

   String     : constant Wide_Wide_String :=
     """(?:""""|[^""\p{Cc}\p{Co}\p{Cs}\t\p{Zl}\p{Zp}])*""";

   Character  : constant Wide_Wide_String :=
     "'[^\p{Cc}\p{Co}\p{Cs}\t\p{Zl}\p{Zp}]'";

   Exp        : constant Wide_Wide_String :=
     "(?:[Ee][+-]?[0-9](?:_?[0-9])*)?";

   Decimal    : constant Wide_Wide_String :=
     "[0-9](?:_?[0-9])*(?:\.[0-9](?:_?[0-9])*)?" & Exp;

   Based      : constant Wide_Wide_String :=
     "[0-9](?:_?[0-9])*#[0-9a-fA-F](?:_?[0-9a-fA-F])*#" & Exp;

   Numeric    : constant Wide_Wide_String :=
     "(?:" & Based & ")|(?:" & Decimal & ")";

   Pattern    : constant Wide_Wide_String :=
     "(" & Identifier & ")|" &  --  1 => Identifier
     "(" & Comment & ")|" &     --  2 => Comment
     "(" & String & ")|" &      --  3 => String literal
     "(" & Character & ")|" &   --  4 => Character literal
     "(" & Numeric & ")";       --  5 => Numeric literal

   function Is_Keyword
     (Self : Ada_Highlighter'Class;
      Text : VSS.Strings.Virtual_String) return Boolean is
        (Self.Keyword.Contains
           (Text.Transform
              (VSS.Transformers.Caseless.To_Identifier_Caseless)));

   ---------------
   -- Highlight --
   ---------------

   procedure Highlight
     (Self   : Ada_Highlighter;
      Info   : VSS.Strings.Virtual_String;
      Lines  : VSS.String_Vectors.Virtual_String_Vector;
      Action : not null access procedure
        (Text     : VSS.Strings.Virtual_String;
         Style    : VSS.Strings.Virtual_String;
         New_Line : Boolean))
   is
      use type VSS.Strings.Character_Count;
      use type VSS.Characters.Virtual_Character;

      function Back
        (Cursor : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
           return VSS.Strings.Character_Iterators.Character_Iterator;

      function After_Tick
        (Cursor : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
           return Boolean is (Back (Cursor).Element = ''');

      ----------
      -- Back --
      ----------

      function Back
        (Cursor : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
           return VSS.Strings.Character_Iterators.Character_Iterator
      is
         Ignore : Boolean;
      begin
         return Result : VSS.Strings.Character_Iterators.Character_Iterator do
            Result.Set_At (Cursor);
            Ignore := Result.Backward;
         end return;
      end Back;

   begin
      for Index in 1 .. Lines.Last_Index loop
         declare
            Line : constant VSS.Strings.Virtual_String := Lines (Index);

            From : VSS.Strings.Character_Iterators.Character_Iterator :=
              Line.Before_First_Character;

            Match : VSS.Regular_Expressions.Regular_Expression_Match;
         begin
            while From.Forward loop
               Match := Self.Pattern.Match (Line, From);

               exit when not Match.Has_Match;

               if Match.First_Marker.Character_Index /=
                 From.First_Character_Index
               then
                  Action
                    (Text     => Line.Slice (From, Back (Match.First_Marker)),
                     Style    => VSS.Strings.Empty_Virtual_String,
                     New_Line => False);
               end if;

               for J in 1 .. Self.Style.Length loop
                  if Match.Has_Capture (J) then
                     Action
                       (Text     => Match.Captured,
                        Style    => Self.Style
                          (if J = 1
                             and then not After_Tick (Match.First_Marker)
                             and then Self.Is_Keyword (Match.Captured)
                           then 1 else J + 1),
                        New_Line => False);

                     exit;
                  end if;
               end loop;

               From.Set_At (Match.Last_Marker);
            end loop;

            if From.Is_Valid then
               Action
                 (Text     => Line.Tail_From (From),
                  Style    => VSS.Strings.Empty_Virtual_String,
                  New_Line => Index /= Lines.Last_Index);
            elsif Index /= Lines.Last_Index then
               Action
                 (Text     => VSS.Strings.Empty_Virtual_String,
                  Style    => VSS.Strings.Empty_Virtual_String,
                  New_Line => Index /= Lines.Last_Index);
            end if;
         end;
      end loop;
   end Highlight;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self : in out Ada_Highlighter'Class) is
   begin
      if not Self.Pattern.Is_Valid then
         Self.Pattern := VSS.Regular_Expressions.To_Regular_Expression
           (VSS.Strings.To_Virtual_String (Pattern));
         pragma Assert (Self.Pattern.Is_Valid);

         Self.Style :=
           ["keyword",
            "id",
            "comment",
            "string",
            "char",
            "number"];

         declare
            List : constant VSS.String_Vectors.Virtual_String_Vector :=
              ["abort", "abs", "abstract", "accept", "access", "aliased",
               "all", "and", "array", "at", "begin", "body", "case",
               "constant", "declare", "delay", "delta", "digits", "do",
               "else", "elsif", "end", "entry", "exception", "exit", "for",
               "function", "generic", "goto", "if", "in", "interface", "is",
               "limited", "loop", "mod", "new", "not", "null", "of", "or",
               "others", "out", "overriding", "package", "parallel", "pragma",
               "private", "procedure", "protected", "raise", "range",
               "record", "rem", "renames", "requeue", "return", "reverse",
               "select", "separate", "some", "subtype", "synchronized",
               "tagged", "task", "terminate", "then", "type", "until", "use",
               "when", "while", "with", "xor"];
         begin
            for Item of List loop
               Self.Keyword.Insert (Item);
            end loop;
         end;
      end if;
   end Initialize;

end Vyasa.Highlighters.Ada;
