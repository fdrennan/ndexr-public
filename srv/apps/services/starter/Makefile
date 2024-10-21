.PHONY: sass

# Get all .scss files but ignore the ones starting with an underscore
SASS_FILES := $(filter-out src/css/_%.scss, $(wildcard src/css/*.scss))
CSS_FILES := $(SASS_FILES:.scss=.css)

sass: $(CSS_FILES)

src/css/%.css: src/css/%.scss
	@sass --style=compressed $< $@

fuser:
	@sudo fuser -k 8000/tcp

style:
	R -e "styler::style_dir()" 


clean: style sass

ndexr: style sass
	make -C ~/manager ndexr

gateway:
	make -C ~/manager gateway

push:	style
	git add --all
	git commit -m 'save'
	git push

pull:
	git pull

pip:
	$$(python -c "import sys; print(sys.executable)") ./get-pip.py && $$(python -c "import sys; print(sys.executable)") -m pip install -r requirements.txt


build:
	ssh rxedn cd ./manager/srv/ndexr/services/console && make ndexr

start:
	./app.sh start

stop:
	./app.sh stop

migrateimages:
	cp -r src/images/* ../../../gateway/services/nginx/html/images/.
