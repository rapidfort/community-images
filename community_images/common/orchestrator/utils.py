""" Utils for community images orchestrator """

class Utils:

    @staticmethod(f)
    def replace_in_file(infile_path, outfile_path, search_str, replace_str):
        """ Replace text in file """
        # Read in the file
        with open(infile_path, 'r') as file :
            filedata = file.read()

        # Replace the target string
        filedata = filedata.replace(search_str, replace_str)

        # Write the file out again
        with open(outfile_path, 'w') as file:
            file.write(filedata)
