--  SPDX-FileCopyrightText: 2025 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with Ada.Containers.Hashed_Sets; use Ada;
with VSS.Strings.Hash;
with VSS.Regular_Expressions;

package Vyasa.Highlighters.Ada is

   pragma Preelaborate;

   type Ada_Highlighter is limited new Highlighter with private;

   procedure Initialize (Self : in out Ada_Highlighter'Class);

   procedure Highlight
     (Self   : Ada_Highlighter;
      Info   : VSS.Strings.Virtual_String;
      Lines  : VSS.String_Vectors.Virtual_String_Vector;
      Action : not null access procedure
        (Text     : VSS.Strings.Virtual_String;
         Style    : VSS.Strings.Virtual_String;
         New_Line : Boolean));

private

   package String_Sets is new Containers.Hashed_Sets
     (VSS.Strings.Virtual_String,
      VSS.Strings.Hash,
      VSS.Strings."=",
      VSS.Strings."=");

   type Ada_Highlighter is limited new Highlighter with record
      Pattern : VSS.Regular_Expressions.Regular_Expression;
      Style   : VSS.String_Vectors.Virtual_String_Vector;
      Keyword : String_Sets.Set;
   end record;

end Vyasa.Highlighters.Ada;
