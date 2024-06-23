.PHONY: all clean

all:
	cmake --toolchain=cmake/toolchain.cmake -S . -B build && $(MAKE) -C build subsdk9_meta

clean:
	rm -r build || true

update-headers:
	git submodule update --remote ./include/
