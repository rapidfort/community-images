import fileinput
import sys


if(len(sys.argv) != 2):
    print("Usage latest_tag <prefix>")
    exit(1)

tags = []

for tag in sys.stdin:
    tags.append(tag)


tags.sort(key = lambda tag: int(tag[len(sys.argv[1]):]))
if tags:
    print(tags[-1])
