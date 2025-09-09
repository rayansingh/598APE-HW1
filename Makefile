FUNC := g++
copt := -c 
OBJ_DIR := ./bin/
FLAGS := -O3 -lm -g -Werror

CPP_FILES := $(wildcard src/*.cpp)
OBJ_FILES := $(addprefix $(OBJ_DIR),$(notdir $(CPP_FILES:.cpp=.obj)))

TEXTURE_CPP_FILES := $(wildcard src/Textures/*.cpp)
TEXTURE_OBJ_FILES := $(addprefix $(OBJ_DIR)Textures/,$(notdir $(TEXTURE_CPP_FILES:.cpp=.obj)))

all:
	cd ./src && make
	$(FUNC) ./main.cpp -o ./main.exe ./src/*.obj ./src/Textures/*.obj $(FLAGS)

clean:
	cd ./src && make clean
	rm -f ./*.exe
	rm -f ./*.obj
	rm -f ./*.svg
	rm -f ./*.html
	rm -f ./*.data
	rm -f ./*.data.old
	rm -f ./*.folded
	rm -f ./output/*.ppm
	rm -f ./output/*.avi

pianoroom: all
	mkdir -p output
	./main.exe -i inputs/pianoroom.ray --ppm -o output/pianoroom.ppm -H 500 -W 500

perf-pianoroom: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ./main.exe -i inputs/pianoroom.ray --ppm -o output/pianoroom.ppm -H 500 -W 500
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > pianoroom_flamegraph.svg

test-pianoroom: all
	mkdir -p output
	./main.exe -i inputs/pianoroom.ray --ppm -o output/pianoroom.ppm -H 500 -W 500
	diff golden/pianoroom.ppm output/pianoroom.ppm

globe: all
	mkdir -p output
	./main.exe -i inputs/globe.ray --ppm  -a inputs/globe.animate --movie -F 24 

test-globe: all
	mkdir -p output
	./main.exe -i inputs/globe.ray --ppm  -a inputs/globe.animate --movie -F 24 
	diff golden/globe.animate output/globe.animate

perf-globe: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ./main.exe -i inputs/globe.ray --ppm  -a inputs/globe.animate --movie -F 24 
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > globe_flamegraph.svg

elephant: all
	mkdir -p output
	./main.exe -i inputs/elephant.ray --ppm  -a inputs/elephant.animate --movie -F 24 -W 100 -H 100 -o output/sphere.mp4 

perf-elephant: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ./main.exe -i inputs/elephant.ray --ppm  -a inputs/elephant.animate --movie -F 24 -W 100 -H 100 -o output/sphere.mp4 
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > elephant_flamegraph.svg

test-elephant: all
	mkdir -p output
	./main.exe -i inputs/elephant.ray --ppm  -a inputs/elephant.animate --movie -F 24 -W 100 -H 100 -o output/sphere.mp4 
	diff golden/sphere.mp4 output/sphere.mp4