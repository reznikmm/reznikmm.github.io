with VSS.Strings;

with VSS.XML.Locators;

package VSS.XML.Dummy_Locators is

   type SAX_Locator is new VSS.XML.Locators.SAX_Locator with null record;

   overriding function Get_Column_Number
     (Self : SAX_Locator) return VSS.Strings.Character_Index'Base is (1);

   overriding function Get_Line_Number
     (Self : SAX_Locator) return VSS.Strings.Line_Index'Base is (1);

   overriding function Get_Public_Id
     (Self : SAX_Locator) return VSS.Strings.Virtual_String is
      (VSS.Strings.Empty_Virtual_String);

   overriding function Get_System_Id
     (Self : SAX_Locator) return VSS.Strings.Virtual_String is
      (VSS.Strings.Empty_Virtual_String);

end VSS.XML.Dummy_Locators;
