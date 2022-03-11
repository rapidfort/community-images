import fileinput
import sys



if(len(sys.argv) != 2):
    print("Usage latest_tag <prefix>")
    exit(1)

def get_latest_tag():
    """
    Find latest tags passed to stdin"
    """
    tags = []

    for tag in sys.stdin:
        tags.append(tag)

    tags.sort(key = lambda tag: int(tag[len(sys.argv[1]):]))
    if tags:
        return tags[-1]


def main():
    latest_tag = get_latest_tag()
    if not latest_tag:
        exit(1)

    print(latest_tag)


if __name__ == "__main__":
    main()
