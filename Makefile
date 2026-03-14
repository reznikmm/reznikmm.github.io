VYASA     := vyasa/bin/vyasa-driver
ATOM_TMPL := vyasa/generated/vyasa-templates-atom.adb

POSTS      := $(wildcard posts/*.md)
HTML_FILES := $(patsubst posts/%.md,public/%.html,$(POSTS))

all: $(HTML_FILES) public/atom.xml

public/%.html: posts/%.md $(VYASA)
	@mkdir -p public
	$(VYASA) -i $< -o $@

public/atom.xml: posts/index.md $(VYASA)
	@mkdir -p public
	$(VYASA) -i $< --atom-output $@ --base-url https://reznikmm.github.io

$(VYASA): vyasa/generated/vyasa-templates-index.adb $(ATOM_TMPL)
	alr -C vyasa build

vyasa/generated/vyasa-templates-index.adb: templates/Index.xhtml
	python vyasa/read_xml.py $< Vyasa.Templates.Index > $@

$(ATOM_TMPL): templates/Atom.xml
	python vyasa/read_xml.py $< Vyasa.Templates.Atom > $@
