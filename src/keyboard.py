import fileinput
import sys

if len(sys.argv) > 1:
    layout = sys.argv[1]
else:
    layout = "us"

with fileinput.input("/etc/default/keyboard", inplace=True) as file:
    for line in file:
        if "XKBLAYOUT" in line:
            print('XKBLAYOUT="' + layout + '"')
        else:
            print(line, end="")
