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

| Repository                            | Original Image                                              | Rapidfort Image                                       | Rapidfort Status                              | Build Status                                                        |
|---------------------------------------| ----------------------------------------------------------- | ----------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| [Redis][redis]                        | [Bitnami Redis][redis-original-image]                       | [Rf Redis][redis-rf-image]                   | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Redis Build][redis-badge]][redis-badge-link]                              |
| [Redis Cluster][redis-cluster]        | [Bitnami Redis Cluster][redis-cluster-original-image]       | [Rf Redis Cluster][redis-cluster-rf-image]   | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Redis Cluster Build][redis-cluster-badge]][redis-cluster-badge-link]      |
| [PostgreSQL][postgresql]              | [Bitnami PostgreSQL][postgresql-original-image]             | [Rf PostgreSQL][postgresql-rf-image]         | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![PostgreSQL Build][postgresql-badge]][redis-badge-link]                    |
| [MySQL][mysql]                        | [Bitnami MySQL][mysql-original-image]                       | [Rf MySQL][mysql-rf-image]                   | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![MySQL Build][redis-badge]][mysql-badge-link]                              |
| [MongoDB][mongodb]                    | [Bitnami MongoDB][mongodb-original-image]                   | [Rf MongoDB][mongodb-rf-image]               | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![MongoDB Build][redis-badge]][mongodb-badge-link]                          |
| [Yugabyte][yugabyte]                  | [Bitnami Yugabyte][yugabyte-original-image]                 | [Rf Yugabyte][yugabyte-rf-image]             | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Redis Yugabyte][yugabyte-badge]][yugabyte-badge-link]                     |
| [Huggingface][transformers]           | [Bitnami Huggingface][transformers-original-image]          | [Rf Huggingface][transformers-rf-image]      | [![RF Hardened][rf-hardened-badge]][rf-link]  | [![Huggingface Build][transformers-badge]][transformers-badge-link]          |

## Credits

* [RapidFort](https://github.com/RapidFort)

## Additional Resources

Learn more about container optimization at [RapidFort.com](https://rapidfort.com).

[rf-link]: https://rapidfort.com 
[rf-hardened-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

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

[postgresql]: https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami
[postgresql-original-image]: https://hub.docker.com/r/bitnami/postgresql
[postgresql-rf-image]: https://hub.docker.com/r/rapidfort/postgresql
[postgresql-badge]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml/badge.svg
[postgresql-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml

[mysql]: https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami
[mysql-original-image]: https://hub.docker.com/r/bitnami/mysql
[mysql-rf-image]: https://hub.docker.com/r/rapidfort/mysql
[mysql-badge]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml/badge.svg
[mysql-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml

[mongodb]: https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami
[mongodb-original-image]: https://hub.docker.com/r/bitnami/mongodb
[mongodb-rf-image]: https://hub.docker.com/r/rapidfort/mongodb
[mongodb-badge]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml/badge.svg
[mongodb-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml

[yugabyte]: https://github.com/rapidfort/community-images/tree/main/community_images/yugabyte/yugabytedb
[yugabyte-original-image]: https://hub.docker.com/r/yugabytedb/yugabyte
[yugabyte-rf-image]: https://hub.docker.com/r/rapidfort/yugabyte
[yugabyte-badge]: https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml/badge.svg
[yugabyte-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/yugabyte_yugabytedb.yml

[transformers]: https://github.com/rapidfort/community-images/tree/main/community_images/transformers-pytorch-cpu/huggingface
[transformers-original-image]: https://hub.docker.com/r/huggingface/transformers-pytorch-cpu
[transformers-rf-image]: https://hub.docker.com/r/rapidfort/transformers-pytorch-cpu
[transformers-badge]: https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml/badge.svg
[transformers-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/transformers_pytorch_cpu_huggingface.yml