
![RapidFort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)

<h1> community-images </h1>

[![RF Hardened][rf-h-badge]][rf-link]
[![Dockerhub][dh-rf-badge]][dh-rf]
[![License][license-badge]][license]

[Getting started](#getting-started) ·
[Contributing](CONTRIBUTING.md) ·
[Additional resources](#additional-resources)

**RapidFort is a solution for building secure, optimized Docker containers.**

Every day, we scan the most popular Docker Hub container images and remove unused code. Then we publish the results to share with you.

Our container optimization process reduces the software attack surface and chance of a vulnerability exploit.

Stop downloading container images with thousands of vulnerabilities. Start using secure containers with minimized attack surfaces.


## Getting Started

![Demo][demo]

RapidFort scans your Docker containers, looks for unused code and vulnerabilities, and lets you delete everything you don’t need. It’s a simple command line tool that’s part of [RapidFort](https://rapidfort.com), our commercial product.

## What containers are supported?

We’ve optimized and hardened some of the most popular container images available on Docker Hub and are making them available to the community.

| Repository                        | RapidFort Image                                | View Report                     |  Status                                                                |
|-----------------------------------| ------------------------------------------     | ------------------------------- | --------------------------------------------------------------------   | 
| [Redis][redis]                    | [![dh][dh-rf-badge]][redis-rf-image]           | [![rf-h][rf-h-badge]][rf-link]  | [![redis-ft][redis-badge]][redis-badge-link]                           |
| [Redis Cluster][redis-cluster]    | [![dh][dh-rf-badge]][redis-cluster-rf-image]   | [![rf-h][rf-h-badge]][rf-link]  | [![redis-cluster-ft][redis-cluster-badge]][redis-cluster-badge-link]   |
| [PostgreSQL][postgresql]          | [![dh][dh-rf-badge]][postgresql-rf-image]      | [![rf-h][rf-h-badge]][rf-link]  | [![postgresql-ft][postgresql-badge]][postgresql-badge-link]                 |
| [MariaDB][mariadb]                | [![dh][dh-rf-badge]][mariadb-rf-image]         | [![rf-h][rf-h-badge]][rf-link]  | [![mariadb-ft][mariadb-badge]][mariadb-badge-link]                       |
| [MySQL][mysql]                    | [![dh][dh-rf-badge]][mysql-rf-image]           | [![rf-h][rf-h-badge]][rf-link]  | [![mysql-ft][mysql-badge]][mysql-badge-link]                           |
| [MongoDB][mongodb]                | [![dh][dh-rf-badge]][mongodb-rf-image]         | [![rf-h][rf-h-badge]][rf-link]  | [![mongodb-ft][mongodb-badge]][mongodb-badge-link]                       |

### How to use Community Images

Here’s what you can do with Community Images.

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# install redis, just replace repository with RapidFort registry
$ helm install my-redis bitnami/redis --set image.repository=rapidfort/redis

# install postgresql
$ helm install my-postgresql bitnami/postgresql --set image.repository=rapidfort/postgresql

```

## Additional Resources

Learn more about container optimization at [RapidFort.com](https://rapidfort.com).

[rf-link]: https://rapidfort.com 
[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker
[dh-rf]: https://hub.docker.com/u/rapidfort
[license-badge]: https://img.shields.io/github/license/rapidfort/community-images?color=lightgray&style=flat-square
[license]: https://github.com/rapidfort/community-images/blob/main/LICENSE
[demo]: contrib/demo.gif

[redis]: https://github.com/rapidfort/community-images/tree/main/community_images/redis/bitnami
[redis-original-image]: https://hub.docker.com/r/bitnami/redis
[redis-rf-image]: https://hub.docker.com/r/rapidfort/redis
[redis-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis_ft.yml/badge.svg
[redis-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis_ft.yml

[redis-cluster]: https://github.com/rapidfort/community-images/tree/main/community_images/redis-cluster/bitnami
[redis-cluster-original-image]: https://hub.docker.com/r/bitnami/redis-cluster
[redis-cluster-rf-image]: https://hub.docker.com/r/rapidfort/redis-cluster
[redis-cluster-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_ft.yml/badge.svg
[redis-cluster-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis_cluster_ft.yml

[postgresql]: https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami
[postgresql-original-image]: https://hub.docker.com/r/bitnami/postgresql
[postgresql-rf-image]: https://hub.docker.com/r/rapidfort/postgresql
[postgresql-badge]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_ft.yml/badge.svg
[postgresql-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_ft.yml

[mysql]: https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami
[mysql-original-image]: https://hub.docker.com/r/bitnami/mysql
[mysql-rf-image]: https://hub.docker.com/r/rapidfort/mysql
[mysql-badge]: https://github.com/rapidfort/community-images/actions/workflows/mysql_ft.yml/badge.svg
[mysql-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mysql_ft.yml

[mongodb]: https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami
[mongodb-original-image]: https://hub.docker.com/r/bitnami/mongodb
[mongodb-rf-image]: https://hub.docker.com/r/rapidfort/mongodb
[mongodb-badge]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_ft.yml/badge.svg
[mongodb-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_ft.yml

[mariadb]: https://github.com/rapidfort/community-images/tree/main/community_images/mariadb/bitnami
[mariadb-original-image]: https://hub.docker.com/r/bitnami/mariadb
[mariadb-rf-image]: https://hub.docker.com/r/rapidfort/mariadb
[mariadb-badge]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_ft.yml/badge.svg
[mariadb-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_ft.yml
