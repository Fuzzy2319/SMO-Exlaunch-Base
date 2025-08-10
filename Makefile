.PHONY: all clean update-headers

all: configure
	cmake --build build -j$(shell nproc)

configure:
	cmake --toolchain=cmake/toolchain.cmake -S . -B build

clean:
	-rm -r build

update-headers:
	git submodule update --remote ./include/
