FUNC := g++
copt := -c 
OBJ_DIR := ./bin/
INTEL_INTRINSIC_FLAGS := -mavx512f -mavx512dq -mavx512bw -mavx512vl -mavx512vnni
FLAGS := -O3 -lm -g -Werror $(INTEL_INTRINSIC_FLAGS)

CPP_FILES := $(wildcard src/*.cpp)
OBJ_FILES := $(addprefix $(OBJ_DIR),$(notdir $(CPP_FILES:.cpp=.obj)))

TEXTURE_CPP_FILES := $(wildcard src/Textures/*.cpp)
TEXTURE_OBJ_FILES := $(addprefix $(OBJ_DIR)Textures/,$(notdir $(TEXTURE_CPP_FILES:.cpp=.obj)))

export MEMUSAGE_PROG_NAME=main.exe
MEMUSAGE_LOADER := LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libmemusage.so

# Testcase Run Commands
PIANOROOM_RUN 	:= ./main.exe -i inputs/pianoroom.ray --ppm -o output/pianoroom.ppm -H 500 -W 500
GLOBE_RUN 		:= ./main.exe -i inputs/globe.ray --ppm  -a inputs/globe.animate --movie -F 24
SPHERE_RUN		:= ./main.exe -i inputs/sphere.ray --ppm  -a inputs/elephant.animate --movie -F 24 -W 100 -H 100 -o output/sphere.mp4
ELEPHANT_RUN	:= ./main.exe -i inputs/elephant.ray --ppm  -a inputs/elephant.animate --movie -F 24 -W 100 -H 100 -o output/elephant.mp4 

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
	rm -f ./output/*.mp4

pianoroom: all
	mkdir -p output
	${PIANOROOM_RUN}

perf-pianoroom: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ${PIANOROOM_RUN}
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > pianoroom_flamegraph.svg

mem-pianoroom: all
	mkdir -p output
	${MEMUSAGE_LOADER} ${PIANOROOM_RUN}

test-pianoroom: all
	mkdir -p output
	${PIANOROOM_RUN}
	ffmpeg -hide_banner -i golden/pianoroom.ppm -i output/pianoroom.ppm -lavfi "[1:v][0:v]scale2ref[bs][a];[a][bs]psnr" -f null -

globe: all
	mkdir -p output
	${GLOBE_RUN}

test-globe: all
	mkdir -p output
	${GLOBE_RUN}
	ffmpeg -hide_banner -i golden/output.mp4 -i output/output.mp4 -lavfi "[1:v][0:v]scale2ref[bs][a];[a][bs]psnr" -f null -

perf-globe: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ${GLOBE_RUN}
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > globe_flamegraph.svg

mem-globe: all
	mkdir -p output
	${MEMUSAGE_LOADER} ${GLOBE_RUN}

sphere: all
	mkdir -p output
	${SPHERE_RUN}

perf-sphere: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ${SPHERE_RUN}
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > sphere_flamegraph.svg

test-sphere: all
	mkdir -p output
	${SPHERE_RUN}
	ffmpeg -hide_banner -i golden/sphere.mp4 -i output/sphere.mp4 -lavfi "[1:v][0:v]scale2ref[bs][a];[a][bs]psnr" -f null -

mem-sphere: all
	mkdir -p output
	${MEMUSAGE_LOADER} ${SPHERE_RUN}

elephant: all
	mkdir -p output
	${ELEPHANT_RUN}

perf-elephant: all
	mkdir -p output
	perf record -F 400 -g --call-graph fp -- ${ELEPHANT_RUN}
	perf script | stackcollapse-perf.pl > perf.folded
	flamegraph.pl perf.folded > elephant_flamegraph.svg

test-elephant: all
	mkdir -p output
	${ELEPHANT_RUN}
	ffmpeg -hide_banner -i golden/elephant.mp4 -i output/elephant.mp4 -lavfi "[1:v][0:v]scale2ref[bs][a];[a][bs]psnr" -f null -

mem-elephant: all
	mkdir -p output
	${MEMUSAGE_LOADER} ${ELEPHANT_RUN}
	