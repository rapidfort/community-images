""" Utils for community images orchestrator """

class Utils:
    """ Utils class """

    @staticmethod
    def replace_in_file(infile_path, outfile_path, search_replace_dict):
        """ Replace text in file """
        # Read in the file
        with open(infile_path, 'r', encoding="UTF-8") as file :
            filedata = file.read()

        # Replace the target string
        for search_str, replace_str in search_replace_dict.items():
            filedata = filedata.replace(search_str, replace_str)

        # Write the file out again
        with open(outfile_path, 'w', encoding="UTF-8") as file:
            file.write(filedata)
