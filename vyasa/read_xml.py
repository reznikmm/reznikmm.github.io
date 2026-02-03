import xml.etree.ElementTree as ET
import re
import sys

re_tag = re.compile(r"^\{([^}]*)\}(.*)$")

def chars(list):
    first = True
    for text in list:
        if not first:
            print('CH.Characters (New_Line, Ok);')
        if text:
            #  Replace double quotes with two double quotes 
            print(f'CH.Characters ("{text.replace('"', '""')}", Ok);')
        first = False

with open(sys.argv[1], 'rb') as f:
    proc_name = sys.argv[2]
    read_data = f.read()
    events = ["start", "end", "comment", "pi", "start-ns", "end-ns"]
    parser = ET.XMLPullParser(events)
    parser.feed(read_data)
    stack = []
    print("with VSS.XML.Attributes.Containers;")
    print("with VSS.XML.Content_Handlers;")
    print("with VSS.Characters.Latin;")
    print("")
    print(f'procedure {proc_name}')
    print("  (CH : in out VSS.XML.Content_Handlers.SAX_Content_Handler'Class;")
    print("   Ok : in out Boolean)")
    print("is")
    print("   pragma Style_Checks (Off);")
    print("   New_Line : constant VSS.Strings.Virtual_String :=")
    print("     VSS.Characters.To_Virtual_String (VSS.Characters.Latin.Line_Feed);")
    print("begin")
    for item in parser.read_events():
        (kind, arg) = item
        if kind == 'start-ns':
            (prefix, uri) = arg
            stack.append(prefix)
            print(f'CH.Start_Prefix_Mapping ("{prefix}", +"{uri}", Ok);')
        elif kind == 'start':
            match = re_tag.match(arg.tag)
            uri = match.group(1) if match else ""
            tag = match.group(2) if match else arg.tag

            print("declare")
            print("   Attr : VSS.XML.Attributes.Containers.Attributes;")
            print("begin")
            for attr in arg.attrib:
                match = re_tag.match(attr)
                if match:
                    a_uri = match.group(1)
                    a_tag = match.group(2)
                    print(f'   Attr.Insert (+"{a_uri}", "{a_tag}", "{arg.attrib[attr]}");')
                else:
                    print(f'   Attr.Insert (+"", "{attr}", "{arg.attrib[attr]}");')
            print(f'   CH.Start_Element (+"{uri}", "{tag}", Attr, Ok);')
            print("end;")
            if arg.text:
                chars(arg.text.splitlines())
        elif kind == 'end':
            match = re_tag.match(arg.tag)
            uri = match.group(1) if match else ""
            tag = match.group(2) if match else arg.tag
            print(f'CH.End_Element (+"{uri}", "{tag}", Ok);')
            if arg.tail:
                chars(arg.tail.splitlines())
        elif kind == 'end-ns':
            prefix = stack.pop()
            print(f'CH.End_Prefix_Mapping ("{prefix}", Ok);')
        else:
            print("ERROR")

    print(f'end {proc_name};')
