all:
	mkdir -p build
	cp src/build.sh build
	cp src/config.sh build
	g++ -Wall -Wextra src/gsettings.cpp -o build/gsettings

clean:
	rm -rf build
