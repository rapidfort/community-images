set -x

set -e

pip install jinja-cli

jinja -d community_images/mariadb/bitnami/readme.yml -f yaml community_images/common/templates/image_readme.j2 > community_images/mariadb/bitnami/README.md
