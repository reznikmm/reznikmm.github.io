with VSS.IRIs;
with VSS.Strings;

package Vyasa.Templates is
   pragma Preelaborate;

   function "+" (Text : VSS.Strings.Virtual_String) return VSS.IRIs.IRI is
     (VSS.IRIs.To_IRI (Text));

end Vyasa.Templates;
