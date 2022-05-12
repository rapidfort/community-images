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

| Repository                            | Original Image                                        | Rapidfort Image                                       | Rapidfort Status                              | Build Status                                                              |
|---------------------------------------| ----------------------------------------------------- | ----------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------- |
| [Redis][redis]                        | [Bitnami Redis][redis-original-image]                 | [Rf hardened Redis][redis-rf-image]                   | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Redis Build][redis-badge]][redis-badge-link]                           |
| [Redis Cluster][redis-cluster]        | [Bitnami Redis Cluster][redis-cluster-original-image] | [Rf hardened Redis Cluster][redis-cluster-rf-image]   | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Redis Cluster Build][redis-cluster-badge]][redis-cluster-badge-link]   |
| [Postgresql](https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami) | [Bitnami Postgresql](https://hub.docker.com/r/bitnami/postgresql/)      | [Rf hardened Postgresql](https://hub.docker.com/r/rapidfort/postgresql)     | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Postgresql Build](https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml) |
| [MySQL](https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami) | [Bitnami MySQL](https://hub.docker.com/r/bitnami/mysql/)      | [Rf hardened MySQL](https://hub.docker.com/r/rapidfort/mysql)    | [![RF Hardened][rf-hardened-badge]][rf-link]   | [![MySQL Build](https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml) |
| [MongoDB](https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami) | [Bitnami MongoDB](https://hub.docker.com/r/bitnami/mongodb/)      | [Rf hardened MongoDB](https://hub.docker.com/r/rapidfort/mongodb)   | [![RF Hardened][rf-hardened-badge]][rf-link]    | [![MongoDB Build](https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml) |
| [MariaDB](https://github.com/rapidfort/community-images/tree/main/community_images/mariadb/bitnami) | [Bitnami MariaDB](https://hub.docker.com/r/bitnami/mariadb/)      | [Rf hardened MariaDB](https://hub.docker.com/r/rapidfort/mariadb)  | [![RF Hardened][rf-hardened-badge]][rf-link]     | [![MariaDB Build](https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml) |
| [Yugabyte](https://github.com/rapidfort/community-images/tree/main/community_images/yugabyte/yugabytedb) | [YugabyteDB yugabyte](https://hub.docker.com/r/yugabytedb/yugabyte)      | [Rf hardened yugabyte](https://hub.docker.com/r/rapidfort/yugabyte)  | [![RF Hardened][rf-hardened-badge]][rf-link]     | [![Yugabyte Build](https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml) |
| [Huggingface](https://github.com/rapidfort/community-images/tree/main/community_images/transformers-pytorch-cpu/huggingface) | [Huggingface Pytorch CPU](https://hub.docker.com/r/huggingface/transformers-pytorch-cpu)  | [Rf hardened Pytorch CPU](https://hub.docker.com/r/rapidfort/transformers-pytorch-cpu)  | [![RF Hardened][rf-hardened-badge]][rf-link]         | [![Huggingface Build](https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml) |

## Credits

* [RapidFort](https://github.com/RapidFort)

## Additional Resources

Learn more about container optimization at [RapidFort.com](https://rapidfort.com).

[rf-link]: https://rapidfort.com 
[rf-hardened-badge]: https://img.shields.io/static/v1?label=RAPIDFORT&labelColor=333F48&message=HARDENED&color=08BC08&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[redis]: https://github.com/rapidfort/community-images/tree/main/community_images/redis/bitnami
[redis-original-image]: https://hub.docker.com/r/bitnami/redis
[redis-rf-image]: https://hub.docker.com/r/rapidfort/redis
[redis-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml/badge.svg
[redis-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml

[redis-cluster]: https://github.com/rapidfort/community-images/tree/main/community_images/redis-cluster/bitnami
[redis-cluster-original-image]: https://hub.docker.com/r/bitnami/redis-cluster
[redis-cluster-rf-image]: https://hub.docker.com/r/rapidfort/redis-cluster
[redis-cluster-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_bitnami.yml/badge.svg
[redis-cluster-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_bitnami.yml