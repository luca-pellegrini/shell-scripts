#!/usr/bin/python3
# Replace whitespaces with underscore ("_") characters in filenames

import os
import os.path
import sys


def main():
    if len(sys.argv) < 2 or (not os.path.isdir(sys.argv[1])):
        print("Error: please specify a directory", file=sys.stderr)
        sys.exit(1)
    directory = sys.argv[1]
    filenames_dict = dict()

    for filename in os.listdir(directory):
        if (not filename.startswith(".")  # do not rename hidden files
                and " " in filename):
            path = os.path.join(directory, filename)
            filename_new = filename.replace(" ", "_")
            path_new = os.path.join(directory, filename_new)
            filenames_dict[path] = path_new

    print_changes(filenames_dict)
    if ask_user():
        replace_whitespaces(filenames_dict)
        sys.exit(0)
    else:
        print("No changes made. Exiting.")
        sys.exit(1)


def replace_whitespaces(filenames_dict):
    for path in filenames_dict:
        path_new = filenames_dict[path]
        os.rename(path, path_new)


def print_changes(filenames_dict):
    print("The following files will be renamed:\n")
    for path in filenames_dict:
        print(path, "->", filenames_dict[path])


def ask_user():
    answer = ""
    while answer not in ("y", "s", "n"):
        answer = input("Do you want to continue? [y/n]: ").lower()
    # return False  # DEBUG
    if answer in ("y", "s"):
        return True
    else:
        return False


if __name__ == "__main__":
    main()
