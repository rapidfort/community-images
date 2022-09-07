
[![RapidFort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)][rf-link]

<h1> community-images </h1>

[![RF Hardened][rf-h-badge]][rf-link]
[![Dockerhub][dh-rf-badge]][dh-rf]
[![Slack][slack-badge]][slack-link]
[![License][license-badge]][license]
[![FOSSA Status][fossa-badge]][fossa-link]
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6087/badge)](https://bestpractices.coreinfrastructure.org/projects/6087)
[![CodeQL](https://github.com/rapidfort/community-images/actions/workflows/codeql.yml/badge.svg)](https://github.com/rapidfort/community-images/actions/workflows/codeql.yml)
[![Build][image-ft-badge]][image-ft-badge-link]

[Getting started](#getting-started) ·
[Contributing](CONTRIBUTING.md) ·
[Build Process](#how-community-images-are-built) ·
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

| Repository                        | RapidFort Image                                | View Report                     |
|-----------------------------------| ------------------------------------------     | ------------------------------- |
| [MariaDB][ mariadb-github-link]| [![dh][dh-rf-badge]][mariadb-rf-dh-image-link] | [![rf-h][rf-h-badge]][mariadb-rf-link] |
| [MongoDB®][ mongodb-github-link]| [![dh][dh-rf-badge]][mongodb-rf-dh-image-link] | [![rf-h][rf-h-badge]][mongodb-rf-link] |
| [MySQL][ mysql-github-link]| [![dh][dh-rf-badge]][mysql-rf-dh-image-link] | [![rf-h][rf-h-badge]][mysql-rf-link] |
| [NGINX][ nginx-github-link]| [![dh][dh-rf-badge]][nginx-rf-dh-image-link] | [![rf-h][rf-h-badge]][nginx-rf-link] |
| [PostgreSQL][ postgresql-github-link]| [![dh][dh-rf-badge]][postgresql-rf-dh-image-link] | [![rf-h][rf-h-badge]][postgresql-rf-link] |
| [Redis™][ redis-github-link]| [![dh][dh-rf-badge]][redis-rf-dh-image-link] | [![rf-h][rf-h-badge]][redis-rf-link] |
| [Redis™ Cluster][ redis-cluster-github-link]| [![dh][dh-rf-badge]][redis-cluster-rf-dh-image-link] | [![rf-h][rf-h-badge]][redis-cluster-rf-link] |
| [Envoy][ envoy-github-link]| [![dh][dh-rf-badge]][envoy-rf-dh-image-link] | [![rf-h][rf-h-badge]][envoy-rf-link] |
| [Fluentd][ fluentd-github-link]| [![dh][dh-rf-badge]][fluentd-rf-dh-image-link] | [![rf-h][rf-h-badge]][fluentd-rf-link] |
| [Grafana Oncall][ oncall-github-link]| [![dh][dh-rf-badge]][oncall-rf-dh-image-link] | [![rf-h][rf-h-badge]][oncall-rf-link] |
| [InfluxDB™][ influxdb-github-link]| [![dh][dh-rf-badge]][influxdb-rf-dh-image-link] | [![rf-h][rf-h-badge]][influxdb-rf-link] |
| [Etcd][ etcd-github-link]| [![dh][dh-rf-badge]][etcd-rf-dh-image-link] | [![rf-h][rf-h-badge]][etcd-rf-link] |
| [NATS][ nats-github-link]| [![dh][dh-rf-badge]][nats-rf-dh-image-link] | [![rf-h][rf-h-badge]][nats-rf-link] |
| [Redis™ IronBank][ redis-ib-github-link]| [![dh][dh-rf-badge]][redis-ib-rf-dh-image-link] | [![rf-h][rf-h-badge]][redis-ib-rf-link] |
| [PostgreSQL IronBank][ postgresql-ib-github-link]| [![dh][dh-rf-badge]][postgresql-ib-rf-dh-image-link] | [![rf-h][rf-h-badge]][postgresql-ib-rf-link] |
| [NGINX IronBank][ nginx-ib-github-link]| [![dh][dh-rf-badge]][nginx-ib-rf-dh-image-link] | [![rf-h][rf-h-badge]][nginx-ib-rf-link] |
| [Prometheus][ prometheus-github-link]| [![dh][dh-rf-badge]][prometheus-rf-dh-image-link] | [![rf-h][rf-h-badge]][prometheus-rf-link] |
| [Wordpress][ wordpress-github-link]| [![dh][dh-rf-badge]][wordpress-rf-dh-image-link] | [![rf-h][rf-h-badge]][wordpress-rf-link] |
| [RabbitMQ][ rabbitmq-github-link]| [![dh][dh-rf-badge]][rabbitmq-rf-dh-image-link] | [![rf-h][rf-h-badge]][rabbitmq-rf-link] |
| [Apache][ apache-github-link]| [![dh][dh-rf-badge]][apache-rf-dh-image-link] | [![rf-h][rf-h-badge]][apache-rf-link] |
| [Apache Airflow][ airflow-github-link]| [![dh][dh-rf-badge]][airflow-rf-dh-image-link] | [![rf-h][rf-h-badge]][airflow-rf-link] |
| [Apache Airflow Scheduler][ airflow-scheduler-github-link]| [![dh][dh-rf-badge]][airflow-scheduler-rf-dh-image-link] | [![rf-h][rf-h-badge]][airflow-scheduler-rf-link] |
| [Apache Airflow Worker][ airflow-worker-github-link]| [![dh][dh-rf-badge]][airflow-worker-rf-dh-image-link] | [![rf-h][rf-h-badge]][airflow-worker-rf-link] |

### How to use Community Images

Here’s what you can do with Community Images.

```sh
# Docker
$ docker run --name redis -e ALLOW_EMPTY_PASSWORD=yes rapidfort/redis:latest

# Docker compose
$ docker-compose up -d

# Kubernetes Helm
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# install redis, just replace repository with RapidFort registry
$ helm install my-redis bitnami/redis --set image.repository=rapidfort/redis

# install postgresql
$ helm install my-postgresql bitnami/postgresql --set image.repository=rapidfort/postgresql

```
## How Community Images are Built

Source images are run through an optimization process that identifies and removes unused components from the image.
You can contribute to this project by adding new images, improving coverage scripts, and adding regression and benchmark tests.

![Demo](contrib/coverage.png)

## Additional Resources

Learn more about container optimization at [RapidFort.com](https://rapidfort.com).


[rf-link]: https://rapidfort.com

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[fossa-badge]: https://app.fossa.com/api/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images.svg?type=shield
[fossa-link]: https://app.fossa.com/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images?ref=badge_shield

[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker
[dh-rf]: https://hub.docker.com/u/rapidfort
[license-badge]: https://img.shields.io/github/license/rapidfort/community-images?color=lightgray&style=flat-square
[license]: https://github.com/rapidfort/community-images/blob/main/LICENSE
[demo]: contrib/demo.gif

[slack-badge]: https://img.shields.io/static/v1?label=Join&message=slack&logo=slack&logoColor=E01E5A&color=4A154B
[slack-link]: https://join.slack.com/t/slack-ch72160/shared_invite/zt-1cafpzlyb-9I5He8olcp~FxmpZKxR~CA

[ image-ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/image_run_v3.yml/badge.svg
[ image-ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/image_run_v3.yml


[mariadb-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mariadb/bitnami
[mariadb-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/mariadb?logo=docker&logoColor=white
[mariadb-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mariadb
[mariadb-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fmariadb?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[mongodb-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mongodb/bitnami
[mongodb-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/mongodb?logo=docker&logoColor=white
[mongodb-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mongodb
[mongodb-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fmongodb?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[mysql-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/mysql/bitnami
[mysql-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/mysql?logo=docker&logoColor=white
[mysql-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mysql
[mysql-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fmysql?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[nginx-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/nginx/bitnami
[nginx-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/nginx?logo=docker&logoColor=white
[nginx-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nginx
[nginx-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[postgresql-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/bitnami
[postgresql-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/postgresql?logo=docker&logoColor=white
[postgresql-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/postgresql
[postgresql-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fpostgresql?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[redis-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/redis/bitnami
[redis-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/redis?logo=docker&logoColor=white
[redis-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis
[redis-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fredis?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[redis-cluster-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/redis-cluster/bitnami
[redis-cluster-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/redis-cluster?logo=docker&logoColor=white
[redis-cluster-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis-cluster
[redis-cluster-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fredis-cluster?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[envoy-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/envoy/bitnami
[envoy-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/envoy?logo=docker&logoColor=white
[envoy-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/envoy
[envoy-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fenvoy?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[fluentd-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/fluentd/bitnami
[fluentd-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/fluentd?logo=docker&logoColor=white
[fluentd-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/fluentd
[fluentd-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Ffluentd?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[oncall-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/oncall/grafana
[oncall-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/oncall?logo=docker&logoColor=white
[oncall-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/oncall
[oncall-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fgrafana%2Foncall?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[influxdb-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/influxdb/bitnami
[influxdb-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/influxdb?logo=docker&logoColor=white
[influxdb-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/influxdb
[influxdb-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Finfluxdb?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[etcd-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/etcd/bitnami
[etcd-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/etcd?logo=docker&logoColor=white
[etcd-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/etcd
[etcd-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fetcd?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[nats-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/nats/bitnami
[nats-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/nats?logo=docker&logoColor=white
[nats-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nats
[nats-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnats?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[redis-ib-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/redis/ironbank
[redis-ib-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/redis6-ib?logo=docker&logoColor=white
[redis-ib-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis6-ib
[redis-ib-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/registry1.dso.mil%2Fironbank%2Fopensource%2Fredis%2Fredis6?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[postgresql-ib-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/postgresql/ironbank
[postgresql-ib-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/postgresql12-ib?logo=docker&logoColor=white
[postgresql-ib-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/postgresql12-ib
[postgresql-ib-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/registry1.dso.mil%2Fironbank%2Fopensource%2Fpostgres%2Fpostgresql12?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[nginx-ib-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/nginx/ironbank
[nginx-ib-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/nginx-ib?logo=docker&logoColor=white
[nginx-ib-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nginx-ib
[nginx-ib-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/registry1.dso.mil%2Fironbank%2Fopensource%2Fnginx%2Fnginx?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[prometheus-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/prometheus/bitnami
[prometheus-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/prometheus?logo=docker&logoColor=white
[prometheus-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/prometheus
[prometheus-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fprometheus?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[wordpress-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/wordpress/bitnami
[wordpress-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/wordpress?logo=docker&logoColor=white
[wordpress-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/wordpress
[wordpress-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fwordpress?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[rabbitmq-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/rabbitmq/bitnami
[rabbitmq-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/rabbitmq?logo=docker&logoColor=white
[rabbitmq-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/rabbitmq
[rabbitmq-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Frabbitmq?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[apache-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/apache/bitnami
[apache-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/apache?logo=docker&logoColor=white
[apache-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/apache
[apache-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fapache?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[airflow-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/airflow/airflow/bitnami
[airflow-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/airflow?logo=docker&logoColor=white
[airflow-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/airflow
[airflow-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fairflow?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[airflow-scheduler-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/airflow/airflow-scheduler/bitnami
[airflow-scheduler-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/airflow-scheduler?logo=docker&logoColor=white
[airflow-scheduler-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/airflow-scheduler
[airflow-scheduler-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fairflow-scheduler?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022

[airflow-worker-github-link]: https://github.com/rapidfort/community-images/tree/main/community_images/airflow/airflow-worker/bitnami
[airflow-worker-dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/airflow-worker?logo=docker&logoColor=white
[airflow-worker-rf-dh-image-link]: https://hub.docker.com/r/rapidfort/airflow-worker
[airflow-worker-rf-link]:https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fairflow-worker?utm_source=gh-ci-landing&utm_medium=view-report&utm_id=rsa-ci-2022
