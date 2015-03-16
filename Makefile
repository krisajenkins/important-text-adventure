all: dist/ita.js dist/index.html dist/style.css

dist:
	@mkdir $@

dist/ita.js: src/Main.elm dist
	elm-make $< --output=$@

dist/%.css: static/%.css dist
	cp $< $@

dist/%.html: static/%.html dist
	cp $< $@
