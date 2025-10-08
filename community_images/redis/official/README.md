[![RapidFort][rapidfort-logo-header-svg]][rapidfort-logo-header-link]

<br>


[![rf-h][rf-h-badge]][rf-view-report-button]
[![DH Image][dh-rf-badge]][rf-dh-image-link]
[![Slack][slack-badge]][slack-link]
[![FOSSA Status][fossa-badge]][fossa-link]


[![Zero cve images][zero-cve-images-svg]][zero-cve-images-link]
<br />


# RapidFort hardened image for Redis™ Official


RapidFort has optimized and hardened this Redis™ Official container image. This container is free to use and has no license limitations.


This optimized image is functionally equivalent to [The Docker Community Redis™ Official][source-image-repo-link] image but more secure with a significantly smaller software attack surface.

[![Vulnerabilities by severity][vulns-chart-svg]][vulns-chart-link]

[![Original vs. this image][savings-svg]][savings-link]

[![View Report][full-report-svg]][full-report-link]

<br>
<br>


Every day, RapidFort automatically optimizes and hardens a growing bank of Docker Hub’s most important container images. 

Check out our [entire library of secured container images.](https://hub.docker.com/u/rapidfort)
<br>

[Get the full report here or click on the image below][rf-view-report-link]

## What is Redis™ Official?

> Redis™ is an open-source, networked, in-memory, key-value data store with optional durability. It is written in ANSI C. The development of Redis is sponsored by Redis Labs today; before that, it was sponsored by Pivotal and VMware. According to the monthly ranking by DB-Engines.com, Redis is the most popular key-value store. The name Redis means REmote DIctionary Server.


[Overview of Redis™ Official](http://redis.io)

Disclaimer: Redis is a registered trademark of Redis Labs Ltd. Any rights therein are reserved to Redis Labs Ltd. Any use by RapidFort is for referential purposes only and does not indicate any sponsorship, endorsement, or affiliation between Redis Labs Ltd.


## How do I use this hardened Redis™ Official image?



The runtime instructions for this hardened container image are the same as the official release. Follow the instructions provided with the [The Docker Community Redis™ Official][source-image-repo-link].


[![View Detailed Instructions](https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/view_details.svg)](https://github.com/docker-library/docs/blob/master/redis/README.md)

<br>
<br>

```sh
$ docker run -it --rm -p 6379:6379 rapidfort/redis-official:latest

```

## What is a hardened image?

A hardened container image is a functionally equivalent copy of a container image that has been optimized by removing unnecessary software components, significantly reducing its software attack surface and improving its security. Removing unnecessary software components is a critical practice to protect your infrastructure from attacks and limiting the blast radius of any attacks.

This image is a hardened version of the official [The Docker Community Redis™ Official][source-image-repo-link] image on Docker Hub.

Vulnerability reports for RapidFort's hardened images are updated daily to include newly discovered vulnerabilities and fixes.


[![View on GitHub](https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/view_github.svg)](https://github.com/rapidfort/community-images/tree/main/community_images/redis/official)
<br>
<br>

## What’s the difference between the official [The Docker Community Redis™ Official][source-image-repo-link] image and this hardened image?
RapidFort’s hardened [rapidfort/redis-official][rf-dh-image-link] image has been optimized by RapidFort's SASM platform and is functionally equivalent to the original image.

We are big fans of open-source software and secure software development. RapidFort's community images are our way of giving back to the community and helping reduce the burden on security and development teams.

## Supported tags and respective `Dockerfile` links
* [`8.0-M01`, `8.0-M01-bookworm`](https://github.com/redis/docker-library-redis/blob/1b88507c82861395a5c1b354baab795c73c051e3/debian/Dockerfile)
* [`7.4.1`, `7.4`, `7`, `latest`, `7.4.1-bookworm`, `7.4-bookworm`, `7-bookworm`, `bookworm`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/7.4/debian/Dockerfile)
* [`7.4.1-alpine`, `7.4-alpine`, `7-alpine`, `alpine`, `7.4.1-alpine3.20`, `7.4-alpine3.20`, `7-alpine3.20`, `alpine3.20`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/7.4/alpine/Dockerfile)
* [`7.2.6`, `7.2`, `7.2.6-bookworm`, `7.2-bookworm`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/7.2/debian/Dockerfile)
* [`7.2.6-alpine`, `7.2-alpine`, `7.2.6-alpine3.20`, `7.2-alpine3.20`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/7.2/alpine/Dockerfile)
* [`6.2.16`, `6.2`, `6`, `6.2.16-bookworm`, `6.2-bookworm`, `6-bookworm`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/6.2/debian/Dockerfile)
* [`6.2.16-alpine`, `6.2-alpine`, `6-alpine`, `6.2.16-alpine3.20`, `6.2-alpine3.20`, `6-alpine3.20`](https://github.com/redis/docker-library-redis/blob/e5650da99bb377b2ed4f9f1ef993ff24729b1c16/6.2/alpine/Dockerfile)

## Need support

Join our slack community for any questions.

[![RapidFort Community Slack][slack-png]][slack-link]

## 🌟 Support this project

[![](https://user-images.githubusercontent.com/48997634/174794647-0c851917-e5c9-4fb9-bf88-b61d89dc2f4f.gif)](https://github.com/rapidfort/community-images/stargazers)

### [⏫⭐️ Scroll to the star button](#start-of-content)

If you find this project useful, please star this repo just like many [amazing people](https://github.com/rapidfort/community-images/stargazers) have.

## Have questions?

[![RapidFort](https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/logo_light.svg)][rf-rapidfort-footer-logo-link]


Learn more about RapidFort's pioneering Software Attack Surface Management platform at [RapidFort.com][rf-link].

<br>
<br>

[rapidfort-logo-header-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=rapidfort_logo

[rapidfort-logo-header-svg]: https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/logo_light.svg


[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[fossa-badge]: https://app.fossa.com/api/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images.svg?type=shield

[fossa-link]: https://app.fossa.com/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images?ref=badge_shield

[rf-link]: https://rapidfort.com?utm_source=github&utm_medium=ci_rf_link&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=rapidfort_have_questions

[rf-rapidfort-footer-logo-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=rapidfort_footer_logo

[rf-view-report-button]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=view_report_button

[rf-view-report-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=view_report_link

[rf-image-metrics-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=image_metrics_link

[rf-image-cve-reduction-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=image_cve_reduction_link

[rf-image-savings-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=image_savings_link

[rf-image-vulns-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=vulns_link

[dh-img-size-badge]: https://img.shields.io/docker/image-size/rapidfort/redis-official?logo=docker&logoColor=white&sort=semver

[dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/redis-official?logo=docker&logoColor=white

[slack-badge]: https://img.shields.io/static/v1?label=Join&message=slack&logo=slack&logoColor=E01E5A&color=4A154B

[slack-link]: https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=

[source-image-repo-link]: https://hub.docker.com/_/redis

[rf-dh-image-link]: https://hub.docker.com/r/rapidfort/redis-official


[savings-svg]: https://github.com/rapidfort/community-images/raw/main/community_images/redis/official/assets/savings.svg

[savings-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=image_savings_link

[vulns-chart-svg]: https://github.com/rapidfort/community-images/raw/main/community_images/redis/official/assets/vulns_charts.svg

[vulns-chart-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=vulns_charts

[full-report-svg]: https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/full_report.svg

[full-report-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fredis?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=get_full_report_button

[instructions-svg]: https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/view_details.svg

[zero-cve-images-link]: https://hub.rapidfort.com/repositories?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=redis-official&utm_content=zero_vulns_cve

[zero-cve-images-svg]: https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/zero_cve_images_link.svg

[slack-link]: https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q

[slack-png]: https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_banner.png







