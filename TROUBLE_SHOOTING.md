[![Rapidfort](https://assets.website-files.com/6102f7f1589f985b19197b3d/61082629d82d1361e5835b58_rapidfort_logo-new.svg)](https://rapidfort.com) 

# Trouble Shooting Guide

## Background: 
"RapidFort Community Images" is an open-source project to optimize and harden popular docker images continuously. We pick up a source image ("upstream image"), add coverage scripts, and use RapidFort to optimize and harden the image. A hardened image is created automatically every time a new image is submitted to Docker hub.

Optimized images are significantly smaller and carry fewer vulnerabilities while providing the complete functionality of the original image.

You can contribute to this project by adding new images, improving coverage scripts, and adding regression and benchmark tests.

![Demo](contrib/coverage.png)

Community images project rely on upstream source image to work correctly. Broadly, the issues will fall into following categories:


1. ### Coverage script is not exercising a feature that is used in production (Coverage missing).
    > Remediation: We need to enhance coverage scripts. Please report an issue and provide PR if possible.

1. ### Incorrect usage of the upstream source image (User error).
    > Remediation: Please file a report and update the documentation for the image.

1. ### Upstream source image has introduced a defect (Source image error).
    > Remediation: Please file a report on the source project. For eg: Bitnami Postgres image.

1. ### RapidFort hardened image is introducing a defect (RF error).
    > Remediation: Please report an issue and we would work with our core engineering team to investigate and fix this issue.
