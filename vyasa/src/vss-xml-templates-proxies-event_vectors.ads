with VSS.XML.Event_Vectors;

package VSS.XML.Templates.Proxies.Event_Vectors is

   type Event_Vector_Proxy is
     limited new VSS.XML.Templates.Proxies.Abstract_Value_Proxy with
   record
      Value : aliased VSS.XML.Event_Vectors.Vector;
   end record;

   type Event_Vector_Proxy_Access is access all Event_Vector_Proxy;

   overriding function Value
     (Self : Event_Vector_Proxy) return VSS.XML.Templates.Values.Value
       is (VSS.XML.Templates.Values.Content, Self.Value);

end VSS.XML.Templates.Proxies.Event_Vectors;
