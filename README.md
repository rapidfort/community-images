
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

Our container optimization process reduces the software attack surface and the chance of a vulnerability exploit.

Stop downloading container images with thousands of vulnerabilities. Start using secure containers with minimized attack surfaces.


## Getting Started

![Demo][demo]

[RapidFort](https://rapidfort.com) scans your Docker containers for vulnerabilities and looks for unused components that can be removed.

## What containers are supported?

We’ve optimized and hardened some of the most popular container images on Docker Hub and are making them available to the community.

| Repository                        | RapidFort Image                                | View Report                     |  Status    |
|-----------------------------------| ------------------------------------------     | ------------------------------- | --------   |
| [MariaDB][ mariadb-github-link]| [![dh][dh-rf-badge]][mariadb-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![mariadb-image-ft][mariadb-ft-badge]][mariadb-ft-badge-link] |
| [MongoDB®][ mongodb-github-link]| [![dh][dh-rf-badge]][mongodb-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![mongodb-image-ft][mongodb-ft-badge]][mongodb-ft-badge-link] |
| [MySQL][ mysql-github-link]| [![dh][dh-rf-badge]][mysql-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![mysql-image-ft][mysql-ft-badge]][mysql-ft-badge-link] |
| [NGINX][ nginx-github-link]| [![dh][dh-rf-badge]][nginx-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![nginx-image-ft][nginx-ft-badge]][nginx-ft-badge-link] |
| [PostgreSQL][ postgresql-github-link]| [![dh][dh-rf-badge]][postgresql-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![postgresql-image-ft][postgresql-ft-badge]][postgresql-ft-badge-link] |
| [Redis™][ redis-github-link]| [![dh][dh-rf-badge]][redis-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![redis-image-ft][redis-ft-badge]][redis-ft-badge-link] |
| [Redis™ Cluster][ redis-cluster-github-link]| [![dh][dh-rf-badge]][redis-cluster-rf-dh-image-link] | [![rf-h][rf-h-badge]][rf-link] | [![redis-cluster-image-ft][redis-cluster-ft-badge]][redis-cluster-ft-badge-link] |

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

[![RF SignUp][rf-signup-badge]][rf-signup-link]
[![RF Bookademo][rf-book-badge]][rf-book-link]


[rf-link]: https://rapidfort.com 
[rf-signup-link]: https://frontrow.rapidfort.com/app/login 
[rf-book-link]: https://www.rapidfort.com/request-a-demo

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=[logo]
[rf-signup-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=Sign%20Up&color=D6F5D6&logo=[logo]
[rf-book-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=Book%20A%20Demo&color=59B5F1&logo=[logo]


[logo]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker
[dh-rf]: https://hub.docker.com/u/rapidfort
[license-badge]: https://img.shields.io/github/license/rapidfort/community-images?color=lightgray&style=flat-square
[license]: https://github.com/rapidfort/community-images/blob/main/LICENSE
[demo]: contrib/demo.gif


[mariadb-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mariadb/bitnami
[mariadb-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mariadb
[mariadb-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml/badge.svg
[mariadb-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_bitnami.yml
[mariadb-source-dh-link]: https://hub.docker.com/r/bitnami/mariadb

[mongodb-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami
[mongodb-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mongodb
[mongodb-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml/badge.svg
[mongodb-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mongodb_bitnami.yml
[mongodb-source-dh-link]: https://hub.docker.com/r/bitnami/mongodb

[mysql-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami
[mysql-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mysql
[mysql-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml/badge.svg
[mysql-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml
[mysql-source-dh-link]: https://hub.docker.com/r/bitnami/mysql

[nginx-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/nginx/bitnami
[nginx-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nginx
[nginx-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/nginx_bitnami.yml/badge.svg
[nginx-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/nginx_bitnami.yml
[nginx-source-dh-link]: https://hub.docker.com/r/bitnami/nginx

[postgresql-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami
[postgresql-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/postgresql
[postgresql-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml/badge.svg
[postgresql-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/postgresql_bitnami.yml
[postgresql-source-dh-link]: https://hub.docker.com/r/bitnami/postgresql

[redis-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/redis/bitnami
[redis-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis
[redis-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml/badge.svg
[redis-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis_bitnami.yml
[redis-source-dh-link]: https://hub.docker.com/r/bitnami/redis

[redis-cluster-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/redis-cluster/bitnami
[redis-cluster-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis-cluster
[redis-cluster-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/redis-cluster_bitnami.yml/badge.svg
[redis-cluster-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/redis-cluster_bitnami.yml
[redis-cluster-source-dh-link]: https://hub.docker.com/r/bitnami/redis-cluster
