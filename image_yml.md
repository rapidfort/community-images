# image.yml format details

## parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `name` | name of the image | `""` | yes |
   | `official_name` | Official name of the image | `""` | yes |
   | `official_website` | official website of the image | `""` | yes |
   | `source_image_provider` | source image provider, ex: Bitnami | `""` | yes |
   | `source_image_repo` | soucre image docker repo, used for linking image in frontrow | `""` | yes |
   | `source_image_repo_link` | soucre image docker repo url | `""` | yes |
   | `rf_docker_link` | rapidfort docker link, ex: rapidfort/<image> | `""` | yes |
   | `image_workflow_name` | used for generating github action file name | `""` | yes |
   | `github_location` | relative location of image folder in community_image | `""` | yes |
   | `report_url` | frontrow url for the repo | `""` | yes |
   | `usage_instructions` | usage instructions such as helm install or docker run | `""` | yes |
   | `what_is_text` | description about image, usually copied from official image What is? | `""` | yes |
   | `disclaimer` | disclaimer or any legal liability notice to be added | `""` | yes |
   | `docker_links` | array of all the different image versions build along with link to original Dockerfile | `['""', '""']` | yes |
   | `input_registry.registry` | source registry used to pull docker image, ex: docker.io | `""` | yes |
   | `input_registry.account` | accout in registry from which source image is pulled, ex: bitnami | `""` | yes |
   | `output_registry.registry` | output registry to which docker image should be pused, ex: docker.io | `""` | yes |
   | `output_registry.account` | output account to which hardened image will be pushed, usually "rapidfort" | `""` | yes |
   | `repo_sets` | array of repo_set object describe below. | `['repo_set', 'repo_set']` | yes |
   | `runtimes` | array of runtime object describe below. | `['runtime', 'runtime']` | yes |

## repo_set parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `<repo>.input_base_tag` | input base tag to search for a given repo | `""` | yes |
   | `<repo>.output_repo` | output repo name for the repo | `defaults to <repo>` | False |

## runtime parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `type` | pick from k8s, docker_compose, docker | `pickOne: [k8s, docker_compose, docker]` | yes |
   | `script` | script to be called for the runtime | `""` | False |

### k8s runtime parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `helm_repo` | helm repo to use for k8s runtime, ex: 'bitnami/nats' | `""` | yes |
   | `readiness_wait_pod_name_suffix` | only valid for wait_type: pod, defaults to -0 | `-0` | False |
   | `tls_certs.generate` | if tls certs generation is needed true/false | `false` | False |
   | `tls_certs.secret_name` | secret name to store tls certs | `""` | yes |
   | `tls_certs.common_name` | common name to use in generated tls certs, defaults to localhost | `localhost` | yes |
   | `helm_additional_params` | additional key value parameters rendered as --set key=value for helm install command | `""` | False |
   | `image_keys.<repo>.repository` | key to use for helm install command to specify image repository, needed for multi container system | `image.repository` | False |
   | `image_keys.<repo>.tag` | key to use for helm install command to specify image tag, needed for multi container system | `image.tag` | False |

### docker compose runtime parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `compose_file` | docker compose file path | `""` | yes |
   | `env_file` | environment file for default env variables | `docker.env` | False |
   | `wait_time_sec` | wait time in seconds after docker-compose up | `30` | False |
   | `tls_certs.generate` | if tls certs generation is needed true/false | `false` | False |
   | `tls_certs.out_dir` | output directory relative to image.yml dir to store tls certs, defaults to certs | `certs` | False |
   | `image_keys.<repo>.repository` | environment variable to specify repository for the repo, as describe in docker-compose.yml | `""` | yes |
   | `image_keys.<repo>.tag` | environment variable to specify tag for the repo, as describe in docker-compose.yml | `""` | yes |

### docker runtime parameters
| Name                      | Description                                            | Value | Required |
| ------------------------- | ------------------------------------------------------ | ----- | ----- |
   | `wait_time_sec` | wait time in seconds after all docker run completes | `30` | False |
   | `tls_certs.generate` | if tls certs generation is needed true/false | `false` | False |
   | `tls_certs.out_dir` | output directory relative to image.yml dir to store tls certs, defaults to certs | `certs` | False |
   | `volumes` | map of input volumes, relative to script dir and mounted volume in ALL container | `""` | yes |
   | `environment` | map of environment variables to be mounted in ALL container | `""` | yes |
   | `<repo>.env_file` | repo specific environment file for default env variables | `docker.env` | False |
   | `<repo>.volumes` | map of input volumes, relative to script dir and mounted volume in container | `""` | yes |
   | `<repo>.environment` | map of environment variables to be mounted in container | `""` | yes |
