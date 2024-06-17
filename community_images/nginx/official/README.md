<a href="https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=rapidfort_logo">
<img src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_logo.png" alt="RapidFort" width="200" />
</a>

<br>

[![rf-h][rf-h-badge]][rf-view-report-button]
[![DH Image][dh-rf-badge]][rf-dh-image-link]
[![Slack][slack-badge]][slack-link]
[![FOSSA Status][fossa-badge]][fossa-link]

<img src="/contrib/critical_button.png" alt="⚠️ CRITICAL NOTICE" width="150" /> <br>
<b>As of 7/2024 community-images will be gated. Please register for free at <a style="color:blue;" href="https://www.rapidfort.com/get-a-demo">www.rapidfort.com</a> to access these images</b>

# RapidFort hardened image for NGINX Official


RapidFort has optimized and hardened this NGINX Official container image. This container is free to use and has no license limitations.


This optimized image is functionally equivalent to [The NGINX Docker Maintainers NGINX Official][source-image-repo-link] image but more secure with a significantly smaller software attack surface.

Every day, RapidFort automatically optimizes and hardens a growing bank of Docker Hub’s most important container images. Check out our [entire library](https://hub.docker.com/u/rapidfort) of secured container images.
<br>

[Get the full report here or click on the image below][rf-view-report-link]

[![Metrics][metrics-link]][rf-image-metrics-link]

<h2> Vulnerabilities: Original vs. Hardened

</h2>

[![CVE Reduction][cve-reduction-link]][rf-image-cve-reduction-link]

<a href="https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=get_full_report_button">
<img align="center" src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_button_3.svg" alt="View Report" height="50" />
</a>
<br>
<br>


## What is NGINX Official?

> Nginx (pronounced "engine-x") is an open source reverse proxy server for HTTP, HTTPS, SMTP, POP3, and IMAP protocols, as well as a load balancer, HTTP cache, and a web server (origin server). The nginx project started with a strong focus on high concurrency, high performance and low memory usage. It is licensed under the 2-clause BSD-like license and it runs on Linux, BSD variants, Mac OS X, Solaris, AIX, HP-UX, as well as on other *nix flavors. It also has a proof of concept port for Microsoft Windows.


[Overview of NGINX Official](http://nginx.org/)

Trademarks: This software listing is packaged by RapidFort. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.


## How do I use this hardened NGINX Official image?



The runtime instructions for this hardened container image are the same as the official release. Follow the instructions provided with the [The NGINX Docker Maintainers NGINX Official][source-image-repo-link].

<a href="https://github.com/docker-library/docs/blob/master/nginx/README.md">
<img align="center" src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/view_detailed_instructions_button.svg" alt="View Detailed Instructions" height="50" />
</a>
<br>
<br>

```sh
$ Using docker run:
$ docker run --name my-nginx-app -p 8080:80 -v /some/content:/usr/share/nginx/html:ro -d rapidfort/nginx-official

# If you wish to change the default configuration:
$ docker run --name my-nginx-app -p 8080:80 -v /host/path/nginx.conf:/etc/nginx/nginx.conf:ro -d rapidfort/nginx-official

```

## What is a hardened image?

A hardened container image is a functionally equivalent copy of a container image that has been optimized by removing unnecessary software components, significantly reducing its software attack surface and improving its security. Removing unnecessary software components is a critical practice to protect your infrastructure from attacks and limiting the blast radius of any attacks.

This image is a hardened version of the official [The NGINX Docker Maintainers NGINX Official][source-image-repo-link] image on Docker Hub.

RapidFort is the pioneering Software Attack Surface Management (SASM) platform in the market. Many container images can be reduced by 60-90%, have far fewer vulnerabilities, and load much faster because of their reduced size. Learn more at [RapidFort.com][rf-link].

Vulnerability reports for RapidFort's hardened images are updated daily to include newly discovered vulnerabilities and fixes.

<a href="https://github.com/rapidfort/community-images/tree/main/community_images/nginx/official">
<img align="center" src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/view_on_github_button.svg" alt="View on GitHub" height="50" />
</a>
<br>
<br>

## What’s the difference between the official [The NGINX Docker Maintainers NGINX Official][source-image-repo-link] image and this hardened image?
RapidFort’s hardened [rapidfort/nginx-official][rf-dh-image-link] image has been optimized by RapidFort's SASM platform and is functionally equivalent to the original image.

We are big fans of open-source software and secure software development. RapidFort's community images are our way of giving back to the community and helping reduce the burden on security and development teams.

## Supported tags and respective `Dockerfile` links
* [`1.27.0`, `mainline`, `1`, `1.27`, `latest`, `1.27.0-bookworm`, `mainline-bookworm`, `1-bookworm`, `1.27-bookworm`, `bookworm`](https://github.com/nginxinc/docker-nginx/blob/3180cdbec313dc4a9f6dd1109ae66adaf98f11fb/mainline/debian/Dockerfile)
* [`1.25.4`, `mainline`, `1`, `1.25`, `latest`, `1.25.4-bookworm`, `mainline-bookworm`, `1-bookworm`, `1.25-bookworm`, `bookworm`](https://github.com/nginxinc/docker-nginx/blob/1f227619c1f1baa0bed8bed844ea614437ff14fb/mainline/debian/Dockerfile)
* [`1.25.4-perl`, `mainline-perl`, `1-perl`, `1.25-perl`, `perl`, `1.25.4-bookworm-perl`, `mainline-bookworm-perl`, `1-bookworm-perl`, `1.25-bookworm-perl`, `bookworm-perl`](https://github.com/nginxinc/docker-nginx/blob/1f227619c1f1baa0bed8bed844ea614437ff14fb/mainline/debian-perl/Dockerfile)
* [`1.25.4-otel`, `mainline-otel`, `1-otel`, `1.25-otel`, `otel`, `1.25.4-bookworm-otel`, `mainline-bookworm-otel`, `1-bookworm-otel`, `1.25-bookworm-otel`, `bookworm-otel`](https://github.com/nginxinc/docker-nginx/blob/9cb278860bdcea48abc0bc770a29ead3fc9a1fe6/mainline/debian-otel/Dockerfile)
* [`1.25.4-alpine`, `mainline-alpine`, `1-alpine`, `1.25-alpine`, `alpine`, `1.25.4-alpine3.18`, `mainline-alpine3.18`, `1-alpine3.18`, `1.25-alpine3.18`, `alpine3.18`](https://github.com/nginxinc/docker-nginx/blob/1f227619c1f1baa0bed8bed844ea614437ff14fb/mainline/alpine/Dockerfile)
* [`1.25.4-alpine-perl`, `mainline-alpine-perl`, `1-alpine-perl`, `1.25-alpine-perl`, `alpine-perl`, `1.25.4-alpine3.18-perl`, `mainline-alpine3.18-perl`, `1-alpine3.18-perl`, `1.25-alpine3.18-perl`, `alpine3.18-perl`](https://github.com/nginxinc/docker-nginx/blob/1f227619c1f1baa0bed8bed844ea614437ff14fb/mainline/alpine-perl/Dockerfile)
* [`1.25.4-alpine-slim`, `mainline-alpine-slim`, `1-alpine-slim`, `1.25-alpine-slim`, `alpine-slim`, `1.25.4-alpine3.18-slim`, `mainline-alpine3.18-slim`, `1-alpine3.18-slim`, `1.25-alpine3.18-slim`, `alpine3.18-slim`](https://github.com/nginxinc/docker-nginx/blob/1f227619c1f1baa0bed8bed844ea614437ff14fb/mainline/alpine-slim/Dockerfile)
* [`1.25.4-alpine-otel`, `mainline-alpine-otel`, `1-alpine-otel`, `1.25-alpine-otel`, `alpine-otel`, `1.25.4-alpine3.18-otel`, `mainline-alpine3.18-otel`, `1-alpine3.18-otel`, `1.25-alpine3.18-otel`, `alpine3.18-otel`](https://github.com/nginxinc/docker-nginx/blob/9cb278860bdcea48abc0bc770a29ead3fc9a1fe6/mainline/alpine-otel/Dockerfile)
* [`1.24.0`, `stable`, `1.24`, `1.24.0-bullseye`, `stable-bullseye`, `1.24-bullseye`](https://github.com/nginxinc/docker-nginx/blob/1a8d87b69760693a8e33cd8a9e0c2e5f0e8b0e3c/stable/debian/Dockerfile)
* [`1.24.0-perl`, `stable-perl`, `1.24-perl`, `1.24.0-bullseye-perl`, `stable-bullseye-perl`, `1.24-bullseye-perl`](https://github.com/nginxinc/docker-nginx/blob/1a8d87b69760693a8e33cd8a9e0c2e5f0e8b0e3c/stable/debian-perl/Dockerfile)
* [`1.24.0-alpine`, `stable-alpine`, `1.24-alpine`, `1.24.0-alpine3.17`, `stable-alpine3.17`, `1.24-alpine3.17`](https://github.com/nginxinc/docker-nginx/blob/1a8d87b69760693a8e33cd8a9e0c2e5f0e8b0e3c/stable/alpine/Dockerfile)
* [`1.24.0-alpine-perl`, `stable-alpine-perl`, `1.24-alpine-perl`, `1.24.0-alpine3.17-perl`, `stable-alpine3.17-perl`, `1.24-alpine3.17-perl`](https://github.com/nginxinc/docker-nginx/blob/1a8d87b69760693a8e33cd8a9e0c2e5f0e8b0e3c/stable/alpine-perl/Dockerfile)
* [`1.24.0-alpine-slim`, `stable-alpine-slim`, `1.24-alpine-slim`, `1.24.0-alpine3.17-slim`, `stable-alpine3.17-slim`, `1.24-alpine3.17-slim`](https://github.com/nginxinc/docker-nginx/blob/1a8d87b69760693a8e33cd8a9e0c2e5f0e8b0e3c/stable/alpine-slim/Dockerfile)

## Need support

Join our slack community for any questions.

<a href="https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q">
<img src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_banner.png" alt="RapidFort Community Slack" width="600" />
</a>

## 🌟 Support this project

[![](https://user-images.githubusercontent.com/48997634/174794647-0c851917-e5c9-4fb9-bf88-b61d89dc2f4f.gif)](https://github.com/rapidfort/community-images/stargazers)

### [⏫⭐️ Scroll to the star button](#start-of-content)

If you find this project useful, please star this repo just like many [amazing people](https://github.com/rapidfort/community-images/stargazers) have.

## Have questions?

[![RapidFort](https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_logo_footer.png)][rf-rapidfort-footer-logo-link]


Learn more about RapidFort's pioneering Software Attack Surface Management platform at [RapidFort.com][rf-link].

<br>
<br>


[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[fossa-badge]: https://app.fossa.com/api/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images.svg?type=shield
[fossa-link]: https://app.fossa.com/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images?ref=badge_shield

[rf-link]: https://rapidfort.com?utm_source=github&utm_medium=ci_rf_link&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=rapidfort_have_questions

[rf-rapidfort-footer-logo-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=rapidfort_footer_logo
[rf-view-report-button]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=view_report_button
[rf-view-report-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=view_report_link
[rf-image-metrics-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=image_metrics_link
[rf-image-cve-reduction-link]: https://us01.rapidfort.com/app/community/imageinfo/docker.io%2Flibrary%2Fnginx?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=nginx-official&utm_content=image_cve_reduction_link

[dh-img-size-badge]: https://img.shields.io/docker/image-size/rapidfort/nginx-official?logo=docker&logoColor=white&sort=semver
[dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/nginx-official?logo=docker&logoColor=white

[slack-badge]: https://img.shields.io/static/v1?label=Join&message=slack&logo=slack&logoColor=E01E5A&color=4A154B
[slack-link]: https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=
[metrics-link]: https://github.com/rapidfort/community-images/raw/main/community_images/nginx/official/assets/metrics.webp
[cve-reduction-link]: https://github.com/rapidfort/community-images/raw/main/community_images/nginx/official/assets/cve_reduction.webp

[source-image-repo-link]: https://hub.docker.com/_/nginx
[rf-dh-image-link]: https://hub.docker.com/r/rapidfort/nginx-official
