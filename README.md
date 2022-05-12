![Rapidfort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg) 
# community-images

**Rapidfort is a solution for building secure, optimized Docker containers.**

Every day, we scan the most popular Docker Hub container images and remove unused code. Then we publish the results to share with you.

Our container optimization process reduces the software attack surface and chance of a vulnerability exploit.

Stop downloading container images with thousands of vulnerabilities. Start using secure containers with minimized attack surfaces.

[Getting started](#getting-started) ·
[Hardened images](#rapidfort-hardened-images) ·
[Contributing](CONTRIBUTING.md) ·
[Credits](#credits) ·
[Additional resources](#additional-resources)

## Getting Started

ANIMATED GIF GOES HERE

Rapidfort scans your Docker containers, looks for unused code and vulnerabilities, and lets you delete everything you don’t need. It’s a simple command line tool that’s part of [RapidFort](https://rapidfort.com), our commercial product.

### What containers are supported?

TBD

### How to use Community Images

Here’s what you can do with Community Images.

```sh
helm install --image x  # Do x

docker run y  # Do y
```

### Step 1: Get your container

TBD

## Rapidfort Hardened Images

We’ve optimized and hardened some of the most popular container images available on Docker Hub and are making them available to the community.

| Repository | Original Image      | Rapidfort Image | Status |
|----| ----------- | ----------- | ----------- |
| [Redis](https://github.com/rapidfort/community-images/tree/main/community_images/redis/bitnami) | [Bitnami Redis](https://hub.docker.com/r/bitnami/redis)      | [Rf hardened Redis](https://hub.docker.com/r/rapidfort/redis)       | [![Redis Build](https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml) |
| [Redis Cluster](https://github.com/rapidfort/community-images/tree/main/community_images/redis-cluster/bitnami) | [Bitnami Redis Cluster](https://hub.docker.com/r/bitnami/redis-cluster)      | [Rf hardened Redis cluster](https://hub.docker.com/r/rapidfort/redis-cluster)       | [![Redis Cluster Build](https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_bitnami.yml) |
| [Postgresql](https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami) | [Bitnami Postgresql](https://hub.docker.com/r/bitnami/postgresql/)      | [Rf hardened Postgresql](https://hub.docker.com/r/rapidfort/postgresql)       | [![Postgresql Build](https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml) |
| [MySQL](https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami) | [Bitnami MySQL](https://hub.docker.com/r/bitnami/mysql/)      | [Rf hardened MySQL](https://hub.docker.com/r/rapidfort/mysql)       | [![MySQL Build](https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml) |
| [MongoDB](https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami) | [Bitnami MongoDB](https://hub.docker.com/r/bitnami/mongodb/)      | [Rf hardened MongoDB](https://hub.docker.com/r/rapidfort/mongodb)       | [![MongoDB Build](https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml) |
| [MariaDB](https://github.com/rapidfort/community-images/tree/main/community_images/mariadb/bitnami) | [Bitnami MariaDB](https://hub.docker.com/r/bitnami/mariadb/)      | [Rf hardened MariaDB](https://hub.docker.com/r/rapidfort/mariadb)       | [![MariaDB Build](https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml) |
| [Yugabyte](https://github.com/rapidfort/community-images/tree/main/community_images/yugabyte/yugabytedb) | [YugabyteDB yugabyte](https://hub.docker.com/r/yugabytedb/yugabyte)      | [Rf hardened yugabyte](https://hub.docker.com/r/rapidfort/yugabyte)       | [![Yugabyte Build](https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml) |
| [Huggingface](https://github.com/rapidfort/community-images/tree/main/community_images/transformers-pytorch-cpu/huggingface) | [Huggingface Pytorch CPU](https://hub.docker.com/r/huggingface/transformers-pytorch-cpu)      | [Rf hardened Pytorch CPU](https://hub.docker.com/r/rapidfort/transformers-pytorch-cpu)       | [![Huggingface Build](https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml) |

## Credits

* [RapidFort](https://github.com/RapidFort)

## Additional Resources

Learn more about container optimization at [RapidFort.com](https://rapidfort.com).
