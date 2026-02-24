--  SPDX-FileCopyrightText: 2025 Max Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
----------------------------------------------------------------

with VSS.String_Vectors;
with VSS.Strings;

package Vyasa.Highlighters is
   pragma Preelaborate;

   type Highlighter is limited interface;

   procedure Highlight
     (Self   : Highlighter;
      Info   : VSS.Strings.Virtual_String;
      Lines  : VSS.String_Vectors.Virtual_String_Vector;
      Action : not null access procedure
        (Text     : VSS.Strings.Virtual_String;
         Style    : VSS.Strings.Virtual_String;
         New_Line : Boolean)) is abstract;

   type Highlighter_Access is access constant Highlighter'Class;

end Vyasa.Highlighters;
