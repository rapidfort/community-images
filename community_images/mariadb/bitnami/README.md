[![Rapidfort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)](https://rapidfort.com) 

[![dh][dh-rf-badge]][mariadb-rf-image]
[![rf-h][rf-h-badge]][rf-link] 
[![mariadb-ft][mariadb-badge]][mariadb-badge-link]

# RapidFort hardened image for MariaDB

## What is MariaDB?

> MariaDB is an open source, community-developed SQL database server that is widely in use around the world due to its enterprise features, flexibility, and collaboration with leading tech firms.

[Overview of MariaDB](https://www.mariadb.com/)

## How to use Community Images

Here’s what you can do with Community Images.

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# install mariadb, just replace repository with RapidFort registry
$ helm install my-mariadb bitnami/mariadb --set image.repository=rapidfort/mariadb

```

Trademarks: This software listing is packaged by Rapidfort. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

<br>
<br>

### Sign up now: https://rapidfort.com
### Github: https://github.com/rapidfort/community-images

[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[rf-link]: https://rapidfort.com 
[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[mariadb-original-image]: https://hub.docker.com/r/bitnami/mariadb
[mariadb-rf-image]: https://hub.docker.com/r/rapidfort/mariadb
[mariadb-badge]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_ft.yml/badge.svg
[mariadb-badge-link]: https://github.com/rapidfort/community-images/actions/workflows/mariadb_ft.yml