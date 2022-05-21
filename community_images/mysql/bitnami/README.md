[![Rapidfort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)](https://rapidfort.com) 

[![dh][dh-rf-badge]][rf-dh-image-link]
[![rf-h][rf-h-badge]][rf-link] 
[![image-ft][ft-badge]][ft-badge-link]

# RapidFort hardened image for MySQL

This MySQL container was hardened by RapidFort’s container optimization process. This container is free to use and has no license limitations.

It is the same as [bitnami/mysql][source-image-dh-link] image, but much more secure.

Every day, we optimize and harden a variety of Docker Hub’s most popular images. Check out our [entire library](https://hub.docker.com/u/rapidfort) of secured containers.

## What is MySQL?

> MySQL is a fast, reliable, scalable, and easy to use open source relational database system. Designed to handle mission-critical, heavy-load production applications.


[Overview of MySQL](https://www.mysql.com/)

## How do I use this hardened MySQL image?

The runtime instructions for this container are no different than the official release. Follow the instructions in their readme, but use our hardened image.

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# install mysql, just replace repository with RapidFort registry
$ helm install my-mysql bitnami/mysql --set image.repository=rapidfort/mysql

```

## What is a hardened image?

A hardened image is a copy of a container that has been optimized and reduced for significantly improved security. Because every container makes use of many open source software components and their dependencies, there’s a lot of extra weight that can be trimmed.

This image is a hardened version of the official [bitnami/mysql][source-image-dh-link] image available here on Docker Hub.

RapidFort is an industry-leading container optimization solution that minimizes software attack surface by removing unused code. Most containers can be reduced by at least 50%, which reduces the opportunity for malicious attacks and CVE exploits. Learn more at [RapidFort.com][rf-link].

Our hardened images are updated daily using the latest vulnerability information available.

## What’s the difference between the official [bitnami/mysql][source-image-dh-link] image and this hardened image?
RapidFort’s hardened [rapidfort/mysql][rf-dh-image-link] image has been optimized by our proprietary scanning and slimming technology. We are big fans of open source software, containerized infrastructure, and security.

We are making available secure copies of the images we use every day, as well as the most popular ones on Docker Hub. We want to make the world a safer place to operate.

## Have questions?
If you’d like to learn more about how RapidFort works or our container optimization process:

* https://rapidfort.com


Trademarks: This software listing is packaged by RapidFort. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

<br>
<br>


[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[rf-link]: https://rapidfort.com?utm_source=img_github&utm_medium=badge&utm_campaign=ci1
[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[source-image-dh-link]: https://hub.docker.com/r/bitnami/mysql
[rf-dh-image-link]: https://hub.docker.com/r/rapidfort/mysql

[ft-badge]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml/badge.svg
[ft-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mysql_bitnami.yml
