all:
	mkdir -p build
	cp src/build.sh build
	cp src/config.sh build
	g++ -Wall -Wextra src/gsettings.cpp -o build/gsettings
	rustc src/keyboard.rs -o build/keyboard

clean:
	rm -rf build
