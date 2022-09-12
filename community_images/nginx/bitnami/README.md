[![RapidFort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)][rf-rapidfort-logo-link]

[![rf-h][rf-h-badge]][rf-view-report-button]
[![DH Image][dh-rf-badge]][rf-dh-image-link]
[![Slack][slack-badge]][slack-link]
[![FOSSA Status][fossa-badge]][fossa-link]


# RapidFort hardened image for NGINX

RapidFort’s container optimization process hardened this NGINX container. This container is free to use and has no license limitations.

It is the same as the [Bitnami NGINX][source-image-repo-link] image but more secure.

Every day, we optimize and harden a variety of Docker Hub’s most famous images. Check out our [entire library](https://hub.docker.com/u/rapidfort) of secured containers.
<br>

[Get the full report here or click on the image below][rf-view-report-link]

[![Metrics][metrics-link]][rf-image-metrics-link]

## Vulnerabilities: Original vs. Hardened

[![CVE Reduction][cve-reduction-link]][rf-image-cve-reduction-link]

## What is NGINX?

> Nginx (pronounced "engine-x") is an open source reverse proxy server for HTTP, HTTPS, SMTP, POP3, and IMAP protocols, as well as a load balancer, HTTP cache, and a web server (origin server). The nginx project started with a strong focus on high concurrency, high performance and low memory usage. It is licensed under the 2-clause BSD-like license and it runs on Linux, BSD variants, Mac OS X, Solaris, AIX, HP-UX, as well as on other *nix flavors. It also has a proof of concept port for Microsoft Windows.


[Overview of NGINX](http://nginx.org/)

Trademarks: This software listing is packaged by RapidFort. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.


## How do I use this hardened NGINX image?

The runtime instructions for this container are no different from the official release. Follow the instructions in their readme, but use our hardened image.

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# install nginx, just replace repository with RapidFort registry
$ helm install my-nginx bitnami/nginx --set image.repository=rapidfort/nginx

```

## What is a hardened image?

A hardened image is a copy of a container that has been optimized and reduced for significantly improved security. Because every container uses many open-source software components and their dependencies, there’s a lot of extra weight that can be trimmed.

This image is a hardened version of the official [Bitnami NGINX][source-image-repo-link] image on Docker Hub.

RapidFort is an industry-leading container optimization solution that minimizes software attack surfaces by removing unused code. Most containers can be reduced by at least 50%, which reduces the opportunity for malicious attacks and CVE exploits. Learn more at [RapidFort.com][rf-link].

Our hardened images are updated daily using the latest vulnerability information available.


## What’s the difference between the official [Bitnami NGINX][source-image-repo-link] image and this hardened image?
RapidFort’s hardened [rapidfort/nginx][rf-dh-image-link] image has been optimized by our proprietary scanning and slimming technology. We are big fans of open-source software, containerized infrastructure, and security.

We are making secure copies of the images we use every day and the most popular ones on Docker Hub. We want to make the world a safer place to operate.

## Supported tags and respective `Dockerfile` links
* [`1.23`, `1.23-debian-11`, `1.23.1`, `1.23.1-debian-11-r11`, `latest` (1.23/debian-11/Dockerfile)](https://github.com/bitnami/containers/blob/main/bitnami/nginx/1.23/debian-11/Dockerfile)
* [`1.22`, `1.22-debian-11`, `1.22.0`, `1.22.0-debian-11-r29` (1.22/debian-11/Dockerfile)](https://github.com/bitnami/containers/blob/main/bitnami/nginx/1.22/debian-11/Dockerfile)

Subscribe to project updates by watching the [rapidfort/community-images GitHub repo](https://github.com/rapidfort/community-images).

## Have questions?
If you'd like to learn more about RapidFort or our container optimization process, visit [RapidFort.com][rf-link].

<br>
<br>


[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[fossa-badge]: https://app.fossa.com/api/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images.svg?type=shield
[fossa-link]: https://app.fossa.com/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images?ref=badge_shield

[rf-link]: https://rapidfort.com?utm_source=github&utm_medium=ci_rf_link&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=rapidfort_have_questions

[rf-rapidfort-logo-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=rapidfort_logo
[rf-view-report-button]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=view_report_button
[rf-view-report-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=view_report_link
[rf-image-metrics-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=image_metrics_link
[rf-image-cve-reduction-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx&utm_content=image_cve_reduction_link

[dh-img-size-badge]: https://img.shields.io/docker/image-size/rapidfort/nginx?logo=docker&logoColor=white&sort=semver
[dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/nginx?logo=docker&logoColor=white

[slack-badge]: https://img.shields.io/static/v1?label=Join&message=slack&logo=slack&logoColor=E01E5A&color=4A154B
[slack-link]: https://join.slack.com/t/slack-ch72160/shared_invite/zt-1cafpzlyb-9I5He8olcp~FxmpZKxR~CA

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=
[metrics-link]: https://github.com/rapidfort/community-images/raw/main/community_images/nginx/bitnami/assets/metrics.png
[cve-reduction-link]: https://github.com/rapidfort/community-images/raw/main/community_images/nginx/bitnami/assets/cve_reduction.png

[source-image-repo-link]: https://hub.docker.com/r/bitnami/nginx
[rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nginx
