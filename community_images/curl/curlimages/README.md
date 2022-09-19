<a href="https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=rapidfort_logo">
<img src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_logo.png" alt="RapidFort" width="200" />
</a>

<br>

[![rf-h][rf-h-badge]][rf-view-report-button]
[![DH Image][dh-rf-badge]][rf-dh-image-link]
[![Slack][slack-badge]][slack-link]
[![FOSSA Status][fossa-badge]][fossa-link]

# RapidFort hardened image for Curl

RapidFort’s container optimization process hardened this Curl container. This container is free to use and has no license limitations.

It is the same as the [curlimages Curl][source-image-repo-link] image but more secure.

Every day, we optimize and harden a variety of Docker Hub’s most famous images. Check out our [entire library](https://hub.docker.com/u/rapidfort) of secured containers.
<br>

[Get the full report here or click on the image below][rf-view-report-link]

[![Metrics][metrics-link]][rf-image-metrics-link]

<h2> Vulnerabilities: Original vs. Hardened

</h2>

[![CVE Reduction][cve-reduction-link]][rf-image-cve-reduction-link]

<a href="https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=get_full_report_button">
<img align="center" src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_button_3.png" alt="View Report" height="50" />
</a>
<br>
<br>


## What is Curl?

> curl is a command line tool and library for transferring data with URLs.

curl is used in command lines or scripts to transfer data. It is also used in cars, television sets, routers, printers, audio equipment, mobile phones, tablets, settop boxes, media players and is the internet transfer backbone for thousands of software applications affecting billions of humans daily.
Supports the following protocols (so far!):.
DICT, FILE, FTP, FTPS, Gopher, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, Telnet and TFTP. curl supports SSL certificates, HTTP POST, HTTP PUT, FTP uploading, HTTP form based upload, proxies, HTTP/2, cookies, user+password authentication (Basic, Plain, Digest, CRAM-MD5, NTLM, Negotiate and Kerberos), file transfer resume, proxy tunnelling and more.


[Overview of Curl](https://github.com/curl/curl-docker)

Trademarks: This software listing is packaged by RapidFort. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.


## How do I use this hardened Curl image?

The runtime instructions for this container are no different from the official release. Follow the instructions in their readme, but use our hardened image.

```sh
# Check everything works properly by running:

$ docker run --rm rapidfort/curl:latest --version

# Here is a more specific example of running curl docker container:

$ docker run --rm rapidfort/curl:latest -L -v https://curl.haxx.se

# To work with files it is best to mount directory:

$ docker run --rm -it -v "$PWD:/work" rapidfort/curl -d@/work/test.txt https://httpbin.org/post

```

## What is a hardened image?

A hardened image is a copy of a container that has been optimized and reduced for significantly improved security. Because every container uses many open-source software components and their dependencies, there’s a lot of extra weight that can be trimmed.

This image is a hardened version of the official [curlimages Curl][source-image-repo-link] image on Docker Hub.

RapidFort is an industry-leading container optimization solution that minimizes software attack surfaces by removing unused code. Most containers can be reduced by at least 50%, which reduces the opportunity for malicious attacks and CVE exploits. Learn more at [RapidFort.com][rf-link].

Our hardened images are updated daily using the latest vulnerability information available.


## What’s the difference between the official [curlimages Curl][source-image-repo-link] image and this hardened image?
RapidFort’s hardened [rapidfort/curl][rf-dh-image-link] image has been optimized by our proprietary scanning and slimming technology. We are big fans of open-source software, containerized infrastructure, and security.

We are making secure copies of the images we use every day and the most popular ones on Docker Hub. We want to make the world a safer place to operate.

## Supported tags and respective `Dockerfile` links
* [`7.xx.x`, `latest` (latest/Dockerfile)](https://github.com/curl/curl-docker/blob/master/alpine/latest/Dockerfile)

## Need support

Join our slack community for any questions.

<a href="https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q">
<img src="https://raw.githubusercontent.com/rapidfort/community-images/main/contrib/github_banner.png" alt="RapidFort Community Slack" width="600" />
</a>

## 🌟 Support this project

![](https://user-images.githubusercontent.com/48997634/174794647-0c851917-e5c9-4fb9-bf88-b61d89dc2f4f.gif)

### [⏫⭐️ Scroll to the star button](#start-of-content)

If you believe this project has potential, feel free to **star this repo** just like many [amazing people](https://github.com/rapidfort/community-images/stargazers)
have.

## Have questions?
[![RapidFort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)][rf-rapidfort-footer-logo-link]


If you'd like to learn more about RapidFort or our container optimization process, visit [RapidFort.com][rf-link].

<br>
<br>


[dh-rf-badge]: https://img.shields.io/badge/dockerhub-images-important.svg?logo=Docker

[fossa-badge]: https://app.fossa.com/api/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images.svg?type=shield
[fossa-link]: https://app.fossa.com/projects/git%2Bgithub.com%2Frapidfort%2Fcommunity-images?ref=badge_shield

[rf-link]: https://rapidfort.com?utm_source=github&utm_medium=ci_rf_link&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=rapidfort_have_questions

[rf-rapidfort-footer-logo-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=rapidfort_footer_logo
[rf-view-report-button]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=view_report_button
[rf-view-report-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=view_report_link
[rf-image-metrics-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=image_metrics_link
[rf-image-cve-reduction-link]: https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fcurlimages%2Fcurl?utm_source=github&utm_medium=ci_view_report&utm_campaign=sep_01_sprint&utm_term=curl&utm_content=image_cve_reduction_link

[dh-img-size-badge]: https://img.shields.io/docker/image-size/rapidfort/curl?logo=docker&logoColor=white&sort=semver
[dh-img-pulls-badge]: https://img.shields.io/docker/pulls/rapidfort/curl?logo=docker&logoColor=white

[slack-badge]: https://img.shields.io/static/v1?label=Join&message=slack&logo=slack&logoColor=E01E5A&color=4A154B
[slack-link]: https://join.slack.com/t/rapidfortcommunity/shared_invite/zt-1g3wy28lv-DaeGexTQ5IjfpbmYW7Rm_Q

[rf-h-badge]: https://img.shields.io/static/v1?label=RapidFort&labelColor=333F48&message=hardened&color=50B4C4&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAAkCAYAAAAKNyObAAAACXBIWXMAACE4AAAhOAFFljFgAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAHvSURBVHgB7ZjvTcMwEMUvEgNkhNuAjOAR2IAyQbsB2YAyQbsBYoKwQdjA3aAjHA514Xq1Hf9r6QeeFKVJ3tkv+cWOVYCAiKg124b82gZqe0+NNlsHJbLBxthg1o+RASetIEdTJxnBRvtUMCHgM6TIBtMZwY7SiQFfrhUsN+Ao/TJYR3WC5QY88/Nge6oXLBRwO+P/GcnNMZzZteBR0zQfogM0O4Q47Uz9TtSrUIHs71+paugw16Dn+qt5xJ/TD4viEcrE25tepaXPaHxP350GXtD10WwHQWjQxKhl7YUGRg/MuPaY9vxuzPFA+RpEW9rj0yCMbcCsmG9B+Xpk7YRo4RnjQEEttBiBtAefyI23BtoYpBrmRO6ZX0EZWo60c1yfaGBMOKRzdKVocYZO/NpuMss7E9cHitcc0gFS5Qig2LUUtCGkmmJwOsJJvLlokdWtfMFzAvLGctCOooYPtg2USoRQ7HwM2hXzIzuvKQenIxzHm4oWmZ9TKF1AnAR8sI2moB093nKcjoBvtnHFzoXQ8qeMDGcLtUW/i4NYtJ3jJhRcSnRYHMSg1Q5PD5cWHT4/ih0vIpDOf9QrhZtQLsWxlILT8AjXEol/iQRaiVTBX4pO57D6U0WJBFoFtyaLtuqLfwf19G62e7hFWbQKKuoLYovGDo9dW28AAAAASUVORK5CYII=
[metrics-link]: https://github.com/rapidfort/community-images/raw/main/community_images/curl/curlimages/assets/metrics.png
[cve-reduction-link]: https://github.com/rapidfort/community-images/raw/main/community_images/curl/curlimages/assets/cve_reduction.png

[source-image-repo-link]: https://hub.docker.com/r/curlimages/curl
[rf-dh-image-link]: https://hub.docker.com/r/rapidfort/curl
