"""
This file is used by dockertags script to sort and find
latest tag from a given list of tags
"""
import sys


if len(sys.argv) != 2:
    print("Usage latest_tag <prefix>")
    sys.exit(1)

def get_latest_tag():
    """
    Find latest tags passed to stdin"
    """
    tags = []

    for tag in sys.stdin:
        if "rfstub" not in tag and tag[len(sys.argv[1]):].isdigit():
            tags.append(tag)

    if not tags:
        return []

    tags.sort(key = lambda tag: int(tag[len(sys.argv[1]):]))
    if tags:
        return tags[-1]
    return []


def main():
    """Main function to sort and find latest tags"""
    latest_tag = get_latest_tag()
    if latest_tag:
        print(latest_tag)


if __name__ == "__main__":
    main()
