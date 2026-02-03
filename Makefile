VYASA := vyasa/bin/vyasa-driver

POSTS := $(wildcard posts/*.md)
HTML_FILES := $(patsubst posts/%.md,public/%.html,$(POSTS))

# for each file in posts/*.md, generate public/*.html
all: $(HTML_FILES)

public/%.html: posts/%.md $(VYASA)
	@mkdir -p public
	$(VYASA) -i $< -o $@

$(VYASA):
	alr -C vyasa build
