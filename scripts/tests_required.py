# Script to check if github actions test is required
import sys


def main():
    print(sys.argv)
    if len(sys.argv) != 3:
        sys.exit(1)

    output_file = sys.argv(2)
    with open(output_file, "w", encoding="utf8") as fp:
        fp.write("TEST_REQUIRED=no")

if __name__ == "__main__":
    main()
