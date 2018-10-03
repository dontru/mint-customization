#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

const char* FILENAME =
    "/usr/share/glib-2.0/schemas/mint-artwork.gschema.override";

int main(int argc, char** argv) {
  if (argc != 5) {
    std::cout << "usage: ./gsettings set SCHEMA KEY VALUE" << std::endl;
    return 1;
  }

  std::string schema = argv[2];
  std::string key = argv[3];
  std::string value = argv[4];

  schema = "[" + schema + "]";
  key += "=";

  std::ifstream infile(FILENAME);
  std::ostringstream sstr;
  sstr << infile.rdbuf();
  std::string buffer = sstr.str();

  size_t start = buffer.find(schema);
  if (start != std::string::npos) {
    size_t end = buffer.find("\n\n[", start);
    if (end == std::string::npos)
      end = buffer.length() - 1;
    size_t len = end - start;
    std::string subbuffer = buffer.substr(start, len);

    size_t substart = subbuffer.find(key);
    if (substart != std::string::npos) {
      substart += key.length();
      size_t subend = subbuffer.find("\n", substart);
      size_t sublen = subend - substart;
      subbuffer.replace(substart, sublen, value);
    } else {
      subbuffer += "\n" + key + value;
    }

    buffer.replace(start, len, subbuffer);
  } else {
    buffer += "\n" + schema;
    buffer += "\n" + key + value;
    buffer += "\n";
  }

  std::ofstream outfile(FILENAME);
  outfile << buffer;
}
