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
    search_str = sys.argv[1]
    search_str_len = len(search_str)

    for tag in sys.stdin:
        if "rfstub" not in tag and tag[search_str_len:].isdigit():
            tags.append(tag)

    if not tags:
        return []

    tags.sort(key = lambda tag: int(tag[search_str_len:]))
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
