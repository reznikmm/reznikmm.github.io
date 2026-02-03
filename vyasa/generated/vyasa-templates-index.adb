with VSS.XML.Attributes.Containers;
with VSS.XML.Content_Handlers;
with VSS.Characters.Latin;

procedure Vyasa.Templates.Index
  (CH : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;
   Ok : in out Boolean)
is
   pragma Style_Checks (Off);
   New_Line : constant VSS.Strings.Virtual_String :=
     VSS.Characters.To_Virtual_String (VSS.Characters.Latin.Line_Feed);
begin
CH.Start_Prefix_Mapping ("", +"http://www.w3.org/1999/xhtml", Ok);
CH.Start_Prefix_Mapping ("tal", +"http://xml.adacore.com/namespaces/tal", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "lang", "en");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "html", Attr, Ok);
end;
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "head", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "charset", "UTF-8");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "meta", Attr, Ok);
end;
CH.End_Element (+"http://www.w3.org/1999/xhtml", "meta", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "name", "viewport");
   Attr.Insert (+"", "content", "width=device-width, initial-scale=1.0");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "meta", Attr, Ok);
end;
CH.End_Element (+"http://www.w3.org/1999/xhtml", "meta", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "title", Attr, Ok);
end;
CH.Characters ("{{title}} | My Ada Blog", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "title", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "rel", "stylesheet");
   Attr.Insert (+"", "href", "style.css");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "link", Attr, Ok);
end;
CH.End_Element (+"http://www.w3.org/1999/xhtml", "link", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "head", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "body", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "header", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("        ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "nav", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "href", "index.html");
   Attr.Insert (+"", "class", "logo");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "a", Attr, Ok);
end;
CH.Characters ("Ada_Blog", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "a", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "class", "links");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "div", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("                ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "href", "about.html");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "a", Attr, Ok);
end;
CH.Characters ("About Me", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "a", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "div", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("        ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "nav", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "header", Ok);
CH.Characters (New_Line, Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "main", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("        ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "article", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "h1", Attr, Ok);
end;
CH.Characters ("{{title}}", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "h1", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "class", "metadata");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "div", Attr, Ok);
end;
CH.Characters ("Date: {{date}}", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "div", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "hr", Attr, Ok);
end;
CH.End_Element (+"http://www.w3.org/1999/xhtml", "hr", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("            ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   Attr.Insert (+"", "class", "content");
   Attr.Insert (+"http://xml.adacore.com/namespaces/tal", "content", "content");
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "section", Attr, Ok);
end;
CH.End_Element (+"http://www.w3.org/1999/xhtml", "section", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("        ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "article", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "main", Ok);
CH.Characters (New_Line, Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "footer", Attr, Ok);
end;
CH.Characters (New_Line, Ok);
CH.Characters ("        ", Ok);
declare
   Attr : VSS.XML.Attributes.Containers.Attributes;
begin
   CH.Start_Element (+"http://www.w3.org/1999/xhtml", "p", Attr, Ok);
end;
CH.Characters ("Max Reznik © 2026 — Formatted with Vyasa, Static site generator in Ada", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "p", Ok);
CH.Characters (New_Line, Ok);
CH.Characters ("    ", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "footer", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "body", Ok);
CH.End_Element (+"http://www.w3.org/1999/xhtml", "html", Ok);
CH.End_Prefix_Mapping ("tal", Ok);
CH.End_Prefix_Mapping ("", Ok);
end Vyasa.Templates.Index;
