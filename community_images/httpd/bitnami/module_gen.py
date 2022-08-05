import argparse
# import subprocess
import os


def load_module(s, f):
    s = os.path.basename(s)
    s_temp = s[:-3]
    s_temp = s_temp.split("_")
    s_temp.pop(0)
    s_temp.append("module")

    module_file = os.path.join("modules", s)
    module_name = "_".join(s_temp)


    f.write(" ".join(["LoadModule", module_name, module_file]) + '\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Module Generation")
    parser.add_argument('directory', type=str, nargs=1,
                    help='Enter the module directory')

    args = parser.parse_args()
    directory = args.directory[0]

    files = os.listdir(directory)

    with open("module_list", "w") as f:
        for file in files:
            load_module(file, f)
