""" Merges tags into image.yml """
import sys
import logging
import yaml

def read_yaml(yaml_path):
    """ read yaml file from path and returns dict """
    try:
        with open(yaml_path, "r", encoding="utf8") as yml_stream:
            return yaml.safe_load(yml_stream)
    except yaml.YAMLError as exc:
        logging.error(exc)
    return {}

def write_yaml(yaml_dict, yaml_path):
    """ write yaml_dict to yaml_path """
    with open(yaml_path, "w", encoding="utf8") as outfile:
        yaml.dump(yaml_dict, outfile, default_flow_style=False)

def prepare_yml(input_yml, output_yml):
    """ prepare yml file by merging info """
    input_dict = read_yaml(input_yml)

    write_yaml(input_dict, output_yml)

def main():
    """ main driver """
    if len(sys.argv) != 3:
        logging.error(f"invalid sys.argv {sys.argv}")
        sys.exit(1)
    input_yml = sys.argv[1]
    output_yml = sys.argv[2]
    prepare_yml(input_yml, output_yml)

if __name__ == "__main__":
    main()
